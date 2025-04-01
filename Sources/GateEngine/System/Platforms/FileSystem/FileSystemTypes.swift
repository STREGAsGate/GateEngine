/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
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

public struct FileSystemWriteOptions: OptionSet, Sendable {
    public typealias RawValue = UInt
    public var rawValue: RawValue
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public static let createDirectories = Self(rawValue: 1 << 1)
    public static let atomically = Self(rawValue: 1 << 2)

    @inlinable
    public static var `default`: Self { [] }  // {[.createDirectories, .atomically]}
}

#endif
