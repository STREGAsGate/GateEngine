/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public final class TileMapSystem: System {
    public override func update(game: Game, input: HID, withTimePassed deltaTime: Float) async {
        for entity in game.entities {
            if let tileMap = entity.component(ofType: TileMapComponent.self) {
                rebuild(tileMap)
            }
        }
    }
    
    @inline(__always)
    func rebuild(_ tileMap: TileMapComponent) {
        guard tileMap.needsRebuild else {return}
        guard let tileSet = tileMap.tileSet else {return}
        tileMap.needsRebuild = false
        
        var triangles: [Triangle] = []
        triangles.reserveCapacity(Int(tileMap.mapSize.width * tileMap.mapSize.height) * 2)
        
        let tileSize = tileSet.tileSize
        
        let wM: Float = 1 / tileSet.texture.size.width
        let hM: Float = 1 / tileSet.texture.size.height
        for hIndex in 0 ..< Int(tileMap.mapSize.height) {
            for wIndex in 0 ..< Int(tileMap.mapSize.width) {
                let tile = tileSet.rectForTile(tileMap.tileIndexAtCoordinate(column: wIndex, row: hIndex))
                let rect = Rect(position: Position2(x: Float(wIndex) * tileSize.width, y: Float(hIndex) * tileSize.height), size: tileSize)
                let v1 = Vertex(px: rect.x,     py: rect.y,    pz: 0, tu1: tile.x    * wM, tv1: tile.y    * hM)
                let v2 = Vertex(px: rect.maxX,  py: rect.y,    pz: 0, tu1: tile.maxX * wM, tv1: tile.y    * hM)
                let v3 = Vertex(px: rect.maxX,  py: rect.maxY, pz: 0, tu1: tile.maxX * wM, tv1: tile.maxY * hM)
                let v4 = Vertex(px: rect.x,     py: rect.maxY, pz: 0, tu1: tile.x    * wM, tv1: tile.maxY * hM)
                
                triangles.append(Triangle(v1: v1, v2: v2, v3: v3, repairIfNeeded: false))
                triangles.append(Triangle(v1: v3, v2: v4, v3: v1, repairIfNeeded: false))
            }
        }
        if triangles.isEmpty == false {
            tileMap.geometry?.rawGeometry = RawGeometry(triangles: triangles)
        }
    }

    public override class var phase: System.Phase {.updating}
    public override class func sortOrder() -> SystemSortOrder? {
        return .tileMapSystem
    }
}
