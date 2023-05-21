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
}

public extension RenderingSystemSortOrder {
    static let standard: Self       = 0_100
    static let performance: Self    = RenderingSystemSortOrder(rawValue: .max)
}
