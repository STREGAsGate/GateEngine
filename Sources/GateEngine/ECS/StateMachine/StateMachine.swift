/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class StateMachine {
    public private(set) var currentState: any State
    
    public init(initialState: any State.Type) {
        self.currentState = initialState.init()
    }
    
    @MainActor internal func updateState(for entity: Entity, game: Game, input: HID, deltaTime: Float) {
        currentState.update(for: entity, inGame: game, input: input, withTimePassed: deltaTime)
        guard currentState.canMoveToNextState(for: entity, game: game, input: input) else {return}
                
        for state in currentState.possibleNextStates(for: entity, game: game, input: input) {
            if state.canBecomeCurrentState(for: entity, from: currentState, game: game, input: input) {
                currentState.willMoveToNextState(for: entity, nextState: state, game: game, input: input)
                let previousState = currentState
                currentState = state.init()
                currentState.apply(to: entity, previousState: previousState, game: game, input: input)
                currentState.update(for: entity, inGame: game, input: input, withTimePassed: deltaTime)
                return
            }
        }
    }
}

public protocol State: AnyObject {
    init()
    
    @MainActor func apply(to entity: Entity, previousState: some State, game: Game, input: HID)
    @MainActor func update(for entity: Entity, inGame game: Game, input: HID, withTimePassed deltaTime: Float)
    
    @MainActor func canMoveToNextState(for entity: Entity, game: Game, input: HID) -> Bool
    @MainActor func possibleNextStates(for entity: Entity, game: Game, input: HID) -> [any State.Type]
    
    @MainActor func willMoveToNextState(for entity: Entity, nextState: any State.Type, game: Game, input: HID)
    
    @MainActor static func canBecomeCurrentState(for entity: Entity, from currentState: some State, game: Game, input: HID) -> Bool
}

public extension State {
    func canMoveToNextState(for entity: Entity, game: Game, input: HID) -> Bool {
        return true
    }
    
    func willMoveToNextState(for entity: Entity, nextState: any State.Type, game: Game, input: HID) {
        
    }
    
    static func canBecomeCurrentState(for entity: Entity, from currentState: some State, game: Game, input: HID) -> Bool {
        return true
    }
}
