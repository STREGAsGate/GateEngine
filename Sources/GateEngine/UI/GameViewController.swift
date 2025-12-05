/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public struct GameViewSnapshot: Sendable {
    let frame: Rect
    let bounds: Rect
    let backgroundColor: Color?
    
    static var empty: GameViewSnapshot {
        return .init(frame: .zero, bounds: .zero, backgroundColor: nil)
    }
}
internal extension GameView {
    func snapshot() -> GameViewSnapshot {
        return GameViewSnapshot(
            frame: self.frame, 
            bounds: self.bounds, 
            backgroundColor: self.backgroundColor
        )
    }
}

public final class GameView: View {
    @usableFromInline
    var _drawables: [any Drawable] = []
    
    override final func shouldDraw() -> Bool {
        if let gameViewController, gameViewController.shouldSkipRendering {
            return false
        }
        return super.shouldDraw()
    }
    
    public override func canBeHit() -> Bool {
        return true
    }
   
    enum Mode {
        case screen
        case offScreen
    }
    var mode: Mode = .screen
    
    private var deltaTimeHelper = DeltaTimeHelper(name: "Rendering")
    
    override final func draw(_ rect: Rect, into canvas: inout UICanvas) {
        var frame = frame
        if mode == .offScreen {
            super.draw(rect, into: &canvas)
            frame = rect
            self._renderTarget?.size = Size2i(frame.size)
        }
        
        if let gameViewController {
            gameViewController.context.beginRendering()
            
            let highPrecisionDeltaTime = self.deltaTimeHelper.getDeltaTime()
            let deltaTime = Float(highPrecisionDeltaTime)
            
            // Draw below content
            gameViewController.context.updateRendering(into: self, deltaTime: deltaTime, for: .beforeGameView)
            // Draw GameView
            gameViewController.render(context: gameViewController.context, into: self, withTimePassed: deltaTime)
            // Draw above content
            gameViewController.context.updateRendering(into: self, deltaTime: deltaTime, for: .afterGameView)
            
            gameViewController.context.endRendering()
            
            if mode == .offScreen {
                canvas.insert(
                    DrawCommand(
                        resource: .geometry(.rectOriginTopLeft),
                        transforms: [
                            Transform3(
                                position: Position3(
                                    x: frame.x,
                                    y: frame.y,
                                    z: 0
                                ),
                                scale: Size3(
                                    frame.width,
                                    frame.height,
                                    1
                                )
                            )
                        ], 
                        material: Material(texture: renderTargetTexture, tintColor: Self.colorOffscreenRendered ? .yellow : .white),
                        vsh: .standard,
                        fsh: Self.colorOffscreenRendered ? .textureSampleTintColor : .textureSample,
                        flags: .userInterface
                    )
                )
            }
        }
    }
    
    @usableFromInline
    internal var _renderTarget: RenderTarget? = nil
    @usableFromInline
    internal var renderTarget: any RenderTargetProtocol {
        return _renderTarget ?? self.window!
    }
    internal var renderTargetTexture: Texture {
        return _renderTarget?.texture ?? self.window!.texture
    }
    
    public override func didLayout() {
        super.didLayout()
        self.deltaTimeHelper.reset()
    }
    
    public override func didChangeSuperview() {
        super.didChangeSuperview()
        
        if self.superView == nil {
            _renderTarget = nil
            return
        }
        
        if _viewController?.isRootViewController == true {
            self.mode = .screen
            _renderTarget = nil
        }else{
            self.mode = .offScreen
            Game.shared.attributes.insert(.renderingIsPermitted)
            _renderTarget = RenderTarget(backgroundColor: .clear)
            Game.shared.attributes.remove(.renderingIsPermitted)
        }
    }
}
extension GameView {
    @inlinable
    public var gameViewController: GameViewController? {
        return _viewController as? GameViewController
    }
    @inlinable
    public func insert(_ canvas: Canvas) {
        if canvas.hasContent {
            self.renderTarget.insert(canvas)
        }
    }
    
    @inlinable
    public func insert(_ scene: Scene) {
        if scene.hasContent {
            self.renderTarget.insert(scene)
        }
    }
}

open class GameViewController: ViewController {
    public let context = ECSContext()

    @inlinable
    public var gameView: GameView {
        return unsafeDowncast(self.view, to: GameView.self)
    } 
    
    final public override func loadView() {
        self.view = GameView()
        Task {
            await self.setup(context: self.context)
        }
    }
    
    internal var shouldSkipRendering: Bool = false
    
    internal override func _update(withTimePassed deltaTime: Float) async {
        await super._update(withTimePassed: deltaTime)
        if view.superView != nil {
            self.shouldSkipRendering = (await context.shouldRenderAfterUpdate(withTimePassed: deltaTime) == false)
        }else{
            self.shouldSkipRendering = true
        }
    }
    
    @MainActor
    open func setup(context: ECSContext) async {
        
    }
    
    open func render(context: ECSContext, into view: GameView, withTimePassed deltaTime: Float) {
        
    }
}

extension GameView {
    /**
     Move a 3D point into this view's coordinate space.
     
     - returns: A 2D position representing the location of a 3D object in this view's bounds.
     */
    public func convert(_ position: Position3, from camera: inout Camera) -> Position2 {
        let size = self.bounds.size
        let matricies = camera.matricies(withViewportSize: size * self.interfaceScale)
        var position = position * matricies.viewProjection()
        position.x /= position.z
        position.y /= position.z
        
        position.x = size.width * (position.x + 1) / 2
        position.y = size.height * (1.0 - ((position.y + 1) / 2))
        
//        position.x /= self.interfaceScale
//        position.y /= self.interfaceScale
        
        return Position2(position.x, position.y)
    }
    
    /**
     Move a 2D point into a 3D space.
     
     - returns: A Ray3D representing the location of a 2D point located on the view. The ray's direction is toward the 3D space accounting for perspective distortion.
     */
    public func convert(_ position: Position2, to camera: inout Camera) -> Ray3D {
        switch camera.fieldOfView {
        case .perspective(let fieldOfView):
            let size = self.bounds.size
            let halfSize = size / 2
            let aspectRatio = size.aspectRatio
            
            let inverseView = camera.matricies(withViewportSize: size * interfaceScale).view.inverse
            let halfFOV = tan(fieldOfView.rawValueAsRadians * 0.5)
            let near = camera.clippingPlane.near
            let far = camera.clippingPlane.far
            
            let dx = halfFOV * (position.x / halfSize.width - 1.0) * aspectRatio
            let dy = halfFOV * (1.0 - position.y / halfSize.height)
            
            let p1 = Position3(dx * near, dy * near, near) * inverseView
            let p2 = Position3(dx * far, dy * far, far) * inverseView
            
            return Ray3D(from: p1, toward: p2)
        case .orthographic(let center):
            let size = self.bounds.size * interfaceScale
            var position = position * interfaceScale
            switch center {
            case .topLeft:
                break
            case .center:
                position -= size / 2
            }
            
            let x = position.x
            let y = position.y

            let inverseView = camera.matricies(withViewportSize: size).view.inverse
            let start = Position3(x, y, -1) * inverseView

            return Ray3D(from: start, toward: camera.transform.rotation.forward)
        }
    }
}

extension GameViewController {
    @inlinable
    public var entities: [Entity] {
        return context.sortedEntities()
    }
    @inlinable
    public func insertEntity(_ entity: Entity) {
        context.insertEntity(entity)
    }
    @inlinable
    public func removeEntity(_ entity: Entity) {
        context.removeEntity(entity)
    }
    @inlinable @discardableResult
    public func removeEntity(named name: String) -> Entity? {
        return context.removeEntity(named: name)
    }
    @inlinable @discardableResult
    public func removeEntity(where block: (Entity) -> (Bool)) -> Entity? {
        return context.removeEntity(where: block)
    }
    @inlinable
    public func entity(named name: String) -> Entity? {
        return context.entity(named: name)
    }
    @inlinable
    public func entity(withID id: ObjectIdentifier) -> Entity? {
        return context.entity(withID: id)
    }
    @inlinable
    public func firstEntity(withComponent component: any Component.Type) -> Entity? {
        return context.firstEntity(withComponent: component)
    }
    @inlinable
    public func system<T: System>(ofType systemType: T.Type) -> T {
        return context.system(ofType: systemType)
    }
    @inlinable
    public func hasSystem<T: System>(ofType systemType: T.Type) -> Bool {
        return context.hasSystem(ofType: systemType)
    }
    @inlinable
    public func system<T: RenderingSystem>(ofType systemType: T.Type) -> T {
        return context.system(ofType: systemType)
    }
    @inlinable
    public func insertSystem(_ newSystem: System) {
        context.insertSystem(newSystem)
    }
    @inlinable
    public func insertSystem(_ newSystem: RenderingSystem) {
        context.insertSystem(newSystem)
    }
    @inlinable @discardableResult
    public func insertSystem<T: System>(_ system: T.Type) -> T {
        return context.insertSystem(system)
    }
    @inlinable @discardableResult
    public func insertSystem<T: RenderingSystem>(_ system: T.Type) -> T {
        return context.insertSystem(system)
    }
    @inlinable
    public func removeSystem(_ system: System) {
        context.removeSystem(system)
    }
    @inlinable
    public func removeSystem(_ system: RenderingSystem) {
        context.removeSystem(system)
    }
    @inlinable @discardableResult
    public func removeSystem<T: System>(_ system: T.Type) -> T? {
        return context.removeSystem(system)
    }
    @inlinable @discardableResult
    public func removeSystem<T: RenderingSystem>(_ system: T.Type) -> T? {
        return context.removeSystem(system)
    }
}

@MainActor extension GameViewController {
    func system<T: PlatformSystem>(ofType systemType: T.Type) -> T {
        return context.system(ofType: systemType)
    }
    @discardableResult
    func insertSystem<T: PlatformSystem>(_ system: T.Type) -> T {
        return context.insertSystem(system)
    }
    
    func insertSystem(_ newSystem: PlatformSystem) {
        context.insertSystem(newSystem)
    }
    
    func removeSystem(_ system: PlatformSystem) {
        context.removeSystem(system)
    }
    @discardableResult
    func removeSystem<T: PlatformSystem>(_ system: T.Type) -> T? {
        return context.removeSystem(system)
    }
}
