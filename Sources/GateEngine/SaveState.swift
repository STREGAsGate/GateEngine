/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation
import GameMath

/**
 Recommended values for game state storage conform to this protocol.
 
 It is not recommended, but you may add this protocol to other vlaue types.
 The value types chosen were chosen for long term, cross platform, and cloud service support.
 */

public protocol StateIntegerValue: BinaryInteger {}
extension Int: StateIntegerValue {}
// UInt won't fit in the integer storge
// extension UInt: StateIntegerValue {}
extension Int8: StateIntegerValue {}
extension UInt8: StateIntegerValue {}
extension Int16: StateIntegerValue {}
extension UInt16: StateIntegerValue {}
extension Int32: StateIntegerValue {}
extension UInt32: StateIntegerValue {}
extension Int64: StateIntegerValue {}
// UInt64 won't fit in the integer storge
// extension UInt64: StateIntegerValue {}

/**
 Recommended values for game state storage conform to this protocol.
 
 It is not recommended, but you may add this protocol to other vlaue types.
 The value types chosen were chosen for long term, cross platform, and cloud service support.
 */
public protocol StateFloatingPointValue: BinaryFloatingPoint {}
extension Float: StateFloatingPointValue {}
extension Double: StateFloatingPointValue {}

/**
 Recommended values for game state storage conform to this protocol.
 
 It is not recommended, but you may add this protocol to other vlaue types.
 The value types chosen were chosen for long term, cross platform, and cloud service support.
 */
public protocol StateCodableValue: Codable {}
extension Color: StateCodableValue {}
extension Insets: StateCodableValue {}
extension Circle: StateCodableValue {}
extension Rect: StateCodableValue {}
extension Degrees: StateCodableValue {}
extension Radians: StateCodableValue {}
extension Matrix3x3: StateCodableValue {}
extension Matrix4x4: StateCodableValue {}
extension Size2: StateCodableValue {}
extension Position2: StateCodableValue {}
extension Direction2: StateCodableValue {}
extension Size3: StateCodableValue {}
extension Transform2: StateCodableValue {}
extension Position3: StateCodableValue {}
extension Direction3: StateCodableValue {}
extension Quaternion: StateCodableValue {}
extension Transform3: StateCodableValue {}

extension Array: StateCodableValue where Element: StateCodableValue {}

extension Game {
    public class State: Codable {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        enum CodingKeys: String, CodingKey {
            case bools
            case integers
            case doubles
            case strings
            case datas
        }
        private var bools: [String : Bool]
        private var integers: [String : Int64]
        private var doubles: [String : Double]
        private var strings: [String : String]
        private var datas: [String : Data]
        
        /**
         Add a bool value to the state.
         - parameter key: A unique identifier that will be used to retrieve the value latyer.
         - parameter value: The value to place in the state.
         */
        public func setValue(_ value: Bool, forKey key: String) {
            //assert(bools.keys.contains(key) == false, "Key already used for a bool value.")
            assert(integers.keys.contains(key) == false, "Key already used for an integer value.")
            assert(doubles.keys.contains(key) == false, "Key already used for a floating point value.")
            assert(strings.keys.contains(key) == false, "Key already used for a string value.")
            assert(datas.keys.contains(key) == false, "Key already used for an encoded value.")
            assert(key.isAscii, "ASCII characters are required for state keys for compatibility reasons.")
            bools.updateValue(value, forKey: key)
        }
        /**
         Retrieve an exisiting bool value from the state.
         - parameter key: The unique identifier originally used to set the value.
         - returns: The saved value or nil if no value was found.
         */
        public func boolForKey(_ key: String) -> Bool {
            return bools[key] == true
        }
        
        /**
         Add a integer value to the state.
         - parameter key: A unique identifier that will be used to retrieve the value latyer.
         - parameter value: The value to place in the state.
         */
        public func setValue<T: StateIntegerValue>(_ value: T, forKey key: String) {
            assert(bools.keys.contains(key) == false, "Key already used for a bool value.")
            //assert(integers.keys.contains(key) == false, "Key already used for an integer value.")
            assert(doubles.keys.contains(key) == false, "Key already used for a floating point value.")
            assert(strings.keys.contains(key) == false, "Key already used for a string value.")
            assert(datas.keys.contains(key) == false, "Key already used for an encoded value.")
            assert(key.isAscii, "ASCII characters are required for state keys for compatibility reasons.")
            assert(MemoryLayout<T>.size <= MemoryLayout<Int64>.size, "\(T.self) is not guaranteed to fit in state storage and cannot be used.")
            integers.updateValue(Int64(value), forKey: key)
        }
        /**
         Retrieve an exisiting integer value from the state.
         - parameter key: The unique identifier originally used to set the value.
         - returns: The saved value or nil if no value was found.
         */
        public func integerForKey<T: StateIntegerValue>(_ key: String, ofType: T.Type = Int.self) -> T? {
            if let int = integers[key] {
                return T(int)
            }
            return nil
        }
        
        /**
         Add a floating point value to the state.
         - parameter key: A unique identifier that will be used to retrieve the value latyer.
         - parameter value: The value to place in the state.
         */
        public func setValue<T: StateFloatingPointValue>(_ value: T, forKey key: String) {
            assert(bools.keys.contains(key) == false, "Key already used for a bool value.")
            assert(integers.keys.contains(key) == false, "Key already used for an integer value.")
            //assert(doubles.keys.contains(key) == false, "Key already used for a floating point value.")
            assert(strings.keys.contains(key) == false, "Key already used for a string value.")
            assert(datas.keys.contains(key) == false, "Key already used for an encoded value.")
            assert(key.isAscii, "ASCII characters are required for state keys for compatibility reasons.")
            assert(MemoryLayout<T>.size <= MemoryLayout<Double>.size, "\(T.self) is not guaranteed to fit in state storage and cannot be used.")
            doubles.updateValue(Double(value), forKey: key)
        }
        /**
         Retrieve an exisiting floating point value from the state.
         - parameter key: The unique identifier originally used to set the value.
         - returns: The saved value or nil if no value was found.
         */
        public func floatForKey<T: StateFloatingPointValue>(_ key: String, ofType: T.Type = Float.self) -> T? {
            if let double = doubles[key] {
                return T(double)
            }
            return nil
        }
        
        /**
         Add a string value to the state.
         - parameter key: A unique identifier that will be used to retrieve the value latyer.
         - parameter value: The string to place in the state.
         - note: The value has a length limit of 2048. If you can't know the length of the string saving it here is not wise.
         */
        public func setValue(_ value: String, forKey key: String) {
            assert(bools.keys.contains(key) == false, "Key already used for a bool value.")
            assert(integers.keys.contains(key) == false, "Key already used for an integer value.")
            assert(doubles.keys.contains(key) == false, "Key already used for a floating point value.")
            //assert(strings.keys.contains(key) == false, "Key already used for a string value.")
            assert(datas.keys.contains(key) == false, "Key already used for an encoded value.")
            assert(key.isAscii, "ASCII characters are required for state keys for compatibility reasons.")
            assert(value.count <= 2048, "The value has a length of \(value.count) which exceeds maximum of 2048.")
            strings.updateValue(value, forKey: key)
        }
        /**
         Retrieve an exisiting string value from the state.
         - parameter key: The unique identifier originally used to set the value.
         - returns: The saved value or nil if no value was found.
         */
        public func stringForKey(_ key: String) -> String? {
            return strings[key]
        }
        
        /**
            Encode a struct type.
         
            Valid types are GameMath values like ``Position3``, ``Color``, ``Degrees``, ``Rect``, etc...
         */
        public func encode<T: StateCodableValue>(_ value: T, forKey key: String) throws {
            assert(bools.keys.contains(key) == false, "Key already used for a bool value.")
            assert(integers.keys.contains(key) == false, "Key already used for an integer value.")
            assert(doubles.keys.contains(key) == false, "Key already used for a floating point value.")
            assert(strings.keys.contains(key) == false, "Key already used for a string value.")
            //assert(datas.keys.contains(key) == false, "Key already used for an encoded value.")
            assert(key.isAscii, "ASCII characters are required for state keys for compatibility reasons.")
            let data = try encoder.encode(value)
            datas.updateValue(data, forKey: key)
        }
        /**
         Decode a struct type.
         
         Valid types are GameMath values like ``Position3``, ``Color``, ``Degrees``, ``Rect``, etc...
         - parameter type: The type top decode
         - parameter key: The unique identifier originally used to set the value.
         - returns: The saved value. or nil if no value was found.
         - throws: Forwarded Swift.JSONDecoder errors if the decoding fails.
         */
        public func decode<T: StateCodableValue>(_ type: T.Type, forKey key: String) throws -> T? {
            if let data = self.datas[key] {
                return try decoder.decode(type, from: data)
            }
            return nil
        }
        
        /**
         Remove a value from the state
         - parameter key: The key used to store the value.
         */
        public func removeValueForKey(_ key: String) {
            bools.removeValue(forKey: key)
            integers.removeValue(forKey: key)
            doubles.removeValue(forKey: key)
            strings.removeValue(forKey: key)
            datas.removeValue(forKey: key)
        }

        internal init(name: String) {
            self.bools = [:]
            self.integers = [:]
            self.doubles = [:]
            self.strings = [:]
            self.datas = [:]
            self.name = name
        }
        
        /// The name used to save and load this state instance
        internal var name: String! = nil
        
        /// Persist the current values which will be loaded next time the game is run
        @MainActor public func save() async throws {
            try await Game.shared.platform.saveState(self, as: name)
        }
    }
}

fileprivate extension String {
    @_transparent
    var isAscii: Bool {
        for char in self {
            for code in char.unicodeScalars {
                guard code.isASCII else {return false}
            }
        }
        return true
    }
}
