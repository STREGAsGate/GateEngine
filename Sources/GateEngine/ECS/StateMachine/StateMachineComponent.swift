/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class StateMachineComponent: Component {
    public var stateMachines: [StateMachine]
    
    @inlinable
    public var currentState: any State {
        return stateMachines[0].currentState
    }
    
    /// A blank state that does nothing
    internal struct NoState: State {
        public init() { }
        public func possibleNextStates(for entity: Entity, context: ECSContext, input: HID) -> [any State.Type] {
            return []
        }
    }
    
    public init() {
        self.stateMachines = [StateMachine(initialState: NoState.self)]
    }
    
    public init(initialState: any State.Type) {
        self.stateMachines = [StateMachine(initialState: initialState)]
    }
    
    public static let componentID: ComponentID = ComponentID()
}
