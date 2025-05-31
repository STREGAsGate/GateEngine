/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
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
    /// Return false exit the program
    func shouldFinishLaunching(game: Game) async throws -> Bool
    
    /// Called when the app finishes loading.
    @MainActor 
    func didFinishLaunching(game: Game, options: LaunchOptions) async

    /**
     Create a customized mainWindow

     Use `game.windowManager.createWindow(identifier:style:)`
     - parameter game: The game to create the window from
     - parameter identifier: The identifier to give the window. You must use this identifier.
     */
    @MainActor 
    func createMainWindow(using manager: WindowManager, with identifier: String) throws -> Window

    /// The end user has tried to open a window using the platforms mechanisms
    @MainActor 
    func createUserRequestedWindow(using manager: WindowManager) throws -> Window?

    /**
     A display has been attached.
     - returns: A new window instance to put on the screen. Passing an existing window is undefined behaviour.
    */
    @MainActor 
    func createWindowForExternalScreen(using manager: WindowManager) throws -> Window?

    /// Might be called immediately before the app closes.
    @MainActor 
    func willTerminate(game: Game)

    /**
     Start the game with no window and skip updating RenderingSystem(s).

     This is checked a single time at game launch and the result is peristsed unil the game is quit.

     Exmples of why you might want to return true:
     - Creating a multiplayer server.
     - Running your project in a remote environment, such as over SSH, where windows cannot be opened.
     - returns: true if the game doesn't draw anything.
     - note: RenderingSystem(s) do not receive updates in headless mode.
     */
    @MainActor 
    func isHeadless() -> Bool

    /**
     Add additional search locations for resources.

     This can be helpful for mods and expanability.
     Search paths for your Swift Packages are already located automatically and don't need to be added here.
     - returns: An array of URLs each pointing to a directory containing game resources.
     */
    nonisolated func customResourceLocations() -> [String]

    /**
    An ID for the current game. This identifier is used for storing user settings.

    By providing a stable identifier, you're free to rename your executable without breaking user settings.
    By default the executablke name is used.
    */
    nonisolated func gameIdentifier() -> StaticString?
    
    /**
     This is called when the platform host wants you to open something. This can be a user selected file or something else.
     */
    func openURLs(_ urls: [URL])

    @MainActor 
    init()
}

extension GameDelegate {
    public func shouldFinishLaunching(game: Game) async throws -> Bool { return true }
    
    public func createUserRequestedWindow(using manager: WindowManager) throws -> Window? { return nil }
    public func createWindowForExternalScreen(using manager: WindowManager) throws -> Window? { return nil }

    public func willTerminate(game: Game) {}
    public func isHeadless() -> Bool { return false }
    public func customResourceLocations() -> [String] { return [] }
    internal func resolvedCustomResourceLocations() -> [URL] {
        return customResourceLocations().compactMap({ URL(string: $0) })
    }

    public func gameIdentifier() -> StaticString? { return nil }

    internal func resolvedGameIdentifier() -> String {
        let charSet = CharacterSet(
            charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-."
        )
        if let identifer: StaticString = self.gameIdentifier() {
            let customIdentifier = identifer.withUTF8Buffer {
                return String(decoding: $0, as: UTF8.self)
            }
            assert(
                customIdentifier.trimmingCharacters(in: charSet).isEmpty,
                "gameIdentifier can only contain english letters, numbers, `_`, `-` or `.`."
            )
            assert(customIdentifier.first != ".", "gameIdentifier can't start with a period.")
            return customIdentifier
        }

        #if canImport(Darwin)
        // Apple has a identifier system for thier platforms already, use it
        if let identifier = Bundle.main.bundleIdentifier {
            return identifier
        }
        #endif

        func getGameModuleName() -> String {
            let ref = String(reflecting: type(of: self))
            return String(ref.split(separator: ".")[0])
        }

        var identifier: String = ""
        var isFirst = true
        for character in CommandLine.arguments.first ?? getGameModuleName() {
            if isFirst {
                isFirst = false
                if character == "." {
                    // Don't allow period as the first character as it means something to most file systems.
                    identifier.append("_")
                    continue
                }
            }
            let scalars = character.unicodeScalars
            if scalars.count == 1, let scalar = scalars.first {
                if charSet.contains(scalar) {
                    identifier.append(character)
                    continue
                }
            }
            identifier.append("_")
        }
        return identifier
    }
    
    public func openURLs(_ urls: [URL]) {
        
    }
}

extension GameDelegate {
    @MainActor public static func main() async throws {
        let delegate = Self()
        Game._shared = Game(delegate: delegate)
        if try await delegate.shouldFinishLaunching(game: Game.shared) == true {
            Platform.current.main()
        }
    }
}
