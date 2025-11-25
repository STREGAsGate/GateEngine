/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct StateMachine {
    public internal(set) var currentState: any State
    
    public init(initialState: any State.Type) {
        self.currentState = InitState(initialState: initialState)
    }
    
    private struct InitState: State {
        nonisolated(unsafe) let initialState: any State.Type
        nonisolated init(initialState: any State.Type) {
            self.initialState = initialState
        }
        func possibleNextStates(for entity: Entity, context: ECSContext, input: HID) -> [any State.Type] {
            return [initialState]
        }
        init() {fatalError()}
    }
    
    @MainActor
    internal mutating func updateState(for entity: Entity, context: ECSContext, input: HID, deltaTime: Float) {
        currentState.update(for: entity, inContext: context, input: input, withTimePassed: deltaTime)
        guard currentState.canChangeState(for: entity, context: context, input: input) else {return}
        
        let previousState = currentState
        for state in currentState.possibleNextStates(for: entity, context: context, input: input) {
            if var new = state.constructNew(ifSwitchingFrom: previousState, for: entity, context: context, input: input) {
                if currentState.canMoveToNextState(new, for: entity, context: context, input: input) {
                    if new.canBecomeCurrent(from: currentState, for: entity, context: context, input: input) {
                        currentState.willMoveToNextState(new, for: entity, context: context, input: input)
                        currentState = new
                        currentState.didBecomeCurrent(from: previousState, for: entity, context: context, input: input)
                        currentState.update(for: entity, inContext: context, input: input, withTimePassed: deltaTime)
                        return
                    }
                }
            }
        }
    }
}

@MainActor
public protocol State {
    nonisolated init()
    
    mutating func canBecomeCurrent(from currentState: some State, for entity: Entity, context: ECSContext, input: HID) -> Bool
    mutating func didBecomeCurrent(from previousState: some State, for entity: Entity, context: ECSContext, input: HID)
    
    mutating func update(for entity: Entity, inContext context: ECSContext, input: HID, withTimePassed deltaTime: Float)
    
    mutating func canChangeState(for entity: Entity, context: ECSContext, input: HID) -> Bool
    mutating func possibleNextStates(for entity: Entity, context: ECSContext, input: HID) -> [any State.Type]
    
    mutating func canMoveToNextState(_ nextState: some State, for entity: Entity, context: ECSContext, input: HID) -> Bool
    mutating func willMoveToNextState(_ nextState: some State, for entity: Entity, context: ECSContext, input: HID)
    
    static func constructNew(ifSwitchingFrom currentState: some State, for entity: Entity, context: ECSContext, input: HID) -> Self?
}

public extension State {
    func canBecomeCurrent(from currentState: some State, for entity: Entity, context: ECSContext, input: HID) -> Bool {
        return true
    }
    
    func didBecomeCurrent(from previousState: some State, for entity: Entity, context: ECSContext, input: HID) {
        
    }
    
    func update(for entity: Entity, inContext context: ECSContext, input: HID, withTimePassed deltaTime: Float) {
        
    }
    
    func canChangeState(for entity: Entity, context: ECSContext, input: HID) -> Bool {
        return true
    }
    
    func canMoveToNextState(_ nextState: some State, for entity: Entity, context: ECSContext, input: HID) -> Bool {
        return true
    }
    
    func willMoveToNextState(_ nextState: some State, for entity: Entity, context: ECSContext, input: HID) {
        
    }
    
    static func constructNew(ifSwitchingFrom currentState: some State, for entity: Entity, context: ECSContext, input: HID) -> Self? {
        var new = self.init()
        if new.canBecomeCurrent(from: currentState, for: entity, context: context, input: input) {
            return new
        }
        return nil
    }
}
