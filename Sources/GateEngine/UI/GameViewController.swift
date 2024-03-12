/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public final class GameView: View {
    @usableFromInline
    var _drawables: [any Drawable] = []
    
    override final func shouldDraw() -> Bool {
        if let gameViewController, gameViewController.shouldSkipRendering {
            return false
        }
        return super.shouldDraw()
    }
    
    private var pendingBackgroundColor: Color? = nil
    public override var backgroundColor: Color? {
        get {
            switch mode {
            case .screen:
                return window?.clearColor
            case .offScreen:
                return _renderTarget?.clearColor
            }
        }
        set {
            switch mode {
            case .screen:
                if let window {
                    window.clearColor = newValue ?? .clear
                }else{
                    self.pendingBackgroundColor = newValue
                }
            case .offScreen:
                _renderTarget?.clearColor = newValue ?? .clear
            }
            super.backgroundColor = nil
        }
    }
    
    enum Mode {
        case screen
        case offScreen
    }
    var mode: Mode = .screen
    
    private var deltaTimeAccumulator: Double = 0
    private var previousTime: Double = 0
    
    override final func draw(into canvas: inout UICanvas, at frame: Rect) {
        if mode == .offScreen {
            super.draw(into: &canvas, at: frame)
            self._renderTarget?.size = frame.size
        }
        
        if let gameViewController {
            guard let _deltaTime = Game.getNextDeltaTime(
                accumulator: &deltaTimeAccumulator, 
                previous: &previousTime
            ) else {
                return
            }
            
            let deltaTime = Float(_deltaTime)
            gameViewController.render(context: gameViewController.context, into: self, withTimePassed: deltaTime)
            gameViewController.context.updateRendering(into: self, deltaTime: deltaTime)
            
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
    
    public override func didChangeSuperview() {
        if self.superView == nil {
            _renderTarget = nil
            return
        }
        if _viewController?.isRootViewController == true {
            self.mode = .screen
            _renderTarget = nil
            if let pendingBackgroundColor {
                if let window {
                    self.backgroundColor = pendingBackgroundColor
                    self.pendingBackgroundColor = nil
                }
            }
        }else{
            self.mode = .offScreen
            _renderTarget = RenderTarget(backgroundColor: self.backgroundColor ?? .clear)
        }
    }
}
extension GameView {
    @_transparent
    public var gameViewController: GameViewController? {
        return _viewController as? GameViewController
    }
    @_transparent
    public func insert(_ canvas: Canvas) {
        if canvas.hasContent {
            self.renderTarget.insert(canvas)
        }
    }
    
    @_transparent
    public func insert(_ scene: Scene) {
        if scene.hasContent {
            self.renderTarget.insert(scene)
        }
    }
}

open class GameViewController: ViewController {
    @usableFromInline
    internal let context = ECSContext()

    final public override func loadView() {
        self.view = GameView()
    }
    
    internal var shouldSkipRendering: Bool = false
    
    internal override func _update(withTimePassed deltaTime: Float) async {
        await super._update(withTimePassed: deltaTime)
        self.shouldSkipRendering = (await context.shouldRenderAfterUpdate(withTimePassed: deltaTime) == false)
    }
    
    open func render(context: ECSContext, into view: GameView, withTimePassed deltaTime: Float) {
        
    }
}

extension GameViewController {
    @_transparent
    public var entities: ContiguousArray<Entity> {
        return context.sortedEntities()
    }
    @_transparent
    public func insertEntity(_ entity: Entity) {
        context.insertEntity(entity)
    }
    @_transparent
    public func removeEntity(_ entity: Entity) {
        context.removeEntity(entity)
    }
    @_transparent @discardableResult
    public func removeEntity(named name: String) -> Entity? {
        return context.removeEntity(named: name)
    }
    @_transparent @discardableResult
    public func removeEntity(where block: (Entity) -> (Bool)) -> Entity? {
        return context.removeEntity(where: block)
    }
    @_transparent
    public func entity(named name: String) -> Entity? {
        return context.entity(named: name)
    }
    @_transparent
    public func entity(withID id: ObjectIdentifier) -> Entity? {
        return context.entity(withID: id)
    }
    @_transparent
    public func firstEntity(withComponent component: any Component.Type) -> Entity? {
        return context.firstEntity(withComponent: component)
    }
    @_transparent
    public func system<T: System>(ofType systemType: T.Type) -> T {
        return context.system(ofType: systemType) as! T
    }
    @_transparent
    public func hasSystem<T: System>(ofType systemType: T.Type) -> Bool {
        return context.hasSystem(ofType: systemType)
    }
    @_transparent
    public func system<T: RenderingSystem>(ofType systemType: T.Type) -> T {
        return context.system(ofType: systemType) as! T
    }
    @_transparent
    public func insertSystem(_ newSystem: System) {
        context.insertSystem(newSystem)
    }
    @_transparent
    public func insertSystem(_ newSystem: RenderingSystem) {
        context.insertSystem(newSystem)
    }
    @_transparent @discardableResult
    public func insertSystem<T: System>(_ system: T.Type) -> T {
        return context.insertSystem(system) as! T
    }
    @_transparent @discardableResult
    public func insertSystem<T: RenderingSystem>(_ system: T.Type) -> T {
        return context.insertSystem(system) as! T
    }
    @_transparent
    public func removeSystem(_ system: System) {
        context.removeSystem(system)
    }
    @_transparent
    public func removeSystem(_ system: RenderingSystem) {
        context.removeSystem(system)
    }
    @_transparent @discardableResult
    public func removeSystem<T: System>(_ system: T.Type) -> T? {
        return context.removeSystem(system) as? T
    }
    @_transparent @discardableResult
    public func removeSystem<T: RenderingSystem>(_ system: T.Type) -> T? {
        return context.removeSystem(system) as? T
    }
}

@MainActor extension GameViewController {
    @_transparent
    func system<T: PlatformSystem>(ofType systemType: T.Type) -> T {
        return context.system(ofType: systemType) as! T
    }
    @_transparent @discardableResult
    func insertSystem<T: PlatformSystem>(_ system: T.Type) -> T {
        return context.insertSystem(system) as! T
    }
    @_transparent
    func insertSystem(_ newSystem: PlatformSystem) {
        context.insertSystem(newSystem)
    }
    @_transparent
    func removeSystem(_ system: PlatformSystem) {
        context.removeSystem(system)
    }
    @_transparent @discardableResult
    func removeSystem<T: PlatformSystem>(_ system: T.Type) -> T? {
        return context.removeSystem(system) as? T
    }
}
