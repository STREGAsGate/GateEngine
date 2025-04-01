/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

 protocol Vector3SIMD {
    associatedtype Scalar: SIMDScalar
    
    var x: Scalar {get set}
    var y: Scalar {get set}
    var z: Scalar {get set}
    init(_ x: Scalar, _ y: Scalar, _ z: Scalar)
    
    static var zero: Self {get}
}

struct Position3i: Vector3SIMD {
    public typealias Scalar = Int
    public var simd: SIMD3<Scalar>
    
    @inlinable
    public subscript(index: Int) -> Scalar {
        get {
            return simd[index]
        }
        set(newValue) {
            simd[index] = newValue
        }
    }
    
    public init(_ x: Scalar, _ y: Scalar, _ z: Scalar) {
        self.simd = SIMD3(x, y, z)
    }
    
    public init() {
        self.simd = .zero
    }
        
    @inlinable
    public var x: Scalar {
        get {
            return simd.x
        }
        set {
            simd.x = newValue
        }
    }
    @inlinable
    public var y: Scalar {
        get {
            return simd.y
        }
        set {
            simd.y = newValue
        }
    }
    @inlinable
    public var z: Scalar {
        get {
            return simd.z
        }
        set {
            simd.z = newValue
        }
    }
    
    public static let zero: Position3i = .init()
}
