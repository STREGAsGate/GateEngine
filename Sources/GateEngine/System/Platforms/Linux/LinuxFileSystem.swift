/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(Linux)

public struct LinuxFileSystem: FileSystem {
    let homeDir: String = {
        String(cString: getenv("HOME") ?? getpwuid(getuid()).pointee.pw_dir)
    }()
    public func pathForSearchPath(_ searchPath: FileSystemSearchPath, in domain: FileSystemSearchPathDomain) throws -> String {
        switch searchPath {
        case .persistent:
            switch domain {
            case .currentUser:
                return URL(fileURLWithPath: homeDir)
                       .appendingPathComponent(".config")
                       .appendingPathComponent("." + Game.shared.identifier)
                       .path
            case .shared:
                return URL(fileURLWithPath: "/var/lib")
                       .appendingPathComponent(Game.shared.identifier)
                       .path
            }
        case .cache:
            switch domain {
            case .currentUser:
                return URL(fileURLWithPath: homeDir)
                       .appendingPathComponent(".cache")
                       .appendingPathComponent(Game.shared.identifier)
                       .path
            case .shared:
                return URL(fileURLWithPath: "/var/cache")
                       .appendingPathComponent(Game.shared.identifier)
                       .path
            }
        case .temporary:
            return URL(fileURLWithPath: "/tmp")
                   .appendingPathComponent(Game.shared.identifier)
                   .path
        }
    }
}
#endif
