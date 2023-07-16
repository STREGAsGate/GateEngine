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
    
    #if GATEENGINE_PLATFORM_HAS_FILESYSTEM
    associatedtype FileSystem: GateEngine.FileSystem
    static var fileSystem: FileSystem {get}
    var fileSystem: FileSystem {get}
    #endif
}

public extension Platform {
    @_transparent
    var fileSystem: Self.FileSystem {
        return Self.fileSystem
    }
}

internal protocol InternalPlatform: AnyObject, Platform {
    var staticResourceLocations: [URL] {get}
    
    func systemTime() -> Double
    func main()
    
    func saveState(_ state: Game.State, as name: String) async throws
    func loadState(named name: String) async -> Game.State
    
    #if GATEENGINE_PLATFORM_HAS_FILESYSTEM
    func saveStatePath(forStateNamed name: String) throws -> String
    #endif
    
    #if GATEENGINE_ASYNCLOAD_CURRENTPLATFORM
    init(delegate: GameDelegate) async
    #else
    init(delegate: GameDelegate)
    #endif
}

#if GATEENGINE_PLATFORM_SUPPORTS_FOUNDATION_FILEMANAGER && !GATEENGINE_ENABLE_WASI_IDE_SUPPORT
extension InternalPlatform {
    static func getStaticSearchPaths(delegate: GameDelegate) async -> [URL] {
        #if canImport(Darwin)
        let bundleExtension: String = "bundle"
        #else
        let bundleExtension: String = "resources"
        #endif
        
        let excludedResourceBundles = ["JavaScriptKit_JavaScriptKit.\(bundleExtension)"]

        let bundleURLs: Set<URL> = {
            var urls: [URL?] = [Bundle.main.bundleURL,
                               Bundle.main.resourceURL,
                               Bundle.module.bundleURL.deletingLastPathComponent()]
            urls.append(contentsOf: Bundle.allBundles.compactMap({$0.resourceURL}))
            return Set(urls.compactMap({$0}))
        }()
        
        var resourceFolders: [URL] = []
        
        do {
            for bundleURL in bundleURLs {
                let contents = try await Self.fileSystem.contentsOfDirectory(at: bundleURL.path)
                resourceFolders.append(contentsOf: contents.map({bundleURL.appendingPathComponent($0)}))
            }
        }catch{
            Log.error(error)
        }
        
        // Filter out non-resource bundles
        #if canImport(Darwin)
        resourceFolders = resourceFolders.filter({$0.pathExtension.caseInsensitiveCompare(bundleExtension) == .orderedSame}).compactMap({Bundle(url: $0)?.resourceURL})
        #else
        resourceFolders = resourceFolders.filter({$0.pathExtension.caseInsensitiveCompare(bundleExtension) == .orderedSame})
        #endif

        // Add the executables own path
        resourceFolders.insert(URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent(), at: 0)
        
        // Add GateEngine bundles resource path
        if let gateEnigneResources: URL = Bundle.module.resourceURL {
            resourceFolders.insert(gateEnigneResources, at: 0)
        }

        // Add the main bundles resource path
        if let mainResources: URL = Bundle.main.resourceURL {
            resourceFolders.insert(mainResources, at: 0)
        }

        // Add the main bundles path
        resourceFolders.append(Bundle.main.bundleURL)

        do {
            // Resolve simlinks so duplicates can be removed
            resourceFolders = try resourceFolders.map({
                let path = try fileSystem.resolvePath($0.path)
                return URL(fileURLWithPath: path)
            })
        }catch{
            Log.error(error)
        }
        
        // Remove excluded
        resourceFolders.removeAll(where: {
            for excluded in excludedResourceBundles {
                if $0.path.contains(excluded) {
                    return true
                }
            }
            return false
        })
        
        // Remove duplicates
        resourceFolders = Array(OrderedSet(resourceFolders))
        
        // Remove unreachable
        resourceFolders = resourceFolders.compactMap({
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: $0.path, isDirectory: &isDirectory), isDirectory.boolValue {
                return $0
            }
            return nil
        })

        if resourceFolders.isEmpty {
            Log.error("Failed to load any resource bundles! Check code signing and directory premissions.")
        }else{
            let relativeDescriptor: String = "[MainBundle]"
            let relativePath = Bundle.main.bundleURL.path
            Log.debug("Loaded static resource search paths: (GameDelegate search paths not included)", resourceFolders.map({
                let relativeDescriptor = "\n  \"\(relativeDescriptor)"
                var path = $0.path.replacingOccurrences(of: relativePath, with: relativeDescriptor)
                if path == relativeDescriptor {
                    path += "/"
                }
                return path + "\","
            }).joined())
        }

        return resourceFolders
    }
}

extension InternalPlatform {
    func saveStatePath(forStateNamed name: String) throws -> String {
        return URL(fileURLWithPath: try fileSystem.pathForSearchPath(.persistent, in: .currentUser)).appendingPathComponent(name).path
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
    func loadState(named name: String) async -> Game.State {
        do {
            let data = try await fileSystem.read(from: try saveStatePath(forStateNamed: name))
            let state = try JSONDecoder().decode(Game.State.self, from: data)
            state.name = name
            return state
        }catch let error as NSError {
            if error.domain == NSCocoaErrorDomain && error.code == 260 {// File not found
                Log.debug("No Game State \"\(name)\" found. Creating new Game State.")
            }else if error.domain == NSPOSIXErrorDomain && error.code == 2 {// File not found
                Log.debug("No Game State \"\(name)\" found. Creating new Game State.")
            }else{
                Log.error("Game State \"\(name)\" failed to restore:", error)
            }
            return Game.State(name: name)
        }
    }
    
    func saveState(_ state: Game.State, as name: String) async throws {
        let data = try JSONEncoder().encode(state)
        let path = try self.saveStatePath(forStateNamed: name)
        let dir = URL(fileURLWithPath: path).deletingLastPathComponent().path
        if await fileSystem.itemExists(at: dir) == false {
            try await fileSystem.createDirectory(at: dir)
        }
        try await fileSystem.write(data, to: path)
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
