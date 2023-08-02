/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Gravity

public struct GravityValue: GravityValueEmitting {
    public var gValue: gravity_value_t

    @usableFromInline
    internal init(gValue: gravity_value_t) {
        self.gValue = gValue
    }

    @usableFromInline
    internal init?(optionalGValue gValue: gravity_value_t) {
        guard gValue.isa != gravity_class_null else { return nil }
        self.init(gValue: gValue)
    }
}

extension GravityValue {
    public static let null = GravityValue(gValue: gravity_value_from_null())
    public static let undefined = GravityValue(gValue: gravity_value_from_undefined())
}

extension GravityValue {
    public enum ValueType {
        case object
        case bool
        case null
        case int
        case float
        case function
        case closure
        case fiber
        case `class`
        case string
        case instance
        case list
        case map
        case module
        case range
        case upvalue
    }

    public var valueType: ValueType {
        switch gValue.isa {
        case gravity_class_object:
            return .object
        case gravity_class_bool:
            return .bool
        case gravity_class_null:
            return .null
        case gravity_class_int:
            return .int
        case gravity_class_float:
            return .float
        case gravity_class_function:
            return .function
        case gravity_class_closure:
            return .closure
        case gravity_class_fiber:
            return .fiber
        case gravity_class_class:
            return .class
        case gravity_class_string:
            return .string
        case gravity_class_instance:
            return .instance
        case gravity_class_list:
            return .list
        case gravity_class_map:
            return .map
        case gravity_class_module:
            return .module
        case gravity_class_range:
            return .range
        case gravity_class_upvalue:
            return .upvalue
        default:
            fatalError()
        }
    }
}

// MARK: - Bool
extension GravityValue {
    @inline(__always)
    public init(_ value: Bool) {
        gValue = gravity_value_from_bool(value)
    }
    @inlinable
    public func getBool() -> Bool {
        return gValue.n != 0
    }
}

// MARK: - Int
extension GravityValue {
    @inline(__always)
    public init<T: BinaryInteger>(_ value: T) {
        gValue = gravity_value_from_int(gravity_int_t(value))
    }
    @inlinable
    public func getInt<T: BinaryInteger>() -> T {
        return T.init(gValue.n)
    }
    @inlinable
    public func getInt() -> Int {
        return Int(gValue.n)
    }

    /**
     Interpreted the value.
     Attempts to convert the value to the return type.
     - returns: An interpreted version of the value.
     */
    @inlinable
    public func asInt() -> Int {
        switch self.valueType {
        case .int:
            return Int(gValue.n)
        case .float:
            return Int(gValue.f)
        case .string:
            if let v = Int(self.string) {
                return v
            }
            fallthrough
        default:
            return unsafeBitCast(gValue.p, to: Int.self)
        }
    }
}

// MARK: - Float
extension GravityValue {
    @inline(__always)
    internal init<T: BinaryFloatingPoint>(_ value: T) {
        let value = gravity_float_t(value)
        if value.isFinite == false {
            gValue = gravity_value_from_undefined()
        } else {
            gValue = gravity_value_from_float(value)
        }
    }

    /**
     Interpreted the value.
     Attempts to convert the value to the return type.
     - returns: An interpreted version of the value.
     */
    @inlinable
    public func asFloat() -> Float {
        switch self.valueType {
        case .float:
            return Float(gValue.f)
        case .int:
            return Float(getInt())
        case .string:
            if let v = Float(self.string) {
                return v
            }
            fallthrough
        default:
            return Float(unsafeBitCast(gValue.p, to: Double.self))
        }
    }

    @inlinable
    public func asDouble() -> Double {
        switch self.valueType {
        case .float:
            return gValue.f
        case .int:
            return Double(getInt())
        case .string:
            if let v = Double(self.string) {
                return v
            }
            fallthrough
        default:
            return unsafeBitCast(gValue.p, to: Double.self)
        }
    }
}

// MARK: - Range
extension GravityValue {
    @inline(__always) @usableFromInline
    internal init(_ value: Range<Int>, _ gravity: Gravity? = nil) {
        let value = gravity_range_new(
            gravity?.vm,
            gravity_int_t(value.lowerBound),
            gravity_int_t(value.upperBound),
            true
        )
        gValue = gravity_value_from_object(value)
    }
    @inlinable
    public func getRange() -> Range<Int> {
        let range = unsafeBitCast(gValue.p, to: UnsafeMutablePointer<gravity_range_t>.self).pointee
        return Int(range.from) ..< Int(range.to)
    }

    @inline(__always) @usableFromInline
    internal init(_ value: ClosedRange<Int>, _ gravity: Gravity? = nil) {
        let value = gravity_range_new(
            gravity?.vm,
            gravity_int_t(value.lowerBound),
            gravity_int_t(value.upperBound),
            true
        )
        gValue = gravity_value_from_object(value)
    }
    @inlinable
    public func getRange() -> ClosedRange<Int> {
        let range = unsafeBitCast(gValue.p, to: UnsafeMutablePointer<gravity_range_t>.self).pointee
        return Int(range.from) ... Int(range.to)
    }

    @inlinable
    public static func ... (lhs: GravityValue, rhs: GravityValue) -> GravityValue {
        let lower = lhs.getInt()
        let upper = rhs.getInt()
        return GravityValue(lower ... upper)
    }
    @inlinable
    public static func ..< (lhs: GravityValue, rhs: GravityValue) -> GravityValue {
        let lower = lhs.getInt()
        let upper = rhs.getInt()
        return GravityValue(lower ..< upper)
    }
}

// MARK: - String
extension GravityValue {
    @inline(__always)
    internal init(_ value: String, _ gravity: Gravity? = nil) {
        self.gValue = value.withCString { cValue in
            return gravity_string_to_value(gravity?.vm, cValue, UInt32(value.utf8.count))
        }
    }
    @inline(__always)
    internal init(_ value: StaticString, _ gravity: Gravity) {
        self.gValue = gravity_string_to_value(
            gravity.vm,
            value.utf8Start,
            UInt32(value.utf8CodeUnitCount)
        )
    }

    @inlinable
    internal var string: String {
        assert(self.valueType == .string)
        let string = unsafeBitCast(gValue.p, to: UnsafeMutablePointer<gravity_string_t>.self)
        return String(cString: string.pointee.s)
    }

    @inlinable
    public func getString() -> String? {
        guard self.valueType == .string else { return nil }
        return self.string
    }

    @inlinable
    public func asString() -> String {
        switch self.valueType {
        case .string:
            return self.string
        default:
            return self.description
        }
    }
}

// MARK: - List
extension GravityValue {
    @inline(__always)
    internal init(_ values: [GravityValue], _ gravity: Gravity? = nil) {
        var values = values.map({ $0.gValue })
        let list = gravity_list_from_array(gravity?.vm, UInt32(values.count), &values)
        self.gValue = gravity_value_from_object(list)
    }

    @inlinable
    internal var array: [GravityValue] {
        assert(self.valueType == .list)
        let list = unsafeBitCast(gValue.p, to: UnsafeMutablePointer<gravity_list_t>.self).pointee
        let array = list.array
        let buffer = UnsafeBufferPointer(start: array.p, count: array.n)
        return Array(buffer.map({ GravityValue(gValue: $0) }))
    }

    @inlinable
    public func getList() -> [GravityValue]? {
        guard valueType == .list else { return nil }
        let a = array
        guard a.isEmpty == false else { return nil }
        return a
    }
}

// MARK: - Map
extension GravityValue {
    @inline(__always)
    internal init(_ values: [GravityValue: GravityValue], _ gravity: Gravity? = nil) {
        let map = gravity_map_new(gravity?.vm, UInt32(values.count))
        for pair in values {
            gravity_map_insert(gravity?.vm, map, pair.key.gValue, pair.value.gValue)
        }
        self.gValue = gravity_value_from_object(map)
    }
    @inline(__always) @usableFromInline
    internal func getMap() -> [GravityValue: GravityValue] {
        assert(valueType == .map, "Expected \"map\" but found \"\(valueType)\".")
        let map = unsafeBitCast(gValue.p, to: UnsafeMutablePointer<gravity_map_t>.self).pointee
        let hash = map.hash
        var dict = [GravityValue: GravityValue](minimumCapacity: Int(gravity_hash_count(hash)))
        gravity_hash_iterate(
            hash,
            { hash, key, value, dictp in
                let dict = dictp!.assumingMemoryBound(
                    to: Dictionary<GravityValue, GravityValue>.self
                )
                dict.pointee[GravityValue(gValue: key)] = GravityValue(gValue: value)
            },
            &dict
        )
        return dict
    }
}

// MARK: - Closure
extension GravityValue {
    @inline(__always)
    public func getClosure(
        gravity: Gravity,
        sender: (any GravityValueConvertible)?
    ) -> GravityClosure? {
        guard valueType == .closure else {
            assert(
                valueType == .null,
                "Gravity: Expected \"closure\" but found \"\(valueType)\". Check your spelling."
            )
            return nil
        }
        let closure = unsafeBitCast(gValue.p, to: UnsafeMutablePointer<gravity_closure_t>.self)
        return GravityClosure(gravity: gravity, closure: closure, sender: sender)
    }
}

// MARK: - Class
extension GravityValue {
    @inline(__always)
    public func getClass(gravity: Gravity) -> GravityClass? {
        guard valueType == .class else {
            assert(
                valueType == .null,
                "Gravity: Expected \"class\" but found \"\(valueType)\". Check your spelling."
            )
            return nil
        }
        return GravityClass(value: self, gravity: gravity)
    }
}

// MARK: - Instance
extension GravityValue {
    @inline(__always)
    public func getInstance(gravity: Gravity) -> GravityInstance? {
        guard valueType == .instance else {
            assert(
                valueType == .null,
                "Gravity: Expected \"instance\" but found \"\(valueType)\". Check your spelling."
            )
            return nil
        }
        return GravityInstance(value: self, gravity: gravity)
    }
}

extension GravityValue: CustomStringConvertible {
    public var description: String {
        let valueType = self.valueType
        switch valueType {
        case .null:
            return "null"
        case .int:
            return "\(self.getInt())"
        case .float:
            return "\(self.asDouble())"
        case .range:
            return "\(self.getRange() as Range<Int>)"
        case .string:
            return self.string
        case .bool:
            return "\(self.getBool())"
        case .list:
            return "\(self.array)"
        case .map:
            return "\(self.getMap())"
        default:
            return "\(valueType)"
        }
    }
}

extension GravityValue: CustomDebugStringConvertible {
    @inlinable
    public var debugDescription: String {
        return description
    }
}

extension GravityValue: CustomReflectable {
    public var customMirror: Mirror {
        switch valueType {
        case .null:
            return Mirror(reflecting: ())
        case .int:
            return Mirror(reflecting: self.getInt())
        case .float:
            return Mirror(reflecting: self.asDouble())
        case .string:
            return Mirror(reflecting: self.string)
        case .bool:
            return Mirror(reflecting: self.getBool())
        case .list:
            return Mirror(reflecting: self.array)
        case .map:
            return Mirror(reflecting: self.getMap())
        default:
            return Mirror(reflecting: self)
        }
    }
}

extension GravityValue: Equatable {
    @inline(__always)
    public static func == (lhs: GravityValue, rhs: GravityValue) -> Bool {
        return gravity_value_equals(lhs.gValue, rhs.gValue)
    }
}

extension GravityValue: Hashable {
    @inline(__always)
    public func hash(into hasher: inout Hasher) {
        hasher.combine(gValue.n)
        hasher.combine(gValue.f)
        hasher.combine(gValue.p)
        hasher.combine(gValue.isa)
    }
}

extension GravityValue: ExpressibleByNilLiteral {
    @inline(__always)
    public init(nilLiteral: ()) {
        self.gValue = Self.null.gValue
    }
}

extension GravityValue: ExpressibleByBooleanLiteral {
    public typealias BooleanLiteralType = Bool
    @inline(__always)
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
}

extension GravityValue: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int
    @inline(__always)
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

extension GravityValue: ExpressibleByFloatLiteral {
    #if arch(i386) || arch(arm) || arch(wasm32)  // 32bit target
    public typealias FloatLiteralType = Float
    #else
    public typealias FloatLiteralType = Double  // 64bit target
    #endif
    @inline(__always)
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
}

extension GravityValue: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    @inline(__always)
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}

extension GravityValue: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = GravityValue
    @inline(__always)
    public init(arrayLiteral elements: GravityValue...) {
        self.init(elements)
    }
}

extension GravityValue: ExpressibleByDictionaryLiteral {
    public typealias Key = GravityValue
    public typealias Value = GravityValue
    @inline(__always)
    public init(dictionaryLiteral elements: (GravityValue, GravityValue)...) {
        self.init(Dictionary(uniqueKeysWithValues: elements))
    }
}
