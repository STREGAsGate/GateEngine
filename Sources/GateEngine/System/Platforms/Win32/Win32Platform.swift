/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(WinSDK)

import WinSDK
import Foundation

@MainActor struct Win32Platform: InternalPlatform {
    let searchPaths: [URL] = {
        let url: URL = Bundle.module.bundleURL.deletingLastPathComponent()
        do {
            var files: [URL] = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            files = files.filter({$0.pathExtension.caseInsensitiveCompare("bundle") == .orderedSame})
            return files.compactMap({Bundle(url: $0)?.resourceURL})
        }catch{
            print("[GateEngine] Error: Failed to load resource bundles!\n", error)
        }
        return [Bundle.main, Bundle.module].compactMap({$0.resourceURL})
    }()
    
    var pathCache: [String:String] = [:]
    func locateResource(from path: String) async -> String? {
        if let existing: String = pathCache[path] {
            return existing
        }
        let searchPaths: [URL] = Game.shared.delegate.resourceSearchPaths() + searchPaths
        for searchPath: URL in searchPaths {
            let file: URL = searchPath.appendingPathComponent(path)
            let path: String = file.path
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        return nil
    }
    
    func loadResource(from path: String) async throws -> Data {
        if let path: String = await locateResource(from: path) {
            do {
                let url: URL = URL(fileURLWithPath: path)
                return try Data(contentsOf: url, options: .mappedIfSafe)
            }catch{
                print("[GateEngine] Error: Failed to load resource \(path).")
                throw error
            }
        }
        throw "[GateEngine] Error: Failed to load resource " + path + "."
    }
    
    func saveStateURL() throws -> URL {
        var url: URL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        url.appendPathComponent(Bundle.main.bundleIdentifier ?? CommandLine.arguments[0])
        url.appendPathComponent("SaveState.data")
        return url
    }
    func loadState() -> Game.State {
        do {
            let data: Data = try Data(contentsOf: try saveStateURL())
            return try JSONDecoder().decode(Game.State.self, from: data)
        }catch{
            print(error.localizedDescription)
            return Game.State()
        }
    }
    func saveState(_ state: Game.State) throws {
        let url: URL = try saveStateURL()
        let data: Data = try JSONEncoder().encode(state)
        try data.write(to: url, options: .atomic)
    }
    
    func systemTime() -> Double {
        return Date.timeIntervalSinceReferenceDate
    }
}

extension Win32Platform {
    @MainActor func main() {
        var msg: MSG = MSG()
        var nExitCode: Int32 = EXIT_SUCCESS

        Game.shared.didFinishLaunching()
        
        mainLoop: while true {
            // Process all messages in thread's message queue; for GUI applications UI
            // events must have high priority.
            while PeekMessageW(&msg, nil, 0, 0, UINT(PM_REMOVE)) {
                if msg.message == UINT(WM_QUIT) {
                    nExitCode = Int32(msg.wParam)
                    break mainLoop
                }

                TranslateMessage(&msg)
                DispatchMessageW(&msg)
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

            // Yield control to the system until the earlier of a requisite timer
            // expiration or a message is posted to the runloop.
            _ = MsgWaitForMultipleObjects(0, nil, false,
                                        DWORD(exactly: time?.timeIntervalSinceNow ?? -1) ?? INFINITE,
                                        DWORD(QS_ALLINPUT) | DWORD(QS_KEY) | DWORD(QS_MOUSE) | DWORD(QS_RAWINPUT))
        }

        Game.shared.willTerminate()
        exit(nExitCode)
    }
}

#endif
