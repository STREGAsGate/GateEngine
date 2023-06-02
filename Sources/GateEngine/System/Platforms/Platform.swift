/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation
import Collections

public protocol Platform: AnyObject {
    func locateResource(from path: String) async -> String?
    func loadResource(from path: String) async throws -> Data
    
    var supportsMultipleWindows: Bool {get}
}

internal protocol InternalPlatform: AnyObject, Platform {
    var pathCache: [String:String] {get set}
    static var staticSearchPaths: [URL] {get}
    
    func saveStateURL() throws -> URL
    func saveState(_ state: Game.State) throws
    func loadState() -> Game.State
    
    func systemTime() -> Double
    func main()
}

#if !os(WASI)
extension InternalPlatform {
    public static func getStaticSearchPaths() -> [URL] {
        #if canImport(Darwin)
        let bundleExtension: String = "bundle"
        #else
        let bundleExtension: String = "resources"
        #endif

        let resourceBundleSearchURLs: Set<URL> = {
            var urls = [Bundle.main.resourceURL, Bundle.module.bundleURL.deletingLastPathComponent()].compactMap({$0})
            urls.append(contentsOf: Bundle.allBundles.compactMap({$0.resourceURL}))
            return Set(urls)
        }()
        
        // Add the application and GateEngine resource bundles if they exist
        var files: [URL] = [Bundle.main, Bundle.module].compactMap({$0.resourceURL})
        
        for searchURL in resourceBundleSearchURLs {
            do {
                let urls = try FileManager.default.contentsOfDirectory(at: searchURL, includingPropertiesForKeys: nil, options: [])
                files.append(contentsOf: urls)
            }catch{
                Log.info(error)
            }
            
            // Sometimes the URL varient returns empty arrays, use the path varient too and clear the duplicates
            do {
                let paths = try FileManager.default.contentsOfDirectory(atPath: searchURL.path)
                files.append(contentsOf: paths.map({searchURL.appendingPathComponent($0)}))
            }catch{
                Log.info(error)
            }
        }
        
        // Filter out non-resource bundles
        files = files.filter({$0.pathExtension.caseInsensitiveCompare(bundleExtension) == .orderedSame}).compactMap({Bundle(url: $0)?.resourceURL})
        
        // Add the executables own path
        files.insert(URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent(), at: 0)
        
        // Add the main bundles resource path
        if let mainResources = Bundle.main.resourceURL {
            files.insert(mainResources, at: 0)
        }
        
        // Add the main bundles path
        files.append(Bundle.main.bundleURL)

        // Resolve simlinks so duplicates can be removed
        files = files.map({$0.resolvingSymlinksInPath()})
        
        // Expand tilde
        #if os(macOS)
        files = files.map({
            @_transparent
            func expandTilde(_ path: String) -> String {
                var components = path.components(separatedBy: "/")
                guard components.first == "~" else {return path}
                components.remove(at: 0)
                
                let home = FileManager.default.homeDirectoryForCurrentUser.path.components(separatedBy: "/")
                components.insert(contentsOf: home, at: 0)
                return components.joined(separator: "/")
            }
            return URL(fileURLWithPath: expandTilde($0.path))
        })
        #endif
        
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
}

extension InternalPlatform {
    func saveStateURL() throws -> URL {
        var url: URL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        url.appendPathComponent(Bundle.main.bundleIdentifier ?? CommandLine.arguments[0])
        url.appendPathComponent("SaveState.data")
        return url
    }
    
    #if os(macOS) || os(iOS) || os(Windows)
    func systemTime() -> Double {
        var time = timespec()
        if clock_gettime(CLOCK_MONOTONIC_RAW, &time) != 0 {
            return -1
        }
        return Double(time.tv_sec) + (Double(time.tv_nsec) / 1e+9)
    }
    #endif
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
#endif

#if os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT
public typealias CurrentPlatform = WASIPlatform
#elseif canImport(UIKit)
public typealias CurrentPlatform = UIKitPlatform
#elseif canImport(AppKit)
public typealias CurrentPlatform = AppKitPlatform
#elseif canImport(WinSDK)
public typealias CurrentPlatform = Win32Platform
#elseif os(Linux)
public typealias CurrentPlatform = LinuxPlatform
#elseif os(Android)
public typealias CurrentPlatform = AndroidPlatform
#else
    #error("The target platform is not supported.")
#endif
