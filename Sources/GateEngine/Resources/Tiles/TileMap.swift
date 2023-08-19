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

    public class Layer {
        public let name: String?
        public let size: Size2
        public let tileSize: Size2
        public let tileIndices: [[Int]]

        public var rows: Int {
            return tileIndices.count
        }
        public var columns: Int {
            return tileIndices.first?.count ?? 0
        }

        public func tileIndexAtCoordinate(column: Int, row: Int) -> Int {
            return tileIndices[row][column]
        }

        public func tileIndexAtPosition(_ position: Position2) -> Int {
            let column = position.x / tileSize.width
            let row = position.y / tileSize.height
            return tileIndexAtCoordinate(column: Int(column), row: Int(row))
        }

        public func pixelCenterForTileAt(column: Int, row: Int) -> Position2 {
            return (Position2(Float(column), Float(row)) * tileSize)
        }

        init(name: String?, size: Size2, tileSize: Size2, tileIndices: [[Int]]) {
            self.name = name
            self.size = size
            self.tileSize = tileSize
            self.tileIndices = tileIndices
        }
    }
}
