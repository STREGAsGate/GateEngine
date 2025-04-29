/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Gravity

//MARK: - Emitters
protocol GravityValueEmitting {
    var gValue: gravity_value_t { get }
}

protocol GravityClassEmitting {
    var gClass: UnsafeMutablePointer<gravity_class_t>! { get }
}

protocol GravityInstanceEmitting {
    var gInstance: UnsafeMutablePointer<gravity_instance_t> { get }
}

protocol GravityClosureEmitting {
    var gClosure: UnsafeMutablePointer<gravity_closure_t>! { get }
}

// MARK: - GravityVMReferencing
public protocol GravityVMReferencing {
    var _gravity: Gravity { get }
}

// MARK: - GravityGetValueExtended
public protocol GravityGetVarExtended {
    func getVar(_ key: String) -> GravityValue?
}

extension GravityGetVarExtended {
    /**
     Obtain a value from gravity.
     - parameter key: The name of the `var` as written in the gravity script.
     */
    @inlinable
    public func getVar(_ key: String) -> Bool? {
        return getVar(key)?.getBool()
    }

    /**
     Obtain a value from gravity.
     - parameter key: The name of the `var` as written in the gravity script.
     */
    @inlinable
    public func getVar<T: BinaryInteger>(_ key: String) -> T? {
        return getVar(key)?.getInt()
    }

    /**
     Obtain a value from gravity.
     - parameter key: The name of the `var` as written in the gravity script.
     */
    @inlinable
    public func getVar(_ key: String) -> Float? {
        return getVar(key)?.asFloat()
    }

    /**
     Obtain a value from gravity.
     - parameter key: The name of the `var` as written in the gravity script.
     */
    @inlinable
    public func getVar(_ key: String) -> Double? {
        return getVar(key)?.asDouble()
    }

    /**
     Obtain a value from gravity.
     - parameter key: The name of the `var` as written in the gravity script.
     */
    @inlinable
    public func getVar(_ key: String) -> String? {
        return getVar(key)?.getString()
    }
}

// MARK: - GravityGetValueExtendedVMReferencing
public protocol GravityGetVarExtendedVMReferencing: GravityGetVarExtended, GravityVMReferencing {}
extension GravityGetVarExtendedVMReferencing {
    @inlinable
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
public protocol GravitySetVarExtended {
    func setVar(_ key: String, to value: GravityValue)
}
extension GravitySetVarExtended {
    /**
     Assign a value to a `var` in the gravity script.
     - parameter value: The swift value to assign
     - parameter key: The name of the `extern var` as written in the gravity script.
     */
    @inlinable
    public func setVar(_ key: String, to value: some BinaryInteger) {
        self.setVar(key, to: GravityValue(value))
    }

    /**
     Assign a value to a `var` in the gravity script.
     - parameter value: The swift value to assign
     - parameter key: The name of the `extern var` as written in the gravity script.
     */
    @inlinable
    public func setVar(_ key: String, to value: some BinaryFloatingPoint) {
        self.setVar(key, to: GravityValue(value))
    }

    /**
     Assign a value to a `var` in the gravity script.
     - parameter value: The swift value to assign
     - parameter key: The name of the `extern var` as written in the gravity script.
     */
    @inlinable
    public func setVar(_ key: String, to value: String) {
        self.setVar(key, to: GravityValue(value))
    }

    /**
     Assign a value to a `var` in the gravity script.
     - parameter value: The swift value to assign
     - parameter key: The name of the `extern var` as written in the gravity script.
     */
    @inlinable
    public func setVar(_ key: String, to value: GravityInstance) {
        self.setVar(key, to: value.gravityValue)
    }
}

// MARK: - GravityGetClosureExtended
public protocol GravityGetFuncExtended {
    func getFunc(_ key: String) -> GravityClosure?
}
