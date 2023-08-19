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
        guard let sortOrder = system.sortOrder() else { return Self(rawValue: .min) }
        return Self(rawValue: sortOrder.rawValue + 1)
    }

    /// Sorter before another system
    @inlinable @inline(__always)
    public static func before(_ system: System.Type) -> Self? {
        guard let sortOrder = system.sortOrder() else { return nil }
        return Self(rawValue: sortOrder.rawValue - 1)
    }
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
        guard let sortOrder = system.sortOrder() else { return Self(rawValue: .min) }
        return Self(rawValue: sortOrder.rawValue + 1)
    }

    /// Sorter before another system
    @inlinable @inline(__always)
    public static func before(_ system: RenderingSystem.Type) -> Self? {
        guard let sortOrder = system.sortOrder() else { return nil }
        return Self(rawValue: sortOrder.rawValue - 1)
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
}

extension RenderingSystemSortOrder {
    public static let standard: Self = 0_100
    public static let performance: Self = RenderingSystemSortOrder(rawValue: .max)
}

// MARK: - PlatformSystem

extension PlatformSystemSortOrder {
    public static let hidSystem: Self = 1_000

    public static let audioSystem: Self = 0_001
    public static let cacheSystem: Self = 1_002
    public static let deferredSystem: Self = 100_000
}

public struct PlatformSystemSortOrder: RawRepresentable, ExpressibleByIntegerLiteral {
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
}
