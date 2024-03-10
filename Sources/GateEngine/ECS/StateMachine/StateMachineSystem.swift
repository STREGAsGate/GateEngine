/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class StateMachineSystem: System {
    public override func update(context: ECSContext, input: HID, withTimePassed deltaTime: Float) async {
        for entity in game.entities {
            guard let stateMachineComponent = entity.component(ofType: StateMachineComponent.self) else {
                continue
            }
            if stateMachineComponent.shouldApplyInitialState {
                applyInitialStateIfNeeded(for: stateMachineComponent, of: entity, inGame: game, input: input)
            }
            stateMachineComponent.stateMachine.updateState(for: entity, game: game, input: input, deltaTime: deltaTime)
        }
    }
    
    func applyInitialStateIfNeeded(for component: StateMachineComponent, of entity: Entity, inGame game: Game, input: HID) {
        component.stateMachine.currentState.apply(to: entity, previousState: component.stateMachine.currentState, game: game, input: input)
        component.shouldApplyInitialState = false
    }
    
    
    public override func didRemove(entity: Entity, from context: ECSContext, input: HID) async {
        guard let stateMachineComponent = entity.component(ofType: StateMachineComponent.self) else {
            return
        }
        stateMachineComponent.stateMachine.currentState.willMoveToNextState(
            for: entity,
            nextState: StateMachineComponent.NoState.self,
            game: game,
            input: input
        )
    }
    
    public override class var phase: System.Phase {return .updating}
}
