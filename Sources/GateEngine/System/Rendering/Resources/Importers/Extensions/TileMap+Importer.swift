/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

extension ResourceManager {
    public func addTileMapImporter(_ type: TileMapImporter.Type) {
        guard importers.tileMapImporters.contains(where: {$0 == type}) == false else {return}
        importers.tileMapImporters.insert(type, at: 0)
    }

    fileprivate func importerForFileType(_ file: String) -> TileMapImporter? {
        for type in self.importers.tileMapImporters {
            if type.supportedFileExtensions().contains(where: {$0.caseInsensitiveCompare(file) == .orderedSame}) {
                return type.init()
            }
        }
        return nil
    }
}

public struct TileMapImporterOptions: Equatable, Hashable {
    public var subobjectName: String? = nil

    public static func named(_ name: String) -> Self {
        return TileMapImporterOptions(subobjectName: name)
    }

    public static var none: TileMapImporterOptions {
        return TileMapImporterOptions()
    }
}

public protocol TileMapImporter: AnyObject {
    init()

    func process(data: Data, baseURL: URL, options: TileMapImporterOptions) async throws -> TileMap

    static func supportedFileExtensions() -> [String]
}

extension TileMap {
    public convenience init(path: String, options: TileMapImporterOptions = .none) async throws {
        guard let fileExtension = path.components(separatedBy: ".").last else {
            throw "Unknown file type."
        }
        guard let importer: TileMapImporter = await Game.shared.resourceManager.importerForFileType(fileExtension) else {
            throw "No importer for \(fileExtension)."
        }

        do {
            let data = try await Game.shared.platform.loadResource(from: path)
            let copy = try await importer.process(data: data, baseURL: URL(string: path)!.deletingLastPathComponent(), options: options)
            self.init(layers: copy.layers)
        }catch let DecodingError.dataCorrupted(context) {
            throw "corrupt data (\(Swift.type(of: self)): \(context))"
        }catch let DecodingError.keyNotFound(key, context) {
            throw "key '\(key)' not found: \(context.debugDescription), codingPath: \(context.codingPath)"
        }catch let DecodingError.valueNotFound(value, context) {
            throw "value '\(value)' not found: \(context.debugDescription), codingPath: \(context.codingPath)"
        }catch let DecodingError.typeMismatch(type, context)  {
            throw "type '\(type)' mismatch: \(context.debugDescription), codingPath: \(context.codingPath)"
        }catch {
            throw "\(error)"
        }
    }
}
