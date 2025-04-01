/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

@dynamicMemberLookup
public final class CameraComponent: Component {
    @usableFromInline
    internal var _camera: Camera = Camera(fieldOfView: .perspective(60°), clippingPlane: ClippingPlane())
    
    public var isActive: Bool = true
    
    required public init() {
        
    }
    
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Camera, T>) -> T {
        @inlinable
        get {
            assert(keyPath != \Camera.transform, "CameraComponent.transform cannot be used. Add a Transform3Component to the camera entity.")
            return _camera[keyPath: keyPath]
        }
        @inlinable
        set {
            assert(keyPath != \Camera.transform, "CameraComponent.transform cannot be used. Add a Transform3Component to the camera entity.")
            _camera[keyPath: keyPath] = newValue
        }
    }
    
    public static let componentID: ComponentID = ComponentID()
}

@MainActor 
extension ECSContext {
    public var cameraEntity: Entity? {
        return self.entities.first(where: {
            return $0.component(ofType: CameraComponent.self)?.isActive == true
        })
    }
}
