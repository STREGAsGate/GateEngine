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
            if stateMachineComponent.shouldApplyInitialState {
                await applyInitialStateIfNeeded(for: stateMachineComponent, of: entity, inContext: context, input: input)
            }
            stateMachineComponent.stateMachine.updateState(for: entity, context: context, input: input, deltaTime: deltaTime)
        }
    }
    
    func applyInitialStateIfNeeded(for component: StateMachineComponent, of entity: Entity, inContext context: ECSContext, input: HID) async {
        component.stateMachine.currentState.apply(to: entity, previousState: component.stateMachine.currentState, context: context, input: input)
        component.shouldApplyInitialState = false
    }
    
    public override func didRemove(entity: Entity, from context: ECSContext, input: HID) async {
        guard let stateMachineComponent = entity.component(ofType: StateMachineComponent.self) else {
            return
        }
        stateMachineComponent.stateMachine.currentState.willMoveToNextState(
            for: entity,
            nextState: StateMachineComponent.NoState.self,
            context: context,
            input: input
        )
    }
    
    public override class var phase: System.Phase {return .updating}
}
