/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

@MainActor public final class RenderTarget {
    let isWindow: Bool
    @usableFromInline
    var backend: RenderTargetBackend
    private var drawables: [Any] = []
    
    internal init(windowBacking: WindowBacking?) {
        self.isWindow = windowBacking != nil
        self.backend = getBackend(windowBacking: windowBacking)
        self.clearColor = .black
    }
    public convenience init() {
        self.init(windowBacking: nil)
    }
    
    public private(set) lazy var texture: Texture = Texture(renderTarget: self)
    
    internal var renderTargets: Set<RenderTarget> {
        var renderTargets:  Set<RenderTarget> = []
        for drawable in drawables {
            if let scene = drawable as? Scene {
                renderTargets.formUnion(scene.renderTargets)
            }else if let canvas = drawable as? Canvas {
                renderTargets.formUnion(canvas.renderTargets)
            }
        }
        return renderTargets
    }
    
    @inlinable
    public var size: Size2 {
        get {
            return backend.size
        }
        set {
            backend.size = newValue
        }
    }
    
    @inlinable
    public var clearColor: Color {
        get {
            return backend.clearColor
        }
        set {
            backend.clearColor = newValue
        }
    }
    
    var previousSize: Size2? = nil
    private func reshapeIfNeeded() {
        if backend.wantsReshape || previousSize != backend.size {
            previousSize = backend.size
            backend.reshape()
        }
    }
    
    internal func draw() {
        for renderTarget in renderTargets {
            assert(renderTarget !== self, "You created a RenderTarget infinite loop")
            renderTarget.draw()
        }
        self.reshapeIfNeeded()
        backend.willBeginFrame()

        for drawable in drawables {
            switch drawable {
            case let scene as Scene:
                drawScene(scene)
            case let canvas as Canvas:
                drawCanvas(canvas)
            case let container as RenderTargetFillContainer:
                drawRenderTarget(container)
            default:
                print("\(type(of: drawable)) cannot be drawn and was skipped.")
                continue
            }
        }
        drawables.removeAll(keepingCapacity: true)
        backend.didEndFrame()
    }
    
    @inline(__always)
    private func drawScene(_ scene: Scene) {
        let matrices = scene.camera.matricies(withAspectRatio: self.size.aspectRatio)
        
        backend.willBeginContent(matrices: matrices, viewport: scene.viewport)
        for command in scene.drawCommands {
            Game.shared.renderer.draw(command, camera: scene.camera, matrices: matrices, renderTarget: self)
        }
        backend.didEndContent()
    }
    
    @inline(__always)
    private func drawCanvas(_ canvas: Canvas) {
        let matrices = canvas.matrices(withSize: self.size)

        backend.willBeginContent(matrices: matrices, viewport: canvas.viewport)
        for command in canvas.drawCommands {
            Game.shared.renderer.draw(command, camera: canvas.camera, matrices: matrices, renderTarget: self)
        }
        backend.didEndContent()
    }
    
    @inline(__always)
    private func drawRenderTarget(_ container: RenderTargetFillContainer) {
        container.renderTarget.draw()
        backend.willBeginContent(matrices: nil, viewport: nil)
        Game.shared.renderer.draw(container.renderTarget, into: self, options: container.options, sampler: container.filter)
        backend.didEndContent()
    }
}

public extension RenderTarget {
    func insert(_ scene: Scene) {
        self.drawables.append(scene)
    }
    
    func insert(_ canvas: Canvas) {
        if let size = canvas.size {
            precondition(size == self.size, "Canvas size must match the render targets size.")
        }
        self.drawables.append(canvas)
    }
}

public extension RenderTarget {
    struct RenderTargetFillOptions: OptionSet {
        public typealias RawValue = Int
        public let rawValue: RawValue
        
        /// Discards the texel if the destination depth is greater then or equal to the target depth
        public static let depthFailDiscard = Self(rawValue: 1 << 1)
        
        public static let flipHorizontal = Self(rawValue: 1 << 2)
        public static let flipVertical = Self(rawValue: 1 << 3)
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    enum RenderTargetFillSampleFilter {
        case nearest
        case linear
    }
    func insert(_ target: RenderTarget,
                withOptions options: RenderTargetFillOptions = [],
                sampleFilter: RenderTargetFillSampleFilter = .nearest) {
        guard target.size.width > 1, target.size.height > 1 else {return}
        guard target.isWindow == false else {fatalError("Window.framebuffer cannot be used as a render target. Find another solution.")}
        drawables.append(RenderTargetFillContainer(renderTarget: target, options: options, filter: sampleFilter))
    }
    
    struct RenderTargetFillContainer {
        let renderTarget: RenderTarget
        let options: RenderTargetFillOptions
        let filter: RenderTargetFillSampleFilter
    }
}

extension RenderTarget: Hashable {
    public static func ==(lhs: RenderTarget, rhs: RenderTarget) -> Bool {
        return lhs === rhs
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

@usableFromInline
@MainActor internal protocol RenderTargetBackend {
    var size: Size2 {get set}
    var clearColor: Color {get set}
    var wantsReshape: Bool {get}
    func reshape()
    
    func willBeginFrame()
    func didEndFrame()
    
    func willBeginContent(matrices: Matrices?, viewport: Rect?)
    func didEndContent()
}

extension RenderTargetBackend {
    var wantsReshape: Bool {false}
}

@_transparent
@MainActor fileprivate func getBackend(windowBacking: WindowBacking?) -> RenderTargetBackend {
#if canImport(MetalKit)
    return MetalRenderTarget(windowBacking: windowBacking)
#elseif canImport(WebGL2)
    return WebGL2RenderTarget(isWindow: windowBacking != nil)
#elseif canImport(WinSDK)
    return DX12RenderTarget(windowBacking: windowBacking)
#else
    #error("Not implemented.")
#endif
}
