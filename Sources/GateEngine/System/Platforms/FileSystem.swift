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
    /**
     The Save Directory for your game.
     
     Files that you want to keep forever should go here.
     This includes player progression, stats, screenshots, etc...
     */
    case persistent
    /**
     The Cache Directory for your game.
     
     Files that your game will regenerate when missing.
     
     GateEngine or the host operating system will delete these files when your game is not using them.
     
     For the best user expirience, you should delete them yourself when you are finished with them as you are the only one who knows when they are no longer needed.
     */
    case cache
    /**
     The Temporary Directory for your game.
     
     Files placed here are volatile the momenet you're done writing them.
     
     Use this directory to perfrom atomic operations and temporary scratch.
     - note: Do not store files here for any reason. They will randomly be destroyed.
     */
    case temporary
}

public enum FileSystemItemType {
    case directory
    case file
}

/*
 FileSystem uses URL instead of String paths because URL automatically handles converting Unix paths to Windows paths on Windows.
 This allows users to use Unix paths exclusivley.
 */

public protocol FileSystem {
    func itemExists(at path: String) async -> Bool
    func itemType(at path: String) async -> FileSystemItemType?
    
    func contentsOfDirectory(at path: String) async throws -> [String]
    func createDirectory(at path: String) async throws
    
    func read(from path: String) async throws -> Data
    func write(_ data: Data, to path: String) async throws
    
    func resolvePath(_ path: String) throws -> String
    func pathForSearchPath(_ searchPath: FileSystemSearchPath, in domain: FileSystemSearchPathDomain) throws -> String
}

#endif