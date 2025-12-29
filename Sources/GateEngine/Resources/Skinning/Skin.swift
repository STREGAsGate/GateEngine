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
        
        init(rawJoint: RawSkin.RawJoint) {
            self.id = rawJoint.id
            self.inverseBindMatrix = rawJoint.inverseBindMatrix
        }
    }
    
    public init(rawSkin: RawSkin) {
        self.joints = rawSkin.joints.map({Joint(rawJoint: $0)})
        self.jointIndices = rawSkin.jointIndices
        self.jointWeights = rawSkin.jointWeights
        self.bindShape = rawSkin.bindShape
    }
}


// MARK: - Resource Manager

public protocol SkinImporter: ResourceImporter {
    mutating func loadSkin(options: SkinImporterOptions) async throws(GateEngineError) -> RawSkin
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

    func skinImporterForPath(_ path: String) async throws(GateEngineError) -> any SkinImporter {
        for type in self.importers.skinImporters {
            if type.canProcessFile(path) {
                return try await self.importers.getImporter(path: path, type: type)
            }
        }
        throw .custom(category: "\(Self.self)", message: "No SkinImporter could be found for \(path)")
    }
}

extension RawSkin {
    public init(path: String, options: SkinImporterOptions = .none) async throws(GateEngineError) {
        var importer: any SkinImporter = try await Game.unsafeShared.resourceManager.skinImporterForPath(path)
        self = try await importer.loadSkin(options: options)
    }
}

extension Skin {
    public init(path: String, options: SkinImporterOptions = .none) async throws {
        do {
            let rawSkin = try await RawSkin(path: path, options: options)
            self.init(rawSkin: rawSkin)
        } catch {
            throw GateEngineError(error)
        }
    }
}
