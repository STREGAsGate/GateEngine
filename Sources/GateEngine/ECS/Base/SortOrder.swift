/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct SystemSortOrder: RawRepresentable, ExpressibleByIntegerLiteral, Sendable {
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
        guard let sortOrder = system.sortOrder() else { return Self(rawValue: .min) }
        return Self(rawValue: sortOrder.rawValue + 1)
    }

    /// Sorter before another system
    @inlinable @inline(__always)
    public static func before(_ system: System.Type) -> Self? {
        guard let sortOrder = system.sortOrder() else { return nil }
        return Self(rawValue: sortOrder.rawValue - 1)
    }
    
    @inlinable @inline(__always)
    public static var last: Self {
        return Self(rawValue: .max)
    }
}

public struct RenderingSystemSortOrder: RawRepresentable, ExpressibleByIntegerLiteral, Sendable {
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
        guard let sortOrder = system.sortOrder() else { return Self(rawValue: .min) }
        return Self(rawValue: sortOrder.rawValue + 1)
    }

    /// Sorter before another system
    @inlinable @inline(__always)
    public static func before(_ system: RenderingSystem.Type) -> Self? {
        guard let sortOrder = system.sortOrder() else { return nil }
        return Self(rawValue: sortOrder.rawValue - 1)
    }
    
    @inlinable @inline(__always)
    public static var last: Self {
        return Self(rawValue: .max)
    }
}

// MARK: - GateEngine Provided System Orders

extension SystemSortOrder {
    public static let tileMapSystem: Self = 0_100
    public static let spriteSystem: Self = 0_200

    public static let physics2DSystem: Self = 2_100
    public static let collision2DSystem: Self = 2_200

    public static let physics3DSystem: Self = 3_100
    public static let collision3DSystem: Self = 3_200

    public static let rigSystem: Self = 4_100
    public static let objectAnimation3DSystem: Self = 4_100
}

extension RenderingSystemSortOrder {
    public static let standard: Self = 0_100
    public static let performance: Self = RenderingSystemSortOrder(rawValue: .max)
}

// MARK: - PlatformSystem

extension PlatformSystemSortOrder {
    // Run before everything
    public static let delaySystem: Self = 0
    
    public static let hidSystem: Self   = 1_001
    public static let audioSystem: Self = 1_002
    public static let cacheSystem: Self = 1_003
   
    // Run after everything
    public static let deferredSystem: Self = 100_000
}

public struct PlatformSystemSortOrder: RawRepresentable, ExpressibleByIntegerLiteral, Sendable {
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
        guard let sortOrder = system.sortOrder() else { return Self(rawValue: .min) }
        return Self(rawValue: sortOrder.rawValue + 1)
    }

    /// Sorter before another system
    @inlinable @inline(__always)
    public static func before(_ system: System.Type) -> Self? {
        guard let sortOrder = system.sortOrder() else { return nil }
        return Self(rawValue: sortOrder.rawValue - 1)
    }
    
    @inlinable @inline(__always)
    public static var last: Self {
        return Self(rawValue: .max)
    }
}
