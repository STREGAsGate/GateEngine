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
 
 It is not recommended, but you may add this prototcol to other vlaue types.
 The value types chosen were chosen for long term, cross platform, and cloud service support.
 */
public protocol StateIntegerValue: BinaryInteger {}
extension Int: StateIntegerValue {}
extension UInt: StateIntegerValue {}
extension Int8: StateIntegerValue {}
extension UInt8: StateIntegerValue {}
extension Int16: StateIntegerValue {}
extension UInt16: StateIntegerValue {}
extension Int32: StateIntegerValue {}
extension UInt32: StateIntegerValue {}
extension Int64: StateIntegerValue {}
extension UInt64: StateIntegerValue {}

/**
 Recommended values for game state storage conform to this protocol.
 
 It is not recommended, but you may add this prototcol to other vlaue types.
 The value types chosen were chosen for long term, cross platform, and cloud service support.
 */
public protocol StateFloatingPointValue: BinaryFloatingPoint {}
extension Float: StateFloatingPointValue {}
extension Double: StateFloatingPointValue {}

/**
 Recommended values for game state storage conform to this protocol.
 
 It is not recommended, but you may add this prototcol to other vlaue types.
 The value types chosen were chosen for long term, cross platform, and cloud service support.
 */
public protocol StateCodableValue: Codable {}
extension Degrees: StateCodableValue {}
extension Radians: StateCodableValue {}
extension Size2: StateCodableValue {}
extension Position2: StateCodableValue {}
extension Direction2: StateCodableValue {}
extension Size3: StateCodableValue {}
extension Position3: StateCodableValue {}
extension Direction3: StateCodableValue {}
extension Quaternion: StateCodableValue {}
extension Matrix3x3: StateCodableValue {}
extension Matrix4x4: StateCodableValue {}

extension Game {
    public class State: Codable {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        enum CodingKeys: CodingKey {
            case bools
            case integers
            case doubles
            case strings
        }
        private var bools: [String : Bool]
        private var integers: [String : Int64]
        private var doubles: [String : Double]
        private var strings: [String : String]
        
        public func setValue(_ value: Bool, forKey key: String) {
            assert(key.isAscii, "ASCII characters are required for state keys for compatibility reasons.")
            bools.updateValue(value, forKey: key)
        }
        public func boolForKey(_ key: String) -> Bool {
            return bools[key] == true
        }
        
        public func setValue<T: StateIntegerValue>(_ value: T, forKey key: String) {
            assert(key.isAscii, "ASCII characters are required for state keys for compatibility reasons.")
            assert(MemoryLayout<T>.size <= MemoryLayout<Int64>.size, "\(T.self) is not guaranteed to fit in state storage and cannot be used.")
            integers.updateValue(Int64(value), forKey: key)
        }
        public func integerForKey<T: StateIntegerValue>(_ key: String, ofType: T.Type = Int.self) -> T? {
            if let int = integers[key] {
                return T(int)
            }
            return nil
        }
        
        public func setValue<T: StateFloatingPointValue>(_ value: T, forKey key: String) {
            assert(key.isAscii, "ASCII characters are required for state keys for compatibility reasons.")
            assert(MemoryLayout<T>.size <= MemoryLayout<Double>.size, "\(T.self) is not guaranteed to fit in state storage and cannot be used.")
            doubles.updateValue(Double(value), forKey: key)
        }
        public func floatForKey<T: StateFloatingPointValue>(_ key: String, ofType: T.Type = Float.self) -> T? {
            if let double = doubles[key] {
                return T(double)
            }
            return nil
        }
        
        public func setValue(_ value: String, forKey key: String) {
            assert(key.isAscii, "ASCII characters are required for state keys for compatibility reasons.")
            strings.updateValue(value, forKey: key)
        }
        public func stringForKey(_ key: String) -> String? {
            return strings[key]
        }
        
        public func encode<T: StateCodableValue>(_ value: T, forKey key: String) throws {
            assert(key.isAscii, "ASCII characters are required for state keys for compatibility reasons.")
            let data = try encoder.encode(value)
            let string = data.base64EncodedString()
            self.setValue(string, forKey: key)
        }
        public func decode<T: StateCodableValue>(_ type: T.Type, forKey key: String) throws -> T? {
            if let string = self.stringForKey(key) {
                if let data = Data(base64Encoded: string) {
                    return try decoder.decode(type, from: data)
                }
            }
            return nil
        }
        
        public func removeValueForKey(_ key: String) {
            bools.removeValue(forKey: key)
            integers.removeValue(forKey: key)
            doubles.removeValue(forKey: key)
            strings.removeValue(forKey: key)
        }

        internal init() {
            self.bools = [:]
            self.integers = [:]
            self.doubles = [:]
            self.strings = [:]
        }
        var name: String! = nil
        @MainActor public func save() throws {
            try Game.shared.platform.saveState(self, as: name)
        }
    }
}

fileprivate extension String {
    var isAscii: Bool {
        for char in self {
            for code in char.unicodeScalars {
                guard code.isASCII else {return false}
            }
        }
        return true
    }
}
