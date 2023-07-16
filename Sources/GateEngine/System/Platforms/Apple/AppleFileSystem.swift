/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(Darwin)
import Foundation

public struct AppleFileSystem: FileSystem {
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
        return url.path
    }
}

#endif
