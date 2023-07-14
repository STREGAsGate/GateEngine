/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(Linux)

import Foundation
import LinuxSupport

public final class LinuxPlatform: Platform, InternalPlatform {
    let fileSystem: FileSystem = LinuxFileSystem()
    static let staticSearchPaths: [URL] = getStaticSearchPaths()
    var pathCache: [String:String] = [:]
    
    public var supportsMultipleWindows: Bool {
        return true
    }
    
    public func locateResource(from path: String) async -> String? {
        if let existing = pathCache[path] {
            return existing
        }
        let searchPaths = Game.shared.delegate.customResourceLocations() + Self.staticSearchPaths
        for searchPath in searchPaths {
            let file = searchPath.appendingPathComponent(path)
            let path = file.path
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        return nil
    }
    
    public func loadResource(from path: String) async throws -> Data {
        if let path = await locateResource(from: path) {
            do {
                let url: URL = URL(fileURLWithPath: path)
                return try Data(contentsOf: url, options: .mappedIfSafe)
            }catch{
                Log.error("Failed to load resource \"\(path)\".")
                throw error
            }
        }
        throw "failed to locate."
    }
}

extension LinuxPlatform {
    @MainActor func main() {
        var nExitCode: Int32 = EXIT_SUCCESS

        Game.shared.didFinishLaunching()
        
        var window: Window? = Game.shared.windowManager.mainWindow
        mainLoop: while true {

            let eventMask: Int = (StructureNotifyMask | EnterWindowMask | LeaveWindowMask | PointerMotionMask | ButtonPressMask | ButtonReleaseMask | KeyPressMask | KeyReleaseMask)
            for window: Window in Game.shared.windowManager.windows {
                let x11Window: X11Window = window.windowBacking as! X11Window
                var event: XEvent = XEvent()
                while XCheckWindowEvent(x11Window.xDisplay, x11Window.xWindow, eventMask, &event) == 1 {
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
        exit(nExitCode)
    }
}

#endif
