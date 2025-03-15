/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(Darwin) && GATEENGINE_PLATFORM_HAS_FILESYSTEM && GATEENGINE_PLATFORM_HAS_SynchronousFileSystem
import Foundation

public struct SynchronousAppleFileSystem: SynchronousFileSystem {
    public func pathForSearchPath(_ searchPath: FileSystemSearchPath,
                                  in domain: FileSystemSearchPathDomain = .currentUser) throws -> String {
        return try AppleFileSystem.pathForSearchPath(searchPath, in: domain)
    }
}
#endif
