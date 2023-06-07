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

    @discardableResult
    public func createWindow(identifier: String, style: WindowStyle) throws -> Window {
        guard game.isHeadless == false else {throw "Cannot create a window when running headless."}
        precondition(game.renderingIsPermitted, "A window can only be created from a RenderingSystem.")
        #if GATEENGINE_PLATFORM_EVENT_DRIVEN
        // Single threaded platforms can only ever have 1 window
        guard windows.isEmpty else {throw "This platform doesn't support multiple windows."}
        #else
        guard game.platform.supportsMultipleWindows || windows.isEmpty else {throw "This platform doesn't support multiple windows."}
        #endif
        guard identifierIsUnused(identifier) else {throw "Window with identifier \"\(identifier)\" already exists."}
        let window: Window = Window(identifier: identifier, style: style)
        self.windows.append(window)
        if identifier == mainWindowIdentifier {
            self.mainWindow = window
        }
        window.delegate = self
        window.show()
        return window
    }

    internal func removeWindow(_ identifier: String) {
        windows.removeAll(where: {$0.identifier.caseInsensitiveCompare(identifier) == .orderedSame})
        
        // If the main window is closed, close all windows
        if identifier == mainWindowIdentifier {
            for window in windows {
                window.windowBacking.close()
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
    
    internal var windowsThatRequestedDraw: [(window: Window, deltaTime: Float)] = []
    
    @inline(__always)
    func drawWindows() {
        game.renderingIsPermitted = true
        for pair: (window: Window, deltaTime: Float) in windowsThatRequestedDraw {
            game.ecs.updateRendering(withTimePassed: pair.deltaTime, window: pair.window)
            pair.window.didDrawSomething = true
        }
        game.renderingIsPermitted = false
        self.windowsThatRequestedDraw.removeAll(keepingCapacity: true)
    }
}

extension WindowManager: WindowDelegate {
    @inline(__always)
    func window(_ window: Window, wantsUpdateForTimePassed deltaTime: Float) {
        window.didDrawSomething = false
        if let index = windowsThatRequestedDraw.firstIndex(where: {$0.window == window}) {
            // If the window dropped a frame, add the next deltaTime
            self.windowsThatRequestedDraw[index].deltaTime += deltaTime
        }else{
            self.windowsThatRequestedDraw.append((window, deltaTime))
        }
    }
    
    @_transparent
    func mouseChange(event: MouseChangeEvent, position: Position2, delta: Position2, window: Window?) {
        game.hid.mouseChange(event: event, position: position, delta: delta, window: window)
    }
    @_transparent
    func mouseClick(event: MouseClickEvent, button: MouseButton, count: Int?, position: Position2?, delta: Position2?, window: Window?) {
        game.hid.mouseClick(event: event, button: button, count: count, position: position, delta: delta, window: window)
    }
    
    @_transparent
    func screenTouchChange(id: AnyHashable, kind: TouchKind, event: TouchChangeEvent, position: Position2) {
        game.hid.screenTouchChange(id: id, kind: kind, event: event, position: position)
    }
    @_transparent
    func surfaceTouchChange(id: AnyHashable, event: TouchChangeEvent, surfaceID: AnyHashable, normalizedPosition: Position2) {
        game.hid.surfaceTouchChange(id: id, event: event, surfaceID: surfaceID, normalizedPosition: normalizedPosition)
    }

    @_transparent
    func keyboardDidhandle(key: KeyboardKey,
                           character: Character?,
                           modifiers: KeyboardModifierMask,
                           isRepeat: Bool,
                           event: KeyboardEvent) -> Bool {
        return game.hid.keyboardDidhandle(key: key,
                                          character: character,
                                          modifiers: modifiers,
                                          isRepeat: isRepeat,
                                          event: event)
    }
}
