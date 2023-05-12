/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@MainActor open class RenderingSystem {
    @usableFromInline
    internal var context: ECSContext! = nil
    
    @inlinable
    public var game: Game {
        return context.game
    }
    
    required public init() {
        
    }
    
    internal final func willUpdate(game: Game, window: Window, withTimePassed deltaTime: Float) {
        if didSetup == false {
            didSetup = true
            setup(game: game)
        }
        if shouldRender(game: game, window: window, withTimePassed: deltaTime) {
            render(game: game, window: window, withTimePassed: deltaTime)
        }
    }

    private var didSetup = false
    open func setup(game: Game) {
        
    }
    
    open func shouldRender(game: Game, window: Window, withTimePassed deltaTime: Float) -> Bool {
        return true
    }
    
    open func render(game: Game, window: Window, withTimePassed deltaTime: Float) {
        preconditionFailure("Must Override \"\(#function)\" in \(type(of: Self.self))")
    }
        
    open func teardown(game: Game) {
        
    }

    open class func sortOrder() -> Int? {
        return nil
    }
}

extension RenderingSystem: Hashable {
    public static func ==(lhs: RenderingSystem, rhs: RenderingSystem) -> Bool {
        return type(of: lhs) == type(of: rhs)
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine("\(type(of: self))")
    }
}
