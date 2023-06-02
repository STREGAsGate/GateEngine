/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(UIKit)

import UIKit
import AVFoundation

public final class UIKitPlatform: Platform, InternalPlatform {
    public static let staticSearchPaths: [URL] = getStaticSearchPaths()
    var pathCache: [String:String] = [:]
    
    public var supportsMultipleWindows: Bool {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad, .mac:
            return true
        default:
            return false
        }
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

internal final class UIKitApplicationDelegate: NSObject, UIApplicationDelegate {
    func applicationDidFinishLaunching(_ application: UIApplication) {
        Game.shared.didFinishLaunching()
        
        do {// The following will silence music if a user is already playing their own music
            let session = AVAudioSession.sharedInstance()
            
            do {
                try session.setCategory(.ambient)
                try session.setActive(true)
            }catch{
                Log.error("AVAudioSession", error)
            }
            
            if session.secondaryAudioShouldBeSilencedHint {
                if let mixer = Game.shared.audio.musicMixers[.music] {
                    mixer.volume = 0
                }
            }else{
                if let mixer = Game.shared.audio.musicMixers[.music] {
                    mixer.volume = 1
                }
            }
            
            NotificationCenter.default.addObserver(forName: AVAudioSession.silenceSecondaryAudioHintNotification, object: nil, queue: nil) { notification in
                if notification.userInfo?[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? Int == 1 {
                    if let mixer = Game.shared.audio.musicMixers[.music] {
                        mixer.volume = 0
                    }
                }else{
                    if let mixer = Game.shared.audio.musicMixers[.music] {
                        mixer.volume = 1
                    }
                }
            }
        }
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: connectingSceneSession.configuration.name, sessionRole: connectingSceneSession.role)
        config.delegateClass = UIKitWindowSceneDelegate.self
        return config
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        Game.shared.willTerminate()
    }
}

internal final class UIKitWindowSceneDelegate: NSObject, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {return}
        do {
            Game.shared.renderingIsPermitted = true
            let window: Window
            if Game.shared.windowManager.windows.isEmpty {
                window = try Game.shared.delegate.createMainWindow(game: Game.shared, identifier: Game.shared.windowManager.mainWindowIdentifier)
            }else{
                window = try Game.shared.windowManager.createWindow(identifier: session.persistentIdentifier, style: .system)
            }
            let uiWindow = (window.windowBacking as! UIKitWindow).uiWindow
            uiWindow.windowScene = windowScene
            Game.shared.renderingIsPermitted = false
        }catch{
            Log.error(error)
        }
    }
}

extension UIKitPlatform {
    @MainActor func main() {
        if Bundle.main.bundleIdentifier == nil {
            Log.error("Info.plist not found.")
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
            Log.info("Creating generic Info.plist then quitting... You need to manually start the Game again.")
            exit(0)
        }
        
        UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(UIKitApplicationDelegate.self))
    }
}

#endif
