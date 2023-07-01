/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if (os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT) && canImport(FileSystem)

import Foundation
import FileSystem
import DOM

public struct WASIFileSystem: FileSystem {
    public func itemExists(at url: URL) async -> Bool {
        var currentDirectoy: FileSystemDirectoryHandle = globalThis.navigator.storage.getDirectory()
        for component in url.pathComponents {
            if let exists = try? await currentDirectoy.getDirectoryHandle(name: component) {
                currentDirectoy = exists
            }else{
                return false
            }
        }
        return true
    }
    
    public func createDirectory(at url: URL) async throws {
        var currentDirectoy: FileSystemDirectoryHandle = globalThis.navigator.storage.getDirectory()
        for component in url.pathComponents {
            currentDirectoy = try await currentDirectoy.getDirectoryHandle(name: component, options: FileSystemGetDirectoryOptions(create: true))
        }
    }
    
    public func urlForSearchPath(_ searchPath: FileSystemSearchPath, in domain: FileSystemSearchPathDomain) throws -> URL {
        switch searchPath {
        case .persistant:
            switch domain {
            case .currentUser:
                return URL(fileURLWithPath: "User/Data")
            case .shared:
                return URL(fileURLWithPath: "Shared/Data")
            }
        case .cache:
            switch domain {
            case .currentUser:
                return URL(fileURLWithPath: "User/Cache")
            case .shared:
                return URL(fileURLWithPath: "Shared/Cache")
            }
        case .temporary:
            return URL(fileURLWithPath: "tmp")
        }
    }
    
    public func write(_ data: Data, to url: URL) async throws {
        
    }
    
    public func read(from url: URL) async throws -> Data {
        
    }
}

public extension Foundation.Data {
    init(contentsOf url: URL) throws {
        
    }
    struct WASIWriteOptions: OptionSet {
        public typealias RawValue = UInt
        public let rawValue: RawValue
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public static let atomic: WASIWriteOptions = WASIWriteOptions(rawValue: 1 << 1)
    }
    func write(to url: URL, options: WASIWriteOptions) throws {
        
    }
}

#endif
