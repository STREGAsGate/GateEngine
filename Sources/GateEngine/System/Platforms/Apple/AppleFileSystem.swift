/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(Darwin)

import Foundation

public struct AppleFileSystem: FileSystem {
    public func itemExists(at url: URL) -> Bool {
        assert(url.isFileURL, "The url must be a file URL. Use `init(fileURLWithPath:)`")
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    public func itemType(at url: URL) async -> FileSystemItemType? {
        assert(url.isFileURL, "The url must be a file URL. Use `init(fileURLWithPath:)`")
        var isDirectory: ObjCBool = ObjCBool(false)
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        if exists {
            if isDirectory.boolValue {
                return .directory
            }
            return .file
        }
        return nil
    }
    
    
    public func contentsOfDirectory(at url: URL) async throws -> [String] {
        return try FileManager.default.contentsOfDirectory(atPath: url.path)
    }
    
    public func createDirectory(at url: URL) async throws {
        assert(url.isFileURL, "The url must be a file URL. Use `init(fileURLWithPath:)`")
        try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true)
    }
    
    
    public func read(from url: URL) async throws -> Data {
        assert(url.isFileURL, "The url must be a file URL. Use `init(fileURLWithPath:)`")
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let data = try Data(contentsOf: url)
                continuation.resume(returning: data)
            }catch{
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func write(_ data: Data, to url: URL) async throws {
        assert(url.isFileURL, "The url must be a file URL. Use `init(fileURLWithPath:)`")
        try await withCheckedThrowingContinuation { continuation in
            do {
                try data.write(to: url)
                continuation.resume()
            }catch{
                continuation.resume(throwing: error)
            }
        }
    }
    
    
    public func resolveURL(_ url: URL) throws -> URL {
        var url = url
        
        // Expand symlinks
        url.resolveSymlinksInPath()

        // Expand .. and remove .
        url.standardize()
        
        // Expand Tilde
        #if canImport(Foundation.NSString)
        url = URL(fileURLWithPath: (url.path as NSString).expandingTildeInPath)
        #endif
        
        return url
    }
    
    public func urlForSearchPath(_ searchPath: FileSystemSearchPath, in domain: FileSystemSearchPathDomain = .currentUser) throws -> URL {
        let _searchPath: FileManager.SearchPathDirectory
        switch searchPath {
        case .persistent:
            _searchPath = .applicationSupportDirectory
        case .cache:
            _searchPath = .cachesDirectory
        case .temporary:
            _searchPath = .itemReplacementDirectory
        }
        let _domainMask: FileManager.SearchPathDomainMask
        switch domain {
        case .currentUser:
            _domainMask = .userDomainMask
        case .shared:
            _domainMask = .localDomainMask
        }
        var url: URL = try FileManager.default.url(for: _searchPath, in: _domainMask, appropriateFor: nil, create: false)
        url = url.appendingPathComponent(Game.shared.identifier)
        if FileManager.default.fileExists(atPath: url.path) == false {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }
}

#endif
