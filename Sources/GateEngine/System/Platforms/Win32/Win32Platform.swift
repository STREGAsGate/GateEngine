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
    let searchPaths: [URL] = getStaticSearchPaths()
    var pathCache: [String:String] = [:]
    
    var supportsMultipleWindows: Bool {
        return true
    }
}

extension Win32Platform {
    private func makeManifest() {
        var url = URL(fileURLWithPath: CommandLine.arguments[0])
        let manifest = """
        <assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0" xmlns:asmv3="urn:schemas-microsoft-com:asm.v3" >
        <asmv3:application>
            <asmv3:windowsSettings xmlns="http://schemas.microsoft.com/SMI/2005/WindowsSettings">
            <dpiAware>true</dpiAware>
            </asmv3:windowsSettings>
        </asmv3:application>
        </assembly>
        """
        let name: String = url.lastPathComponent + ".manifest"
        url.deleteLastPathComponent()
        url.appendPathComponent(name)
        do {
            if FileManager.default.fileExists(atPath: url.path) == false {
                try manifest.write(to: url, atomically: false, encoding: .utf8)
            }
        }catch{
            Log.error("Failed to create manifest: \(name)\n", error)
        }
    }
    @MainActor func main() {
        makeManifest()

        var msg: MSG = MSG()
        var nExitCode: Int32 = EXIT_SUCCESS

        Game.shared.didFinishLaunching()
        
        var window: Win32Window? = Game.shared.windowManager.mainWindow?.windowBacking as? Win32Window
        mainLoop: while true {
            if Game.shared.windowManager.windows.isEmpty {
                window = nil
                WinSDK.PostQuitMessage(WinSDK.EXIT_SUCCESS)
            }
            // Process all messages in thread's message queue; for GUI applications UI
            // events must have high priority.
            window?.window.vSyncCalled()

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
            if let time: Date = time, let exactly: UInt32 = DWORD(exactly: time.timeIntervalSinceNow) {
                _ = MsgWaitForMultipleObjects(0, nil, false,
                                            exactly,
                                            DWORD(QS_ALLINPUT) | DWORD(QS_KEY) | DWORD(QS_MOUSE) | DWORD(QS_RAWINPUT))
            }
        }

        Game.shared.willTerminate()
        exit(nExitCode)
    }
}

#endif
