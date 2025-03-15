/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
import Foundation
import Collections

public extension Platform {
    /// The current platform (read only)
    @inline(__always)
    nonisolated static var current: Platform {Game.unsafeShared.unsafePlatform}
}

public protocol PlatformProtocol: Sendable {
    func locateResource(from path: String) async -> String?
    func loadResource(from path: String) async throws -> Data

    var supportsMultipleWindows: Bool { get }

    #if GATEENGINE_PLATFORM_HAS_FILESYSTEM
    #if GATEENGINE_PLATFORM_HAS_SynchronousFileSystem
    associatedtype AsyncFileSystem: AsynchronousFileSystem
    static var fileSystem: AsyncFileSystem { get }
    var fileSystem: AsyncFileSystem { get }
    #endif
    #if GATEENGINE_PLATFORM_HAS_AsynchronousFileSystem
    associatedtype SyncFileSystem: SynchronousFileSystem
    static var synchronousFileSystem: SyncFileSystem { get }
    var synchronousFileSystem: SyncFileSystem { get }
    #endif
    #endif
}

#if GATEENGINE_PLATFORM_HAS_FILESYSTEM
extension PlatformProtocol {
    #if GATEENGINE_PLATFORM_HAS_SynchronousFileSystem
    @_transparent
    public var fileSystem: Self.AsyncFileSystem {
        return Self.fileSystem
    }
    #endif
    #if GATEENGINE_PLATFORM_HAS_AsynchronousFileSystem
    @_transparent
    public var synchronousFileSystem: Self.SyncFileSystem {
        return Self.synchronousFileSystem
    }
    #endif
}
#endif

internal protocol InternalPlatformProtocol: PlatformProtocol {
    var staticResourceLocations: [URL] { get }
    
    func setCursorStyle(_ style: Mouse.Style)

    func systemTime() -> Double
    @MainActor func main()

    func saveState(_ state: Game.State, as name: String) async throws
    func loadState(named name: String) async -> Game.State

    #if GATEENGINE_PLATFORM_HAS_FILESYSTEM
    func saveStatePath(forStateNamed name: String) throws -> String
    #endif
}

#if GATEENGINE_PLATFORM_SUPPORTS_FOUNDATION_FILEMANAGER && !GATEENGINE_ENABLE_WASI_IDE_SUPPORT
extension InternalPlatformProtocol {
    static func getStaticSearchPaths() -> [URL] {
        let executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
        let executableDirectoryURL = executableURL.deletingLastPathComponent()
        
        #if canImport(Darwin)
        let bundleExtension: String = "bundle"
        #else
        let bundleExtension: String = "resources"
        #endif

        let excludedResourceBundles = ["JavaScriptKit_JavaScriptKit.\(bundleExtension)"]

        let bundleURLs: Set<URL> = {
            var urls: [URL?] = [
                Bundle.main.bundleURL,
                Bundle.main.resourceURL,
                Bundle.module.bundleURL.deletingLastPathComponent(),
            ]
            urls.append(
                contentsOf: Bundle.allBundles.compactMap({
                    if FileManager.default.fileExists(
                        atPath: $0.bundleURL.appendingPathComponent("Contents/Info.plist").path
                    ) {
                        if let url = $0.resourceURL {
                            return url
                        }
                    }
                    return $0.bundleURL
                })
            )
            return Set(urls.compactMap({ $0 }))
        }()

        var resourceFolders: [URL] = []

        do {
            // Add resource bundels alongside the executable
            let rootContents = try FileManager.default.contentsOfDirectory(atPath: executableDirectoryURL.path)
                .map({executableDirectoryURL.appendingPathComponent($0)})
            for url in rootContents {
                if url.pathExtension.caseInsensitiveCompare(bundleExtension) == .orderedSame {
                    resourceFolders.append(url)
                }
            }
            
            // Add resource bundles withing resource bundles
            for bundleURL in bundleURLs + resourceFolders {
                let path = bundleURL.path
                if FileManager.default.fileExists(atPath: path) {
                    let contents = try FileManager.default.contentsOfDirectory(atPath: path)
                    resourceFolders.append(
                        contentsOf: contents.map({ bundleURL.appendingPathComponent($0) })
                    )
                }
            }
        } catch {
            Log.error(error)
        }

        // Filter out non-resource bundles
        #if canImport(Darwin)
        resourceFolders = resourceFolders.filter({
            $0.pathExtension.caseInsensitiveCompare(bundleExtension) == .orderedSame
        }).compactMap({
            if let bundle = Bundle(url: $0) {
                if FileManager.default.fileExists(
                    atPath: bundle.bundleURL.appendingPathComponent("Contents/Info.plist").path
                ) {
                    if let url = bundle.resourceURL {
                        return url
                    }
                }
                return bundle.bundleURL
            }
            return nil
        })
        #else
        resourceFolders = resourceFolders.filter({
            $0.pathExtension.caseInsensitiveCompare(bundleExtension) == .orderedSame
        })
        #endif

        // Add the executables own path
        resourceFolders.append(executableDirectoryURL)

        // Add GateEngine bundles resource path
        if let gateEngineResources: URL = Bundle.module.resourceURL {
            resourceFolders.append(gateEngineResources)
        }

        // Add the main bundles resource path
        if let mainResources: URL = Bundle.main.resourceURL {
            resourceFolders.append(mainResources)
        }

        // Add the main bundles path
        resourceFolders.append(Bundle.main.bundleURL)

        do {
            // Resolve simlinks so duplicates can be removed
            resourceFolders = try resourceFolders.map({
                let path = try fileSystem.resolvePath($0.path)
                return URL(fileURLWithPath: path)
            })
        } catch {
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
        resourceFolders = Array(Set(resourceFolders))

        // Remove unreachable
        resourceFolders = resourceFolders.compactMap({
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: $0.path, isDirectory: &isDirectory),
                isDirectory.boolValue
            {
                return $0
            }
            return nil
        })
        
        // Attempt to move the main game resource bundle to the front of the line
        let executableName = executableURL.lastPathComponent + "." + bundleExtension
        if let index = resourceFolders.firstIndex(where: {$0.path.contains(executableName)}) {
            let probablyMainBundle = resourceFolders.remove(at: index)
            resourceFolders.insert(probablyMainBundle, at: 0)
        }
        
        // Move GateEngine's bundle to the end so it's searched less often
        if let index = resourceFolders.firstIndex(where: {$0.path.contains("GateEngine_GateEngine")}) {
            resourceFolders.append(resourceFolders.remove(at: index))
        }
        
        // Move the executables directory to the end so it's searched last
        // Most users will use the Swift Package Manager resources feature
        let executableDirectory = executableURL.deletingLastPathComponent()
        if let index = resourceFolders.firstIndex(where: {$0 == executableDirectory}) {
            resourceFolders.append(resourceFolders.remove(at: index))
        }

        if resourceFolders.isEmpty {
            Log.error(
                "Failed to load any resource bundles! Check code signing and directory premissions."
            )
        } else {
            let relativeDescriptor: String = "\n  \"[MainBundle]"
            let relativePath = Bundle.main.bundleURL.path
            Log.debug(
                "Loaded static resource search paths: (GameDelegate search paths not included)",
                resourceFolders.map({
                    let relativeDescriptor = "\(relativeDescriptor)"
                    var path = $0.path.replacingOccurrences(
                        of: relativePath,
                        with: relativeDescriptor
                    )
                    if path == relativeDescriptor {
                        path += "/"
                    }
                    return path + "\","
                }).joined()
            )
        }

        return resourceFolders
    }
}

extension InternalPlatformProtocol {
    func saveStatePath(forStateNamed name: String) throws -> String {
        return URL(fileURLWithPath: try fileSystem.pathForSearchPath(.persistent, in: .currentUser))
            .appendingPathComponent(name).path
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

extension InternalPlatformProtocol {
    func loadState(named name: String) async -> Game.State {
        do {
            let data = try await fileSystem.read(from: try saveStatePath(forStateNamed: name))
            let state = try JSONDecoder().decode(Game.State.self, from: data)
            state.name = name
            return state
        } catch let error as NSError {
            if error.domain == NSCocoaErrorDomain && error.code == 260 {  // File not found
                Log.debug("No Game State \"\(name)\" found. Creating new Game State.")
            } else if error.domain == NSPOSIXErrorDomain && error.code == 2 {  // File not found
                Log.debug("No Game State \"\(name)\" found. Creating new Game State.")
            } else {
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
public typealias Platform = WASIPlatform
#elseif canImport(UIKit)
public typealias Platform = UIKitPlatform
#elseif canImport(AppKit)
public typealias Platform = AppKitPlatform
#elseif canImport(WinSDK)
public typealias Platform = Win32Platform
#elseif os(Linux)
public typealias Platform = LinuxPlatform
#elseif os(Android)
public typealias Platform = AndroidPlatform
#else
#error("The target platform is not supported.")
#endif
