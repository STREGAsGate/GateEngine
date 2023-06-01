/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public final class CameraComponent: Component {
    public var isActive: Bool = true
    public var clippingPlane: ClippingPlane = ClippingPlane()
    public var fieldOfView: Degrees = Degrees(65)
    
    required public init() {

    }

    public static let componentID: ComponentID = ComponentID()
}

@MainActor public extension Game {
    var cameraEntity: Entity? {
        return self.entities.first(where: {$0.component(ofType: CameraComponent.self)?.isActive == true})
    }
}
