/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */


public enum BuildConfiguration {
    /// The DEBUG build configuration
    case debug
    /// The RELEASE build configuration
    case release
    /// The DISTRIBUTE package trait. Enable the DISTRIBUTE package trait when importing GateEngine as a dependency.
    case distribute
}

public extension Bool {
    /**
     Returns true when the desired config matches the build config.
     - parameter config: The desired build configuration.
     - returns: `true` when the current build configuration matches `config`
     */
    @_transparent
    static func when(_ config: BuildConfiguration) -> Bool {
        switch config {
        case .debug:
            #if DEBUG
            return true
            #else
            return false
            #endif
        case .release:
            #if RELEASE
            return true
            #else
            return false
            #endif
        case .distribute:
            #if DISTRIBUTE
            return true
            #else
            return false
            #endif
        }
    }
}
