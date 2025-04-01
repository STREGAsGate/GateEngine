/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(Darwin) && GATEENGINE_PLATFORM_HAS_FILESYSTEM
import Foundation

internal enum AppleFileSystem {
    static func pathForSearchPath(_ searchPath: FileSystemSearchPath, in domain: FileSystemSearchPathDomain = .currentUser) throws -> String {
        let foundationSearchPath: FileManager.SearchPathDirectory
        switch searchPath {
        case .persistent:
            foundationSearchPath = .applicationSupportDirectory
        case .cache:
            foundationSearchPath = .cachesDirectory
        case .temporary:
            let tmpDir = FileManager.default.temporaryDirectory
            return tmpDir.appendingPathComponent(Game.unsafeShared.info.identifier).path
        }
        let foundationDomainMask: FileManager.SearchPathDomainMask
        switch domain {
        case .currentUser:
            foundationDomainMask = .userDomainMask
        case .shared:
            foundationDomainMask = .localDomainMask
        }
        var url: URL = try FileManager.default.url(for: foundationSearchPath,
                                                   in: foundationDomainMask,
                                                   appropriateFor: nil,
                                                   create: false)
        url = url.appendingPathComponent(Game.unsafeShared.info.identifier)
        return url.path
    }
}
#endif
