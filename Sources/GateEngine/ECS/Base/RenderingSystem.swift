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
    
    /// The user interface scale of the window
    @inlinable
    public final var interfaceScale: Float {
        return game.mainWindow?.interfaceScale ?? 1
    }
    /// The scaled insets for content to be unobscured by notches and system UI clutter
    @inlinable
    public final var safeAreaInsets: Insets {
        return game.mainWindow?.backing.safeAreaInsets ?? .zero
    }
    
    required public init() {
        
    }
    
    internal final func willUpdate(withTimePassed deltaTime: Float) {
        if didSetup == false {
            didSetup = true
            setup()
        }
        if shouldRender(withTimePassed: deltaTime) {
            render(window: game.mainWindow!, into: game.mainWindow!.framebuffer, withTimePassed: deltaTime)
        }
    }

    private var didSetup = false
    open func setup() {
        
    }
    
    open func shouldRender(withTimePassed deltaTime: Float) -> Bool {
        return true
    }
    
    open func render(window: Window, into framebuffer: RenderTarget, withTimePassed deltaTime: Float) {
        preconditionFailure("Must Override \"\(#function)\" in \(type(of: Self.self))")
    }
        
    open func teardown() {
        
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
