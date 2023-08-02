/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import struct Foundation.URL

extension ResourceManager {
    public func addGeometryImporter(_ type: any GeometryImporter.Type, atEnd: Bool = false) {
        guard importers.geometryImporters.contains(where: { $0 == type }) == false else { return }
        if atEnd {
            importers.geometryImporters.append(type)
        } else {
            importers.geometryImporters.insert(type, at: 0)
        }
    }

    fileprivate func importerForFile(_ file: URL) -> (any GeometryImporter)? {
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
    func process(data: Data, baseURL: URL, options: GeometryImporterOptions) async throws
        -> RawGeometry

    static func canProcessFile(_ file: URL) -> Bool
}

extension GeometryImporter {
    public func loadData(path: String, options: GeometryImporterOptions) async throws -> Data {
        return try await Game.shared.platform.loadResource(from: path)
    }
}

extension RawGeometry {
    @inlinable @inline(__always) @_disfavoredOverload
    public init(_ path: GeoemetryPath, options: GeometryImporterOptions = .none) async throws {
        try await self.init(path: path.value, options: options)
    }
    public init(path: String, options: GeometryImporterOptions = .none) async throws {
        let file = URL(fileURLWithPath: path)
        guard
            let importer: any GeometryImporter = await Game.shared.resourceManager.importerForFile(
                file
            )
        else {
            throw GateEngineError.failedToLoad("No importer for \(file.pathExtension).")
        }

        do {
            let data = try await importer.loadData(path: path, options: options)
            self = try await importer.process(
                data: data,
                baseURL: file.deletingLastPathComponent(),
                options: options
            )
        } catch {
            throw GateEngineError(decodingError: error)
        }
    }
}
