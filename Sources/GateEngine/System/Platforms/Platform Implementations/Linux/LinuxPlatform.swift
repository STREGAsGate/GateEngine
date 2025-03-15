/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(Linux)
import Foundation
import LinuxSupport

public final class LinuxPlatform: PlatformProtocol, InternalPlatformProtocol {
    public static let fileSystem: LinuxFileSystem = LinuxFileSystem()
    let staticResourceLocations: [URL]

    init(delegate: any GameDelegate) {
        self.staticResourceLocations = Self.getStaticSearchPaths(delegate: delegate)
    }

    public var supportsMultipleWindows: Bool {
        return true
    }

    public func locateResource(from path: String) async -> String? {
        if path.hasPrefix("/"), await fileSystem.itemExists(at: path) {
            return path
        }
        let searchPaths =
            await Game.shared.delegate.resolvedCustomResourceLocations() + staticResourceLocations
        for searchPath in searchPaths {
            let file = searchPath.appendingPathComponent(path)
            if await fileSystem.itemExists(at: file.path) {
                return file.path
            }
        }

        return nil
    }

    public func loadResource(from path: String) async throws -> Data {
        if let resolvedPath = await locateResource(from: path) {
            do {
                return try await fileSystem.read(from: resolvedPath)
            } catch {
                Log.error("Failed to load resource \"\(resolvedPath)\".", error)
                throw GateEngineError.failedToLoad("\(error)")
            }
        }

        throw GateEngineError.failedToLocate
    }
}

extension LinuxPlatform {
    @MainActor func main() {
        var done = false
        Task(priority: .high) { @MainActor in
            await Game.shared.didFinishLaunching()
            done = true
        }
        while done == false {
            RunLoop.main.run(until: Date())
        }

        let window: Window? = Game.shared.windowManager.mainWindow
        mainLoop: while true {

            let eventMask: Int =
                (StructureNotifyMask | EnterWindowMask | LeaveWindowMask | PointerMotionMask
                    | ButtonPressMask | ButtonReleaseMask | KeyPressMask | KeyReleaseMask)
            for window: Window in Game.shared.windowManager.windows {
                let x11Window: X11Window = window.windowBacking as! X11Window
                var event: XEvent = XEvent()
                while XCheckWindowEvent(x11Window.xDisplay, x11Window.xWindow, eventMask, &event)
                    == 1
                {
                    x11Window.processEvent(event)
                }
                x11Window.draw()
            }

            if Game.shared.windowManager.windows.isEmpty {
                break
            }

            var time: Date? = nil
            repeat {
                // Execute Foundation.RunLoop once and determine the next time the timer
                // fires.  At this point handle all Foundation.RunLoop timers, sources and
                // Dispatch.DispatchQueue.main tasks
                time = RunLoop.main.limitDate(forMode: .default)

                // If Foundation.RunLoop doesn't contain any timers or the timers should
                // not be running right now, we interrupt the current loop or otherwise
                // continue to the next iteration.
            } while (time?.timeIntervalSinceNow ?? -1) <= 0
        }

        Game.shared.willTerminate()
        exit(EXIT_SUCCESS)
    }
}

#endif
