/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@MainActor extension Game {
    @_transparent
    public var entities: ContiguousArray<Entity> {
        return ecs.sortedEntities()
    }
    @_transparent
    public func insertEntity(_ entity: Entity) {
        ecs.insertEntity(entity)
    }
    @_transparent
    public func removeEntity(_ entity: Entity) {
        ecs.removeEntity(entity)
    }
    @_transparent @discardableResult
    public func removeEntity(named name: String) -> Entity? {
        return ecs.removeEntity(named: name)
    }
    @_transparent @discardableResult
    public func removeEntity(where block: (Entity) -> (Bool)) -> Entity? {
        return ecs.removeEntity(where: block)
    }
    @_transparent
    public func entity(named name: String) -> Entity? {
        return ecs.entity(named: name)
    }
    @_transparent
    public func entity(withID id: ObjectIdentifier) -> Entity? {
        return ecs.entity(withID: id)
    }
    @_transparent
    public func firstEntity(withComponent component: any Component.Type) -> Entity? {
        return ecs.firstEntity(withComponent: component)
    }
    @_transparent
    public func system<T: System>(ofType systemType: T.Type) -> T {
        return ecs.system(ofType: systemType) as! T
    }
    @_transparent
    public func hasSystem<T: System>(ofType systemType: T.Type) -> Bool {
        return ecs.hasSystem(ofType: systemType)
    }
    @_transparent
    public func system<T: RenderingSystem>(ofType systemType: T.Type) -> T {
        return ecs.system(ofType: systemType) as! T
    }
    @_transparent
    public func insertSystem(_ newSystem: System) {
        ecs.insertSystem(newSystem)
    }
    @_transparent
    public func insertSystem(_ newSystem: RenderingSystem) {
        ecs.insertSystem(newSystem)
    }
    @_transparent @discardableResult
    public func insertSystem<T: System>(_ system: T.Type) -> T {
        return ecs.insertSystem(system) as! T
    }
    @_transparent @discardableResult
    public func insertSystem<T: RenderingSystem>(_ system: T.Type) -> T {
        return ecs.insertSystem(system) as! T
    }
    @_transparent
    public func removeSystem(_ system: System) {
        ecs.removeSystem(system)
    }
    @_transparent
    public func removeSystem(_ system: RenderingSystem) {
        ecs.removeSystem(system)
    }
    @_transparent @discardableResult
    public func removeSystem<T: System>(_ system: T.Type) -> T? {
        return ecs.removeSystem(system) as? T
    }
    @_transparent @discardableResult
    public func removeSystem<T: RenderingSystem>(_ system: T.Type) -> T? {
        return ecs.removeSystem(system) as? T
    }
}

@MainActor extension Game {
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
            self.sortPlatformSystems()
        }
        return _platformSystems
    }
    
    func sortPlatformSystems() {
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

    private var systemsNeedSorting = true
    private var _systems: [System] = []
    public var systems: [System] {
        if systemsNeedSorting {
            systemsNeedSorting = false
            self.sortSystems()
        }
        return _systems
    }
    
    func sortSystems() {
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

    private var renderingSystemsNeedSorting = true
    private var _renderingSystems: [RenderingSystem] = []
    public var renderingSystems: [RenderingSystem] {
        if renderingSystemsNeedSorting {
            renderingSystemsNeedSorting = false
            self.sortRenderingSystems()
        }
        return _renderingSystems
    }
    
    func sortRenderingSystems() {
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

    private var entitiesDidChange: Bool = true
    @usableFromInline
    private(set) var entities: Set<Entity> = .init(minimumCapacity: 16) {
        didSet {
            self.entitiesDidChange = true
        }
    }
    
    internal var _removedEntities: ContiguousArray<Entity> = []

    private var _sortedEntities: ContiguousArray<Entity> = []
    @usableFromInline
    func sortedEntities() -> ContiguousArray<Entity> {
        if entitiesDidChange {
            entitiesDidChange = false
            self.sortEntities()
        }
        return _sortedEntities
    }
    
    func sortEntities() {
        _sortedEntities.removeAll(keepingCapacity: true)
        _sortedEntities.append(contentsOf: entities)
        _sortedEntities.sort(by: { $0.priority.rawValue > $1.priority.rawValue })
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
        
        if let performance = performance {
            performance.prepareForReuse()
            performance.startFrame()
            performance.startSystems()
        }
//        for system in self.platformSystems {
//            guard type(of: system).phase == .preUpdating else { continue }
//            self.performance?.beginStatForSystem(system)
//            await system.willUpdate(game: game, input: input, withTimePassed: deltaTime)
//            self.performance?.endCurrentStatistic()
//        }
        for system in self.systems {
            self.performance?.beginStatForSystem(system)
            await system.willUpdate(game: game, input: input, withTimePassed: deltaTime)
            self.performance?.endCurrentStatistic()
        }
        for system in self.platformSystems {
//            guard type(of: system).phase == .postDeferred else { continue }
            self.performance?.beginStatForSystem(system)
            await system.willUpdate(game: game, input: input, withTimePassed: deltaTime)
            self.performance?.endCurrentStatistic()
        }
        
        let removed = self._removedEntities
        _removedEntities.removeAll(keepingCapacity: true)
        for entity in removed {
            for system in self.systems {
                await system.gameDidRemove(entity: entity, game: game, input: input)
            }
            for system in self.platformSystems {
                await system.gameDidRemove(entity: entity, game: game, input: input)
            }
        }

        // Drop frame if less then 12fps
        let dropFrame: Bool = deltaTime > /* 1/12 */ 0.08333333333
        // Only drop 1 frame before requiring a frame
        let shouldRender: Bool = game.isHeadless ? false : (previousFrameWasDropped ? true : !dropFrame)

        if previousFrameWasDropped {
            previousFrameWasDropped = false
        }else if shouldRender == false {
            previousFrameWasDropped = true
        }

        if let performance = self.performance {
            performance.endSystems()
            performance.finalizeSystemsFrameTime()
            if shouldRender == false && dropFrame {
                performance.totalDroppedFrames += 1
            }
        }

        return shouldRender
    }

    func updateRendering(withTimePassed deltaTime: Float, window: Window) {
        if let performance = performance {
            performance.startRenderingSystems()
        }

        for system in self.renderingSystems {
            self.performance?.beginStatForSystem(system)
            system.willRender(game: game, window: window, withTimePassed: deltaTime)
            self.performance?.endCurrentStatistic()
        }
        
        if let performance = performance {
            performance.endRenderingSystems()
            performance.finalizeRenderingSystemsFrameTime()
        }
    }
}

//MARK: Entity Management
extension ECSContext {
    @usableFromInline
    func insertEntity(_ entity: Entity) {
        self.entities.insert(entity)
        
        for componentID in entity.componentIDs {
            if let component = entity.componentBank[componentID] {
                if let system = type(of: component).systemThatProcessesThisComponent() {
                    if game.hasSystem(ofType: system) == false {
                        game.insertSystem(system)
                    }
                }
            }
        }
    }
    @usableFromInline
    func removeEntity(_ entity: Entity) {
        if let entity = self.entities.remove(entity) {
            self._removedEntities.append(entity)
        }
    }
    @usableFromInline
    func removeEntity(named name: String) -> Entity? {
        if let entity = self.removeEntity(where: { $0.name == name }) {
            self._removedEntities.append(entity)
            return entity
        }
        return nil
    }
    @usableFromInline
    func removeEntity(where block: (Entity) -> (Bool)) -> Entity? {
        if let removed = self.entities.first(where: block) {
            self._removedEntities.append(removed)
            self.entities.remove(removed)
            return removed
        }
        return nil
    }
    @usableFromInline @_transparent
    func entity(named name: String) -> Entity? {
        return entities.first(where: { $0.name == name })
    }
    @usableFromInline @_transparent
    func entity(withID id: ObjectIdentifier) -> Entity? {
        return entities.first(where: { $0.id == id })
    }
    @usableFromInline @_transparent
    func firstEntity(withComponent type: any Component.Type) -> Entity? {
        return entities.first(where: { $0.hasComponent(type) })
    }
}

//MARK: System Management
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
    func hasSystem(ofType systemType: System.Type) -> Bool {
        for system in _systems {
            if type(of: system) == systemType {
                return true
            }
        }
        return false
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
        guard _systems.contains(where: { type(of: $0) == systemType }) == false else { return }
        var systems = self._systems
        systems.append(newSystem)
        _systems = systems
        systemsNeedSorting = true
    }
    @usableFromInline
    func insertSystem(_ newSystem: RenderingSystem) {
        let systemType = type(of: newSystem)
        guard _renderingSystems.contains(where: { type(of: $0) == systemType }) == false else {
            return
        }
        var renderingSystems = self._renderingSystems
        renderingSystems.append(newSystem)
        _renderingSystems = renderingSystems
        renderingSystemsNeedSorting = true
    }
    func insertSystem(_ newSystem: PlatformSystem) {
        let systemType = type(of: newSystem)
        guard _platformSystems.contains(where: { type(of: $0) == systemType }) == false else {
            return
        }
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
        if let index = self._systems.firstIndex(where: { $0 === system }) {
            self._systems.remove(at: index).teardown(game: game)
        }
    }
    @usableFromInline
    func removeSystem(_ system: RenderingSystem) {
        if let index = self._renderingSystems.firstIndex(where: { $0 === system }) {
            self._renderingSystems.remove(at: index).teardown(game: game)
        }
    }
    func removeSystem(_ system: PlatformSystem) {
        if let index = self._platformSystems.firstIndex(where: { $0 === system }) {
            self._platformSystems.remove(at: index).teardown(game: game)
        }
    }
    @usableFromInline @discardableResult
    func removeSystem<T: System>(_ system: T.Type) -> System? {
        if let index = self._systems.firstIndex(where: { type(of: $0) == system }) {
            let system = self._systems.remove(at: index)
            system.teardown(game: game)
            return system
        }
        return nil
    }
    @usableFromInline @discardableResult
    func removeSystem<T: RenderingSystem>(_ system: T.Type) -> RenderingSystem? {
        if let index = self._renderingSystems.firstIndex(where: { type(of: $0) == system }) {
            let system = self._renderingSystems.remove(at: index)
            system.teardown(game: game)
            return system
        }
        return nil
    }
    @discardableResult
    func removeSystem<T: PlatformSystem>(_ system: T.Type) -> PlatformSystem? {
        if let index = self._platformSystems.firstIndex(where: { type(of: $0) == system }) {
            let system = self._platformSystems.remove(at: index)
            system.teardown(game: game)
            return system
        }
        return nil
    }
}
