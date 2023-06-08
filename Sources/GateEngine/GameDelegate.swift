/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import struct Foundation.URL

public struct LaunchOptions: OptionSet {
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

@MainActor public protocol GameDelegate: AnyObject {
    /// Called when the app finishes loading.
    func didFinishLaunching(game: Game, options: LaunchOptions)
    
    /**
     Create a customized mainWindow
        
     Use `game.windowManager.createWindow(identifier:style:)`
     - parameter game: The game to create the window from
     - parameter identifier: The identifier to give the window. You must use this identifier.
     */
    func createMainWindow(game: Game, identifier: String) throws -> Window
    
    /// Might be called immediatley before the app closes.
    func willTerminate(game: Game)
    
    /**
     Start the game with no window and skip updating RenderingSystem(s).
     
     This is checked a single time at game launch and the result is peristsed unil the game is quit.
     
     Exmples of why you might want to return true:
     - Creating a multiplayer server.
     - Running your project in a remote environment, such as over SSH, where windows cannot be opened.
     - returns: true if the game doesn't draw anything.
     - note: RenderingSystem(s) do not recive updates in headless mode.
     */
    func isHeadless() -> Bool
    
    /**
     Add additional search paths for resources.
     
     This can be helpful for mods and expanability.
     Search paths for your Swift Packages are already located automatically and don't need to be added here.
     - returns: An array of URLs each pinting to a directory containing game resources.
     */
    func resourceSearchPaths() -> [URL]
    
    init()
}

public extension GameDelegate {
    func didFinishLaunching(game: Game, options: LaunchOptions) {}
    func willTerminate(game: Game) {}
    func isHeadless() -> Bool {return false}
    func resourceSearchPaths() -> [URL] {return []}
}

public extension GameDelegate {
    static func main() {
        Game.shared = Game(delegate: Self())
        Game.shared.platform.main()
    }
    
    func createMainWindow(game: Game, identifier: String) throws -> Window {
        return try game.windowManager.createWindow(identifier: identifier, style: .system, options: .defaultForMainWindow)
    }
}


