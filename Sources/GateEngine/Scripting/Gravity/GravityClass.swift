/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@preconcurrency public import Gravity

/// A gravity script class definition.
public class GravityClass: GravityValueEmitting, GravityClassEmitting {
    @usableFromInline
    internal let gravity: Gravity
    public let gClass: UnsafeMutablePointer<gravity_class_t>!

    @usableFromInline
    internal init(name: String, superClass: GravityClass?, gravity: Gravity) {
        self.gravity = gravity
        self.gClass = name.withCString { name in
            return gravity_class_new_pair(gravity.vm, name, superClass?.gClass, 0, 0)
        }
    }

    @usableFromInline
    internal init(value: GravityValue, gravity: Gravity) {
        self.gravity = gravity
        self.gClass = unsafeBitCast(value.gValue.p, to: UnsafeMutablePointer<gravity_class_t>.self)
    }

    @usableFromInline
    internal init(gravity: Gravity, gClass: UnsafeMutablePointer<gravity_class_t>) {
        self.gravity = gravity
        self.gClass = gClass
    }

    @inlinable
    public var gValue: gravity_value_t {
        return gravity_value_from_object(gClass)
    }

    /**
     The super class definition, if any.
     - returns: A new instance of `GravityClass` representing the superclass or `nil`.
     */
    @inlinable
    public var gravitySuperClass: GravityClass? {
        guard let result = gravity_class_getsuper(gClass) else { return nil }
        return GravityClass(gravity: gravity, gClass: result)
        //TODO: Add a setter
    }

    /**
     Add a new variable to the Gravity object.
     - parameter name: The name of the var as written in a gravity script.
     */
    public func addVar(_ name: String) {
        name.withCString { name in
            gravity.setGrabageCollectionEnabled(false)

            let index = gravity_class_add_ivar(gClass, name)
            let function = gravity_function_new_special(nil, nil, UInt16(index), nil, nil)
            let closure = gravity_closure_new(gravity.vm, function)
            gravity_class_bind(gClass, name, gravity_value_from_object(closure))

            gravity.setGrabageCollectionEnabled(true)
        }
    }

    /**
     Add a new function to the Gravity object.
     - parameter name: The name of the function as written in a gravity script.
     - parameter function: A swift function or closure to be called when this func is called in the gravity script.
     */
    public func addFunc(
        _ key: String,
        calling function: @escaping GravitySwiftInstanceFunctionReturns
    ) {
        key.withCString { cName in
            var functionName = key
            let gFunc = withUnsafeMutablePointer(to: &functionName) { functionNamePointer in
                return gravity_function_new_bridged(gravity.vm, cName, functionNamePointer)
            }
            let gClosure = gravity_closure_new(gravity.vm, gFunc)
            let userData = GravityCFuncBridgedUserData(functionName: key, gravityClass: self)
            gFunc!.pointee.xdata = gravity.retainedUserDataPointer(from: userData)

            var gValue = gravity_value_t()
            gValue.p = unsafeBitCast(gClosure, to: UnsafeMutablePointer<gravity_object_t>.self)
            gValue.isa = gravity_class_closure

            gravity_class_bind(gClass, key, gValue)
        }

        let vmID = Int(bitPattern: gravity.vm)
        var funcDatabase = Gravity.storage[vmID]?.cBridgedFunctionMap ?? [:]
        funcDatabase[key] = function
        Gravity.storage[vmID]?.cBridgedFunctionMap = funcDatabase
    }

    /**
     Add a new function to the Gravity object.
     - parameter name: The name of the function as written in a gravity script.
     - parameter function: A swift function or closure to be called when this func is called in the gravity script.
     */
    @inlinable
    public func addFunc(_ key: String, calling function: @escaping GravitySwiftInstanceFunction) {
        let rFunc: GravitySwiftInstanceFunctionReturns = { gravity, sender, args -> GravityValue in
            function(gravity, sender, args)
            return .null
        }
        addFunc(key, calling: rFunc)
    }

    /// Initialize this GravityClass into a GravityInstance
    public func createInstance() -> GravityInstance {
        return GravityInstance(gravityClass: self, gravity: gravity)
    }
}

/// A function called from a gravity instance
public typealias GravitySwiftInstanceFunctionReturns = (
    _ gravity: Gravity,
    _ sender: GravityInstance,
    _ args: [GravityValue]
) -> GravityValue
public typealias GravitySwiftInstanceFunction = (
    _ gravity: Gravity,
    _ sender: GravityInstance,
    _ args: [GravityValue]
) -> Void

internal class GravityCFuncBridgedUserData {
    let functionName: String
    let gravityClass: GravityClass

    init(functionName: String, gravityClass: GravityClass) {
        self.functionName = functionName
        self.gravityClass = gravityClass
    }
}

internal func gravityCFuncBridged(
    vm: OpaquePointer!,
    xdata: UnsafeMutableRawPointer?,
    ctx: gravity_value_t,
    args: UnsafeMutablePointer<gravity_value_t>!,
    nargs: Int16,
    rindex: UInt32
) -> Bool {
    let vmID = Int(bitPattern: vm)
    
    // We use userData to store the Swift functions retrieval key
    guard let userData = unsafeBitCast(xdata, to: Optional<GravityCFuncBridgedUserData>.self) else {
        return true
    }
    // This should never fail
    guard let swiftFunction = Gravity.storage[vmID]?.cBridgedFunctionMap[userData.functionName] else {
        fatalError()
    }

    // An unmanged Gravity instance
    let gravity = Gravity(vm: vm)
    // Convert args to GravityValue(s)
    var args = UnsafeBufferPointer(start: args, count: Int(nargs)).map({ GravityValue(gValue: $0) })

    // The first arg is always the sender
    let sender = GravityInstance(value: args.removeFirst(), gravity: gravity)

    let result = swiftFunction(gravity, sender, args)
    return _gravityHandleCFuncReturn(vm: vm, returnValue: result, returnSlot: rindex)
}
