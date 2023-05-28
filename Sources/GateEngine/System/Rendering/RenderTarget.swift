/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

@MainActor public protocol RenderTargetProtocol: AnyObject, Equatable, Hashable {
    var size: Size2 {get}
    var clearColor: Color {get set}
    func insert(_ scene: Scene)
    func insert(_ canvas: Canvas)
    func insert(_ target: any RenderTargetProtocol, withOptions options: RenderTargetFillOptions, sampleFilter: RenderTargetFillSampleFilter)
}

@MainActor protocol _RenderTargetProtocol: RenderTargetProtocol {
    var texture: Texture {get}
    var renderTargetBackend: RenderTargetBackend {get set}
    var drawables: [Any] {get set}
    var size: Size2 {get set}
    
    func reshapeIfNeeded()
    func draw()
}

extension RenderTargetProtocol {
    @_transparent
    var isWindow: Bool {
        return self is Window
    }
}

extension _RenderTargetProtocol {
    @inlinable @inline(__always)
    public func insert(_ scene: Scene) {
        precondition(Game.shared.renderingIsPermitted, "Rendering can only be changed from a RenderingSystem.")
        self.drawables.append(scene)
    }
    
    @inlinable @inline(__always)
    public func insert(_ canvas: Canvas) {
        precondition(Game.shared.renderingIsPermitted, "Rendering can only be changed from a RenderingSystem.")
        if let size = canvas.size {
            precondition(size == self.size, "Canvas.size must equal RenderTarget.size to insert.")
        }
        self.drawables.append(canvas)
    }
    
    @inlinable @inline(__always)
    public func insert(_ drawCommand: DrawCommand) {
        precondition(Game.shared.renderingIsPermitted, "Rendering can only be changed from a RenderingSystem.")
        self.drawables.append(drawCommand)
    }
    
    @inline(__always)
    internal var renderTargets: [any _RenderTargetProtocol] {
        var allDrawCommands: [DrawCommand] = []
        for drawable in drawables {
            if let scene = drawable as? Scene {
                allDrawCommands.append(contentsOf: scene.drawCommands)
            }else if let canvas = drawable as? Canvas {
                allDrawCommands.append(contentsOf: canvas.drawCommands)
            }else if let command = drawable as? DrawCommand {
                allDrawCommands.append(command)
            }
        }
        
        var uniqueRenderTargets: [any _RenderTargetProtocol] = []
        for drawCommand in allDrawCommands {
            for renderTarget in drawCommand.renderTargets {
                if uniqueRenderTargets.contains(where: {$0 === renderTarget}) == false {
                    uniqueRenderTargets.append(renderTarget)
                }
            }
        }

        return uniqueRenderTargets
    }
}

@MainActor public final class RenderTarget: RenderTargetProtocol, _RenderTargetProtocol {
    @usableFromInline
    var renderTargetBackend: RenderTargetBackend
    var drawables: [Any] = []
    var previousSize: Size2? = nil
    
    @inlinable @inline(__always)
    public var size: Size2 {
        get {
            return renderTargetBackend.size
        }
        set {
            precondition(Game.shared.renderingIsPermitted, "Resizing a RenderTarget can only be done from a RenderingSystem.")
            renderTargetBackend.size = newValue
        }
    }
    
    @inline(__always)
    internal func reshapeIfNeeded() {
        if renderTargetBackend.wantsReshape || previousSize != renderTargetBackend.size {
            previousSize = renderTargetBackend.size
            renderTargetBackend.reshape()
        }
    }
    
    public init() {
        precondition(Game.shared.renderingIsPermitted, "RenderTarget can only be created from a RenderingSystem.")
        self.renderTargetBackend = getRenderTargetBackend(windowBacking: nil)
        self.clearColor = .black
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
            precondition(Game.shared.renderingIsPermitted, "Resizing a RenderTarget can only be done from a RenderingSystem.")
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
    
    internal func draw() {
        for renderTarget in renderTargets {
            assert(renderTarget !== self, "You created a RenderTarget infinite loop")
            renderTarget.draw()
        }
        self.reshapeIfNeeded()
        renderTargetBackend.willBeginFrame()

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
        renderTargetBackend.didEndFrame()
    }
    
    @inline(__always)
    private func drawScene(_ scene: Scene) {
        let matrices = scene.camera.matricies(withAspectRatio: self.size.aspectRatio)
        
        renderTargetBackend.willBeginContent(matrices: matrices, viewport: scene.viewport)
        for command in scene.drawCommands {
            Game.shared.renderer.draw(command, camera: scene.camera, matrices: matrices, renderTarget: self)
        }
        renderTargetBackend.didEndContent()
    }
    
    @inline(__always)
    private func drawCanvas(_ canvas: Canvas) {
        let matrices = canvas.matrices(withSize: self.size)

        renderTargetBackend.willBeginContent(matrices: matrices, viewport: canvas.viewport)
        for command in canvas.drawCommands {
            Game.shared.renderer.draw(command, camera: canvas.camera, matrices: matrices, renderTarget: self)
        }
        renderTargetBackend.didEndContent()
    }
    
    @inline(__always)
    private func drawRenderTarget(_ container: RenderTargetFillContainer) {
        container.renderTarget.draw()
        renderTargetBackend.willBeginContent(matrices: nil, viewport: nil)
        Game.shared.renderer.draw(container.renderTarget, into: self, options: container.options, sampler: container.filter)
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
extension RenderTargetProtocol {
    @inline(__always)
    public func insert(_ target: any RenderTargetProtocol,
                withOptions options: RenderTargetFillOptions = [],
                sampleFilter: RenderTargetFillSampleFilter = .nearest) {
        guard target.size.width > 1, target.size.height > 1 else {return}
        guard target.isWindow == false else {fatalError("Window.framebuffer cannot be used as a render target. Find another solution.")}
        (self as! any _RenderTargetProtocol).drawables.append(RenderTargetFillContainer(renderTarget: target as! any _RenderTargetProtocol, options: options, filter: sampleFilter))
    }
}

extension RenderTargetProtocol {
    nonisolated public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs === rhs
    }
    nonisolated public func hash(into hasher: inout Hasher) {
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
    @inlinable @inline(__always)
    var wantsReshape: Bool {false}
}

@_transparent
@MainActor func getRenderTargetBackend(windowBacking: WindowBacking?) -> RenderTargetBackend {
#if GATEENGINE_FORCE_OPNEGL_APPLE
    return OpenGLRenderTarget(isWindow: windowBacking != nil)
#elseif canImport(MetalKit)
    #if canImport(GLKit) && !targetEnvironment(macCatalyst)
    if MetalRenderer.isSupported == false {
        return OpenGLRenderTarget(isWindow: windowBacking != nil)
    }
    #endif
    return MetalRenderTarget(windowBacking: windowBacking)
#elseif canImport(WebGL2)
    return WebGL2RenderTarget(isWindow: windowBacking != nil)
#elseif canImport(WinSDK)
    return DX12RenderTarget(windowBacking: windowBacking)
#else
    #error("Not implemented.")
#endif
}
