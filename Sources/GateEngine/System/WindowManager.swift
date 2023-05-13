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
        guard game.isHeadless == false else {throw "[GateEngine] Cannot create a window when running headless."}
        precondition(game.renderingIsPermitted, "A window can only be created from a RenderingSystem.")
        #if !GATEENGINE_SUPPORTS_MULTIWINDOW
        guard windows.isEmpty else {throw "This platform doesn't support multiple windows."}
        #endif
        guard identifierIsUnused(identifier) else {throw "Window with identifier \"\(identifier)\" already exists."}
        let window: Window = Window(identifier: identifier, style: style)
        self.windows.append(window)
        if identifier == mainWindowIdentifier {
            self.mainWindow = window
        }
        window.delegate = self
        window.show()
    }

    internal func removeWindow(_ identifier: String) {
        windows.removeAll(where: {$0.identifier.caseInsensitiveCompare(identifier) == .orderedSame})
        
        // If the main window is closed, close all windows
        if identifier == mainWindowIdentifier {
            for window in windows {
                window.backing.close()
            }
        }
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

extension WindowManager: WindowDelegate {
    func window(_ window: Window, wantsUpdateForTimePassed deltaTime: Float) {
        #if GATEENGINE_SUPPORTS_MULTIWINDOW
        self.game.renderingIsPermitted = true
        game.windowsThatRequestedDraw.append((window, deltaTime))
        self.game.renderingIsPermitted = false
        #else
        if self.game.ecs.shouldRenderAfterUpdate(withTimePassed: deltaTime) {
            self.game.ecs.updateRendering(withTimePassed: deltaTime, window: window)
        }
        #endif
    }
    
    func mouseChange(event: MouseChangeEvent, position: Position2) {
        game.hid.mouseChange(event: event, position: position)
    }
    func mouseClick(event: MouseClickEvent, button: MouseButton, count: Int?, position: Position2) {
        game.hid.mouseClick(event: event, button: button, count: count, position: position)
    }

    func touchChange(id: AnyHashable, kind: TouchKind, event: TouchChangeEvent, position: Position2) {
        game.hid.touchChange(id: id, kind: kind, event: event, position: position)
    }

    func keyboardRequestedHandling(key: KeyboardKey,
                                   modifiers: KeyboardModifierMask,
                                   event: KeyboardEvent) -> Bool {
        return game.hid.keyboardRequestedHandling(key: key, modifiers: modifiers, event: event)
    }
}
