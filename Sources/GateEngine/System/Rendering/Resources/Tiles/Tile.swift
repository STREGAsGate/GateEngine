/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Tile: Identifiable {}

public struct Tile {
    public typealias ID = Int
    public let id: ID
    public let properties: [String: String]
    public let colliders: [Collider]?

    public struct Collider {
        public enum Kind {
            case ellipse
            case rect
        }
        public let kind: Kind
        public let center: Position2
        public let radius: Size2
    }

    public func bool(forKey key: String) -> Bool {
        if let value = properties[key] {
            return Bool(value) ?? false
        }
        return false
    }

    public func integer(forKey key: String) -> Int? {
        if let value = properties[key] {
            return Int(value)
        }
        return nil
    }
}
