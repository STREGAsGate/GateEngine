/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(AppKit) && !GATEENGINE_ENABLE_WASI_IDE_SUPPORT

import AppKit
import System

public final class AppKitPlatform: InternalPlatform {
    public static let fileSystem: AppleFileSystem = AppleFileSystem()
    let staticResourceLocations: [URL]
    
    init(delegate: GameDelegate) async {
        self.staticResourceLocations = await Self.getStaticSearchPaths(delegate: delegate)
    }
    
    public var supportsMultipleWindows: Bool {
        return true
    }
    
    public func locateResource(from path: String) async -> String? {
        let searchPaths = Game.shared.delegate.customResourceLocations() + staticResourceLocations
        for searchPath in searchPaths {
            let file = searchPath.appendingPathComponent(path)
            if fileSystem.itemExists(at: file.path) {
                return file.path
            }
        }
        return nil
    }
    
    public func loadResource(from path: String) async throws -> Data {
        if let resolvedPath = await locateResource(from: path) {
            do {
                return try await fileSystem.read(from: resolvedPath)
            }catch{
                Log.error("Failed to load resource \"\(resolvedPath)\".")
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
        Task(priority: .high) {@MainActor in
            await Game.shared.didFinishLaunching()
        }
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
                <string>com.stregasgate.third-party-dev.\(url.lastPathComponent)</string>
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
                guard let rasterizationScale = Game.shared.windowManager.mainWindow?.interfaceScale else {return}
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
        
        final class CustomApp: NSApplication {
            #if GATEENGINE_DEBUG_HID
            // can't prevent the system from sending media keys to other apps, like music, so these are dead in the water for usability
            override func sendEvent(_ event: NSEvent) {
                var forward: Bool = true
                if (event.type == .systemDefined && event.subtype.rawValue == 8) {
                    let keyCode = ((event.data1 & 0xFFFF0000) >> 16)
                    let keyFlags = (event.data1 & 0x0000FFFF)
                    // Get the key state. 0xA is KeyDown, OxB is KeyUp
                    let keyState: KeyboardEvent = (((keyFlags & 0xFF00) >> 8)) == 0xA ? .keyDown : .keyUp
                    let keyRepeat: Bool = (keyFlags & 0x1) != 0
                    
                    let key: KeyboardKey
                    switch Int32(keyCode) {
//                    case NX_NOSPECIALKEY:
//                        key =
                    case NX_KEYTYPE_SOUND_UP:
                        key = .volumeUp
                    case NX_KEYTYPE_SOUND_DOWN:
                        key = .volumeDown
//                    case NX_KEYTYPE_BRIGHTNESS_UP:
//                        key =
//                    case NX_KEYTYPE_BRIGHTNESS_DOWN:
//                        key =
                    case NX_KEYTYPE_CAPS_LOCK:
                        key = .capsLock
//                    case NX_KEYTYPE_HELP:
//                        key =
//                    case NX_POWER_KEY:
//                        key =
                    case NX_KEYTYPE_MUTE:
                        key = .mute
//                    case NX_UP_ARROW_KEY:
//                        key = .up
//                    case NX_DOWN_ARROW_KEY:
//                        key = .down
                    case NX_KEYTYPE_NUM_LOCK:
                        key = .numLock
                        
//                    case NX_KEYTYPE_CONTRAST_UP:
//                        key =
//                    case NX_KEYTYPE_CONTRAST_DOWN:
//                        key =
//                    case NX_KEYTYPE_LAUNCH_PANEL:
//                        key =
//                    case NX_KEYTYPE_EJECT:
//                        key =
//                    case NX_KEYTYPE_VIDMIRROR:
//                        key =
                        
                    case NX_KEYTYPE_PLAY:
                        key = .mediaPlayPause
//                    case NX_KEYTYPE_NEXT:
//                        key = .mediaNextTrack
//                    case NX_KEYTYPE_PREVIOUS:
//                        key = .mediaPreviousTrack
                    case NX_KEYTYPE_FAST:
                        key = .mediaNextTrack
                    case NX_KEYTYPE_REWIND:
                        key = .mediaPreviousTrack
                        
//                    case NX_KEYTYPE_ILLUMINATION_UP:
//                        key =
//                    case NX_KEYTYPE_ILLUMINATION_DOWN:
//                        key =
//                    case NX_KEYTYPE_ILLUMINATION_TOGGLE:
//                        key =
//
//                    case NX_NUMSPECIALKEYS:
//                        key =  /* Maximum number of special keys */
//                    case NX_NUM_SCANNED_SPECIALKEYS:
//                        key =  /* First 24 special keys are */
//                        /* actively scanned in kernel */
//
//                    case NX_KEYTYPE_MENU:
//                        key =
                    default:
                        key = .unhandledPlatformKeyCode(keyCode, nil)
                    }
                    
                    if Game.shared.hid.keyboardDidhandle(key: key, character: nil, modifiers: [], isRepeat: keyRepeat, event: keyState) {
                        forward = true
                    }
                }

                if forward {
                    super.sendEvent(event)
                }
            }
            #endif
        }
        let app = CustomApp.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.regular)
        
        self.setupStatusBarMenu()
        
        app.run()
    }
}

#endif
