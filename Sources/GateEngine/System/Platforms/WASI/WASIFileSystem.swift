/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if (os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT) && canImport(FileSystem)

import Foundation
import FileSystem

public struct WASIFileSystem: FileSystem {
    public func itemExists(at url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    public func createDirectory(at url: URL) throws {
        try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true)
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
}
#endif
