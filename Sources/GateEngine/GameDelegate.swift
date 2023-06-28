/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public struct LaunchOptions: OptionSet {
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

public protocol GameDelegate: AnyObject {
    /// Called when the app finishes loading.
    @MainActor func didFinishLaunching(game: Game, options: LaunchOptions)
    
    /**
     Create a customized mainWindow
        
     Use `game.windowManager.createWindow(identifier:style:)`
     - parameter game: The game to create the window from
     - parameter identifier: The identifier to give the window. You must use this identifier.
     */
    @MainActor func createMainWindow(game: Game, identifier: String) throws -> Window
    
    /// The end user has tried to open a window using the platforms mechanisms
    @MainActor func userRequestedWindow(game: Game) throws -> Window?
    
    /**
     A display has been attached.
     - returns: A new window instance to put on the screen. Passing an existing window is undefined behaviour.
    */
    @MainActor func screenBecomeAvailable(game: Game) throws -> Window?
    
    /// Might be called immediatley before the app closes.
    @MainActor func willTerminate(game: Game)
    
    /**
     Start the game with no window and skip updating RenderingSystem(s).
     
     This is checked a single time at game launch and the result is peristsed unil the game is quit.
     
     Exmples of why you might want to return true:
     - Creating a multiplayer server.
     - Running your project in a remote environment, such as over SSH, where windows cannot be opened.
     - returns: true if the game doesn't draw anything.
     - note: RenderingSystem(s) do not recive updates in headless mode.
     */
    @MainActor func isHeadless() -> Bool
    
    /**
     Add additional search paths for resources.
     
     This can be helpful for mods and expanability.
     Search paths for your Swift Packages are already located automatically and don't need to be added here.
     - returns: An array of URLs each pointing to a directory containing game resources.
     */
    nonisolated func resourceSearchPaths() -> [URL]
    
    /**
    An ID for the current game. This identifier is used for storing user settings.
    
    By providing a stable identifier, you're free to rename your executable without breaking user settings.
    By default the executablke name is used.
    */
    nonisolated func gameIdentifier() -> StaticString?

    @MainActor init()
}

public extension GameDelegate {
    @MainActor func createMainWindow(game: Game, identifier: String) throws -> Window {
        return try game.windowManager.createWindow(identifier: identifier, style: .system, options: .defaultForMainWindow)
    }
    func userRequestedWindow(game: Game) throws -> Window? {return nil}
    func screenBecomeAvailable(game: Game) throws -> Window? {return nil}
    
    func willTerminate(game: Game) {}
    func isHeadless() -> Bool {return false}
    func resourceSearchPaths() -> [URL] {return []}

    func gameIdentifier() -> StaticString? {return nil}

    @_transparent
    internal func resolvedGameIdentifier() -> String {
        if let identifer: StaticString = self.gameIdentifier() {
            return identifer.withUTF8Buffer {
                return String(decoding: $0, as: UTF8.self)
            }
        }
        #if canImport(Darwin)
        if let identifier = Bundle.main.bundleIdentifier {
            return identifier
        }
        #endif
        return CommandLine.arguments[0]
    }
}

public extension GameDelegate {
    @MainActor static func main() {
        Game.shared = Game(delegate: Self())
        Game.shared.platform.main()
    }
}
