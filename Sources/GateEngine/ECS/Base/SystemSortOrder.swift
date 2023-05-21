/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct SystemSortOrder: RawRepresentable, ExpressibleByIntegerLiteral {
    public typealias RawValue = Int
    public let rawValue: RawValue
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    public typealias IntegerLiteralType = RawValue
    public init(integerLiteral value: RawValue) {
        self.rawValue = value
    }
    
    /// Sorter after another system
    @inlinable @inline(__always)
    public static func after(_ system: System.Type) -> Self {
        guard let sortOrder = system.sortOrder() else {return Self(rawValue: .min)}
        return Self(rawValue: sortOrder.rawValue + 1)
    }
    
    /// Sorter before another system
    @inlinable @inline(__always)
    public static func before(_ system: System.Type) -> Self? {
        guard let sortOrder = system.sortOrder() else {return nil}
        return Self(rawValue: sortOrder.rawValue - 1)
    }
}

public extension SystemSortOrder {
    static let tileMapSystem: Self      = 0_100
    static let spriteSystem: Self       = 0_200
    
    static let physics2DSystem: Self    = 2_100
    static let collision2DSystem: Self  = 2_200
    
    static let physics3DSystem: Self    = 3_100
    static let colision3DSystem: Self   = 3_200
    
    static let rigSystem: Self          = 4_100
}

public struct RenderingSystemSortOrder: RawRepresentable, ExpressibleByIntegerLiteral {
    public typealias RawValue = Int
    public let rawValue: RawValue
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    public typealias IntegerLiteralType = RawValue
    public init(integerLiteral value: RawValue) {
        self.rawValue = value
    }
    
    /// Sorter after another system
    @inlinable @inline(__always)
    public static func after(_ system: RenderingSystem.Type) -> Self {
        guard let sortOrder = system.sortOrder() else {return Self(rawValue: .min)}
        return Self(rawValue: sortOrder.rawValue + 1)
    }
    
    /// Sorter before another system
    @inlinable @inline(__always)
    public static func before(_ system: RenderingSystem.Type) -> Self? {
        guard let sortOrder = system.sortOrder() else {return nil}
        return Self(rawValue: sortOrder.rawValue - 1)
    }
}

public extension RenderingSystemSortOrder {
    static let standard: Self       = 0_100
    static let performance: Self    = RenderingSystemSortOrder(rawValue: .max)
}
