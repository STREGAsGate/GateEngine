/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class StateMachineComponent: Component {
    public var stateMachine: StateMachine
    internal var shouldApplyInitialState: Bool = true

    public var currentState: any State {
        return stateMachine.currentState
    }
    
    public init() {
        final class NoState: State {
            init() { }
            func apply(to entity: Entity, previousState: any State, game: Game, input: HID) { }
            func update(for entity: Entity, inGame game: Game, input: HID, withTimePassed deltaTime: Double) { }
            func possibleNextStates(for entity: Entity, game: Game, input: HID) -> [any State.Type] {
                return []
            }
        }
        self.stateMachine = StateMachine(initialState: NoState.self)
    }
    
    public init(initialState: any State.Type) {
        self.stateMachine = StateMachine(initialState: initialState)
    }
    public static let componentID: ComponentID = ComponentID()
}
