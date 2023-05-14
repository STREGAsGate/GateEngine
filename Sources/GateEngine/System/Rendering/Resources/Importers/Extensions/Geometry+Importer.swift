/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

extension ResourceManager {
    public func addGeometryImporter(_ type: GeometryImporter.Type) {
        guard importers.geometryImporters.contains(where: {$0 == type}) == false else {return}
        importers.geometryImporters.insert(type, at: 0)
    }
    
    fileprivate func importerForFile(_ file: URL) -> GeometryImporter? {
        for type in self.importers.geometryImporters {
            if type.canProcessFile(file) {
                return type.init()
            }
        }
        return nil
    }
}

public struct GeometryImporterOptions: Equatable, Hashable {
    public var subobjectName: String? = nil
    public var applyRootTransform: Bool = false
    
    /// Unique to each importer
    public var option1: Bool = false
    
    public static func with(name: String? = nil, applyRootTransform: Bool = false) -> Self {
        return GeometryImporterOptions(subobjectName: name, applyRootTransform: applyRootTransform)
    }
    
    public static var applyRootTransform: GeometryImporterOptions {
        return GeometryImporterOptions(applyRootTransform: true)
    }
    
    public static func named(_ name: String) -> Self {
        return GeometryImporterOptions(subobjectName: name)
    }

    public static var none: GeometryImporterOptions {
        return GeometryImporterOptions()
    }

    public static var option1: GeometryImporterOptions {
        return GeometryImporterOptions(subobjectName: nil, applyRootTransform: false, option1: true)
    }
}

public protocol GeometryImporter: AnyObject {
    init()

    func loadData(path: String, options: GeometryImporterOptions) async throws -> Data
    func process(data: Data, baseURL: URL, options: GeometryImporterOptions) async throws -> RawGeometry

    static func canProcessFile(_ file: URL) -> Bool
}

public extension GeometryImporter {
    func loadData(path: String, options: GeometryImporterOptions) async throws -> Data {
        return try await Game.shared.internalPlatform.loadResource(from: path)
    }
}

extension RawGeometry {
    public init(path: String, options: GeometryImporterOptions = .none) async throws {
        let file = URL(fileURLWithPath: path)
        guard let importer: GeometryImporter = await Game.shared.resourceManager.importerForFile(file) else {
            throw "No importer for \(file.pathExtension)."
        }
        
        do {
            let data = try await importer.loadData(path: path, options: options)
            self = try await importer.process(data: data, baseURL: URL(fileURLWithPath: path).deletingLastPathComponent(), options: options)
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
