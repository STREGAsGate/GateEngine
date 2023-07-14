/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if (os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT) && canImport(FileSystem)

import struct Foundation.URL
import FileSystem
import DOM

public struct WASIFileSystem: FileSystem {
    internal func directoryHandle(at path: String) async -> FileSystemDirectoryHandle? {
        if var currentDirectory: FileSystemDirectoryHandle = try? await globalThis.navigator.storage.getDirectory() {
            let components = URL(fileURLWithPath: path).pathComponents
            for index in components.indices {
                let component = components[index]
                if let childHandle = try? await currentDirectory.getDirectoryHandle(name: component) {
                    currentDirectory = childHandle
                    if index == components.indices.last {
                        return currentDirectory
                    }
                }else{
                    break
                }
            }
        }
        return nil
    }
    
    public func itemExists(at path: String) async -> Bool {
        return await itemType(at: path) != nil
    }
    
    public func itemType(at path: String) async -> FileSystemItemType? {
        let url = URL(fileURLWithPath: path)
        if let currentDirectory = await directoryHandle(at: url.deletingLastPathComponent().path) {
            let component = url.lastPathComponent
            
            if let handle = try? await currentDirectory.getDirectoryHandle(name: component), handle.kind == .directory {
                return .directory
            }
            if let handle = try? await currentDirectory.getFileHandle(name: component), handle.kind == .file {
                return .file
            }
        }
        return nil
    }
    
    public func contentsOfDirectory(at path: String) async throws -> [String] {
        let url = URL(fileURLWithPath: path)
        var items: [String] = []
        if let currentDirectory = await directoryHandle(at: url.deletingLastPathComponent().path) {
            let iterator = currentDirectory.makeAsyncIterator()
            var keyValuePairs: [String] = []
            while let keyOrValue = try await iterator.next() {
                keyValuePairs.append(keyOrValue)
            }
            let values = stride(from: 0, to: keyValuePairs.count - 1, by: 2).map({keyValuePairs[$0 + 1]})
            items.append(contentsOf: values)
        }
        return items
    }
    
    public func createDirectory(at path: String) async throws {
        let url = URL(fileURLWithPath: path)
        var currentDirectoy: FileSystemDirectoryHandle = try await globalThis.navigator.storage.getDirectory()
        for component in url.pathComponents {
            currentDirectoy = try await currentDirectoy.getDirectoryHandle(name: component, options: FileSystemGetDirectoryOptions(create: true))
        }
    }
    
    public func resolvePath(_ path: String) throws -> String {
        return path
    }
    
    public func pathForSearchPath(_ searchPath: FileSystemSearchPath, in domain: FileSystemSearchPathDomain) throws -> String {
        switch searchPath {
        case .persistent:
            switch domain {
            case .currentUser:
                return "User/Data"
            case .shared:
                return "Shared/Data"
            }
        case .cache:
            switch domain {
            case .currentUser:
                return "User/Cache"
            case .shared:
                return "Shared/Cache"
            }
        case .temporary:
            return "tmp"
        }
    }
    
    public func write(_ data: Data, to path: String) async throws {
        
    }
    
    public func read(from path: String) async throws -> Data {
        fatalError()
    }
}

#endif
