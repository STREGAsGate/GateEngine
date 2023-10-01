/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

/// Values as seen on a compass
public enum CardinalDirection: String, Codable, Sendable {
    case unknown        = "Unknown"
    case north          = "North"
    case northNorthEast = "NorthNorthEast"
    case northEast      = "NorthEast"
    case eastNorthEast  = "EastNorthEast"
    case east           = "East"
    case eastSouthEast  = "EastSouthEast"
    case southEast      = "SouthEast"
    case southSouthEast = "SouthSouthEast"
    case south          = "South"
    case southSouthWest = "SouthSouthWest"
    case southWest      = "SouthWest"
    case westSouthWest  = "WestSouthWest"
    case west           = "West"
    case westNorthWest  = "WestNorthWest"
    case northWest      = "NorthWest"
    case northNorthWest = "NorthNorthWest"
}

extension Degrees {
    /// Creates degrees from a compass direction. This value is considered an angle around the up vector in 3d.
    @inlinable
    public init(_ cardinalDirection: CardinalDirection) {
        switch cardinalDirection {
        case .unknown:
            fallthrough
        case .north:
            rawValue = 22.5 * 0
        case .northNorthEast:
            rawValue = 22.5 * 1
        case .northEast:
            rawValue = 22.5 * 2
        case .eastNorthEast:
            rawValue = 22.5 * 3
        case .east:
            rawValue = 22.5 * 4
        case .eastSouthEast:
            rawValue = 22.5 * 5
        case .southEast:
            rawValue = 22.5 * 6
        case .southSouthEast:
            rawValue = 22.5 * 7
        case .south:
            rawValue = 22.5 * 8
        case .southSouthWest:
            rawValue = 22.5 * 9
        case .southWest:
            rawValue = 22.5 * 10
        case .westSouthWest:
            rawValue = 22.5 * 11
        case .west:
            rawValue = 22.5 * 12
        case .westNorthWest:
            rawValue = 22.5 * 13
        case .northWest:
            rawValue = 22.5 * 14
        case .northNorthWest:
            rawValue = 22.5 * 15
        }
    }
    
    /// The compass value closest to the current angle
    @inlinable
    public var cardinalDirection: CardinalDirection {
        switch self.normalized.rawValue {
        case 0.0 ... 11.25:
            return .north
        case 11.25 ... 33.75:
            return .northNorthEast
        case 33.75 ... 56.25:
            return .northEast
        case 56.25 ... 78.75:
            return .eastNorthEast
        case 78.75 ... 101.25:
            return .east
        case 101.25 ... 123.75:
            return .eastSouthEast
        case 123.75 ... 146.25:
            return .southEast
        case 146.25 ... 168.75:
            return .southSouthEast
        case 168.75 ... 191.25:
            return .south
        case 191.25 ... 213.75:
            return .southSouthWest
        case 213.75 ... 236.25:
            return .southWest
        case 236.25 ... 258.75:
            return .westSouthWest
        case 258.75 ... 281.25:
            return .west
        case 281.25 ... 303.75:
            return .westNorthWest
        case 303.75 ... 326.25:
            return .northWest
        case 326.25 ... 348.75:
            return .northNorthWest
        case 348.75 ... 360.0:
            return .north
        default:
            return .unknown
        }
    }
}
