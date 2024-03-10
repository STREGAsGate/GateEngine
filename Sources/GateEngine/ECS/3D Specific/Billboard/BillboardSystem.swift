/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class BillboardSystem: System {
    public override func update(context: ECSContext, input: HID, withTimePassed deltaTime: Float) async {
        guard let camera = game.cameraEntity else {return}
        let cameraTransform = camera.transform3
        
        for entity in game.entities {
            guard let billboardComponent = entity.component(ofType: BillboardComponent.self) else {continue}
            guard let transformComponent = entity.component(ofType: Transform3Component.self) else {continue}
            
            switch billboardComponent.style {
            case .align:
                transformComponent.rotation = cameraTransform.rotation
            case .lookAt(let constraint):
                transformComponent.rotation = Quaternion(
                    lookingAt: cameraTransform.position, 
                    from: transformComponent.position,
                    constraint: constraint,
                    isCamera: false
                )
            }
        }
    }
    
    public override class var phase: System.Phase { .simulation }
    public override nonisolated class func sortOrder() -> SystemSortOrder? { .last }
}
