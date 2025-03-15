/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(WinSDK) && GATEENGINE_PLATFORM_HAS_FILESYSTEM && GATEENGINE_PLATFORM_HAS_AsynchronousFileSystem
import Foundation
import WinSDK

public struct AsynchronousWin32FileSystem: AsynchronousFileSystem {
    func urlForFolderID(_ folderID: KNOWNFOLDERID) -> URL {
        return Win32FileSystem.urlForFolderID(folderID)
    }
    public func pathForSearchPath(_ searchPath: FileSystemSearchPath,
                                  in domain: FileSystemSearchPathDomain = .currentUser) throws -> String {
        return try Win32FileSystem.pathForSearchPath(searchPath, in: domain)
    }
}
#endif
