/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Gravity

//MARK: - Emitters
@MainActor
protocol GravityValueEmitting {
    var gValue: gravity_value_t { get }
}
@MainActor
protocol GravityClassEmitting {
    var gClass: UnsafeMutablePointer<gravity_class_t>! { get }
}
@MainActor
protocol GravityInstanceEmitting {
    var gInstance: UnsafeMutablePointer<gravity_instance_t> { get }
}
@MainActor
protocol GravityClosureEmitting {
    var gClosure: UnsafeMutablePointer<gravity_closure_t>! { get }
}

// MARK: - GravityVMReferencing
@MainActor
public protocol GravityVMReferencing {
    var _gravity: Gravity { get }
}

// MARK: - GravityGetValueExtended
@MainActor
public protocol GravityGetVarExtended {
    func getVar(_ key: String) -> GravityValue?
}

@MainActor
extension GravityGetVarExtended {
    /**
     Obtain a value from gravity.
     - parameter key: The name of the `var` as written in the gravity script.
     */
    @inline(__always)
    public func getVar(_ key: String) -> Bool? {
        return getVar(key)?.getBool()
    }

    /**
     Obtain a value from gravity.
     - parameter key: The name of the `var` as written in the gravity script.
     */
    @inline(__always)
    public func getVar<T: BinaryInteger>(_ key: String) -> T? {
        return getVar(key)?.getInt()
    }

    /**
     Obtain a value from gravity.
     - parameter key: The name of the `var` as written in the gravity script.
     */
    @inline(__always)
    public func getVar(_ key: String) -> Float? {
        return getVar(key)?.asFloat()
    }

    /**
     Obtain a value from gravity.
     - parameter key: The name of the `var` as written in the gravity script.
     */
    @inline(__always)
    public func getVar(_ key: String) -> Double? {
        return getVar(key)?.asDouble()
    }

    /**
     Obtain a value from gravity.
     - parameter key: The name of the `var` as written in the gravity script.
     */
    @inline(__always)
    public func getVar(_ key: String) -> String? {
        return getVar(key)?.getString()
    }
}

// MARK: - GravityGetValueExtendedVMReferencing
@MainActor
public protocol GravityGetVarExtendedVMReferencing: GravityGetVarExtended, GravityVMReferencing {}
extension GravityGetVarExtendedVMReferencing {
    @inline(__always)
    public func getVar(_ key: String) -> GravityClosure? {
        return getVar(key)?.getClosure(
            gravity: _gravity,
            sender: self as? any GravityValueConvertible
        )
    }

    @inlinable
    public func getVar(_ key: String) throws -> GravityInstance? {
        guard let value = getVar(key) else { return nil }
        return value.getInstance(gravity: _gravity)
    }
}

// MARK: - GravitySetValueExtended
@MainActor
public protocol GravitySetVarExtended {
    func setVar(_ key: String, to value: GravityValue)
}
extension GravitySetVarExtended {
    /**
     Assign a value to a `var` in the gravity script.
     - parameter value: The swift value to assign
     - parameter key: The name of the `extern var` as written in the gravity script.
     */
    @inline(__always)
    public func setVar(_ key: String, to value: some BinaryInteger) {
        self.setVar(key, to: GravityValue(value))
    }

    /**
     Assign a value to a `var` in the gravity script.
     - parameter value: The swift value to assign
     - parameter key: The name of the `extern var` as written in the gravity script.
     */
    @inline(__always)
    public func setVar(_ key: String, to value: some BinaryFloatingPoint) {
        self.setVar(key, to: GravityValue(value))
    }

    /**
     Assign a value to a `var` in the gravity script.
     - parameter value: The swift value to assign
     - parameter key: The name of the `extern var` as written in the gravity script.
     */
    @inline(__always)
    public func setVar(_ key: String, to value: String) {
        self.setVar(key, to: GravityValue(value))
    }

    /**
     Assign a value to a `var` in the gravity script.
     - parameter value: The swift value to assign
     - parameter key: The name of the `extern var` as written in the gravity script.
     */
    @inline(__always)
    public func setVar(_ key: String, to value: GravityInstance) {
        self.setVar(key, to: value.gravityValue)
    }
}

// MARK: - GravityGetClosureExtended
@MainActor
public protocol GravityGetFuncExtended {
    func getFunc(_ key: String) -> GravityClosure?
}
