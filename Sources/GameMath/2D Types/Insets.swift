/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct Insets {
    public var top: Float
    public var leading: Float
    public var bottom: Float
    public var trailing: Float
    
    @inlinable
    public init(_ value: Float) {
        self.top = value
        self.leading = value
        self.bottom = value
        self.trailing = value
    }
    
    @inlinable
    public init(top: Float, leading: Float, bottom: Float, trailing: Float) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }
}

extension Insets: Equatable {}
extension Insets: Hashable {}
extension Insets: Codable {}

public extension Insets {
    static let zero = Insets(top: 0, leading: 0, bottom: 0, trailing: 0)
}

public extension Insets {
    @_transparent
    static func *(lhs: Self, rhs: Float) -> Self {
        return Insets(top: lhs.top * rhs, leading: lhs.leading * rhs, bottom: lhs.bottom * rhs, trailing: lhs.trailing * rhs)
    }
    @_transparent
    static func *=(lhs: inout Self, rhs: Float) {
        lhs = lhs * rhs
    }
}

public extension Insets {
    @_transparent
    static func /(lhs: Self, rhs: Float) -> Self {
        return Insets(top: lhs.top / rhs, leading: lhs.leading / rhs, bottom: lhs.bottom / rhs, trailing: lhs.trailing / rhs)
    }
    @_transparent
    static func /=(lhs: inout Self, rhs: Float) {
        lhs = lhs / rhs
    }
}
