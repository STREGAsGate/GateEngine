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
    case persistent
    case cache
    case temporary
}

public enum FileSystemItemType {
    case directory
    case file
}

public protocol FileSystem {
    func itemExists(at path: String) -> Bool
    func itemType(at path: String) -> FileSystemItemType?
    
    func contentsOfDirectory(at path: String) throws -> [String]
    func createDirectory(at path: String) throws
    
    func read(from path: String) async throws -> Data
    func write(_ data: Data, to path: String) async throws
    
    func resolvePath(_ path: String) throws -> String
    func pathForSearchPath(_ searchPath: FileSystemSearchPath, in domain: FileSystemSearchPathDomain) throws -> String
}

#endif
