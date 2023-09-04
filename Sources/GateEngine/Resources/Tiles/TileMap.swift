/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public class TileMap {
    public let layers: [Layer]

    public var size: Size2 {
        return layers.first?.size ?? .zero
    }

    init(layers: [Layer]) {
        self.layers = layers
    }
    
    public struct Tile {
        public let id: Int
        public let options: Options
        public struct Options: OptionSet {
            public let rawValue: UInt
            public init(rawValue: UInt) {
                self.rawValue = rawValue
            }
            
            public static let flippedHorizontal    = Options(rawValue: 0x80000000)
            public static let flippedVertical      = Options(rawValue: 0x40000000)
            public static let flippedDiagonal      = Options(rawValue: 0x20000000)
            public static let rotatedHexagonal120  = Options(rawValue: 0x10000000)
        }
    }

    public class Layer {
        public let name: String?
        public let size: Size2
        public let tileSize: Size2
        public let tiles: [[Tile]]

        public var rows: Int {
            return tiles.count
        }
        public var columns: Int {
            return tiles.first?.count ?? 0
        }

        public func tileIndexAtCoordinate(column: Int, row: Int) -> Int {
            return tiles[row][column].id
        }

        public func tileIndexAtPosition(_ position: Position2) -> Int {
            let column = position.x / tileSize.width
            let row = position.y / tileSize.height
            return tileIndexAtCoordinate(column: Int(column), row: Int(row))
        }

        public func pixelCenterForTileAt(column: Int, row: Int) -> Position2 {
            return (Position2(Float(column), Float(row)) * tileSize)
        }

        init(name: String?, size: Size2, tileSize: Size2, tiles: [[Tile]]) {
            self.name = name
            self.size = size
            self.tileSize = tileSize
            self.tiles = tiles
        }
    }
}
