/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public class TileSet {
    public let textureName: String
    public let textureSize: Size2

    public let count: Int
    public let columns: Int
    public let tileSize: Size2

    public let tiles: [Tile]

    init(textureName: String,
         textureSize: Size2,
         count: Int,
         columns: Int,
         tileSize: Size2,
         tiles: [Tile]) {
        self.textureName = textureName
        self.textureSize = textureSize
        self.count = count
        self.columns = columns
        self.tileSize = tileSize
        self.tiles = tiles
    }
    
    public func spriteRect(for tile: Int) -> Rect {
        let row = tile / columns
        let column = tile % columns
        return Rect(position: Position2(tileSize.width * Float(column), tileSize.height * Float(row)),
                    size: Size2(Float(tileSize.width), Float(tileSize.height)))
    }
}
