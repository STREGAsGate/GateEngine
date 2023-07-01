/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if GATEENGINE_PLATFORM_HAS_FILESYSTEM

import Foundation

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
    func itemExists(at url: URL) async -> Bool
    func itemType(at url: URL) async -> FileSystemItemType?
    
    func contentsOfDirectory(at url: URL) async throws -> [String]
    func createDirectory(at url: URL) async throws
    
    func read(from url: URL) async throws -> Data
    func write(_ data: Data, to url: URL) async throws
    
    func resolveURL(_ url: URL) throws -> URL
    func urlForSearchPath(_ searchPath: FileSystemSearchPath, in domain: FileSystemSearchPathDomain) throws -> URL
}

#endif
