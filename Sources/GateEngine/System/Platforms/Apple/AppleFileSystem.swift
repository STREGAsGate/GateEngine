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
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    public func createDirectory(at url: URL) throws {
        try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true)
    }
    
    public func urlForSearchPath(_ searchPath: FileSystemSearchPath, in domain: FileSystemSearchPathDomain) throws -> URL {
        let _searchPath: FileManager.SearchPathDirectory
        switch searchPath {
        case .persistant:
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
