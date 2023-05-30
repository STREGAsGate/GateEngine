/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(macOS)

import AppKit
import System

@MainActor struct AppKitPlatform: InternalPlatform {
    let searchPaths: [URL] = {
        let url = Bundle.module.bundleURL.deletingLastPathComponent()
        do {
            var files = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            files = files.filter({$0.pathExtension.caseInsensitiveCompare("bundle") == .orderedSame}).compactMap({Bundle(url: $0)?.resourceURL})
            files = files.compactMap({
                do {
                    if try $0.checkResourceIsReachable() {
                        return $0
                    }
                }catch{
                    Log.info("Failed to load resource bundle \"\($0)\"")
                }
                return nil
            })
            if files.isEmpty == false {
                return files
            }
        }catch{
            Log.error("Failed to load resource bundles!\n", error)
        }

        let files = [Bundle.main, Bundle.module].compactMap({$0.resourceURL}).compactMap({
            do {
                if try $0.checkResourceIsReachable() {
                    return $0
                }
            }catch{
                Log.info("Failed to load resource bundle \"\($0)\"")
            }
            return nil
        })
        if files.isEmpty {
            Log.error("Failed to load resource bundles! Probably Sandboxing.")
        }
        return files
    }()
    
    var pathCache: [String:String] = [:]
    func locateResource(from path: String) async -> String? {
        if let existing = pathCache[path] {
            return existing
        }
        let searchPaths = Game.shared.delegate.resourceSearchPaths() + searchPaths
        for searchPath in searchPaths {
            let file = searchPath.appendingPathComponent(path)
            let path = file.path
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        return nil
    }
    
    func loadResource(from path: String) async throws -> Data {
        if let path = await locateResource(from: path) {
            do {
                let url: URL
                if #available(macOS 13.0, *) {
                    url = URL(filePath: path)
                } else {
                    url = URL(fileURLWithPath: path)
                }
                return try Data(contentsOf: url, options: .mappedIfSafe)
            }catch{
                Log.error("Failed to load resource \"\(path)\".")
                throw error
            }
        }
        throw "failed to locate."
    }
    
    func saveStateURL() throws -> URL {
        var url = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        url.appendPathComponent(Bundle.main.bundleIdentifier ?? CommandLine.arguments[0])
        url.appendPathComponent("SaveState.data")
        return url
    }
    func loadState() -> Game.State {
        do {
            let data = try Data(contentsOf: try saveStateURL())
            return try JSONDecoder().decode(Game.State.self, from: data)
        }catch{
            Log.error("Game.State failed to restore:", error)
            return Game.State()
        }
    }
    func saveState(_ state: Game.State) throws {
        let url = try saveStateURL()
        let data = try JSONEncoder().encode(state)
        try data.write(to: url, options: .atomic)
    }
    
    func systemTime() -> Double {
        var time = timespec()
        if clock_gettime(CLOCK_MONOTONIC, &time) != 0 {
            return -1
        }
        return Double(time.tv_sec) + (Double(time.tv_nsec) / 1e+9)
    }
    
    var supportsMultipleWindows: Bool {
        return true
    }
}

extension AppKitPlatform {
    func setupStatusBarMenu() {
        let appBundleOrCommandLineName = (Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String) ?? CommandLine.arguments[0].components(separatedBy: "/").last
        let appName = Bundle.main.localizedString(forKey: "CFBundleDisplayName", value: appBundleOrCommandLineName, table: nil)
        let mainMenu = NSMenu()
        
        let appMenu = NSMenu()
        let quit = NSMenuItem(title: "Quit \(appName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quit.keyEquivalentModifierMask = [.command]
        appMenu.addItem(quit)
        
        let appMenuItem = NSMenuItem()
        appMenuItem.title = appName
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)
        
        NSApplication.shared.mainMenu = mainMenu
    }
}

fileprivate class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        Game.shared.resourceManager.addTextureImporter(ApplePlatformImageImporter.self, atEnd: true)
        Game.shared.resourceManager.addGeometryImporter(ApplePlatformModelImporter.self, atEnd: true)
        Game.shared.didFinishLaunching()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        Game.shared.willTerminate()
    }
}

extension AppKitPlatform {
    @MainActor func main() {
        if Bundle.main.bundleIdentifier == nil {
            var url = URL(fileURLWithPath: CommandLine.arguments[0])
            let plist = """
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
                <key>CFBundleDisplayName</key>
                <string>\(url.lastPathComponent)</string>
                <key>CFBundleExecutable</key>
                <string>\(url.lastPathComponent)</string>
                <key>CFBundleIdentifier</key>
                <string>com.swift.\(url.lastPathComponent)</string>
                <key>CFBundleInfoDictionaryVersion</key>
                <string>6.0</string>
                <key>CFBundleName</key>
                <string>\(url.lastPathComponent)</string>
                <key>CFBundleShortVersionString</key>
                <string>1.0</string>
                <key>CFBundleVersion</key>
                <string>1</string>
            </dict>
            </plist>
            """
            url.deleteLastPathComponent()
            url.appendPathComponent("Info.plist")
            try? plist.write(to: url, atomically: false, encoding: .utf8)
            Log.info("Creating generic Info.plist")
            let alert = NSAlert()
            alert.messageText = "Created mock Info.plist in the build directory. This required to trick macOS into thinking your executable is an App. Game Controllers may not function without it.\n\nClick continue to ignore. Quit and launch again to ensure everything functions correctly."
            alert.addButton(withTitle: "Quit")
            alert.addButton(withTitle: "Continue")
            switch alert.runModal() {
            case .alertFirstButtonReturn:
                exit(0)
            default:
                break
            }
        }
        
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.regular)
        
        self.setupStatusBarMenu()
        
        app.run()
    }
}

#endif
