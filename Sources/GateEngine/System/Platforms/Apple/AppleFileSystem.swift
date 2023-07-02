/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(Darwin)

import Foundation

public struct AppleFileSystem: FileSystem {
    public func itemExists(at path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    public func itemType(at path: String) -> FileSystemItemType? {
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
    
    
    public func contentsOfDirectory(at path: String) throws -> [String] {
        return try FileManager.default.contentsOfDirectory(atPath: path)
    }
    
    public func createDirectory(at path: String) throws {
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
    }
    
    
    public func read(from path: String) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                continuation.resume(returning: data)
            }catch{
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func write(_ data: Data, to path: String) async throws {
        guard let url = URL(string: path) else {throw "Failed to read path."}
        assert(url.isFileURL == true, "The url must be a file URL. Use `init(fileURLWithPath:)`")
        try await withCheckedThrowingContinuation { continuation in
            do {
                try data.write(to: url)
                continuation.resume()
            }catch{
                continuation.resume(throwing: error)
            }
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
    
    public func pathForSearchPath(_ searchPath: FileSystemSearchPath, in domain: FileSystemSearchPathDomain) throws -> String {
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
        return url.path
    }
}

#endif
