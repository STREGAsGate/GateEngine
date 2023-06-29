/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public enum FileSystemSearchPathDomain {
    case currentUser
    case shared
}

public enum FileSystemSearchPath {
    case persistant
    case cache
    case temporary
}

public protocol FileSystem {
    func itemExists(at url: URL) -> Bool
    func createDirectory(at url: URL) throws
    func urlForSearchPath(_ searchPath: FileSystemSearchPath, in domain: FileSystemSearchPathDomain) throws -> URL
}
