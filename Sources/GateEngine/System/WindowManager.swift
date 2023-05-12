/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

@MainActor public final class WindowManager {
    unowned let game: Game
    internal init(_ game: Game) {
        self.game = game
    }

    @usableFromInline
    internal var windows: [Window] = []
    
    let mainWindowIdentifier: String = "main"
    public private(set) weak var mainWindow: Window? = nil
    
    public func window(withIdentifier identifier: String) -> Window? {
        return windows.first(where: {$0.identifier.caseInsensitiveCompare(identifier) == .orderedSame})
    }

    public func createWindow(identifier: String, style: WindowStyle) throws {
        #if !GATEENGINE_SUPPORTS_MULTIWINDOW
        guard windows.isEmpty else {throw "This platform doesn't support multiple windows."}
        #endif
        guard identifierIsUnused(identifier) else {throw "Window with identifier \"\(identifier)\" already exists."}
        let window: Window = Window(identifier: identifier, style: style)
        self.windows.append(window)
        if identifier == mainWindowIdentifier {
            self.mainWindow = window
        }
        window.delegate = game
        window.show()
    }

    internal func removeWindow(_ identifier: String) {
        windows.removeAll(where: {$0.identifier.caseInsensitiveCompare(identifier) == .orderedSame})
    }

    @inline(__always)
    func identifierIsUnused(_ identifier: String) -> Bool {
        for window: Window in windows {
            if window.identifier.caseInsensitiveCompare(identifier) == .orderedSame {
                return false
            }
        }
        return true
    }
}
