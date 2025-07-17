/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
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

    @usableFromInline
    nonisolated static let mainWindowIdentifier: String = "main"

    public private(set) weak var mainWindow: Window? = nil

    public func window(withIdentifier identifier: String) -> Window? {
        return windows.first(where: {
            $0.identifier.caseInsensitiveCompare(identifier) == .orderedSame
        })
    }

    @discardableResult
    public func createWindow(
        identifier: String,
        style: WindowStyle = .system,
        options: WindowOptions = .default,
        rootViewController: ViewController
    ) throws -> Window {
        guard game.isHeadless == false else {
            throw GateEngineError.failedToCreateWindow(
                "Cannot create a window when running headless."
            )
        }
        precondition(
            game.attributes.contains(.renderingIsPermitted),
            "A window can only be created from a RenderingSystem."
        )
        guard game.platform.supportsMultipleWindows || windows.isEmpty else {
            throw GateEngineError.failedToCreateWindow(
                "This platform doesn't support multiple windows."
            )
        }
        if let existing = self.window(withIdentifier: identifier) {
            Log.warn(
                "Window with identifier \(identifier) already exists. It was returned with it's original style and options."
            )
            return existing
        }
        let window: Window = Window(
            identifier: identifier,
            rootViewController: rootViewController, 
            style: style,
            options: options
        )
        self.windows.append(window)
        if identifier == Self.mainWindowIdentifier {
            self.mainWindow = window
        }
        window.show()
        return window
    }

    internal func removeWindow(_ identifier: String) {
        windows.removeAll(where: {
            $0.identifier.caseInsensitiveCompare(identifier) == .orderedSame
        })

        // If the main window is closed, close all windows
        #if GATEENGINE_CLOSES_ALLWINDOWS_WITH_MAINWINDOW
        if identifier == Self.mainWindowIdentifier {
            for window in windows {
                window.windowBacking.close()
            }
        }
        #endif
    }

    @inlinable
    func identifierIsUnused(_ identifier: String) -> Bool {
        for window: Window in windows {
            if window.identifier.caseInsensitiveCompare(identifier) == .orderedSame {
                return false
            }
        }
        return true
    }

    internal var windowsThatRequestedDraw: [(window: Window, deltaTime: Double)] = []

    func updateWindows(deltaTime: Float) async {
        for window in windows {
            await window._update(deltaTime: deltaTime)
        }
    }
    
    func drawWindows() {
        game.attributes.insert(.renderingIsPermitted)
        for pair: (window: Window, deltaTime: Double) in windowsThatRequestedDraw {
            pair.window._draw(deltaTime: pair.deltaTime)
        }
        game.attributes.remove(.renderingIsPermitted)
        self.windowsThatRequestedDraw.removeAll(keepingCapacity: true)
//        Game.shared.ecs.performance?.endFrame()
    }
}

extension WindowManager {
    func window(_ window: Window, wantsUpdateForTimePassed deltaTime: Double) {
        window.didDrawSomething = false
        if let index = windowsThatRequestedDraw.firstIndex(where: { $0.window == window }) {
            // If the window dropped a frame, add the next deltaTime
            self.windowsThatRequestedDraw[index].deltaTime += deltaTime
        } else {
            self.windowsThatRequestedDraw.append((window, deltaTime))
        }
        #if GATEENGINE_PLATFORM_EVENT_DRIVEN
        Game.shared.eventLoop {

        }
        #endif
    }
}
