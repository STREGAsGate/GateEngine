/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
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
            let value: Any?
            
            enum CodingKeys: String, CodingKey {
              case name
              case type
              case value
            }
            
            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.name = try container.decode(String.self, forKey: .name)
                self.type = try container.decode(String.self, forKey: .type)
            
                if let value = try? container.decode(String.self, forKey: .value) {
                    self.value = value
                }else if let value = try? container.decode(Int.self, forKey: .value) {
                    self.value = value
                }else if let value = try? container.decode(Bool.self, forKey: .value) {
                    self.value = value
                }else if let value = try? container.decode(Float.self, forKey: .value) {
                    self.value = value
                }else{
                    throw GateEngineError.failedToDecode("\"value\"'s type is not handled.")
                }
            }
        }
    }
}

public final class TiledTSJImporter: TileSetImporter {
    public required init() {}

    public func process(data: Data, baseURL: URL, options: TileSetImporterOptions) async throws -> TileSetBackend {
        do {
            let file = try JSONDecoder().decode(TSJFile.self, from: data)
            
            let tiles: [TileSet.Tile] = (0 ..< file.tilecount).map({ id in
                var properties: [String: String] = [:]
                if let fileTiles = file.tiles {
                    if let fileTile = fileTiles.first(where: {$0.id == id}) {
                        if let fileTileProperties = fileTile.properties {
                            for property in fileTileProperties {
                                if let value = property.value {
                                    properties[property.name] = "\(value)"
                                }
                            }
                        }
                    }
                }
                return TileSet.Tile(id: id, properties: properties, colliders: nil)
            })
            
            let textureURL = baseURL.appendingPathComponent(file.image)
            
            return await TileSetBackend(
                texture: Texture(path: textureURL.path, sizeHint: Size2(Float(file.imagewidth), Float(file.imageheight))),
                count: file.tilecount,
                columns: file.columns,
                tileSize: Size2(Float(file.tilewidth), Float(file.tileheight)),
                tiles: tiles
            )
        }catch{
            throw GateEngineError(error)
        }
    }
    
    static public func supportedFileExtensions() -> [String] {
        return ["tsj"]
    }
}
