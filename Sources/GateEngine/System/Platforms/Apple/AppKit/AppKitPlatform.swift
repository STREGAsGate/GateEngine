/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(macOS)

import AppKit
import System

public final class AppKitPlatform: InternalPlatform {
    static let staticSearchPaths: [URL] = getStaticSearchPaths()
    var pathCache: [String:String] = [:]
    
    public var supportsMultipleWindows: Bool {
        return true
    }
    
    public func locateResource(from path: String) async -> String? {
        if let existing = pathCache[path] {
            return existing
        }
        let searchPaths = await Game.shared.delegate.resourceSearchPaths() + Self.staticSearchPaths
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
            Log.info("Info.plist not found.")
            Log.info("Creating generic Info.plist")
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
            
            do {
                if CommandLine.isDebuggingWithXcode {
                    let alert = NSAlert()
                    alert.messageText = "Created mock Info.plist in the build directory. This is required so macOS see's your executable as an App. Game Controllers may not function without it.\n\nClick continue to ignore. Quit and launch again to ensure everything functions correctly."
                    alert.addButton(withTitle: "Quit")
                    alert.addButton(withTitle: "Continue")
                    switch alert.runModal() {
                    case .alertFirstButtonReturn:
                        exit(0)
                    default:
                        break
                    }
                }else{
                    // Restart now if this is not being debugged by Xcode
                    Log.info("Restarting...")
                    let task = Process()
                    task.launchPath = "/usr/bin/open"
                    task.arguments = [CommandLine.arguments[0]]
                    task.launch()
                    exit(0)
                }
            }
        }
        
        if Bundle.main.infoDictionary?["CFBundleIconFile"] == nil && Bundle.main.infoDictionary?["CFBundleIconName"] == nil {
            Game.shared.defer {
                guard let rasterizationScale = Game.shared.windowManager.mainWindow?.windowBacking.backingScaleFactor else {return}
                Task {@MainActor in
                    let filePath = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent().path
                    let iconPath = await Game.shared.platform.locateResource(from: "GateEngine/Branding/Square Logo.png")!
                    if let image = NSImage(contentsOf: URL(fileURLWithPath: iconPath)) {
                        NSGraphicsContext.current?.saveGraphicsState()
                        if let bitmapRepresentation = NSBitmapImageRep(bitmapDataPlanes: nil,
                                                                       pixelsWide: 512 / Int(rasterizationScale),
                                                                       pixelsHigh: 512 / Int(rasterizationScale),
                                                                       bitsPerSample: 8,
                                                                       samplesPerPixel: 4,
                                                                       hasAlpha: true,
                                                                       isPlanar: false,
                                                                       colorSpaceName: .deviceRGB,
                                                                       bytesPerRow: 0, bitsPerPixel: 0) {
                            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRepresentation)
                            let resizedImage = NSImage(size: NSSize(width: 512 / Int(rasterizationScale), height: 512 / Int(rasterizationScale)))
                            
                            resizedImage.lockFocus()
                            NSGraphicsContext.current?.imageInterpolation = .high
                            image.draw(in: NSRect(origin: .zero, size: resizedImage.size), from: .zero, operation: .copy, fraction: 1)
                            resizedImage.unlockFocus()
                            NSWorkspace.shared.setIcon(resizedImage, forFile: filePath)
                        }
                        NSGraphicsContext.current?.restoreGraphicsState()
                    }
                }
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
