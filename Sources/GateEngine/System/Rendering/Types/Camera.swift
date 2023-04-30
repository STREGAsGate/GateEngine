/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public class Camera {
    public var transform: Transform3 {
        didSet {
            needsUpdateTransform = true
        }
    }
    public var fieldOfView: Degrees {
        @inlinable get {return Degrees(_fieldOfView)}
        @inlinable set {self._fieldOfView = Radians(newValue)}
    }
    public var clippingPlane: ClippingPlane {
        didSet {
            needsUpdateProjection = true
        }
    }

    @usableFromInline internal var _fieldOfView: Radians {
        didSet {
            needsUpdateProjection = true
        }
    }
    
    public init(transform: Transform3 = .default, fieldOfView: Degrees = Degrees(70), clippingPlane: ClippingPlane = ClippingPlane()) {
        self._fieldOfView = Radians(fieldOfView)
        self.transform = transform
        self.clippingPlane = clippingPlane
    }
    
    public convenience init?(_ entity: Entity?) {
        guard let entity = entity else {return nil}
        guard let transformComponent = entity.component(ofType: Transform3Component.self) else {return nil}
        guard let cameraComponent = entity.component(ofType: CameraComponent.self) else {return nil}
        self.init(transform: transformComponent.transform, fieldOfView: cameraComponent.fieldOfView, clippingPlane: cameraComponent.clippingPlane)
    }
    
    private var needsUpdateTransform = true
    private var needsUpdateProjection = true
    
    private var aspect: Float = .nan
    private var persepective: Matrix4x4 = .identity
    private var view: Matrix4x4 = .identity
    private static let viewScale = Matrix4x4(scale: Size3(width: 1.0, height: 1.0, depth: -1.0))
    private var matrices: Matrices = Matrices(projection: .identity)

    public func matricies(withAspectRatio aspect: Float) -> Matrices {
        guard self.needsUpdateTransform || self.needsUpdateProjection else {return matrices}
        
        if needsUpdateProjection || self.aspect != aspect {
            self.needsUpdateProjection = false
            self.aspect = aspect
            self.persepective = Matrix4x4(perspectiveWithFOV: _fieldOfView.rawValue,
                                          aspect: aspect,
                                          near: clippingPlane.near,
                                          far: clippingPlane.far)
        }
        
        if needsUpdateTransform {
            needsUpdateTransform = false
            let position = Matrix4x4(position: transform.position * -1.0)
            let rotation = Matrix4x4(rotation: transform.rotation.conjugate)
            self.view = Self.viewScale * rotation * position
        }

        self.matrices = Matrices(projection: self.persepective, view: self.view)
        
        return matrices
    }
}

public struct ClippingPlane {
    public var near: Float
    public var far: Float
    public var length: Float {
        return far - near
    }
    public static let minPerspectiveNear: Float = 1 / Float(UInt8.max)
    
    internal init(_ range: ClosedRange<Float>) {
        self.near = range.lowerBound
        self.far = range.upperBound
    }
    internal init(_ range: Range<Float>) {
        if range.lowerBound == 0 {
            self.near = range.lowerBound
        }else{
            self.near = range.lowerBound
        }
        self.far = range.upperBound - Float.leastNormalMagnitude
    }
    internal init(_ range: PartialRangeThrough<Float>) {
        self.near = Self.minPerspectiveNear
        self.far = range.upperBound
    }
    internal init(_ range: PartialRangeUpTo<Float>) {
        self.near = Self.minPerspectiveNear
        self.far = range.upperBound - Float.leastNormalMagnitude
    }
    internal init(_ range: PartialRangeFrom<Float>) {
        self.near = range.lowerBound
        self.far = Float.greatestFiniteMagnitude
    }

    public init() {
        self.near = Self.minPerspectiveNear
        self.far = 1000
    }
}
