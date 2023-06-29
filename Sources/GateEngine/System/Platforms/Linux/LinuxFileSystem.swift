/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(Linux)

import Foundation

public struct LinuxFileSystem: FileSystem {
    public func itemExists(at url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    public func createDirectory(at url: URL) throws {
        try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true)
    }
    
    public func urlForSearchPath(_ searchPath: FileSystemSearchPath, in domain: FileSystemSearchPathDomain) throws -> URL {
        let homeDir = getenv("HOME") ?? getpwuid(getuid()).pw_dir
        
    }
}
#endif
