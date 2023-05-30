/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(UIKit)

import UIKit
import AVFoundation

class UIKitPlatform: InternalPlatform {
    let searchPaths: [URL] = {
        let url = Bundle.module.bundleURL.deletingLastPathComponent()
        do {
            var files = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            files = files.filter({$0.pathExtension.caseInsensitiveCompare("bundle") == .orderedSame})
            return files.compactMap({Bundle(url: $0)?.resourceURL})
        }catch{
            Log.error("Failed to load resource bundles!\n", error)
        }
        return [Bundle.main, Bundle.module].compactMap({$0.resourceURL})
    }()
    
    func locateResource(from path: String) async -> String? {
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
                let url = URL(fileURLWithPath: path)
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
        if clock_gettime(CLOCK_MONOTONIC_RAW, &time) != 0 {
            return -1
        }
        return Double(time.tv_sec) + (Double(time.tv_nsec) / 1e+9)
    }
    
    var supportsMultipleWindows: Bool {
        return false
    }
}

internal final class UIKItAppDelegate: NSObject, UIApplicationDelegate {
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
    
    func applicationWillTerminate(_ application: UIApplication) {
        Game.shared.willTerminate()
    }
}

extension UIKitPlatform {
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
            Log.info("Creating generic Info.plist then quitting...")
            exit(0)
        }
        
        UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(UIKItAppDelegate.self))
    }
}

#endif
