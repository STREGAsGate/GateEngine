/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

extension ResourceManager {
    public func addSkinImporter(_ type: SkinImporter.Type) {
        guard importers.skinImporters.contains(where: {$0 == type}) == false else {return}
        importers.skinImporters.insert(type, at: 0)
    }
    
    fileprivate func importerForFile(_ file: URL) -> SkinImporter? {
        for type in self.importers.skinImporters {
            if type.canProcessFile(file) {
                return type.init()
            }
        }
        return nil
    }
}

public struct SkinImporterOptions: Equatable, Hashable {
    public var subobjectName: String? = nil

    public static func named(_ name: String) -> Self {
        return SkinImporterOptions(subobjectName: name)
    }

    public static var none: SkinImporterOptions {
        return SkinImporterOptions()
    }
}

public protocol SkinImporter: AnyObject {
    init()

    func loadData(path: String, options: SkinImporterOptions) async throws -> Data
    func process(data: Data, baseURL: URL, options: SkinImporterOptions) async throws -> Skin

    static func canProcessFile(_ file: URL) -> Bool
}

public extension SkinImporter {
    func loadData(path: String, options: SkinImporterOptions) async throws -> Data {
        return try await Game.shared.internalPlatform.loadResource(from: path)
    }
}

extension Skin {
    public init(path: String, options: SkinImporterOptions = .none) async throws {
        let file = URL(fileURLWithPath: path)
        guard let importer: SkinImporter = await Game.shared.resourceManager.importerForFile(file) else {
            throw "No importer for \(file.pathExtension)."
        }
        
        do {
            let data = try await importer.loadData(path: path, options: options)
            self = try await importer.process(data: data, baseURL: URL(string: path)!.deletingLastPathComponent(), options: options)
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
