/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct StateMachine {
    public private(set) var currentState: any State
    
    public init(initialState: any State.Type) {
        self.currentState = initialState.init()
    }
    
    internal mutating func updateState(for entity: Entity, context: ECSContext, input: HID, deltaTime: Float) async {
        await currentState.update(for: entity, inContext: context, input: input, withTimePassed: deltaTime)
        guard await currentState.canMoveToNextState(for: entity, context: context, input: input) else {return}
        
        for state in await currentState.possibleNextStates(for: entity, context: context, input: input) {
            if state.canBecomeCurrentState(for: entity, from: currentState, context: context, input: input) {
                await currentState.willMoveToNextState(for: entity, nextState: state, context: context, input: input)
                let previousState = currentState
                currentState = state.init()
                await currentState.apply(to: entity, previousState: previousState, context: context, input: input)
                await currentState.update(for: entity, inContext: context, input: input, withTimePassed: deltaTime)
                return
            }
        }
    }
}

public protocol State {
    nonisolated init()
    
    func apply(to entity: Entity, previousState: some State, context: ECSContext, input: HID) async
    func update(for entity: Entity, inContext context: ECSContext, input: HID, withTimePassed deltaTime: Float) async
    
    func canMoveToNextState(for entity: Entity, context: ECSContext, input: HID) async -> Bool
    func possibleNextStates(for entity: Entity, context: ECSContext, input: HID) async -> [any State.Type]
    
    func willMoveToNextState(for entity: Entity, nextState: any State.Type, context: ECSContext, input: HID) async
    
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
