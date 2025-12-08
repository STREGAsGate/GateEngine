/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public typealias Rect2i = Rect2n<Int>
public typealias Rect2f = Rect2n<Float>

public struct Rect2n<Scalar: Vector2n.ScalarType> {
    public var position: Position2n<Scalar>
    public var size: Size2n<Scalar>
    
    @inlinable
    public init(position: Position2n<Scalar>, size: Size2n<Scalar>) {
        self.position = position
        self.size = size
    }
    
    @inlinable
    public init(size: Size2n<Scalar>, center: Position2n<Scalar>) where Scalar: BinaryFloatingPoint {
        self.position = center - size * Size2n<Scalar>(width: 0.5, height: 0.5)
        self.size = size
    }
}

extension Rect2n {
    @_transparent
    public var x: Scalar {
        get {
            return position.x
        }
        mutating set {
            position.x = newValue
        }
    }
    @_transparent
    public var y: Scalar {
        get {
            return position.y
        }
        mutating set {
            position.y = newValue
        }
    }
    @_transparent
    public var width: Scalar {
        get {
            return size.width
        }
        mutating set {
            size.width = newValue
        }
    }
    @_transparent
    public var height: Scalar {
        get {
            return size.height
        }
        mutating set {
            size.height = newValue
        }
    }
}
