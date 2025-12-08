/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct Rect: Sendable {
    public var position: Position2
    public var size: Size2
    
    @inlinable
    public init(position: Position2 = .zero, size: Size2) {
        self.position = position
        self.size = size
    }
    
    @inlinable
    public init(size: Size2, center: Position2) {
        self.position = center - size * 0.5
        self.size = size
    }
}

public extension Rect {
    @inlinable
    init(x: Float, y: Float, width: Float, height: Float) {
        self.init(position: Position2(x: x, y: y), size: Size2(width: width, height: height))
    }
    
    @inlinable
    init(_ x: Float, _ y: Float, _ width: Float, _ height: Float) {
        self.init(position: Position2(x: x, y: y), size: Size2(width: width, height: height))
    }
}

extension Rect: Equatable {}
extension Rect: Hashable {}
extension Rect: Codable {}

public extension Rect {
    @inlinable
    var area: Float {
        return size.width * size.height
    }
    // The left side of the rect
    @inlinable
    var x: Float {
        get {
            return position.x
        }
        set(x) {
            position.x = x
        }
    }
    // The top of the rect
    @inlinable
    var y: Float {
        get {
            return position.y
        }
        set(y) {
            position.y = y
        }
    }
    @inlinable
    var width: Float {
        get {
            return size.width
        }
        set(width) {
            size.width = width
        }
    }
    @inlinable
    var height: Float {
        get {
            return size.height
        }
        set(height) {
            size.height = height
        }
    }
}

extension Rect {
    // The left side of the rect
    @inlinable
    public var minX: Float {
        return x
    }
    // The top of the rect
    @inlinable
    public var minY: Float {
        return y
    }
    // The right side of the rect
    @inlinable
    public var maxX: Float {
        return x + width
    }
    // The bottom of the rect
    @inlinable
    public var maxY: Float {
        return y + height
    }
}

extension Rect {
    @inlinable
    public var center: Position2 {
        get {
            return position + size * 0.5
        }
        set(point) {
            position = point - size * 0.5
        }
    }
}

public extension Rect {
    @inlinable
    var isFinite: Bool {
        return position.isFinite && size.isFinite
    }
}

public extension Rect {
    @inlinable
    func interpolated(to: Self, _ method: InterpolationMethod<Float>) -> Self {
        var copy = self
        copy.interpolate(to: to, method)
        return copy
    }
    @inlinable
    mutating func interpolate(to: Self, _ method: InterpolationMethod<Float>) {
        self.position.interpolate(to: to.position, method)
        self.size.interpolate(to: to.size, method)
    }
}

public extension Rect {
    @inlinable
    func inset(by insets: Insets) -> Rect {
        var copy = self
        copy.x += insets.leading
        copy.y += insets.top
        copy.width -= insets.leading + insets.trailing
        copy.height -= insets.top + insets.bottom
        return copy
    }
    
    @inlinable
    func clamped(within rect: Rect) -> Rect {
        var copy = self
        copy.x = max(rect.x, self.x)
        copy.y = max(rect.y, self.y)
        if copy.maxX > rect.maxX {
            copy.width = rect.maxX - copy.x
        }
        if copy.maxY > rect.maxY {
            copy.height = rect.maxY - copy.y
        }
        return copy
    }
}

extension Rect {
    public static let zero = Self(x: 0, y: 0, width: 0, height: 0)
}

extension Rect {
    @inlinable
    public static func * (lhs: Self, rhs: Float) -> Self {
        return Rect(position: lhs.position * rhs, size: lhs.size * rhs)
    }
    @inlinable
    public static func *= (lhs: inout Self, rhs: Float) {
        lhs = lhs * rhs
    }
    
    @inlinable
    public static func / (lhs: Self, rhs: Float) -> Self {
        return Rect(position: lhs.position / rhs, size: lhs.size / rhs)
    }
    @inlinable
    public static func /= (lhs: inout Self, rhs: Float) {
        lhs = lhs / rhs
    }
}
