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
    fileprivate var file: TSJFile! = nil
    var basePath: String = ""
    public required init() {}
    
    public func synchronousPrepareToImportResourceFrom(path: String) throws(GateEngineError) {
        do {
            let data = try Platform.current.synchronousLoadResource(from: path)
            self.file = try JSONDecoder().decode(TSJFile.self, from: data)
            
            var comps = path.components(separatedBy: "/")
            comps.removeLast()
            if path.hasPrefix("/") {
                comps.insert("/", at: 0)
            }
            self.basePath = comps.joined(separator: "/")
        }catch{
            throw GateEngineError(error)
        }
    }
    public func prepareToImportResourceFrom(path: String) async throws(GateEngineError) {
        do {
            let data = try await Game.shared.platform.loadResource(from: path)
            self.file = try JSONDecoder().decode(TSJFile.self, from: data)
            
            var comps = path.components(separatedBy: "/")
            comps.removeLast()
            if path.hasPrefix("/") {
                comps.insert("/", at: 0)
            }
            self.basePath = comps.joined(separator: "/")
        }catch{
            throw GateEngineError(error)
        }
    }

    public func loadTileSet(options: TileSetImporterOptions) async throws(GateEngineError) -> TileSetBackend {        
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
        
        let texturePath = basePath + "/" + file.image
        
        return await TileSetBackend(
            texture: Texture(path: texturePath, sizeHint: Size2(Float(file.imagewidth), Float(file.imageheight))),
            count: file.tilecount,
            columns: file.columns,
            tileSize: Size2(Float(file.tilewidth), Float(file.tileheight)),
            tiles: tiles
        )
    }
    
    static public func supportedFileExtensions() -> [String] {
        return ["tsj"]
    }
}
