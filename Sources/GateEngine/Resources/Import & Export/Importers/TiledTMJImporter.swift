/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

fileprivate struct TMJFile: Decodable {
    let type: String
    let compressionlevel: Int
    let orientation: String
    let renderorder: String
    let infinite: Bool
    let tileheight: Int
    let tilewidth: Int
    let width: Int
    let height: Int
    let layers: [Layer]
    struct Layer: Decodable {
        let id: Int
        let name: String
        let type: String
        let visible: Bool
        let opacity: Float
        let x: Int
        let y: Int
        let width: Int
        let height: Int
        let data: [UInt32]
    }
    let nextlayerid: Int
    let nextobjectid: Int
    let version: String
    let tiledversion: String
}

public final class TiledTMJImporter: TileMapImporter {
    fileprivate var file: TMJFile! = nil
    public required init() {}

    public func synchronousPrepareToImportResourceFrom(path: String) throws(GateEngineError) {
        do {
            let data = try Platform.current.synchronousLoadResource(from: path)
            self.file = try JSONDecoder().decode(TMJFile.self, from: data)
        }catch{
            throw GateEngineError(error)
        }
    }
    
    public func prepareToImportResourceFrom(path: String) async throws(GateEngineError) {
        do {
            let data = try await Platform.current.loadResource(from: path)
            self.file = try JSONDecoder().decode(TMJFile.self, from: data)
        }catch{
            throw GateEngineError(error)
        }
    }
    
    public func loadTileMap(options: TileMapImporterOptions) async throws(GateEngineError) -> TileMapBackend {       
        var layers: [TileMap.Layer] = []
        layers.reserveCapacity(file.layers.count)
        for fileLayer in file.layers {
            var tiles: [[TileMap.Tile]] = []
            let count = fileLayer.width * fileLayer.height
            for start in stride(from: 0, through: count - 1, by: fileLayer.width) {
                let subset = fileLayer.data[start ..< start + fileLayer.width]
                tiles.append(subset.map({ rawID in
                    var options: TileMap.Tile.Options = []
                    var flags = TileMap.Tile.Options(rawValue: UInt(rawID))
                    if flags.contains(.flippedHorizontal) {
                        options.insert(.flippedHorizontal)
                    }
                    if flags.contains(.flippedVertical) {
                        options.insert(.flippedVertical)
                    }
                    if flags.contains(.flippedDiagonal) {
                        options.insert(.flippedDiagonal)
                    }
                    if flags.contains(.rotatedHexagonal120) {
                        options.insert(.rotatedHexagonal120)
                    }
                    flags.remove([.flippedHorizontal, .flippedVertical, .flippedDiagonal, .rotatedHexagonal120])
                    return TileMap.Tile(id: Int(flags.rawValue) - 1, options: options)
                }))
            }
            let layer = TileMap.Layer(name: fileLayer.name,
                                      size: Size2(Float(fileLayer.width), Float(fileLayer.height)),
                                      tileSize: Size2(Float(file.tilewidth), Float(file.tileheight)),
                                      tiles: tiles)
            layers.append(layer)
        }
        
        return await TileMapBackend(layers: layers)
    }
    
    static public func supportedFileExtensions() -> [String] {
        return ["tmj"]
    }
}
