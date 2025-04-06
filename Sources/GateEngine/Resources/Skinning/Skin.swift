/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public struct Skin: Hashable {
    public let joints: [Joint]
    public let jointIndices: [UInt32]
    public let jointWeights: [Float]
    public let bindShape: Matrix4x4

    public init(joints: [Joint], indices: [UInt32], weights: [Float], bindShape: Matrix4x4) {
        self.joints = joints
        self.jointIndices = indices
        self.jointWeights = weights
        self.bindShape = bindShape
    }

    public struct Joint: Hashable {
        public let id: Int
        public let inverseBindMatrix: Matrix4x4
        public init(id: Int, inverseBindMatrix: Matrix4x4) {
            self.id = id
            self.inverseBindMatrix = inverseBindMatrix
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}


// MARK: - Resource Manager

public protocol SkinImporter: ResourceImporter {
    func loadSkin(options: SkinImporterOptions) async throws(GateEngineError) -> Skin
}

public struct SkinImporterOptions: Equatable, Hashable, Sendable {
    public var subobjectName: String? = nil

    public static func named(_ name: String) -> Self {
        return SkinImporterOptions(subobjectName: name)
    }

    public static var none: SkinImporterOptions {
        return SkinImporterOptions()
    }
}

extension ResourceManager {
    public func addSkinImporter(_ type: any SkinImporter.Type) {
        guard importers.skinImporters.contains(where: { $0 == type }) == false else { return }
        importers.skinImporters.insert(type, at: 0)
    }

    fileprivate func importerForPath(_ path: String) async throws -> (any SkinImporter)? {
        for type in self.importers.skinImporters {
            if type.canProcessFile(path) {
                return try await self.importers.getImporter(path: path, type: type)
            }
        }
        return nil
    }
}

extension Skin {
    public init(path: String, options: SkinImporterOptions = .none) async throws {
        guard
            let importer: any SkinImporter = try await Game.shared.resourceManager.importerForPath(path)
        else {
            throw GateEngineError.failedToLoad("No importer for \(URL(fileURLWithPath: path).pathExtension).")
        }

        do {
            self = try await importer.loadSkin(options: options)
        } catch {
            throw GateEngineError(error)
        }
    }
}
