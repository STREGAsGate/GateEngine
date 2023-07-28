/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

extension ResourceManager {
    public func addTileSetImporter(_ type: TileSetImporter.Type) {
        guard importers.tileSetImporters.contains(where: {$0 == type}) == false else {return}
        importers.tileSetImporters.insert(type, at: 0)
    }

    fileprivate func importerForFileType(_ file: String) -> TileSetImporter? {
        for type in self.importers.tileSetImporters {
            if type.supportedFileExtensions().contains(where: {$0.caseInsensitiveCompare(file) == .orderedSame}) {
                return type.init()
            }
        }
        return nil
    }
}

public struct TileSetImporterOptions: Equatable, Hashable {
    public var subobjectName: String? = nil

    public static func named(_ name: String) -> Self {
        return TileSetImporterOptions(subobjectName: name)
    }

    public static var none: TileSetImporterOptions {
        return TileSetImporterOptions()
    }
}

public protocol TileSetImporter: AnyObject {
    init()

    func process(data: Data, baseURL: URL, options: TileSetImporterOptions) async throws -> TileSet

    static func supportedFileExtensions() -> [String]
}

extension TileSet {
    public convenience init(path: String, options: TileSetImporterOptions = .none) async throws {
        guard let fileExtension = path.components(separatedBy: ".").last else {
            throw GateEngineError.failedToLoad("Unknown file type.")
        }
        guard let importer: TileSetImporter = await Game.shared.resourceManager.importerForFileType(fileExtension) else {
            throw GateEngineError.failedToLoad("No importer for \(fileExtension).")
        }

        do {
            let data = try await Game.shared.platform.loadResource(from: path)
            let copy = try await importer.process(data: data, baseURL: URL(string: path)!.deletingLastPathComponent(), options: options)
            self.init(textureName: copy.textureName,
                      textureSize: copy.textureSize,
                      count: copy.count,
                      columns: copy.columns,
                      tileSize: copy.tileSize,
                      tiles: copy.tiles)
        }catch{
            throw GateEngineError(decodingError: error)
        }
    }
}
