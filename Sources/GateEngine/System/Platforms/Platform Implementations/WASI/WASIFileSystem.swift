/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if (HTML5) && canImport(FileSystem)
import Foundation
import DOM
import WebAPIBase
import FileSystem

public struct WASIFileSystem: FileSystem {
    let supportsWebFileSystem: Bool = {
        guard globalThis.isSecureContext else { return false }
        switch CurrentPlatform.browser {
        case .safari(version: _):
            return false
        case .chrome(let version):
            return version.major >= 86
        case .edge(let version):
            return version.major >= 86
        case .fireFox(let version):
            return version.major >= 111
        case .opera(let version):
            return version.major >= 72
        default:
            return false
        }
    }()

    internal func directoryHandle(at path: String) async -> FileSystemDirectoryHandle? {
        if var currentDirectory: FileSystemDirectoryHandle = try? await globalThis.navigator.storage
            .getDirectory()
        {
            let components = URL(fileURLWithPath: path).pathComponents
            for index in components.indices {
                let component = components[index]
                if let childHandle = try? await currentDirectory.getDirectoryHandle(name: component)
                {
                    currentDirectory = childHandle
                    if index == components.indices.last {
                        return currentDirectory
                    }
                } else {
                    break
                }
            }
        }
        return nil
    }

    public func itemExists(at path: String) async -> Bool {
        if supportsWebFileSystem {
            return await itemType(at: path) != nil
        } else {
            let window: DOM.Window = globalThis
            return window.localStorage[path] != nil
        }
    }

    public func itemType(at path: String) async -> FileSystemItemType? {
        if supportsWebFileSystem {
            let url = URL(fileURLWithPath: path)
            if let currentDirectory = await directoryHandle(
                at: url.deletingLastPathComponent().path
            ) {
                let component = url.lastPathComponent

                if let handle = try? await currentDirectory.getDirectoryHandle(name: component),
                    handle.kind == .directory
                {
                    return .directory
                }
                if let handle = try? await currentDirectory.getFileHandle(name: component),
                    handle.kind == .file
                {
                    return .file
                }
            }
            return nil
        } else {
            let window: DOM.Window = globalThis
            if let value = window.localStorage[path] {
                if value == "" {
                    return .directory
                }
                return .file
            } else {
                return nil
            }
        }
    }

    public func contentsOfDirectory(at path: String) async throws -> [String] {
        if supportsWebFileSystem {
            let url = URL(fileURLWithPath: path)
            var items: [String] = []
            if let currentDirectory = await directoryHandle(
                at: url.deletingLastPathComponent().path
            ) {
                let iterator = currentDirectory.makeAsyncIterator()
                var keyValuePairs: [String] = []
                while let keyOrValue = try await iterator.next() {
                    keyValuePairs.append(keyOrValue)
                }
                let values = stride(from: 0, to: keyValuePairs.count - 1, by: 2).map({
                    keyValuePairs[$0 + 1]
                })
                items.append(contentsOf: values)
            }
            return items
        } else {
            let path = path.lowercased()
            let window: DOM.Window = globalThis
            let keys: [String] = (0 ..< window.localStorage.length).compactMap({
                window.localStorage.key(index: $0)
            })
            return keys.filter({ $0.lowercased().hasPrefix(path) })
        }
    }

    public func createDirectory(at path: String) async throws {
        if supportsWebFileSystem {
            let url = URL(fileURLWithPath: path)
            var currentDirectoy: FileSystemDirectoryHandle = try await globalThis.navigator.storage
                .getDirectory()
            for component in url.pathComponents {
                currentDirectoy = try await currentDirectoy.getDirectoryHandle(
                    name: component,
                    options: FileSystemGetDirectoryOptions(create: true)
                )
            }
        } else {
            let window: DOM.Window = globalThis
            window.localStorage[path] = ""
        }
    }

    public func deleteItem(at path: String) async throws {
        if supportsWebFileSystem {
            let url = URL(fileURLWithPath: path)
            if let dir = await directoryHandle(at: url.deletingLastPathComponent().path) {
                try await dir.removeEntry(name: url.lastPathComponent)
            }
        } else {
            let window: DOM.Window = globalThis
            window.localStorage.removeValue(forKey: path)
        }
    }

    public func moveItem(at originPath: String, to destinationPath: String) async throws {
        if supportsWebFileSystem {
            fatalError()
            //            let url = URL(fileURLWithPath: path)
            //            if let originDirectoryHandle = await directoryHandle(at: url.deletingLastPathComponent().path) {
            //                try await dir.move(name: url.lastPathComponent)
            //            }
        } else {
            let window: DOM.Window = globalThis
            if let value = window.localStorage[originPath] {
                window.localStorage[destinationPath] = value
                window.localStorage.removeValue(forKey: originPath)
            } else {
                throw GateEngineError.failedToLocate
            }
        }
    }

    public func resolvePath(_ path: String) throws -> String {
        var url = URL(fileURLWithPath: path)

        // Expand .. and remove .
        url.standardize()

        return url.path
    }

    public func pathForSearchPath(
        _ searchPath: FileSystemSearchPath,
        in domain: FileSystemSearchPathDomain
    ) throws -> String {
        switch searchPath {
        case .persistent:
            switch domain {
            case .currentUser:
                return "user/data"
            case .shared:
                return "shared/data"
            }
        case .cache:
            switch domain {
            case .currentUser:
                return "user/cache"
            case .shared:
                return "shared/cache"
            }
        case .temporary:
            return "tmp"
        }
    }

    public func write(_ data: Data, to path: String, options: FileSystemWriteOptions = .default)
        async throws
    {
        let url = URL(fileURLWithPath: path)
        if supportsWebFileSystem {
            //TODO: atomic write is not handled
            if let currentDirectory = await directoryHandle(
                at: url.deletingLastPathComponent().path
            ) {
                let fileHandle = try await currentDirectory.getFileHandle(
                    name: url.lastPathComponent,
                    options: FileSystemGetFileOptions(create: options.contains(.createDirectories))
                )
                let stream = try await fileHandle.createWritable(
                    options: FileSystemCreateWritableOptions(keepExistingData: false)
                )
                try await stream.write(
                    data: .bufferSource(BufferSource.arrayBuffer(Uint8Array(data).arrayBuffer))
                )
                try await stream.close()
            }
            throw GateEngineError.failedToLocate
        } else {
            let window: DOM.Window = globalThis
            window.localStorage[url.path] = data.base64EncodedString()
        }
    }

    public func read(from path: String) async throws -> Data {
        let url = URL(fileURLWithPath: path)
        if supportsWebFileSystem {
            if let currentDirectory = await directoryHandle(
                at: url.deletingLastPathComponent().path
            ) {
                let fileHandle = try await currentDirectory.getFileHandle(
                    name: url.lastPathComponent,
                    options: FileSystemGetFileOptions(create: false)
                )
                let file = try await fileHandle.getFile()
                let buffer = try await file.arrayBuffer()
                return Data(buffer)
            }
            throw GateEngineError.failedToLocate
        } else {
            let window: DOM.Window = globalThis
            if let base64 = window.localStorage[url.path] {
                if let data = Data(base64Encoded: base64) {
                    return data
                } else {
                    throw GateEngineError.failedToLoad("Data is corrupted and cannot be read.")
                }
            } else {
                throw GateEngineError.failedToLocate
            }
        }
    }
}

#endif
