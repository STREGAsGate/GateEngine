/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

fileprivate struct TSJFile: Decodable {
    let columns: Int
    let image: String
    let imageheight: Int
    let imagewidth: Int
    let margin: Int
    let name: String
    let spacing: Int
    let tilecount: Int
    let tiledversion: String
    let tileheight: Int
    let tilewidth: Int
    let type: String
    let version: String
    let tiles: [Tile]?
    
    struct Tile: Decodable {
        let id: Int
        let properties: [Property]?
        
        struct Property: Decodable {
            let name: String
            let type: String
            let value: String
        }
    }
}

public class TiledTSJImporter: TileSetImporter {
    public required init() {}

    public func process(data: Data, baseURL: URL, options: TileSetImporterOptions) async throws -> TileSetBackend {
        let file = try JSONDecoder().decode(TSJFile.self, from: data)
        
        let tiles: [TileSet.Tile] = (0 ..< file.tilecount).map({ id in
            var properties: [String: String] = [:]
            if let fileTiles = file.tiles {
                if let fileTile = fileTiles.first(where: {$0.id == id}) {
                    if let fileTileProperties = fileTile.properties {
                        for property in fileTileProperties {
                            properties[property.name] = property.value
                        }
                    }
                }
            }
            return TileSet.Tile(id: id, properties: properties, colliders: nil)
        })

        return TileSetBackend(textureName: file.image,
                              textureSize: Size2(Float(file.imagewidth), Float(file.imageheight)),
                              count: file.tilecount,
                              columns: file.columns,
                              tileSize: Size2(Float(file.tilewidth), Float(file.tileheight)),
                              tiles: tiles)
    }
    
    static public func supportedFileExtensions() -> [String] {
        return ["tsj"]
    }
}
