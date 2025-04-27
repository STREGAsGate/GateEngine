/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@MainActor internal extension Game {
    @inlinable
    var entities: [Entity] {
        return ecs.sortedEntities()
    }
    @inlinable
    func insertEntity(_ entity: Entity) {
        ecs.insertEntity(entity)
    }
    @inlinable
    func removeEntity(_ entity: Entity) {
        ecs.removeEntity(entity)
    }
    @inlinable @discardableResult
    func removeEntity(named name: String) -> Entity? {
        return ecs.removeEntity(named: name)
    }
    @inlinable @discardableResult
    func removeEntity(where block: (Entity) -> (Bool)) -> Entity? {
        return ecs.removeEntity(where: block)
    }
    @inlinable
    func entity(named name: String) -> Entity? {
        return ecs.entity(named: name)
    }
    @inlinable
    func entity(withID id: ObjectIdentifier) -> Entity? {
        return ecs.entity(withID: id)
    }
    @inlinable
    func firstEntity(withComponent component: any Component.Type) -> Entity? {
        return ecs.firstEntity(withComponent: component)
    }
    @inlinable
    func system<T: System>(ofType systemType: T.Type) -> T {
        return ecs.system(ofType: systemType)
    }
    @inlinable
    func hasSystem<T: System>(ofType systemType: T.Type) -> Bool {
        return ecs.hasSystem(ofType: systemType)
    }
    @inlinable
    func system<T: RenderingSystem>(ofType systemType: T.Type) -> T {
        return ecs.system(ofType: systemType)
    }
    @inlinable
    func insertSystem(_ newSystem: System) {
        ecs.insertSystem(newSystem)
    }
    @inlinable
    func insertSystem(_ newSystem: RenderingSystem) {
        ecs.insertSystem(newSystem)
    }
    @inlinable @discardableResult
    func insertSystem<T: System>(_ system: T.Type) -> T {
        return ecs.insertSystem(system)
    }
    @inlinable @discardableResult
    func insertSystem<T: RenderingSystem>(_ system: T.Type) -> T {
        return ecs.insertSystem(system)
    }
    @inlinable
    func removeSystem(_ system: System) {
        ecs.removeSystem(system)
    }
    @inlinable
    func removeSystem(_ system: RenderingSystem) {
        ecs.removeSystem(system)
    }
    @inlinable @discardableResult
    func removeSystem<T: System>(_ system: T.Type) -> T? {
        return ecs.removeSystem(system)
    }
    @inlinable @discardableResult
    func removeSystem<T: RenderingSystem>(_ system: T.Type) -> T? {
        return ecs.removeSystem(system)
    }

    func system<T: PlatformSystem>(ofType systemType: T.Type) -> T {
        return ecs.system(ofType: systemType)
    }
    @discardableResult
    func insertSystem<T: PlatformSystem>(_ system: T.Type) -> T {
        return ecs.insertSystem(system)
    }
    func insertSystem(_ newSystem: PlatformSystem) {
        ecs.insertSystem(newSystem)
    }
    func removeSystem(_ system: PlatformSystem) {
        ecs.removeSystem(system)
    }
    @discardableResult
    func removeSystem<T: PlatformSystem>(_ system: T.Type) -> T? {
        return ecs.removeSystem(system)
    }
}

@MainActor public final class ECSContext {
    /**
     An immutable copy of the View this ECSContext will be drawn into. 
     Use this copy for size and color information from witin your simulation
     */
    public internal(set) var gameView: GameViewSnapshot = .empty
    
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
    public var entities: Set<Entity> = .init(minimumCapacity: 16) {
        didSet {
            self.entitiesDidChange = true
        }
    }
    
    @usableFromInline
    internal var _removedEntities: [Entity] = []

    private var _sortedEntities: [Entity] = []
    @usableFromInline
    func sortedEntities() -> [Entity] {
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

    internal private(set) var performance: Performance? = nil
    func recordPerformance() {
        precondition(performance == nil, "Performance recording was already started!")
        self.performance = Performance()
    }

    public init() {
        
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
        let input = Game.shared.hid
        
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
            await system.willUpdate(input: input, withTimePassed: deltaTime, context: self)
            self.performance?.endCurrentStatistic()
        }
        for system in self.platformSystems {
//            guard type(of: system).phase == .postDeferred else { continue }
            self.performance?.beginStatForSystem(system)
            await system.willUpdate(input: input, withTimePassed: deltaTime, context: self)
            self.performance?.endCurrentStatistic()
        }
        
        let removed = self._removedEntities
        _removedEntities.removeAll(keepingCapacity: true)
        for entity in removed {
            for system in self.systems {
                await system.didRemove(entity: entity, from: self, input: input)
            }
            for system in self.platformSystems {
                await system.didRemove(entity: entity, from: self, input: input)
            }
        }

        // Drop frame if less then 12fps
        let dropFrame: Bool = deltaTime > /* 1/12 */ 0.08333333333
        // Only drop 1 frame before requiring a frame
        let shouldRender: Bool = Game.shared.isHeadless ? false : (previousFrameWasDropped ? true : !dropFrame)

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

    func updateRendering(into view: GameView, deltaTime: Float) {
        if let performance = performance {
            performance.startRenderingSystems()
        }

        for system in self.renderingSystems {
            self.performance?.beginStatForSystem(system)
            system.willRender(into: view, withTimePassed: deltaTime, context: self)
            self.performance?.endCurrentStatistic()
        }
        
        if let performance = performance {
            performance.endRenderingSystems()
            performance.finalizeRenderingSystemsFrameTime()
        }
    }
}

//MARK: Entity Management
public extension ECSContext {
    @inlinable
    func insertEntity(_ entity: Entity) {
        self.entities.insert(entity)
        
        for componentID in entity.componentIDs {
            if let component = entity.componentBank[componentID] {
                if let system = type(of: component).systemThatProcessesThisComponent() {
                    if self.hasSystem(ofType: system) == false {
                        self.insertSystem(system)
                    }
                }
            }
        }
    }
    @inlinable
    func removeEntity(_ entity: Entity) {
        if let entity = self.entities.remove(entity) {
            self._removedEntities.append(entity)
        }
    }
    @inlinable
    func removeEntity(named name: String) -> Entity? {
        if let entity = self.removeEntity(where: { $0.name == name }) {
            self._removedEntities.append(entity)
            return entity
        }
        return nil
    }
    @inlinable
    @discardableResult
    func removeEntity(where block: (Entity) -> (Bool)) -> Entity? {
        if let removed = self.entities.first(where: block) {
            self._removedEntities.append(removed)
            self.entities.remove(removed)
            return removed
        }
        return nil
    }
    @inlinable
    func entity(named name: String) -> Entity? {
        return entities.first(where: { $0.name == name })
    }
    @inlinable
    func entity(withID id: ObjectIdentifier) -> Entity? {
        return entities.first(where: { $0.id == id })
    }
    @inlinable
    func firstEntity(withComponent type: any Component.Type) -> Entity? {
        return entities.first(where: { $0.hasComponent(type) })
    }
}

//MARK: System Management
public extension ECSContext {
    func system<T: System>(ofType systemType: T.Type) -> T {
        for system in _systems {
            if system is T {
                return unsafeDowncast(system, to: systemType)
            }
        }
        return insertSystem(systemType)
    }
    func hasSystem(ofType systemType: System.Type) -> Bool {
        for system in _systems {
            if type(of: system) == systemType {
                return true
            }
        }
        return false
    }
    func system<T: RenderingSystem>(ofType systemType: T.Type) -> T {
        for system in _renderingSystems {
            if system is T {
                return unsafeDowncast(system, to: systemType)
            }
        }
        return insertSystem(systemType)
    }
    internal func system<T: PlatformSystem>(ofType systemType: T.Type) -> T {
        for system in _platformSystems {
            if system is T {
                return unsafeDowncast(system, to: systemType)
            }
        }
        return insertSystem(systemType)
    }
    func insertSystem(_ newSystem: System) {
        let systemType = type(of: newSystem)
        guard _systems.contains(where: { type(of: $0) == systemType }) == false else { return }
        var systems = self._systems
        systems.append(newSystem)
        _systems = systems
        systemsNeedSorting = true
    }
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
    internal func insertSystem(_ newSystem: PlatformSystem) {
        let systemType = type(of: newSystem)
        guard _platformSystems.contains(where: { type(of: $0) == systemType }) == false else {
            return
        }
        var platformSystems = self._platformSystems
        platformSystems.append(newSystem)
        _platformSystems = platformSystems
        platformSystemsNeedSorting = true
    }
    @discardableResult
    func insertSystem<T: System>(_ system: T.Type) -> T {
        let system = system.init()
        self.insertSystem(system)
        return system
    }
    @discardableResult
    func insertSystem<T: RenderingSystem>(_ system: T.Type) -> T {
        let system = system.init()
        self.insertSystem(system)
        return system
    }
    @discardableResult
    internal func insertSystem<T: PlatformSystem>(_ system: T.Type) -> T {
        let system = system.init()
        self.insertSystem(system)
        return system
    }
    func removeSystem(_ system: System) {
        if let index = self._systems.firstIndex(where: { $0 === system }) {
            let system = self._systems.remove(at: index)
            system._teardown(context: self)
        }
    }
    func removeSystem(_ system: RenderingSystem) {
        if let index = self._renderingSystems.firstIndex(where: { $0 === system }) {
            let system = self._renderingSystems.remove(at: index)
            system._teardown(context: self)
        }
    }
    internal func removeSystem(_ system: PlatformSystem) {
        if let index = self._platformSystems.firstIndex(where: { $0 === system }) {
            let system = self._platformSystems.remove(at: index)
            system._teardown(context: self)
        }
    }
    @discardableResult
    func removeSystem<T: System>(_ system: T.Type) -> T? {
        if let index = self._systems.firstIndex(where: { type(of: $0) == system }) {
            let system = self._systems.remove(at: index)
            system.teardown(context: self)
            return system as? T
        }
        return nil
    }
    @discardableResult
    func removeSystem<T: RenderingSystem>(_ system: T.Type) -> T? {
        if let index = self._renderingSystems.firstIndex(where: { type(of: $0) == system }) {
            let system = self._renderingSystems.remove(at: index)
            system.teardown(context: self)
            return system as? T
        }
        return nil
    }
    @discardableResult
    internal func removeSystem<T: PlatformSystem>(_ system: T.Type) -> T? {
        if let index = self._platformSystems.firstIndex(where: { type(of: $0) == system }) {
            let system = self._platformSystems.remove(at: index)
            system.teardown(context: self)
            return system as? T
        }
        return nil
    }
}
