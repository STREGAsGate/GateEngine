/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class StateMachineComponent: Component {
    public var stateMachine: StateMachine
    internal var shouldApplyInitialState: Bool = true

    @inlinable @inline(__always)
    public var currentState: any State {
        return stateMachine.currentState
    }
    
    final class NoState: State {
        init() { }
        func apply(to entity: Entity, previousState: some State, game: Game, input: HID) { }
        func update(for entity: Entity, inGame game: Game, input: HID, withTimePassed deltaTime: Float) { }
        func possibleNextStates(for entity: Entity, game: Game, input: HID) -> [any State.Type] {
            return []
        }
    }
    
    public init() {
        self.stateMachine = StateMachine(initialState: NoState.self)
    }
    
    public init(initialState: any State.Type) {
        self.stateMachine = StateMachine(initialState: initialState)
    }
    
    public static let componentID: ComponentID = ComponentID()
}
