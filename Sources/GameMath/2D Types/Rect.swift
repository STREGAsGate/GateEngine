/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GameMathUseSIMD
public struct Rect {
    public var position: Position2
    public var size: Size2
    
    @inlinable
    public init(position: Position2 = .zero, size: Size2) {
        self.position = position
        self.size = size
    }
}
#else
public struct Rect {
    public var position: Position2
    public var size: Size2
    
    @inlinable
    public init(position: Position2 = .zero, size: Size2) {
        self.position = position
        self.size = size
    }
}
#endif

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
    @_transparent
    var area: Float {
        return size.width * size.height
    }
    // The left side of the rect
    @_transparent
    var x: Float {
        get {
            return position.x
        }
        set(x) {
            position.x = x
        }
    }
    // The top of the rect
    @_transparent
    var y: Float {
        get {
            return position.y
        }
        set(y) {
            position.y = y
        }
    }
    @_transparent
    var width: Float {
        get {
            return size.width
        }
        set(width) {
            size.width = width
        }
    }
    @_transparent
    var height: Float {
        get {
            return size.height
        }
        set(height) {
            size.height = height
        }
    }
    
    // The right side of the rect
    @_transparent
    var maxX: Float {
        return x + width
    }
    // The bottom of the rect
    @_transparent
    var maxY: Float {
        return y + height
    }
}

extension Rect {
    @_transparent
    public var center: Position2 {
        get {
            return Position2(x: x + width / 2, y: y + height / 2)
        }
        set(point) {
            x = point.x - width / 2
            y = point.y - height / 2
        }
    }
}

public extension Rect {
    @_transparent
    var isFinite: Bool {
        return position.isFinite && size.isFinite
    }
}

public extension Rect {
    @_transparent
    func interpolated(to: Self, _ method: InterpolationMethod) -> Self {
        var copy = self
        copy.interpolate(to: to, method)
        return copy
    }
    @_transparent
    mutating func interpolate(to: Self, _ method: InterpolationMethod) {
        self.position.interpolate(to: to.position, method)
        self.size.interpolate(to: to.size, method)
    }
}

public extension Rect {
    @_transparent
    func inset(by insets: Insets) -> Rect {
        var copy = self
        copy.x += insets.leading
        copy.y += insets.top
        copy.width -= insets.leading + insets.trailing
        copy.height -= insets.top + insets.bottom
        return copy
    }
}

extension Rect {
    public static let zero = Self(x: 0, y: 0, width: 0, height: 0)
}

extension Rect {
    @_transparent
    public static func *=(lhs: inout Self, rhs: Float) {
        lhs = lhs * rhs
    }
    @_transparent
    public static func *(lhs: Self, rhs: Float) -> Self {
        return Rect(position: lhs.position * rhs, size: lhs.size * rhs)
    }
    
    @_transparent
    public static func /=(lhs: inout Self, rhs: Float) {
        lhs = lhs / rhs
    }
    @_transparent
    public static func /(lhs: Self, rhs: Float) -> Self {
        return Rect(position: lhs.position / rhs, size: lhs.size / rhs)
    }
}
