/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation
import Collections

public protocol Platform {
    func locateResource(from path: String) async -> String?
    func loadResource(from path: String) async throws -> Data
}

@usableFromInline
@MainActor internal protocol InternalPlatform: Platform {
    var pathCache: [String:String] {get set}
    var searchPaths: [URL] {get}
    
    func saveStateURL() throws -> URL
    func saveState(_ state: Game.State) throws
    func loadState() -> Game.State
    
    func systemTime() -> Double
    func main()
    
    var supportsMultipleWindows: Bool {get}
}

extension InternalPlatform {
    static func getStaticSearchPaths() -> [URL] {
#if os(iOS) || os(tvOS) || os(macOS)
        let bundleExtension: String = "bundle"
#else
        let bundleExtension: String = "resources"
#endif
        let searchURL = Bundle.main.resourceURL ?? Bundle.module.bundleURL.deletingLastPathComponent()
        
        // Add the application and GateEngine resource bundles if they exist
        var files: [URL] = [Bundle.main, Bundle.module].compactMap({$0.resourceURL})
        
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: searchURL, includingPropertiesForKeys: nil)
            files.append(contentsOf: urls)
        }catch{
            Log.info(error)
        }
        
        // Sometimes the URL varient returns empty arrays, use the path varient too and clear the duplicates
        do {
            let paths = try FileManager.default.contentsOfDirectory(atPath: searchURL.path)
            files.append(contentsOf: paths.map({URL(fileURLWithPath: $0)}))
        }catch{
            Log.info(error)
        }
        
        // Filter out non resource bundles
        files = files.filter({$0.pathExtension.caseInsensitiveCompare(bundleExtension) == .orderedSame}).compactMap({Bundle(url: $0)?.resourceURL})
        
        // Add the main bundles path
        if let mainResources = Bundle.main.resourceURL {
            files.append(mainResources)
        }
        
        // Add the executables path
        files.append(URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent())
        
        // Resolve simlinks so duplicates can be removed
        files = files.map({$0.resolvingSymlinksInPath()})
        
        // Remove duplicates and unreachable directories
        files = OrderedSet(files).compactMap({
            do {
                if try $0.checkResourceIsReachable() {
                    return $0
                }
            }catch{
                Log.info("Resource bundle \"\($0)\" is unreachable.")
            }
            return nil
        })
        
        if files.isEmpty == false {
            Log.error("Failed to load any resource bundles! Check code signing and directory premissions.")
        }
        return files
    }
    
    func saveStateURL() throws -> URL {
        var url: URL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        url.appendPathComponent(Bundle.main.bundleIdentifier ?? CommandLine.arguments[0])
        url.appendPathComponent("SaveState.data")
        return url
    }
    
    func systemTime() -> Double {
        var time = timespec()
        if clock_gettime(CLOCK_MONOTONIC_RAW, &time) != 0 {
            return -1
        }
        return Double(time.tv_sec) + (Double(time.tv_nsec) / 1e+9)
    }
}

extension Platform where Self: InternalPlatform {
    func locateResource(from path: String) async -> String? {
        if let existing = await pathCache[path] {
            return existing
        }
        let searchPaths = await Game.shared.delegate.resourceSearchPaths() + searchPaths
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

extension InternalPlatform {
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
}

@_transparent
@MainActor func makeDefaultPlatform() -> InternalPlatform {
#if canImport(UIKit)
    return UIKitPlatform()
#elseif canImport(AppKit)
    return AppKitPlatform()
#elseif canImport(WinSDK)
    return Win32Platform()
#elseif os(Linux)
    return LinuxPlatform()
#elseif os(WASI)
    return WASIPlatform()
#elseif os(Android)
    return AndroidPlatform()
#else
    fatalError("The target platform is not supported.")
#endif
}
