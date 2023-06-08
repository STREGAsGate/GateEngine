/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@MainActor public extension Game {
    @inlinable @inline(__always)
    var entities: ContiguousArray<Entity> {
        return ecs.sortedEntities()
    }
    @inlinable @inline(__always)
    func insertEntity(_ entity: Entity) {
        ecs.insertEntity(entity)
    }
    @inlinable @inline(__always)
    func removeEntity(_ entity: Entity) {
        ecs.removeEntity(entity)
    }
    @inlinable @inline(__always) @discardableResult
    func removeEntity(named name: String) -> Entity? {
        return ecs.removeEntity(named: name)
    }
    @inlinable @inline(__always) @discardableResult
    func removeEntity(where block: (Entity)->(Bool)) -> Entity? {
        return ecs.removeEntity(where: block)
    }
    @inlinable @inline(__always)
    func entity(named name: String) -> Entity? {
        return ecs.entity(named: name)
    }
    @inlinable @inline(__always)
    func entity(withID id: ObjectIdentifier) -> Entity? {
        return ecs.entity(withID: id)
    }
    @inlinable @inline(__always)
    func firstEntity(withComponent component: Component.Type) -> Entity? {
        return ecs.firstEntity(withComponent: component)
    }
    @inlinable @inline(__always)
    func system<T: System>(ofType systemType: T.Type) -> T {
        return ecs.system(ofType: systemType) as! T
    }
    @inlinable @inline(__always)
    func system<T: RenderingSystem>(ofType systemType: T.Type) -> T {
        return ecs.system(ofType: systemType) as! T
    }
    @inlinable @inline(__always)
    func insertSystem(_ newSystem: System) {
        ecs.insertSystem(newSystem)
    }
    @inlinable @inline(__always)
    func insertSystem(_ newSystem: RenderingSystem) {
        ecs.insertSystem(newSystem)
    }
    @inlinable @inline(__always) @discardableResult
    func insertSystem<T: System>(_ system: T.Type) -> T {
        return ecs.insertSystem(system) as! T
    }
    @inlinable @inline(__always) @discardableResult
    func insertSystem<T: RenderingSystem>(_ system: T.Type) -> T {
        return ecs.insertSystem(system) as! T
    }
    @inlinable @inline(__always)
    func removeSystem(_ system: System) {
        ecs.removeSystem(system)
    }
    @inlinable @inline(__always)
    func removeSystem(_ system: RenderingSystem) {
        ecs.removeSystem(system)
    }
    @inlinable @inline(__always) @discardableResult
    func removeSystem<T: System>(_ system: T.Type) -> T? {
        return ecs.removeSystem(system) as? T
    }
    @inlinable @inline(__always) @discardableResult
    func removeSystem<T: RenderingSystem>(_ system: T.Type) -> T? {
        return ecs.removeSystem(system) as? T
    }
}

@MainActor internal extension Game {
    @_transparent
    func system<T: PlatformSystem>(ofType systemType: T.Type) -> T {
        return ecs.system(ofType: systemType) as! T
    }
    @_transparent @discardableResult
    func insertSystem<T: PlatformSystem>(_ system: T.Type) -> T {
        return ecs.insertSystem(system) as! T
    }
    @_transparent
    func insertSystem(_ newSystem: PlatformSystem) {
        ecs.insertSystem(newSystem)
    }
    @_transparent
    func removeSystem(_ system: PlatformSystem) {
        ecs.removeSystem(system)
    }
    @_transparent @discardableResult
    func removeSystem<T: PlatformSystem>(_ system: T.Type) -> T? {
        return ecs.removeSystem(system) as? T
    }
}

@usableFromInline
@MainActor final class ECSContext {
    private var previousFrameWasDropped: Bool = false
    private var platformSystemsNeedSorting = true
    private var _platformSystems: [PlatformSystem] = []
    internal var platformSystems: [PlatformSystem] {
        if platformSystemsNeedSorting {
            platformSystemsNeedSorting = false
            _platformSystems.sort(by: { (lhs, rhs) -> Bool in
                let lhs = type(of: lhs)
                let rhs = type(of: rhs)
                return lhs.phase.rawValue <= rhs.phase.rawValue
            })
            _platformSystems.sort(by: { (lhs, rhs) -> Bool in
                let lhs = type(of: lhs)
                let rhs = type(of: rhs)
                let lhsSO = lhs.sortOrder()?.rawValue
                let rhsSO = rhs.sortOrder()?.rawValue
                if lhsSO != nil || rhsSO != nil {
                    if let lhsSO = lhsSO, let rhsSO = rhsSO {
                        return lhsSO < rhsSO
                    }
                    if lhsSO != nil {
                        return true
                    }
                    if rhsSO != nil {
                        return true
                    }
                }
                return false
            })
        }
        return _platformSystems
    }
    
    private var systemsNeedSorting = true
    private var _systems: [System] = []
    public var systems: [System] {
        if systemsNeedSorting {
            systemsNeedSorting = false
            _systems.sort(by: { (lhs, rhs) -> Bool in
                let lhs = type(of: lhs)
                let rhs = type(of: rhs)
                return lhs.phase.rawValue <= rhs.phase.rawValue
            })
            _systems.sort(by: { (lhs, rhs) -> Bool in
                let lhsSO = type(of: lhs).sortOrder()?.rawValue
                let rhsSO = type(of: rhs).sortOrder()?.rawValue
                if let lhsSO = lhsSO, let rhsSO = rhsSO {
                    return lhsSO < rhsSO
                }
                if lhsSO == nil && rhsSO != nil {
                    return true
                }
                return false
            })
        }
        return _systems
    }
    
    private var renderingSystemsNeedSorting = true
    private var _renderingSystems: [RenderingSystem] = []
    public var renderingSystems: [RenderingSystem] {
        if renderingSystemsNeedSorting {
            renderingSystemsNeedSorting = false
            _renderingSystems.sort(by: { (lhs, rhs) -> Bool in
                let lhsSO = type(of: lhs).sortOrder()?.rawValue
                let rhsSO = type(of: rhs).sortOrder()?.rawValue
                if let lhsSO = lhsSO, let rhsSO = rhsSO {
                    return lhsSO < rhsSO
                }
                if lhsSO == nil && rhsSO != nil {
                    return true
                }
                return false
            })
        }
        return _renderingSystems
    }

    private var entitesDidChange: Bool = true
    @usableFromInline
    private(set) var entities: Set<Entity> = [] {
        didSet {
            self.entitesDidChange = true
        }
    }
    
    private var _sortedEntites: ContiguousArray<Entity> = []
    @usableFromInline
    func sortedEntities() -> ContiguousArray<Entity> {
        if entitesDidChange {
            entitesDidChange = false
            _sortedEntites = ContiguousArray(self.entities.sorted(by: {$0.priority.rawValue > $1.priority.rawValue}))
        }
        return _sortedEntites
    }

    public private(set) var performance: Performance? = nil
    func recordPerformance() {
        precondition(performance == nil, "Performance recording was already started!")
        self.performance = Performance()
    }

    public let game: Game
    public init(game: Game) {
        self.game = game
    }
}


public struct WindowLayout {
    /// The windows identifier
    public let identifier: String
    /// The unscaled backing size of the window
    public let windowSize: Size2
    /// The user interface scale of the window
    public let interfaceScale: Float
    /// The scaled insets for content to be unobscured by notches and system UI clutter
    public let safeAreaInsets: Insets
}
//MARK: Update
extension ECSContext {
    func shouldRenderAfterUpdate(withTimePassed deltaTime: Float) async -> Bool {
        let game = game
        let input = game.hid
        
        //Discard spiked times
        guard deltaTime < 1.0 else {game.ecs.performance?.totalDroppedFrames += 1; return false}
        if let performance = performance {
            performance.prepareForReuse()
            performance.startSystems()
        }
        for system in self.platformSystems {
            guard type(of: system).phase == .preUpdating else {continue}
            self.performance?.beginStatForSystem(system)
            await system.willUpdate(game: game, input: input, withTimePassed: deltaTime)
            self.performance?.endCurrentStatistic()
        }
        for system in self.systems {
            self.performance?.beginStatForSystem(system)
            await system.willUpdate(game: game, input: input, withTimePassed: deltaTime)
            self.performance?.endCurrentStatistic()
        }
        for system in self.platformSystems {
            guard type(of: system).phase == .postDeffered else {continue}
            self.performance?.beginStatForSystem(system)
            await system.willUpdate(game: game, input: input, withTimePassed: deltaTime)
            self.performance?.endCurrentStatistic()
        }
        
        //Drop frame if less then 15fps
        let dropFrame: Bool = deltaTime < 0.067
        //Only drop 1 frame before requiring a frame
        let shouldRender: Bool = game.isHeadless ? false : previousFrameWasDropped ? true : dropFrame
        
        if previousFrameWasDropped {
            previousFrameWasDropped = false
        }else if dropFrame {
            previousFrameWasDropped = true
        }
        
        if let performance = self.performance {
            performance.endSystems()
            if shouldRender == false {
                performance.finalizeSystemsFrameTime()
                if dropFrame {
                    performance.totalDroppedFrames += 1
                }
            }
        }

        return shouldRender
    }
    
    func updateRendering(withTimePassed deltaTime: Float, window: Window) {
        if let performance = performance {
            performance.startRenderingSystems()
        }
        defer {
            if let performance = performance {
                performance.endSystems()
                performance.finalizeSystemsFrameTime()
            }
        }

        let game = game
        
        for system in self.renderingSystems {
            self.performance?.beginStatForSystem(system)
            system.willRender(game: game, window: window, withTimePassed: deltaTime)
            self.performance?.endCurrentStatistic()
        }
        if let performance = performance {
            performance.endRenderingSystems()
            performance.finalizeRenderingSystemsFrameTime()
            performance.startSystems()
        }
    }
}

//MARK: Entity Managment
extension ECSContext {
    @inlinable @inline(__always)
    func insertEntity(_ entity: Entity) {
        guard self.entities.contains(entity) == false else {return}
        self.entities.insert(entity)
    }
    @inlinable @inline(__always) @discardableResult
    func removeEntity(_ entity: Entity) -> Entity? {
        return self.entities.remove(entity)
    }
    @inlinable @inline(__always) @discardableResult
    func removeEntity(named name: String) -> Entity? {
        self.removeEntity(where: {$0.name == name})
    }
    @inlinable @inline(__always) @discardableResult
    func removeEntity(where block: (Entity)->(Bool)) -> Entity? {
        if let removed = self.entities.first(where: block) {
            self.entities.remove(removed)
            return removed
        }
        return nil
    }
    @inlinable @inline(__always)
    func entity(named name: String) -> Entity? {
        return entities.first(where: {$0.name == name})
    }
    @inlinable @inline(__always)
    func entity(withID id: ObjectIdentifier) -> Entity? {
        return entities.first(where: {$0.id == id})
    }
    @inlinable @inline(__always)
    func firstEntity(withComponent type: Component.Type) -> Entity? {
        return entities.first(where: {$0.hasComponent(type)})
    }
}

//MARK: System Managment
extension ECSContext {
    @usableFromInline
    func system(ofType systemType: System.Type) -> System {
        for system in _systems {
            if type(of: system) == systemType {
                return system
            }
        }
        return insertSystem(systemType)
    }
    @usableFromInline
    func system(ofType systemType: RenderingSystem.Type) -> RenderingSystem {
        for system in _renderingSystems {
            if type(of: system) == systemType {
                return system
            }
        }
        return insertSystem(systemType)
    }
    func system(ofType systemType: PlatformSystem.Type) -> PlatformSystem {
        for system in _platformSystems {
            if type(of: system) == systemType {
                return system
            }
        }
        return insertSystem(systemType)
    }
    @usableFromInline
    func insertSystem(_ newSystem: System) {
        let systemType = type(of: newSystem)
        guard _systems.contains(where: {type(of: $0) == systemType}) == false else {return}
        var systems = self._systems
        systems.append(newSystem)
        _systems = systems
        systemsNeedSorting = true
    }
    @usableFromInline
    func insertSystem(_ newSystem: RenderingSystem) {
        let systemType = type(of: newSystem)
        guard _renderingSystems.contains(where: {type(of: $0) == systemType}) == false else {return}
        var renderingSystems = self._renderingSystems
        renderingSystems.append(newSystem)
        _renderingSystems = renderingSystems
        renderingSystemsNeedSorting = true
    }
    func insertSystem(_ newSystem: PlatformSystem) {
        let systemType = type(of: newSystem)
        guard _platformSystems.contains(where: {type(of: $0) == systemType}) == false else {return}
        var platformSystems = self._platformSystems
        platformSystems.append(newSystem)
        _platformSystems = platformSystems
        platformSystemsNeedSorting = true
    }
    @usableFromInline @discardableResult
    func insertSystem(_ system: System.Type) -> System {
        let system = system.init()
        self.insertSystem(system)
        return system
    }
    @usableFromInline @discardableResult
    func insertSystem(_ system: RenderingSystem.Type) -> RenderingSystem {
        let system = system.init()
        self.insertSystem(system)
        return system
    }
    @inline(__always) @discardableResult
    func insertSystem(_ system: PlatformSystem.Type) -> PlatformSystem {
        let system = system.init()
        self.insertSystem(system)
        return system
    }
    @usableFromInline
    func removeSystem(_ system: System) {
        if let index = self._systems.firstIndex(where: {$0 === system}) {
            self._systems.remove(at: index).teardown(game: game)
        }
    }
    @usableFromInline
    func removeSystem(_ system: RenderingSystem) {
        if let index = self._renderingSystems.firstIndex(where: {$0 === system}) {
            self._renderingSystems.remove(at: index).teardown(game: game)
        }
    }
    @_transparent
    func removeSystem(_ system: PlatformSystem) {
        if let index = self._platformSystems.firstIndex(where: {$0 === system}) {
            self._platformSystems.remove(at: index).teardown(game: game)
        }
    }
    @usableFromInline @discardableResult
    func removeSystem<T: System>(_ system: T.Type) -> System? {
        if let index = self._systems.firstIndex(where: {type(of: $0) == system}) {
            let system = self._systems.remove(at: index)
            system.teardown(game: game)
            return system
        }
        return nil
    }
    @usableFromInline @discardableResult
    func removeSystem<T: RenderingSystem>(_ system: T.Type) -> RenderingSystem? {
        if let index = self._renderingSystems.firstIndex(where: {type(of: $0) == system}) {
            let system = self._renderingSystems.remove(at: index)
            system.teardown(game: game)
            return system
        }
        return nil
    }
    @discardableResult
    func removeSystem<T: PlatformSystem>(_ system: T.Type) -> PlatformSystem? {
        if let index = self._platformSystems.firstIndex(where: {type(of: $0) == system}) {
            let system = self._platformSystems.remove(at: index)
            system.teardown(game: game)
            return system
        }
        return nil
    }
}

