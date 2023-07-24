/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GravityC

/// A gravity script class definition.
public class GravityInstance: GravityValueEmitting, GravityInstanceEmitting {
    public let gravity: Gravity
    public let gInstance: UnsafeMutablePointer<gravity_instance_t>

    internal init(gravityClass: GravityClass, gravity: Gravity) {
        self.gravity = gravity
        self.gInstance = gravity_instance_new(gravity.vm, gravityClass.gClass)
    }
    
    lazy var gravitySuper: GravityInstance? = {
        // If we are the base class there is no super
        guard self.gravityClassName != "Object" else {return nil}
        guard let v = gInstance.pointee.objclass?.pointee.superclass else {return nil}
        return GravityInstance(value: v, gravity: gravity)
    }()
    
    internal convenience init(value: GravityValue, gravity: Gravity) {
        assert(value.valueType == .instance || value.valueType == .null)
        self.init(value: value.gValue.p, gravity: gravity)
    }
    
    internal init(value: UnsafeMutablePointer<gravity_object_t>!, gravity: Gravity) {
        self.gravity = gravity
        self.gInstance = unsafeBitCast(value, to: UnsafeMutablePointer<gravity_instance_t>.self)
    }
    
    public var gValue: gravity_value_t {
        return gravity_value_from_object(gInstance)
    }
    
    public var gravityClassName: String {
        return String(cString: gravity_value_name(gValue))
    }
}

extension GravityInstance: GravityGetVarExtendedVMReferencing  {
    @_transparent
    public var _gravity: Gravity {
        return gravity
    }
    
    public func getVar(_ key: String) -> GravityValue? {
        guard let htable = gInstance.pointee.objclass?.pointee.htable else {
            //TODO: Add a caching system to return the same instance over and over.
            fatalError("Another instance was created by you invalidating this one.")
        }
        if let htableValue = key.withCString({gravity_hash_lookup_cstring(htable, $0)?.pointee}) {
            let value = GravityValue(gValue: htableValue)
            if let closure = value.getClosure(gravity: gravity, sender: self) {
                if let index = closure.gClosure.pointee.f?.pointee.index {
                    return GravityValue(optionalGValue: gInstance.pointee.ivars[Int(index)])
                }else{
                    print("Gravity: Failed to obtain var \(key).")
                }
            }
        }
        return gravitySuper?.getVar(key) ?? nil
    }
}

extension GravityInstance: GravitySetVarExtended {
    public func setVar(_ key: String, to value: GravityValue) {
        guard let htable = gInstance.pointee.objclass?.pointee.htable else {
            //TODO: Add a caching system to return the same instance over and over.
            fatalError("Another instance was created by you invalidating this one.")
        }
        let htableValue = key.withCString { key in
            return gravity_hash_lookup_cstring(htable, key).pointee
        }

        if let closure = GravityValue(gValue: htableValue).getClosure(gravity: gravity, sender: self) {
            let ivarIndex = UInt32(closure.gClosure.pointee.f.pointee.index)
            gravity_instance_setivar(gInstance, ivarIndex, value.gValue)
        }else{
            gravitySuper?.setVar(key, to: value)
        }
    }
}

extension GravityInstance: GravityGetFuncExtended {
    public func getFunc(_ key: String) -> GravityClosure? {
        guard let gValue: gravity_value_t = key.withCString({ key in
            return gravity_hash_lookup_cstring(gInstance.pointee.objclass.pointee.htable, key)
        })?.pointee else {return nil}
        let value = GravityValue(gValue: gValue)
        let valueType = value.valueType
        if valueType != .closure {
            return nil
        }
        return value.getClosure(gravity: gravity, sender: self)!
    }
    
    @discardableResult @inline(__always)
    public func runFunc(_ name: String) throws -> GravityValue {
        return try runFunc(name, withArguments: nil)
    }
    
    @discardableResult @inline(__always)
    public func runFunc(_ name: String, withArguments args: [GravityValue]) throws -> GravityValue {
        guard let closure = getFunc(name) else {throw "Gravity: Failed to get closure \(name)."}
        return try closure.run(withArguments: args.map({$0.gValue}))
    }
    
    @discardableResult @inline(__always)
    public func runFunc(_ name: String, withArguments args: GravityValue...) throws -> GravityValue {
        guard let closure = getFunc(name) else {throw "Gravity: Failed to get closure \(name)."}
        return try closure.run(withArguments: args.map({$0.gValue}))
    }
}
