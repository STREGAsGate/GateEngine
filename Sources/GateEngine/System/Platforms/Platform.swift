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

enum FileSystemSearchPathDomain {
    case currentUser
    case shared
}

enum FileSystemSearchPath {
    case persistant
    case cache
    case temporary
}

internal protocol InternalPlatform: AnyObject, Platform {
    var pathCache: [String:String] {get set}
    static var staticSearchPaths: [URL] {get}
    
    func systemTime() -> Double
    func main()
    
    func saveState(_ state: Game.State, as name: String) throws
    func loadState(named name: String) -> Game.State
    
    #if GATEENGINE_PLATFORM_HAS_FILESYSTEM
    func saveStateURL(forStateNamed name: String) throws -> URL
    func urlForSearchPath(_ searchPath: FileSystemSearchPath, in domain: FileSystemSearchPathDomain) throws -> URL
    #endif
}

#if GATEENGINE_PLATFORM_HAS_FILESYSTEM
extension InternalPlatform {
    public static func getStaticSearchPaths() -> [URL] {
        #if canImport(Darwin)
        let bundleExtension: String = "bundle"
        #else
        let bundleExtension: String = "resources"
        #endif
        
        let excludedResourceBundles = ["JavaScriptKit_JavaScriptKit.\(bundleExtension)"]

        let resourceBundleSearchURLs: Set<URL> = {
            var urls: [URL] = [Bundle.main.bundleURL,
                               Bundle.main.resourceURL,
                               Bundle.module.bundleURL.deletingLastPathComponent()].compactMap({$0})
            urls.append(contentsOf: Bundle.allBundles.compactMap({$0.resourceURL}))
            return Set(urls)
        }()
        
        var files: [URL] = []
        
        for searchURL: URL in resourceBundleSearchURLs {
            do {
                let urls: [URL] = try FileManager.default.contentsOfDirectory(at: searchURL, includingPropertiesForKeys: nil, options: [])
                files.append(contentsOf: urls)
            }catch{
                Log.info(error)
            }
            
            // Sometimes the URL varient returns empty arrays, use the path varient too and clear the duplicates later
            do {
                let paths: [String] = try FileManager.default.contentsOfDirectory(atPath: searchURL.path)
                files.append(contentsOf: paths.map({searchURL.appendingPathComponent($0)}))
            }catch{
                Log.info(error)
            }
        }
        
        // Filter out non-resource bundles
        #if canImport(Darwin)
        files = files.filter({$0.pathExtension.caseInsensitiveCompare(bundleExtension) == .orderedSame}).compactMap({Bundle(url: $0)?.resourceURL})
        #else
        files = files.filter({$0.pathExtension.caseInsensitiveCompare(bundleExtension) == .orderedSame})
        #endif

        // Add the executables own path
        files.insert(URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent(), at: 0)
        
        // Add GateEngine bundles resource path
        if let gateEnigneResources: URL = Bundle.module.resourceURL {
            files.insert(gateEnigneResources, at: 0)
        }

        // Add the main bundles resource path
        if let mainResources: URL = Bundle.main.resourceURL {
            files.insert(mainResources, at: 0)
        }

        // Add the main bundles path
        files.append(Bundle.main.bundleURL)

        // Resolve simlinks so duplicates can be removed
        files = files.map({$0.resolvingSymlinksInPath()})
        
        // Expand tilde
        // TODO: There's probably never going to be a tilde?
        #if !os(iOS) && !os(tvOS)
        files = files.map({
            @_transparent
            func expandTilde(_ path: String) -> String {
                var components: [String] = path.components(separatedBy: "/")
                guard components.first == "~" else {return path}
                components.remove(at: 0)
                
                let home: [String] = FileManager.default.homeDirectoryForCurrentUser.path.components(separatedBy: "/")
                components.insert(contentsOf: home, at: 0)
                return components.joined(separator: "/")
            }
            return URL(fileURLWithPath: expandTilde($0.path))
        })
        #endif
        
        // Remove excluded
        files.removeAll(where: {
            for excluded in excludedResourceBundles {
                if $0.path.contains(excluded) {
                    return true
                }
            }
            return false
        })
        
        // Remove duplicates
        files = Array(OrderedSet(files))
        
        // Remove unreachable
        files = files.compactMap({
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: $0.path, isDirectory: &isDirectory), isDirectory.boolValue {
                return $0
            }
            return nil
        })

        if files.isEmpty {
            Log.error("Failed to load any resource bundles! Check code signing and directory premissions.")
        }else{
            let relativeDescriptor: String = "[MainBundle]"
            let relativePath = Bundle.main.bundleURL.path
            Log.debug("Loaded static resource search paths: (GameDelegate search paths not included)", files.map({
                let relativeDescriptor = "\n  \"\(relativeDescriptor)"
                var path = $0.path.replacingOccurrences(of: relativePath, with: relativeDescriptor)
                if path == relativeDescriptor {
                    path += "/"
                }
                return path + "\","
            }).joined())
        }

        return files
    }
}

extension InternalPlatform {
    func saveStateURL(forStateNamed name: String) throws -> URL {
        return try urlForSearchPath(.persistant, in: .currentUser).appendingPathComponent(name)
    }
    
    #if os(macOS) || os(iOS) || os(tvOS) || os(Windows) || os(Linux)
    func systemTime() -> Double {
        var time: timespec = timespec()
        if clock_gettime(CLOCK_MONOTONIC_RAW, &time) != 0 {
            return -1
        }
        return Double(time.tv_sec) + (Double(time.tv_nsec) / 1e+9)
    }
    #endif
}

extension InternalPlatform {
    func loadState(named name: String) -> Game.State {
        do {
            let data = try Data(contentsOf: try saveStateURL(forStateNamed: name))
            let state = try JSONDecoder().decode(Game.State.self, from: data)
            state.name = name
            return state
        }catch{
            Log.error("Game.State failed to restore:", error)
            return Game.State()
        }
    }
    
    func saveState(_ state: Game.State, as name: String) throws {
        let data = try JSONEncoder().encode(state)
        let url = try self.saveStateURL(forStateNamed: name)
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
