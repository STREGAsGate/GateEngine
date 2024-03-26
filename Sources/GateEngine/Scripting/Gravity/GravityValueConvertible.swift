/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Gravity

@MainActor
public protocol GravityValueConvertible {
    var gravityValue: GravityValue { get }
}

extension Bool: GravityValueConvertible {
    public var gravityValue: GravityValue { GravityValue(self) }
}

extension Int: GravityValueConvertible {
    public var gravityValue: GravityValue { GravityValue(self) }
}
extension Int8: GravityValueConvertible {
    public var gravityValue: GravityValue { GravityValue(self) }
}
extension Int16: GravityValueConvertible {
    public var gravityValue: GravityValue { GravityValue(self) }
}
extension Int32: GravityValueConvertible {
    public var gravityValue: GravityValue { GravityValue(self) }
}
extension Int64: GravityValueConvertible {
    public var gravityValue: GravityValue { GravityValue(self) }
}

extension UInt: GravityValueConvertible {
    public var gravityValue: GravityValue { GravityValue(self) }
}
extension UInt8: GravityValueConvertible {
    public var gravityValue: GravityValue { GravityValue(self) }
}
extension UInt16: GravityValueConvertible {
    public var gravityValue: GravityValue { GravityValue(self) }
}
extension UInt32: GravityValueConvertible {
    public var gravityValue: GravityValue { GravityValue(self) }
}
extension UInt64: GravityValueConvertible {
    public var gravityValue: GravityValue { GravityValue(self) }
}

extension Float: GravityValueConvertible {
    public var gravityValue: GravityValue { GravityValue(self) }
}

extension Double: GravityValueConvertible {
    public var gravityValue: GravityValue { GravityValue(self) }
}

extension String: GravityValueConvertible {
    public var gravityValue: GravityValue { GravityValue(self) }
}

extension Array: GravityValueConvertible where Element == any GravityValueConvertible {
    public var gravityValue: GravityValue { GravityValue(self.map({ $0.gravityValue })) }
}

extension GravityValue: GravityValueConvertible {
    public var gravityValue: GravityValue { self }
}

extension GravityClass: GravityValueConvertible {
    public var gravityValue: GravityValue { GravityValue(gValue: self.gValue) }
}

extension GravityInstance: GravityValueConvertible {
    public var gravityValue: GravityValue { GravityValue(gValue: self.gValue) }
}

extension GravityClosure: GravityValueConvertible {
    public var gravityValue: GravityValue { GravityValue(gValue: self.gValue) }
}
