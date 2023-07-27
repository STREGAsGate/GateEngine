/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Gravity

public class GravityClosure: GravityValueEmitting, GravityClosureEmitting {
    let gravity: Gravity
    public let gClosure: UnsafeMutablePointer<gravity_closure_t>!
    let sender: GravityValue?

    internal init(gravity: Gravity, closure: UnsafeMutablePointer<gravity_closure_t>, sender: GravityValueConvertible?) {
        self.gravity = gravity
        self.gClosure = closure
        self.sender = sender?.gravityValue
    }
    
    public var gValue: gravity_value_t {
        var gValue = gravity_value_t()
        gValue.p = unsafeBitCast(gClosure, to: UnsafeMutablePointer<gravity_object_t>.self)
        gValue.isa = gravity_class_closure
        return gValue
    }
    
    @discardableResult @usableFromInline
    internal func run(withArguments args: [gravity_value_t], sender: GravityValueConvertible? = nil) throws -> GravityValue {
        var args = args
        gravity_vm_runclosure(gravity.vm, gClosure, sender?.gravityValue.gValue ?? gravity_value_from_null(), &args, UInt16(args.count))

        if let error = gravity.recentError {throw error}

        return GravityValue(gValue: gravity_vm_result(gravity.vm))
    }
    
    @discardableResult @inlinable
    public func run() throws -> GravityValue {
        return try run(withArguments: [])
    }
    
    @discardableResult @inlinable
    public func run(withArguments args: [GravityValueConvertible]) throws -> GravityValue {
        return try run(withArguments: args.map({$0.gravityValue.gValue}))
    }
    
    @discardableResult @inlinable
    public func run(withArguments args: GravityValueConvertible...) throws -> GravityValue {
        return try run(withArguments: args.map({$0.gravityValue.gValue}))
    }
}
