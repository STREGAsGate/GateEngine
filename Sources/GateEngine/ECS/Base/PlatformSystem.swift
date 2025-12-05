/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

/// PlatformSystems are private and reserved for internal use by the engine.
@MainActor internal class PlatformSystem {
    private var didSetup = false

    @usableFromInline
    internal weak var _context: ECSContext! = nil
    @inlinable
    public var context: ECSContext {
        return _context.unsafelyUnwrapped
    }
    
    public required init() { }

    internal final func willUpdate(input: HID, withTimePassed deltaTime: Float, context: ECSContext) async {
        if didSetup == false {
            self._context = context
            didSetup = true
            await setup(context: context, input: input)
        }
        if await shouldUpdate(context: context, input: input, withTimePassed: deltaTime) {
            await update(context: context, input: input, withTimePassed: deltaTime)
        }
    }
    internal func _teardown(context: ECSContext) {
        self.teardown(context: context)
        self._context = nil
        self.didSetup = false
    }
    
    /**
     Called once when the entity is removed from the game.
     
     Use `gameDidRemove()` to cleanup an Entity that will be destoryed.
     */
    open func didRemove(entity: Entity, from context: ECSContext, input: HID) async {
        
    }

    /**
     Called once when the system is first inserted into the game.

     Use `setup()` to create any system specific data and add it to the game.
     - note: The call to `setup()` is deferred until the next update frame after the system has been inserted and will be called immediatled before `update(withTimePassed:)`.
     */
    open func setup(context: ECSContext, input: HID) async {

    }

    /**
     Called before `update(withTimePassed:)`. Return `true` if you would like `update(withTimePassed:)` to be called, otherwise return `false`.
     - parameter deltaTime: The duration of time since the last update frame.
     */
    open func shouldUpdate(context: ECSContext, input: HID, withTimePassed deltaTime: Float) async -> Bool {
        return true
    }

    /**
     Called every update frame.
     - parameter deltaTime: The duration of time since the last update frame.
     */
    open func update(context: ECSContext, input: HID, withTimePassed deltaTime: Float) async {
        preconditionFailure("Must Override \"\(#function)\" in \(type(of: Self.self))")
    }

    /**
     Called when the system is removed from the game.

     Use teardown to cleanup any system specific data within the game.
     - note: The call to `teardown()` happens immediately updon removal from the game.
     */
    open func teardown(context: ECSContext) {

    }

    /**
     The major sort order for systems.

     The phase value is simply a suggestion for grouping your systems.
     The value returned will not affect how or if the system is updated.
     */
    open class var phase: Phase {
        preconditionFailure("Must Override \"\(#function)\" in \(type(of: Self.self))")
    }
    /// The minor sort order for systems
    open class func sortOrder() -> PlatformSystemSortOrder? {
        return .dontCare
    }
}

extension PlatformSystem {
    enum Phase: UInt {
        case preUpdating
        case postDeferred
    }
}

extension PlatformSystem: Hashable {
    nonisolated public static func == (lhs: PlatformSystem, rhs: PlatformSystem) -> Bool {
        return Swift.type(of: lhs) == Swift.type(of: rhs)
    }
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine("\(type(of: self))")
    }
}
