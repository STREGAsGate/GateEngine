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
    public static let fileSystem: AppleFileSystem = AppleFileSystem()
    public let staticResourceLocations: [URL]
    
    init(delegate: GameDelegate) async {
        self.staticResourceLocations = await Self.getStaticSearchPaths(delegate: delegate)
    }
    
    internal var applicationRequestedWindow: Bool = false
    weak internal var windowPreparingForSceneConnection: UIKitWindow? = nil
    
    internal var overrideSupportsMultipleWindows: Bool? = nil
    public var supportsMultipleWindows: Bool {
        if let overrideSupportsMultipleWindows {
            return overrideSupportsMultipleWindows
        }
        return UIApplication.shared.supportsMultipleScenes
    }
    
    public func locateResource(from path: String) async -> String? {
        let searchPaths = Game.shared.delegate.customResourceLocations() + staticResourceLocations
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
            }catch{
                Log.error("Failed to load resource \"\(resolvedPath)\".", error)
                throw GateEngineError.failedToLoad("\(error)")
            }
        }
        
        throw GateEngineError.failedToLocate
    }
}

internal final class UIKitApplicationDelegate: NSObject, UIApplicationDelegate {
    func applicationDidFinishLaunching(_ application: UIApplication) {
        Task(priority: .high) {
            await Game.shared.didFinishLaunching()
        }
        
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
        for session in application.openSessions {
            application.requestSceneSessionDestruction(session, options: nil)
        }
    }
}

internal final class UIKitWindowSceneDelegate: NSObject, UIWindowSceneDelegate {
    func attachExistingWindow(forSession session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) -> UIKitWindow? {
        if let userActivity = (connectionOptions.userActivities.first(where: {$0.activityType == "GateEngineWindow"}) ?? session.stateRestorationActivity) {
            if let requestedWindowIdentifier = userActivity.userInfo?["WindowIdentifier"] as? String {
                if let createdWindow = Game.shared.windowManager.window(withIdentifier: requestedWindowIdentifier) {
                    let uiKitWindow = createdWindow.windowBacking as? UIKitWindow
                    if let title = UserDefaults.standard.string(forKey: "Windows/\(createdWindow.identifier)/title") {
                        createdWindow.title = title
                    }
                    return uiKitWindow
                }
            }
        }
        return nil
    }
    
    func persistSessionIdentifier(_ session: UISceneSession, forWindow window: Window) {
        UserDefaults.standard.set(window.identifier, forKey: session.persistentIdentifier)
        UserDefaults.standard.synchronize()
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {return}
        do {
            Game.shared.renderingIsPermitted = true
            if let restoredWindow = attachExistingWindow(forSession: session, options: connectionOptions) {
                assert(restoredWindow.window.isMainWindow == false)
                restoredWindow.uiWindow.windowScene = windowScene
                windowScene.title = restoredWindow.title
            }else if session.stateRestorationActivity != nil {
                UIApplication.shared.requestSceneSessionDestruction(session, options: nil)
            }else if Game.shared.windowManager.mainWindow == nil && session.role == .windowApplication {
                let window = try Game.shared.delegate.createMainWindow(game: Game.shared, identifier: WindowManager.mainWindowIdentifier)
                let uiWindow = (window.windowBacking as! UIKitWindow).uiWindow
                uiWindow.windowScene = windowScene
                windowScene.title = window.title
                persistSessionIdentifier(session, forWindow: window)
            }else{// Platform requested a window, probably from a user action
                Game.shared.platform.applicationRequestedWindow = true
                if session.role == .windowExternalDisplay {
                    Game.shared.platform.overrideSupportsMultipleWindows = true
                    if let window = try Game.shared.delegate.createWindowForExternalscreen(game: Game.shared) {
                        let uiKitWindow = (window.windowBacking as! UIKitWindow)
                        uiKitWindow.uiWindow.windowScene = windowScene
                        windowScene.title = window.title
                        persistSessionIdentifier(session, forWindow: window)
                    }
                    Game.shared.platform.overrideSupportsMultipleWindows = nil
                }else{
                    Game.shared.platform.overrideSupportsMultipleWindows = true
                    if let window = try Game.shared.delegate.createUserRequestedWindow(game: Game.shared) {
                        let uiWindow = (window.windowBacking as! UIKitWindow).uiWindow
                        uiWindow.windowScene = windowScene
                        windowScene.title = window.title
                        persistSessionIdentifier(session, forWindow: window)
                    }else{
                        UIApplication.shared.requestSceneSessionDestruction(session, options: nil)
                    }
                    Game.shared.platform.overrideSupportsMultipleWindows = nil
                }
            }
            Game.shared.renderingIsPermitted = false
        }catch{
            Log.error(error)
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        Log.info("Scene Disconnect:", scene.title ?? "[NoTitle]")
        for window in Game.shared.windowManager.windows {
            let uiWindow = (window.windowBacking as! UIKitWindow).uiWindow
            if uiWindow.windowScene?.session.persistentIdentifier == scene.session.persistentIdentifier {
                Game.shared.windowManager.removeWindow(window.identifier)
                UserDefaults.standard.removeObject(forKey: "Windows/\(window.identifier)/title")
                break
            }
            #if GATEENGINE_CLOSES_ALLWINDOWS_WITH_MAINWINDOW
            if window.isMainWindow {
                for session in UIApplication.shared.openSessions {
                    UIApplication.shared.requestSceneSessionDestruction(session, options: nil)
                }
            }
            #endif
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
