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
    
    internal func updateState(for entity: Entity, game: Game, deltaTime: Double) {
        currentState.update(for: entity, inGame: game, withTimePassed: deltaTime)
        guard currentState.canMoveToNextState(for: entity, game: game) else {return}
                
        for state in currentState.possibleNextStates(for: entity, game: game) {
            if state.canBecomeCurrentState(for: entity, from: currentState, game: game) {
                currentState.willMoveToNextState(for: entity, nextState: state, game: game)
                let previousState = currentState
                currentState = state.init()
                print("State Switched:", type(of: currentState))
                currentState.apply(to: entity, previousState: previousState, game: game)
                currentState.update(for: entity, inGame: game, withTimePassed: deltaTime)
                return
            }
        }
    }
}

public protocol State: AnyObject {
    init()
    
    func apply(to entity: Entity, previousState: any State, game: Game)
    func update(for entity: Entity, inGame game: Game, withTimePassed deltaTime: Double)
    
    func canMoveToNextState(for entity: Entity, game: Game) -> Bool
    func possibleNextStates(for entity: Entity, game: Game) -> [any State.Type]
    
    func willMoveToNextState(for entity: Entity, nextState: any State.Type, game: Game)
    
    static func canBecomeCurrentState(for entity: Entity, from currentState: any State, game: Game) -> Bool
}

public extension State {
    func canMoveToNextState(for entity: Entity, game: Game) -> Bool {
        return true
    }
    
    func willMoveToNextState(for entity: Entity, nextState: any State.Type, game: Game) {
        
    }
    
    static func canBecomeCurrentState(for entity: Entity, from currentState: any State, game: Game) -> Bool {
        return true
    }
}
