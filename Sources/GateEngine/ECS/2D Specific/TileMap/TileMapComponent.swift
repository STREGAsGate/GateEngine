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
        
        public func containsCoordinate(_ coordinate: TileMap.Layer.Coordinate) -> Bool {
            return tiles.indices.contains(coordinate.row)
            && tiles[coordinate.row].indices.contains(coordinate.column)
        }
        
        public func coordinate(at position: Position2) -> TileMap.Layer.Coordinate? {
            let row = Int(position.y / tileSize.height)
            let column = Int(position.x / tileSize.width)
            if tiles.indices.contains(row) && tiles[row].indices.contains(column) {
                return TileMap.Layer.Coordinate(column: column, row: row)
            }
            return nil
        }
        
        public func tileAtCoordinate(_ coordinate: TileMap.Layer.Coordinate) -> TileMap.Tile {
            assert(containsCoordinate(coordinate), "Coordinate out of range")
            return tiles[coordinate.row][coordinate.column]
        }

        public func tileAtPosition(_ position: Position2) -> TileMap.Tile? {
            guard let coordinate = coordinate(at: position) else {return nil}
            return tileAtCoordinate(coordinate)
        }
        
        public func rectForTileAt(_ coordinate: TileMap.Layer.Coordinate) -> Rect {
            assert(containsCoordinate(coordinate), "Coordinate out of range")
            let x = Float(coordinate.column)
            let y = Float(coordinate.row)
            let position = Position2(x, y) * tileSize
            return Rect(position: position, size: tileSize)
        }

//        public func tileIndexAtCoordinate(column: Int, row: Int) -> Int {
//            return tiles[row][column].id
//        }
//
//        public func tileIndexAtPosition(_ position: Position2) -> Int {
//            let column = position.x / tileSize.width
//            let row = position.y / tileSize.height
//            return tileIndexAtCoordinate(column: Int(column), row: Int(row))
//        }
//
//        public func pixelCenterForTileAt(column: Int, row: Int) -> Position2 {
//            return (Position2(Float(column), Float(row)) * tileSize)
//        }

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
