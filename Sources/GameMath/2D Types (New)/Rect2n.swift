/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public typealias Rect2i = Rect2n<Int>
public typealias Rect2f = Rect2n<Float>

@frozen
public struct Rect2n<Scalar: Vector2n.ScalarType> {
    public var origin: Position2n<Scalar>
    public var size: Size2n<Scalar>
    
    @inlinable
    public init(origin: Position2n<Scalar>, size: Size2n<Scalar>) {
        self.origin = origin
        self.size = size
    }
    
    @inlinable
    public init(size: Size2n<Scalar>, center: Position2n<Scalar>) where Scalar: BinaryFloatingPoint {
        self.origin = center - (size / 2)
        self.size = size
    }
}

extension Rect2n where Scalar: FixedWidthInteger {
    @inlinable
    public var center: Position2n<Scalar> {
        get {
            return origin + (size / 2)
        }
        mutating set {
            self.origin = newValue - (size / 2)
        }
    }
}

extension Rect2n where Scalar: FloatingPoint {
    @inlinable
    public var center: Position2n<Scalar> {
        get {
            return origin + (size / 2)
        }
        mutating set {
            self.origin = newValue - (size / 2)
        }
    }
}
extension Rect2n {
    @inlinable
    public var min: Position2n<Scalar> {
        return self.origin
    }
    
    @inlinable
    public var max: Position2n<Scalar> {
        return self.origin + self.size
    }
}

extension Rect2n {
    @_transparent
    public var x: Scalar {
        get {
            return origin.x
        }
        mutating set {
            origin.x = newValue
        }
    }
    @_transparent
    public var y: Scalar {
        get {
            return origin.y
        }
        mutating set {
            origin.y = newValue
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

extension Rect2n where Scalar: Comparable {
    /// `true` if `rhs` is inside `self`
    public func contains(_ rhs: Position2n<Scalar>, withThreshold threshold: Scalar = 0) -> Bool {
        let min = self.min - threshold
        guard rhs.x >= min.x && rhs.y >= min.y else {return false}
        
        let max = self.max + threshold
        guard rhs.x < max.x && rhs.y < max.y else {return false}
        
        return true
    }

    public func nearestSurfacePosition(to point: Position2n<Scalar>) -> Position2n<Scalar> {
        return point.clamped(from: self.min, to: self.max)
    }
}


// MARK: - Common Protocol Conformances
extension Rect2n: Equatable where Scalar: Equatable { }
extension Rect2n: Hashable where Scalar: Hashable { }
extension Rect2n: Sendable where Scalar: Sendable { }
extension Rect2n: Codable where Scalar: Codable { }
extension Rect2n: BitwiseCopyable where Scalar: BitwiseCopyable { }
extension Rect2n: BinaryCodable where Self: BitwiseCopyable { }
