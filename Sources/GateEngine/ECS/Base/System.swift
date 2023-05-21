/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public extension System {
    enum Phase: UInt {
        /// Handle cache, memory managment, and game state changes.
        case updating
        /// Retrieve and parse network data.
        case networking
        /// Update non-player states.
        case artificialIntelligence
        /// Update anything that moves.
        case simulation
        /// Perform 2D layout and related user input.
        case userInterface
        /// Any system marked as deffered will update last, but before rendering.
        case deferred
    }
}

@MainActor open class System {
    required public init() {}
    
    public private(set) lazy var backgroundTask = BackgroundTask(system: self)
    public class BackgroundTask {
        unowned let system: System
        init(system: System) {
            self.system = system
        }
        public enum State {
            ///Not running and never finished
            case initial
            case running
            case finished
        }
        public private(set) var state: State = .initial
        @inline(__always)
        nonisolated public var isRunning: Bool {
            return state == .running
        }
        
        @MainActor public func run(_ block: @escaping ()->Void) {
            assert(self.isRunning == false, "A Task cannot be run when it's running.")
            self.state = .running
            Task(priority: .background) {
                block()
                Task { @MainActor in
                    //Update the state between simulation ticks
                    self.state = .finished
                }
            }
        }
    }
    
    @inlinable @inline(__always)
    public var entities: ContiguousArray<Entity> {
        return Game.shared.entities
    }
        
    internal final func willUpdate(game: Game, input: HID, withTimePassed deltaTime: Float) {
        if didSetup == false {
            didSetup = true
            setup(game: game, input: input)
        }
        if shouldUpdate(withTimePassed: deltaTime) {
            update(game: game, input: input, withTimePassed: deltaTime)
        }
    }

    private var didSetup = false
    
    /**
     Called once when the system is first inserted into the game.
     
     Use `setup()` to create any system specific data and add it to the game.
     - note: The call to `setup()` is deffered until the next update frame after the system has been inserted and will be called immediatled before `update(withTimePassed:)`.
     */
    open func setup(game: Game, input: HID) {
        
    }
    
    /**
     Called before `update(withTimePassed:)`. Return `true` if you would like `update(withTimePassed:)` to be called, otherwise return `false`.
     - parameter deltaTime: The duration of time since the last update frame.
     */
    open func shouldUpdate(withTimePassed deltaTime: Float) -> Bool {
        return true
    }
    
    /**
     Called every update frame.
     - parameter deltaTime: The duration of time since the last update frame.
     */
    open func update(game: Game, input: HID, withTimePassed deltaTime: Float) {
        
    }
    
    /**
     Called when the system is removed from the game.
        
     Use teardown to cleanup any system specific data within the game.
     - note: The call to `teardown()` happens immediatley updon removal from the game.
     */
    open func teardown(game: Game) {
        
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
    nonisolated open class func sortOrder() -> SystemSortOrder? {
        return nil
    }
}

extension System: Hashable {
    public static func ==(lhs: System, rhs: System) -> Bool {
        return type(of: lhs) == type(of: rhs)
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine("\(type(of: self))")
    }
}
