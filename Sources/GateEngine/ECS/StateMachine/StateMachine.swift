/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class StateMachine {
    public private(set) var currentState: any State
    
    public init(initialState: any State.Type) {
        self.currentState = initialState.init()
    }
    
    @MainActor internal func updateState(for entity: Entity, context: ECSContext, input: HID, deltaTime: Float) {
        currentState.update(for: entity, inContext: context, input: input, withTimePassed: deltaTime)
        guard currentState.canMoveToNextState(for: entity, context: context, input: input) else {return}
                
        for state in currentState.possibleNextStates(for: entity, context: context, input: input) {
            if state.canBecomeCurrentState(for: entity, from: currentState, context: context, input: input) {
                currentState.willMoveToNextState(for: entity, nextState: state, context: context, input: input)
                let previousState = currentState
                currentState = state.init()
                currentState.apply(to: entity, previousState: previousState, context: context, input: input)
                currentState.update(for: entity, inContext: context, input: input, withTimePassed: deltaTime)
                return
            }
        }
    }
}

@MainActor public protocol State: AnyObject {
    nonisolated init()
    
    func apply(to entity: Entity, previousState: some State, context: ECSContext, input: HID)
    func update(for entity: Entity, inContext context: ECSContext, input: HID, withTimePassed deltaTime: Float)
    
    func canMoveToNextState(for entity: Entity, context: ECSContext, input: HID) -> Bool
    func possibleNextStates(for entity: Entity, context: ECSContext, input: HID) -> [any State.Type]
    
    func willMoveToNextState(for entity: Entity, nextState: any State.Type, context: ECSContext, input: HID)
    
    static func canBecomeCurrentState(for entity: Entity, from currentState: some State, context: ECSContext, input: HID) -> Bool
}

public extension State {
    func canMoveToNextState(for entity: Entity, context: ECSContext, input: HID) -> Bool {
        return true
    }
    
    func willMoveToNextState(for entity: Entity, nextState: any State.Type, context: ECSContext, input: HID) {
        
    }
    
    static func canBecomeCurrentState(for entity: Entity, from currentState: some State, context: ECSContext, input: HID) -> Bool {
        return true
    }
}
