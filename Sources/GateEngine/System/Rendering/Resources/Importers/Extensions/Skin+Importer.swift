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
    
    fileprivate func importerForFileType(_ file: String) -> SkinImporter? {
        for type in self.importers.skinImporters {
            if type.supportedFileExtensions().contains(where: {$0.caseInsensitiveCompare(file) == .orderedSame}) {
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

    static func supportedFileExtensions() -> [String]
}

public extension SkinImporter {
    func loadData(path: String, options: SkinImporterOptions) async throws -> Data {
        return try await Game.shared.internalPlatform.loadResource(from: path)
    }
}

extension Skin {
    public init(path: String, options: SkinImporterOptions = .none) async throws {
        guard let fileExtension = path.components(separatedBy: ".").last else {
            throw "Unknown file type."
        }
        guard let importer: SkinImporter = await Game.shared.resourceManager.importerForFileType(fileExtension) else {
            throw "No importer for \(fileExtension)."
        }
        
        do {
            let data = try await importer.loadData(path: path, options: options)
            self = try await importer.process(data: data, baseURL: URL(string: path)!.deletingLastPathComponent(), options: options)
        }catch let DecodingError.dataCorrupted(context) {
            throw "Failed to load \(Swift.type(of: self)): \(context)"
        }catch let DecodingError.keyNotFound(key, context) {
            throw "Failed to load \(Swift.type(of: self)): Key '\(key)' not found: \(context.debugDescription), codingPath: \(context.codingPath)"
        }catch let DecodingError.valueNotFound(value, context) {
            throw "Failed to load \(Swift.type(of: self)): Value '\(value)' not found: \(context.debugDescription), codingPath: \(context.codingPath)"
        }catch let DecodingError.typeMismatch(type, context)  {
            throw "Failed to load \(Swift.type(of: self)): Type '\(type)' mismatch: \(context.debugDescription), codingPath: \(context.codingPath)"
        }catch {
            throw "Failed to load \(Swift.type(of: self)): \(error)"
        }
    }
}
