/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

@MainActor public class TileMapComponent: Component {
    internal var needsSetup: Bool = true
    
    public var tileSet: TileSet! = nil {
        didSet {
            needsSetup = true
        }
    }
    public var tileMap: TileMap! = nil {
        didSet {
            needsSetup = true
        }
    }
    
    public var layers: [Layer] = []
    
    public init(tileSetPath: String, tileMapPath: String) {
        self.tileSet = TileSet(path: tileSetPath)
        self.tileMap = TileMap(path: tileMapPath)
    }
    
    @MainActor public struct Layer {
        public let name: String?
        public let size: Size2
        public let tileSize: Size2
        public private(set) var tiles: [[TileMap.Tile]]
        public var animations: [TileAnimation] = []
        public private(set) var geometry: MutableGeometry = MutableGeometry()
        internal var needsRebuild: Bool = true
        
        public var rows: Int {
            return tiles.count
        }
        public var columns: Int {
            return tiles.first?.count ?? 0
        }
        
        public mutating func setTile(_ tile: TileMap.Tile, at coordinate: TileMap.Layer.Coordinate) {
            assert(containsCoordinate(coordinate), "Coordinate out of range")
            self.tiles[coordinate.row][coordinate.column] = tile
            self.needsRebuild = true
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
        
        public struct TileAnimation {
            let coordinate: TileMap.Layer.Coordinate
            let frames: [TileMap.Tile]
            let duration: Float
            var accumulatedTime: Float = 0
            let timePerFrame: Float
            var repeats: Bool
            
            var previousTileIndex: Int = -1
            
            private mutating func append(deltaTime: Float) {
                accumulatedTime += deltaTime
                if repeats {
                    while accumulatedTime > duration {
                        accumulatedTime -= duration
                    }
                }else if accumulatedTime > duration {
                    accumulatedTime = duration
                }
            }
            internal mutating func getNewTile(advancingBy deltaTime: Float) -> TileMap.Tile? {
                self.append(deltaTime: deltaTime)
                
                let index = Int(accumulatedTime / timePerFrame)
                if previousTileIndex != index {
                    self.previousTileIndex = index
                    return frames[index]
                }
                return nil
            }
            
            public init(coordinate: TileMap.Layer.Coordinate, frames: [TileMap.Tile], duration: Float, repeats: Bool = true) {
                self.coordinate = coordinate
                self.frames = frames
                if duration == 0 {
                    self.duration = .ulpOfOne
                }else{
                    self.duration = duration
                }
                self.timePerFrame = duration / Float(frames.count)
                self.repeats = repeats
            }
        }
    }
    
    nonisolated required public init() {}
    public static let componentID: ComponentID = ComponentID()
}
