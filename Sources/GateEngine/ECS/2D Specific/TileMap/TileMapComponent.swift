/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

@MainActor public class TileMapComponent: Component {
    internal var needsSetup: Bool = true
    
    public var tileSet: TileSet! = nil
    public var tileMap: TileMap! = nil
    
    public var layers: [Layer] = []
    
    public init(tileSetPath: String, tileMapPath: String) {
        self.tileSet = TileSet(path: tileSetPath)
        self.tileMap = TileMap(path: tileMapPath)
    }
    
    @MainActor public struct Layer {
        public let name: String?
        public let size: Size2
        public let tileSize: Size2
        public var tiles: [[TileMap.Tile]] {
            didSet {
                needsRebuild = true
            }
        }
        public private(set) var geometry: MutableGeometry = MutableGeometry()
        internal var needsRebuild: Bool = true
        
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

        internal init(layer: TileMap.Layer) {
            self.name = layer.name
            self.size = layer.size
            self.tileSize = layer.tileSize
            self.tiles = layer.tiles
        }
    }
    
    nonisolated required public init() {}
    public static let componentID: ComponentID = ComponentID()
}
