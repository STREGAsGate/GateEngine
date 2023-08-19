/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public class TileMapComponent: Component {
    public var tileSet: TileSet? = nil
    public var mapSize: Size2 = .zero {
        didSet {
            needsRebuild = true
        }
    }
    public var tileIndices: [Int] = [] {
        didSet {
            needsRebuild = true
        }
    }

    @MainActor public internal(set) var geometry: MutableGeometry? = MutableGeometry()
    internal var needsRebuild: Bool = true

    public func tileIndexAtCoordinate(column: Int, row: Int) -> Int {
        return tileIndices[(row * Int(mapSize.width)) + column]
    }

    public func tileIndexAtPosition(_ position: Position2) -> Int {
        let column = position.x / tileSet!.tileSize.width
        let row = position.y / tileSet!.tileSize.height
        return tileIndexAtCoordinate(column: Int(column), row: Int(row))
    }

    public func pixelCenterForTileAt(column: Int, row: Int) -> Position2 {
        return (Position2(Float(column), Float(row)) * tileSet!.tileSize)
    }

    public class TileSet {
        public let tileSize: Size2
        public let texture: Texture

        public let count: Int
        public let columns: Int

        @MainActor public init(tileSize: Size2, texture: Texture) {
            self.tileSize = tileSize
            self.texture = texture
            let columns = Int(texture.size.width / tileSize.width)
            self.count = Int(texture.size.height / tileSize.height) * columns
            self.columns = columns
        }

        public func rectForTile(_ tile: Int) -> Rect {
            let row = tile / columns
            let column = tile % columns
            let position = Position2(tileSize.width * Float(column), tileSize.height * Float(row))
            let size = Size2(Float(tileSize.width), Float(tileSize.height))
            return Rect(position: position, size: size)
        }
    }

    required public init() {}
    public static let componentID: ComponentID = ComponentID()
}
