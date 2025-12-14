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

/**
 Returns true when the desired config matches the build config.
 - parameter config: The desired build configuration.
 - returns: `true` when the current build configuration matches `config`
 */
@_transparent
@inlinable
public func when(_ config: BuildConfiguration) -> Bool {
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

@_transparent
@inlinable
public func when(not config: BuildConfiguration) -> Bool {
    return when(config) == false
}

/**
 Returns a given value when the desired config matches the build config.
 - parameter config: The desired build configuration.
 - parameter trueValue: The value to return when the config is a match.
 - parameter falseValue: The value to return when the config is **not** a match.
 - returns: `trueValue` when the current build configuration matches `config`, otherwsie `falseValue`
 */
@_transparent
@inlinable
public func when<T>(_ config: BuildConfiguration, use trueValue: T, else falseValue: T) -> T {
    return when(config) ? trueValue : falseValue
}

@_transparent
@inlinable
public func when<T>(not config: BuildConfiguration, use trueValue: T, else falseValue: T) -> T {
    return when(config) == false ? trueValue : falseValue
}
