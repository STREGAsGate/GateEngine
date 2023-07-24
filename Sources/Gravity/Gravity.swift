/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GravityC
import struct Foundation.URL

extension Gravity {
    static var version: String {
        return GRAVITY_VERSION
    }
    static var versionNumber: Int {
        return Int(GRAVITY_VERSION_NUMBER)
    }
}

internal var gravityDelegate: gravity_delegate_t = {
    var delegate: gravity_delegate_t = gravity_delegate_t()
    delegate.error_callback = errorCallback(vm:errorType:description:errorDesc:xdata:)
    #if canImport(Foundation) && !os(WASI)
    delegate.filename_callback = filenameCallback(fileID:xData:)
    delegate.loadfile_callback = loadFileCallback(file:size:fileID:xData:isStatic:)
    #endif
    #if DEBUG
    delegate.unittest_callback = unittestCallback(vm:errorType:desc:note:value:row:column:xdata:)
    #endif
    delegate.bridge_execute = gravityCFuncBridged(vm:xdata:ctx:args:nargs:rindex:)
    return delegate
}()

public class Gravity {
    let vm: OpaquePointer
    var isManaged: Bool
    
    @inline(__always)
    var didRunMain: Bool {
        get {Self.storage[vm]!.didRunMain}
        set {Self.storage[vm]!.didRunMain = newValue}
    }
    
    @inline(__always)
    var sourceCodeBaseURL: URL? {
        get {Self.storage[vm]!.sourceCodeBaseURL}
        set {Self.storage[vm]!.sourceCodeBaseURL = newValue}
    }
    
    @inline(__always)
    var sourceCodeSearchPaths: Set<URL> {
        get {
            return Self.storage[vm]!.sourceCodeSearchPaths
        }
        set {
            Self.storage[vm]!.sourceCodeSearchPaths = newValue
        }
    }
    
    @inline(__always)
    var loadedFilesByID: [UInt32:URL] {
        get {
            return Self.storage[vm]!.loadedFilesByID
        }
        set {
            Self.storage[vm]!.loadedFilesByID = newValue
        }
    }
    
    @inline(__always)
    func filenameForID(_ id: UInt32) -> String? {
        return Self.storage[vm]!.loadedFilesByID[id]?.lastPathComponent
    }
    
    @inline(__always)
    var mainClosure: UnsafeMutablePointer<gravity_closure_t>? {
        get {Self.storage[vm]!.mainClosure}
        set {Self.storage[vm]!.mainClosure = newValue}
    }
    
    @inline(__always)
    var recentError: Error? {
        get {Self.storage[vm]!.recentError}
        set {Self.storage[vm]!.recentError = newValue}
    }
    
    #if DEBUG
    static var unitTestExpected: Testing? = nil
    #endif
    
    /**
     Check if the compiled gravity script included an external script file.
     - parameter fileName: The name of the gravity script to check for.
     - returns: true if the compiled script included the additional sourece
     */
    public func compiledSourceDidLoadFile(_ fileName: String) -> Bool {
        return loadedFilesByID.values.contains(where: {$0.lastPathComponent.compare(fileName) == .orderedSame})
    }
    
    @inline(__always)
    internal func setGrabageCollectionEnabled(_ enabled: Bool) {
        gravity_gc_setenabled(vm, enabled)
    }
    
    // These references are used in various xdata areas and should
    // stay alive while this gravity instance is alive.
    struct UserDataReference: Hashable {
        let reference: AnyObject
        @inlinable
        func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(reference))
        }
        static func ==(lhs: Self, rhs: Self) -> Bool {
            return lhs.reference === rhs.reference
        }
    }
    @inline(__always)
    internal var userDataReferences: Set<UserDataReference> {
        get {Self.storage[vm]!.userDataReferences}
        set {Self.storage[vm]!.userDataReferences = newValue}
    }
    internal func retainedUserDataPointer(from reference: AnyObject) -> UnsafeMutableRawPointer {
        let userDataP = Unmanaged.passUnretained(reference).toOpaque()
        userDataReferences.insert(UserDataReference(reference: reference))
        return userDataP
    }
    
    /// Create a new gravity instance.
    public init() {
        self.vm = gravity_vm_new(&gravityDelegate)
        self.isManaged = true
        assert(Self.storage[vm] == nil)
        Self.storage[vm] = GravityStorage()
    }
    
    internal init(vm: OpaquePointer) {
        self.vm = vm
        self.isManaged = false
    }
    
    internal init?(unwrappingVM vm: OpaquePointer?) {
        guard let vm = vm else {return nil}
        self.vm = vm
        self.isManaged = false
    }
    
    /**
     Compile a gravity script.
     - parameter sourceCode: The gravity script as a `String`.
     - parameter addDebug: `true` to add debug. nil to add debug only in DEBUG configurations.
     - throws: Gravity compilation errors such as syntax problems.
     */
    public func compile(_ sourceCode: String, addDebug: Bool? = nil) throws {
        self.mainClosure = nil
        self.didRunMain = false
        try sourceCode.withCString { cString in
            #if DEBUG
            let isDebug = true
            #else
            let isDebug = false
            #endif
            
            gravityDelegate.xdata = Unmanaged.passUnretained(self).toOpaque()
            
            let compiler: OpaquePointer = gravity_compiler_create(&gravityDelegate)
            if let closure = gravity_compiler_run(compiler, cString, sourceCode.count, 0, true, addDebug ?? isDebug) {
                self.mainClosure = closure
                gravity_compiler_transfer(compiler, vm)
                gravity_compiler_free(compiler)
            }else if let error = recentError {
                defer {
                    gravity_compiler_free(compiler)
                    recentError = nil
                }
                throw error
            }else{
                gravity_compiler_free(compiler)
                throw "Gravity Error: Failed to compile."
            }
        }
        #if canImport(Foundation) && !os(WASI)
        sourceCodeBaseURL = nil
        #endif
    }
    
    /// Runs the  `func main()` of the gravity script.
    @discardableResult
    public func runMain() throws -> GravityValue {
        guard let mainClosure = mainClosure else {throw "No main closure found. Did you forget to compile?"}
        self.didRunMain = true
        gravity_vm_runmain(vm, mainClosure)
        if let error = recentError {throw error}
        return GravityValue(gValue: gravity_vm_result(vm))
    }
    
    @inline(__always)
    public func getClass(_ key: String) -> GravityClass? {
        return getVar(key)?.getClass(gravity: self)
    }
    
    @inline(__always)
    public func setClass(_ key: String, to value: GravityClass) {
        setVar(key, to: value.gravityValue)
    }
    
    /**
     References an object instance from within the gravity script.
     - parameter key: The name of the `var` as written in the gravity script.
     - returns: A `GravityInstance` which references the script closure/function for `key`.
    */
    @inline(__always)
    public func getInstance(_ key: String) -> GravityInstance? {
        return getVar(key)?.getInstance(gravity: self)
    }
    
    /**
     Make a new gravity value from a Swift value.
     - parameter value: The Swift value to store in the `GravityValue`.
     - returns: A `GravityValue` representing the provided Swift vlaue.
     */
    public func createValue(_ value: any BinaryInteger) -> GravityValue {
        return GravityValue(value)
    }
    /**
     Make a new gravity value from a Swift value.
     - parameter value: The Swift value to store in the `GravityValue`.
     - returns: A `GravityValue` representing the provided Swift vlaue.
     */
    public func createValue(_ value: any BinaryFloatingPoint) -> GravityValue {
        return GravityValue(value)
    }
    
    /**
     Make a new gravity value from a Swift value.
     - parameter value: The Swift value to store in the `GravityValue`.
     - returns: A `GravityValue` representing the provided Swift vlaue.
     */
    public func createValue(_ value: Bool) -> GravityValue {
        return GravityValue(value)
    }
    
    /**
     Make a new gravity value from a Swift value.
     - parameter value: The Swift value to store in the `GravityValue`.
     - returns: A `GravityValue` representing the provided Swift vlaue.
     */
    public func createValue(_ value: String) -> GravityValue {
        return GravityValue(value, self)
    }
    
    /**
     Make a new gravity value from a Swift value.
     - parameter value: The Swift value to store in the `GravityValue`.
     - returns: A `GravityValue` representing the provided Swift vlaue.
     */
    public func createValue(_ value: StaticString) -> GravityValue {
        return GravityValue(value, self)
    }
    
    /**
     Make a new gravity value from a Swift value.
     - parameter value: The Swift value to store in the `GravityValue`.
     - returns: A `GravityValue` representing the provided Swift vlaue.
     */
    public func createValue(_ values: [GravityValue]) -> GravityValue {
        return GravityValue(values, self)
    }
    
    /**
     Make a new gravity value from a Swift value.
     - parameter value: The Swift value to store in the `GravityValue`.
     - returns: A `GravityValue` representing the provided Swift vlaue.
     */
    public func createValue(_ values: [GravityValue:GravityValue]) -> GravityValue {
        return GravityValue(values, self)
    }
    
    /**
     Make a new gravity class definition.
     - parameter name: The class name as written in a gravity script.
     - parameter superClass: An optional super class for the gravity class.
     - returns: A `GravityClass` representing a gravity class.
     */
    public func createClass(_ name: String, superClass: GravityClass? = nil) -> GravityClass {
        let theClass = GravityClass(name: name, superClass: superClass, gravity: self)
        name.withCString { cString in
            gravity_vm_setvalue(vm, cString, theClass.gValue)
        }
        return theClass
    }
    
    deinit {
        guard isManaged else {return}
        Self.cleanupStorage(vm)
        gravity_vm_free(vm)
        gravity_core_free()
    }
}

// This is only called for global closures. Instance methods use the seperate bridge delegate callback.
internal func gravityCFuncInternal(vm: OpaquePointer!, args: UnsafeMutablePointer<gravity_value_t>!, nargs: UInt16, rindex: UInt32) -> Bool {
    let functionName: String = {
        let gClosure = unsafeBitCast(args!.pointee.p, to: UnsafeMutablePointer<gravity_closure_t>.self)
        let cName = gClosure.pointee.f.pointee.identifier!
        return String(cString: cName)
    }()
    
    guard let function = Gravity.storage[vm]?.cInternalFunctionMap[functionName] else {fatalError()}
    var args = UnsafeBufferPointer(start: args, count: Int(nargs)).map({GravityValue(gValue: $0)})
    args.removeFirst()// The first is always the closure being called
    let result = function(Gravity(vm: vm), args)
    return _gravityHandleCFuncReturn(vm: vm, returnValue: result, returnSlot: rindex)
}

@inline(__always)
internal func _gravityHandleCFuncReturn(vm: OpaquePointer, returnValue: GravityValue, returnSlot: UInt32) -> Bool {
    switch returnValue.valueType {
    case .closure:
        gravity_vm_setslot(vm, returnValue.gValue, returnSlot)
        return false
    case .fiber:
        return false
    default:
        gravity_vm_setslot(vm, returnValue.gValue, returnSlot)
        return true
    }
}

extension Gravity {
    internal static var storage: [OpaquePointer : GravityStorage] = [:]
    internal struct GravityStorage {
        var mainClosure: UnsafeMutablePointer<gravity_closure_t>? = nil
        var didRunMain: Bool = false
        var recentError: Error? = nil
        
        var loadedFilesByID: [UInt32:URL] = [:]
        
        #if canImport(Foundation) && !os(WASI)
        var sourceCodeBaseURL: URL? = nil {
            willSet {
                if let newValue = newValue {
                    sourceCodeSearchPaths.insert(newValue)
                }else{
                    sourceCodeSearchPaths.removeAll(keepingCapacity: true)
                }
            }
        }
        var sourceCodeSearchPaths: Set<URL> = []
        #endif
        
        var userDataReferences: Set<UserDataReference> = []
        
        var cInternalFunctionMap: [String:GravitySwiftFunctionReturns] = [:]
        var cBridgedFunctionMap: [String:GravitySwiftInstanceFunctionReturns] = [:]
    }
    @inline(__always)
    internal static func cleanupStorage(_ vm: OpaquePointer) {
        storage.removeValue(forKey: vm)
    }
    
    /**
     Assign a Swift function/closure to be called from the gravity script
     - parameter key: The name of the `extern func` as wirrten in the gravity script.
     - parameter function: The swift function to call
     */
    public func setFunc(_ key: String, to function: @escaping GravitySwiftFunctionReturns) {
        key.withCString { cKey in
            let gFunc = gravity_function_new_internal(vm, cKey, gravityCFuncInternal, 0)
            let gClosure = gravity_closure_new(vm, gFunc)
            
            var gValue = gravity_value_t()
            gValue.p = unsafeBitCast(gClosure, to: UnsafeMutablePointer<gravity_object_t>.self)
            gValue.isa = gravity_class_closure
            
            gravity_vm_setvalue(vm, cKey, gValue)
        }
        
        var funcDatabase = Self.storage[vm]?.cInternalFunctionMap ?? [:]
        funcDatabase[key] = function
        Self.storage[vm]?.cInternalFunctionMap = funcDatabase
    }
    
    /**
     Assign a Swift function/closure to be called from the gravity script
     - parameter key: The name of the `extern func` as wirrten in the gravity script.
     - parameter function: The swift function to call
     */
    @inlinable
    public func setFunc(_ key: String, to function: @escaping GravitySwiftFunction) {
        let rFunc: GravitySwiftFunctionReturns = {gravity, args -> GravityValue in
            function(gravity, args)
            return .null
        }
        setFunc(key, to: rFunc)
    }
}

/// A function called from gravity that has no ownership, such as a global function.
public typealias GravitySwiftFunctionReturns = (_ gravity: Gravity, _ args: [GravityValue]) -> GravityValue
public typealias GravitySwiftFunction = (_ gravity: Gravity, _ args: [GravityValue]) -> Void

extension Gravity: GravityVMReferencing {
    @_transparent
    public var _gravity: Gravity {
        return self
    }
}

extension Gravity: GravityGetVarExtendedVMReferencing {
    /**
     Obtain a value from gravity.
     - parameter key: The name of the `var` as written in the gravity script.
     */
    public func getVar(_ key: String) -> GravityValue? {
        guard didRunMain else {fatalError("Gravity Error: `runMain()` must be called before you can do this.")}
        return key.withCString { cString in
            let value: gravity_value_t = gravity_vm_getvalue(vm, cString, UInt32(key.utf8.count))
            return GravityValue(optionalGValue: value)
        }
    }
}

extension Gravity: GravitySetVarExtended {
    /**
     Assign a value to a `var` in the gravity script.
     - parameter value: The swift value to assign
     - parameter key: The name of the `extern var` as written in the gravity script.
     */
    public func setVar(_ key: String, to value: GravityValue) {
        key.withCString { cString in
            gravity_vm_setvalue(vm, cString, value.gValue)
        }
    }
}

extension Gravity: GravityGetFuncExtended {
    /**
     References a closure/function from within the gravity script.
     - parameter key: The name of the closure as written in the gravity script.
     - returns: A `GravityClosure` which references the script closure/function for `key`.
                You can call `run()` on the `GravityClosure` to execute the reference script closure.
    */
    public func getFunc(_ key: String) -> GravityClosure? {
        return getVar(key)?.getClosure(gravity: self, sender: nil)
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

extension Gravity: Equatable {
    public static func ==(lhs: Gravity, rhs: Gravity) -> Bool {
        return lhs.vm == rhs.vm
    }
}
