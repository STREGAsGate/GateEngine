/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

@MainActor public protocol RenderTargetProtocol: AnyObject, Equatable, Hashable {
    var size: Size2 { get }
    var clearColor: Color { get set }
    var rootViewController: ViewController? {get set}
    func insert(_ scene: Scene)
    func insert(_ canvas: Canvas)
//    func insert(
//        _ target: any RenderTargetProtocol,
//        withOptions options: RenderTargetFillOptions,
//        sampleFilter: RenderTargetFillSampleFilter
//    )
}

@MainActor protocol _RenderTargetProtocol: RenderTargetProtocol {
    var lastDrawnFrame: UInt { get set }
    var texture: Texture { get }
    var renderTargetBackend: any RenderTargetBackend { get set }
    var drawables: [any Drawable] { get set }
    var size: Size2 { get set }

    func reshapeIfNeeded()
    func draw(_ frame: UInt)
    
    func matrices() -> Matrices
}

extension RenderTargetProtocol {
    @_transparent
    var isWindow: Bool {
        return self is Window
    }
}

extension _RenderTargetProtocol {
    @inlinable @inline(__always)
    internal func insert(_ canvas: UICanvas) {
        precondition(
            Game.shared.attributes.contains(.renderingIsPermitted),
            "Rendering can only be changed from a RenderingSystem."
        )
        self.drawables.append(canvas)
    }
    
    @inlinable @inline(__always)
    public func insert(_ scene: Scene) {
        precondition(
            Game.shared.attributes.contains(.renderingIsPermitted),
            "Rendering can only be changed from a RenderingSystem."
        )
        self.drawables.append(scene)
    }

    @inlinable @inline(__always)
    public func insert(_ canvas: Canvas) {
        precondition(
            Game.shared.attributes.contains(.renderingIsPermitted),
            "Rendering can only be changed from a RenderingSystem."
        )
        precondition(
            canvas.size == nil || canvas.size!.aspectRatio == self.size.aspectRatio,
            "Canvas.size.aspectRatio must equal RenderTarget.size.aspectRatio to insert."
        )
        self.drawables.append(canvas)
    }

//    @inlinable @inline(__always)
//    public func insert(_ drawCommand: DrawCommand) {
//        precondition(
//            Game.shared.attributes.contains(.renderingIsPermitted),
//            "Rendering can only be changed from a RenderingSystem."
//        )
//        self.drawables.append(drawCommand)
//    }

    @inline(__always)
    internal var renderTargets: [any _RenderTargetProtocol] {
        var allDrawCommands: [DrawCommand] = []
        for drawable in drawables {
            allDrawCommands.append(contentsOf: drawable.drawCommands)
        }

        var uniqueRenderTargets: [any _RenderTargetProtocol] = []
        for drawCommand in allDrawCommands {
            for renderTarget in drawCommand.renderTargets {
                if uniqueRenderTargets.contains(where: { $0 === renderTarget }) == false {
                    uniqueRenderTargets.append(renderTarget)
                }
            }
        }

        return uniqueRenderTargets
    }
}

@MainActor public final class RenderTarget: View, RenderTargetProtocol, _RenderTargetProtocol {
    @usableFromInline
    var renderTargetBackend: any RenderTargetBackend
    var previousSize: Size2? = nil
    var lastDrawnFrame: UInt = .max
    var drawables: [any Drawable] = []
    
    public var rootViewController: ViewController? = nil {
        willSet {
            rootViewController?.view.removeFromSuperview()
        }
        didSet {
            if let view = rootViewController?.view {
                view.fill(self)
            }
        }
    }

    @inlinable @inline(__always)
    public var size: Size2 {
        get {
            return renderTargetBackend.size
        }
        set {
            precondition(
                Game.shared.attributes.contains(.renderingIsPermitted),
                "Resizing a RenderTarget can only be done from a RenderingSystem."
            )
            renderTargetBackend.size = newValue
        }
    }

    @inline(__always)
    internal func reshapeIfNeeded() {
        if previousSize != renderTargetBackend.size || renderTargetBackend.wantsReshape {
            previousSize = renderTargetBackend.size
            renderTargetBackend.reshape()
        }
    }

    public init(size: Size2? = nil, backgroundColor: Color = .black, rootViewController: ViewController? = nil) {
        precondition(
            Game.shared.attributes.contains(.renderingIsPermitted),
            "RenderTarget can only be created from a RenderingSystem."
        )
        self.renderTargetBackend = getRenderTargetBackend()
        self.rootViewController = rootViewController
        super.init()
        self.backgroundColor = backgroundColor
        if let size {
            self.size = size
        }
    }

    internal init(backend: some RenderTargetBackend) {
        self.renderTargetBackend = backend
    }

    public private(set) lazy var texture: Texture = Texture(renderTarget: self)
}

extension _RenderTargetProtocol {
    @inlinable @inline(__always)
    public var size: Size2 {
        get {
            return renderTargetBackend.size
        }
        set {
            precondition(
                Game.shared.attributes.contains(.renderingIsPermitted),
                "Resizing a RenderTarget can only be done from a RenderingSystem."
            )
            renderTargetBackend.size = newValue
        }
    }

    @inlinable @inline(__always)
    public var clearColor: Color {
        get {
            return renderTargetBackend.clearColor
        }
        set {
            renderTargetBackend.clearColor = newValue
        }
    }
    
    internal func matrices() -> Matrices {
        let ortho = Matrix4x4(
            orthographicWithTop: 0,
            left: 0,
            bottom: self.size.height,
            right: self.size.width,
            near: 0,
            far: Float(Int32.max)
        )
        
        let view = Matrix4x4(position: .zero)
        return Matrices(projection: ortho, view: view)
    }

    internal func draw(_ frame: UInt) {
        guard self.lastDrawnFrame != frame else { return }
        self.lastDrawnFrame = frame

        if let view = self as? View {
            var canvas = UICanvas(estimatedCommandCount: 10)
            self.drawView(view, into: &canvas, forOffScreen: false, frameNumber: frame, superClip: Rect(size: size))
            if canvas.hasContent {
                self.drawables.append(canvas)
                if let window = self as? Window {
                    window.didDrawSomething = true
                }
            }
        }
        
        for renderTarget in renderTargets {
            renderTarget.draw(frame)
        }
        if let window = self as? Window {
            window.offScreenRendering.renderTarget.draw(frame)
        }
        
        self.reshapeIfNeeded()
        
        if self.drawables.isEmpty == false {
            renderTargetBackend.willBeginFrame(frame)
            
            for drawable in self.drawables {
                switch drawable {
                case let uiCanvas as UICanvas:
                    drawUICanvas(uiCanvas, clipRect: nil, stencil: nil)
                case let scene as Scene:
                    drawScene(scene, aspectRatio: self.size.aspectRatio, clipRect: nil, stencil: nil)
                case let canvas as Canvas:
                    drawCanvas(canvas, clipRect: nil, stencil: nil)
                case let container as RenderTargetFillContainer:
                    drawRenderTarget(container, frame: frame, clipRect: nil, stencil: nil)
                default:
                    Log.warn("\(type(of: drawable)) cannot be drawn and was skipped.")
                    continue
                }
            }
            self.drawables.removeAll(keepingCapacity: true)
            
            renderTargetBackend.didEndFrame(frame)
        }
    }

    private func drawView(_ view: View, into canvas: inout UICanvas, forOffScreen: Bool, frameNumber: UInt, superClip: Rect) {
        guard view.shouldDraw() else {return}
        switch view.renderingMode {
        case .screen:
            let frame = view.representationFrame()
            let clip = frame.clamped(within: superClip)
            view.draw(into: &canvas, at: frame)
            for subview in view.subviews {
                self.drawView(subview, into: &canvas, forOffScreen: forOffScreen, frameNumber: frameNumber, superClip: clip)
            }
        case .offScreen:
            drawOffScreenViewHierarchy(for: view, into: &canvas, frameNumber: frameNumber)
        }
    }
    
    private func drawOffScreenViewHierarchy(for view: View, into onScreenCanvas: inout UICanvas, frameNumber: UInt) {
        guard let window = view.window else {fatalError()}
        let offScreenFrame = view.offScreenFrame()
        
        var offScreenCanvas: UICanvas = UICanvas(estimatedCommandCount: 10)
        view.draw(into: &offScreenCanvas, at: offScreenFrame)
        
        for subview in view.subviews {
            self.drawView(subview, into: &offScreenCanvas, forOffScreen: true, frameNumber: frameNumber, superClip: offScreenFrame)
        }
        if offScreenCanvas.hasContent {
            window.offScreenRendering.renderTarget.insert(offScreenCanvas)
            
            let renderingFrame = view.representationFrame()
            view.drawOffScreenRepresentation(into: &onScreenCanvas, at: renderingFrame)
        }
    }
    
    @inline(__always)
    private func drawUICanvas(_ canvas: UICanvas, clipRect: Rect?, stencil: UInt8?) {
        assert(canvas.hasContent)
        let matrices = canvas.matrices(withSize: self.size)
        
        let scissorRect: Rect? = clipRect
        
        renderTargetBackend.willBeginContent(matrices: matrices, viewport: nil, scissorRect: scissorRect, stencil: stencil)
        for command in canvas.drawCommands {
            Game.shared.renderer.draw(
                command,
                camera: nil,
                matrices: matrices,
                renderTarget: self
            )
        }
        renderTargetBackend.didEndContent()
    }

    @inline(__always)
    private func drawScene(_ scene: Scene, aspectRatio: Float, clipRect: Rect?, stencil: UInt8?) {
        let matrices = scene.camera.matricies(withAspectRatio: aspectRatio)

        var scissorRect: Rect? = nil
        if let sceneScissor = scene.scissorRect {
            if let clipRect {
                scissorRect = sceneScissor.clamped(within: clipRect)
            }else{
                scissorRect = sceneScissor
            }
        }else{
            scissorRect = clipRect
        }
        
        renderTargetBackend.willBeginContent(matrices: matrices, viewport: clipRect, scissorRect: scissorRect, stencil: stencil)
        for command in scene._drawCommands {
            Game.shared.renderer.draw(
                command,
                camera: scene.camera,
                matrices: matrices,
                renderTarget: self
            )
        }
        renderTargetBackend.didEndContent()
    }

    @inline(__always)
    private func drawCanvas(_ canvas: Canvas, clipRect: Rect?, stencil: UInt8?) {
        let matrices = canvas.matrices(withSize: self.size)
        
        var scissorRect: Rect? = nil
        if let canvasScissor = canvas.scissorRect {
            if let clipRect {
                scissorRect = canvasScissor.clamped(within: clipRect)
            }else{
                scissorRect = canvasScissor
            }
        }else{
            scissorRect = clipRect
        }
        
        renderTargetBackend.willBeginContent(matrices: matrices, viewport: canvas.viewport, scissorRect: scissorRect, stencil: stencil)
        for command in canvas._drawCommands {
            Game.shared.renderer.draw(
                command,
                camera: canvas.camera,
                matrices: matrices,
                renderTarget: self
            )
        }
        renderTargetBackend.didEndContent()
    }

    @inline(__always)
    private func drawRenderTarget(_ container: RenderTargetFillContainer, frame: UInt, clipRect: Rect?, stencil: UInt8?) {
        container.renderTarget.draw(frame)
                
        renderTargetBackend.willBeginContent(matrices: nil, viewport: nil, scissorRect: clipRect, stencil: stencil)
        Game.shared.renderer.draw(
            container.renderTarget,
            into: self,
            options: container.options,
            sampler: container.filter
        )
        renderTargetBackend.didEndContent()
    }
}

public struct RenderTargetFillOptions: OptionSet {
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
public enum RenderTargetFillSampleFilter {
    case nearest
    case linear
}
struct RenderTargetFillContainer {
    let renderTarget: any _RenderTargetProtocol
    let options: RenderTargetFillOptions
    let filter: RenderTargetFillSampleFilter    
}
//extension RenderTargetProtocol {
//    @inline(__always)
//    public func insert(
//        _ target: any RenderTargetProtocol,
//        withOptions options: RenderTargetFillOptions = [],
//        sampleFilter: RenderTargetFillSampleFilter = .nearest
//    ) {
//        guard target.size.width > 1, target.size.height > 1 else { return }
//        guard target.isWindow == false else {
//            fatalError(
//                "Window.framebuffer cannot be used as a render target. Find another solution."
//            )
//        }
//        (self as! any _RenderTargetProtocol).drawables.append(
//            RenderTargetFillContainer(
//                renderTarget: target as! any _RenderTargetProtocol,
//                options: options,
//                filter: sampleFilter
//            )
//        )
//    }
//}

extension RenderTargetProtocol {
    @_transparent
    nonisolated public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs === rhs
    }
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

@usableFromInline
@MainActor internal protocol RenderTargetBackend {
    var size: Size2 { get set }
    var clearColor: Color { get set }
    var wantsReshape: Bool { get }
    func reshape()

    func willBeginFrame(_ frame: UInt)
    func didEndFrame(_ frame: UInt)

    func willBeginContent(matrices: Matrices?, viewport: GameMath.Rect?, scissorRect: GameMath.Rect?, stencil: UInt8?)
    func didEndContent()
}

extension RenderTargetBackend {
    @inlinable @inline(__always)
    var wantsReshape: Bool { false }
}

@_transparent
@MainActor func getRenderTargetBackend() -> any RenderTargetBackend {
    #if GATEENGINE_FORCE_OPNEGL_APPLE
    return OpenGLRenderTarget(windowBacking: nil)
    #elseif canImport(MetalKit)
    #if canImport(GLKit) && !targetEnvironment(macCatalyst)
    if MetalRenderer.isSupported == false {
        return OpenGLRenderTarget(windowBacking: nil)
    }
    #endif
    return MetalRenderTarget(windowBacking: nil)
    #elseif canImport(WebGL2)
    return WebGL2RenderTarget(isWindow: false)
    #elseif canImport(WinSDK)
    return DX12RenderTarget(windowBacking: nil)
    #elseif os(Linux)
    return OpenGLRenderTarget(windowBacking: nil)
    #else
    #error("Not implemented.")
    #endif
}
