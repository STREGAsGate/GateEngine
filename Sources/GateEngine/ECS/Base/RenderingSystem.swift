/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@MainActor open class RenderingSystem {
    private var didSetup = false

    /// The game instance.
    @inlinable @inline(__always)
    public final var game: Game {
        return Game.shared
    }

    /// The current delta time as a Double
    /// Use this instead of the System Float variant when keeping track of timers
    public internal(set) var highPrecisionDeltaTime: Double = 0

    required public init() {

    }

    internal final func willRender(game: Game, window: Window, withTimePassed deltaTime: Float) {
        self.highPrecisionDeltaTime = window.highPrecisionDeltaTime
        if didSetup == false {
            didSetup = true
            setup(game: game)
        }
        if shouldRender(game: game, window: window, withTimePassed: deltaTime) {
            render(game: game, window: window, withTimePassed: deltaTime)
        }
    }

    /**
     Called once when this ``RenderingSystem`` is inserted into the game instance.

     Provides an oportuninty to setup any objects this system depends on.

     - parameter game: The game instance.
     **/
    open func setup(game: Game) {

    }

    /**
     Allows rendering to be skipped. Called every render frame.
     - parameter game: The game instance.
     - parameter window: The target window that wants to be rendered.
     - parameter deltaTime: The duration since the last time this window was rendered.
     - returns: `true` if you want to render, otherwise `false`.
     **/
    open func shouldRender(game: Game, window: Window, withTimePassed deltaTime: Float) -> Bool {
        return true
    }

    /**
     Allows rendering to be skipped. Called every render frame.
     - parameter game: The game instance.
     - parameter window: The target window that wants to be rendered.
     - parameter deltaTime: The duration since the last time this window was rendered.
     - returns: `true` if you want to render, otherwise `false`.
     **/
    open func render(game: Game, window: Window, withTimePassed deltaTime: Float) {
        preconditionFailure("Must Override \"\(#function)\" in \(type(of: Self.self))")
    }

    /**
     Called when this ``RenderingSystem`` is removed from the game instance.

     Provides an oportuninty to clean up any objects this system depended on.

     - parameter game: The game instance.
     **/
    open func teardown(game: Game) {

    }

    /**
     Provide a sorting order to ensure this system is processed at the right time.

     Every ``RenderingSystem`` is sorted before being rendered.
     The sort order determines how the systems are sorted.
     Returning `nil` means you don't care, and the order will be undefined.

     - returns: A ``RenderingSystemSortOrder`` describing this systems position.
     **/
    nonisolated open class func sortOrder() -> RenderingSystemSortOrder? {
        return nil
    }
}

extension RenderingSystem: Hashable {
    public static func == (lhs: RenderingSystem, rhs: RenderingSystem) -> Bool {
        return type(of: lhs) == type(of: rhs)
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine("\(type(of: self))")
    }
}
