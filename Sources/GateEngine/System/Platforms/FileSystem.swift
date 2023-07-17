/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if GATEENGINE_PLATFORM_HAS_FILESYSTEM

public enum FileSystemSearchPathDomain {
    case currentUser
    case shared
}

public enum FileSystemSearchPath {
    /**
     The Save Directory for your game.
     
     Files that you want to keep forever should go here.
     This includes player progression, stats, screenshots, etc...
     */
    case persistent
    /**
     The Cache Directory for your game.
     
     Files that your game will regenerate when missing.
     
     GateEngine or the host operating system will delete these files when your game is not using them.
     
     For the best user expirience, you should delete them yourself when you are finished with them as you are the only one who knows when they are no longer needed.
     */
    case cache
    /**
     The Temporary Directory for your game.
     
     Files placed here are volatile the momenet you're done writing them.
     
     Use this directory to perfrom atomic operations and temporary scratch.
     - note: Do not store files here for any reason. They will randomly be destroyed.
     */
    case temporary
}

public enum FileSystemItemType {
    case directory
    case file
}

public struct FileSystemWriteOptions: OptionSet {
    public typealias RawValue = UInt
    public var rawValue: RawValue
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    public static let createDirectories = Self(rawValue: 1 << 1)
    public static let atomically = Self(rawValue: 1 << 2)
    
    @_transparent
    public static var `default`: Self {[]}// {[.createDirectories, .atomically]}
}

/*
 FileSystem uses URL instead of String paths because URL automatically handles converting Unix paths to Windows paths on Windows.
 This allows users to use Unix paths exclusivley.
 */

public protocol FileSystem {
    func itemExists(at path: String) async -> Bool
    func itemType(at path: String) async -> FileSystemItemType?
    
    func contentsOfDirectory(at path: String) async throws -> [String]
    func createDirectory(at path: String) async throws
    
    func deleteItem(at path: String) async throws
    func moveItem(at originPath: String, to destinationPath: String) async throws
    
    func read(from path: String) async throws -> Data
    func write(_ data: Data, to path: String, options: FileSystemWriteOptions) async throws
    
    func resolvePath(_ path: String) throws -> String
    func pathForSearchPath(_ searchPath: FileSystemSearchPath, in domain: FileSystemSearchPathDomain) throws -> String
}

#if GATEENGINE_PLATFORM_SUPPORTS_FOUNDATION_FILEMANAGER
import Foundation

extension FileSystem {
    public func itemExists(at path: String) async -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    public func itemType(at path: String) async -> FileSystemItemType? {
        var isDirectory: ObjCBool = ObjCBool(false)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        if exists {
            if isDirectory.boolValue {
                return .directory
            }
            return .file
        }
        return nil
    }
    
    public func contentsOfDirectory(at path: String) async throws -> [String] {
        return try FileManager.default.contentsOfDirectory(atPath: path)
    }
    
    public func createDirectory(at path: String) async throws {
        let url = URL(fileURLWithPath: path)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    public func deleteItem(at path: String) async throws {
        try FileManager.default.removeItem(atPath: path)
    }
    
    public func moveItem(at originPath: String, to destinationPath: String) async throws {
        try FileManager.default.moveItem(atPath: originPath, toPath: destinationPath)
    }
    
    public func read(from path: String) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let url = URL(fileURLWithPath: path)
                let data = try Data(contentsOf: url, options: .mappedIfSafe)
                continuation.resume(returning: data)
            }catch{
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func write(_ data: Data, to path: String, options: FileSystemWriteOptions = .default) async throws {
        func writeData(to destinationPath: String) async throws {
            try await withCheckedThrowingContinuation { continuation in
                do {
                    try data.write(to: URL(fileURLWithPath: destinationPath), options: [])
                    continuation.resume()
                }catch{
                    continuation.resume(throwing: error)
                }
            }
        }
        func createDirectoryIfNeeded(at dirPath: String) async throws {
            if await itemExists(at: dirPath) == false {
                try await createDirectory(at: dirPath)
            }
        }
        if options.contains(.createDirectories) {
            let dirPath = URL(fileURLWithPath: path).deletingLastPathComponent().path
            try await createDirectoryIfNeeded(at: dirPath)
        }
        if options.contains(.atomically) {
            let tmpDir = URL(fileURLWithPath: try pathForSearchPath(.temporary, in: .currentUser))
            let tmpPath = tmpDir.appendingPathComponent(URL(fileURLWithPath: path).lastPathComponent).path
            try await createDirectoryIfNeeded(at: tmpDir.path)
            try await writeData(to: tmpPath)
            try await moveItem(at: tmpPath, to: path)
        }else{
            try await writeData(to: path)
        }
    }
    
    public func resolvePath(_ path: String) throws -> String {
        var url = URL(fileURLWithPath: path)
        
        // Expand symlinks
        url.resolveSymlinksInPath()

        // Expand .. and remove .
        url.standardize()
        
        // Expand Tilde
        #if canImport(Foundation.NSString)
        url = URL(fileURLWithPath: (url.path as NSString).expandingTildeInPath)
        #endif
        
        return url.path
    }
}
#endif

#endif
