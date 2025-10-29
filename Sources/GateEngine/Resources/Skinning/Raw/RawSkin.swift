/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public import GameMath
public import GateUtilities

public struct RawSkin: Hashable, BinaryCodable {
    public let joints: [RawJoint]
    public let jointIndices: [UInt32]
    public let jointWeights: [Float]
    public let bindShape: Matrix4x4
    
    public init(joints: [RawJoint], indices: [UInt32], weights: [Float], bindShape: Matrix4x4) {
        self.joints = joints
        self.jointIndices = indices
        self.jointWeights = weights
        self.bindShape = bindShape
    }
    
    public struct RawJoint: Hashable, BinaryCodable {
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

extension RawSkin {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try joints.encode(into: &data, version: version)
        try jointIndices.encode(into: &data, version: version)
        try jointWeights.encode(into: &data, version: version)
        try self.bindShape.encode(into: &data, version: version)
    }
    
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        self.joints = try .init(decoding: data, at: &offset, version: version)
        self.jointIndices = try .init(decoding: data, at: &offset, version: version)
        self.jointWeights = try .init(decoding: data, at: &offset, version: version)
        self.bindShape = try Matrix4x4(decoding: data, at: &offset, version: version)
    }
}

extension RawSkin.RawJoint {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try self.id.encode(into: &data, version: version)
        try self.inverseBindMatrix.encode(into: &data, version: version)
    }
    
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        self.id = try Int(decoding: data, at: &offset, version: version)
        self.inverseBindMatrix = try Matrix4x4(decoding: data, at: &offset, version: version)
    }
}
