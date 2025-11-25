/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class StateMachineSystem: System {
    public override func update(context: ECSContext, input: HID, withTimePassed deltaTime: Float) async {
        for entity in context.entities {
            guard let stateMachineComponent = entity.component(ofType: StateMachineComponent.self) else {
                continue
            }
            for index in stateMachineComponent.stateMachines.indices {
                stateMachineComponent.stateMachines[index].updateState(for: entity, context: context, input: input, deltaTime: deltaTime)
            }
        }
    }
    
    // Transition the current state out, so states have a chance to cleanup
    public override func didRemove(entity: Entity, from context: ECSContext, input: HID) async {
        guard let stateMachineComponent = entity.component(ofType: StateMachineComponent.self) else {return}
        
        let state: any State.Type = StateMachineComponent.NoState.self
        for index in stateMachineComponent.stateMachines.indices {
            let previousState = stateMachineComponent.stateMachines[index].currentState
            var currentState: any State {
                return stateMachineComponent.stateMachines[index].currentState
            }
            if var new = state.constructNew(ifSwitchingFrom: previousState, for: entity, context: context, input: input) {
                if currentState.canMoveToNextState(new, for: entity, context: context, input: input) {
                    if new.canBecomeCurrent(from: currentState, for: entity, context: context, input: input) {
                        currentState.willMoveToNextState(new, for: entity, context: context, input: input)
                    }
                }
            }
        }
    }
    
    public override class var phase: System.Phase {return .updating}
}
