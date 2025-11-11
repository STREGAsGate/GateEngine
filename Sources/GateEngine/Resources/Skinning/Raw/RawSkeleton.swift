/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public import GameMath
public import GateUtilities

public struct RawSkeleton: Equatable, Hashable, Codable {
    public var joints: [RawJoint] = []
    
    public struct RawJoint: Equatable, Hashable, Identifiable, Codable {
        public typealias ID = Int
        public let id: ID
        public var parent: ID?
        public let name: String?
        public var localTransform: Transform3
        
        public nonisolated func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        public nonisolated static func == (lhs: RawJoint, rhs: RawJoint) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    public init(rawJoints: [RawJoint]) {
        self.joints = rawJoints
    }
}

extension RawSkeleton: BinaryCodable {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try self.joints.encode(into: &data, version: version)
    }
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        try self.joints = .init(decoding: data, at: &offset, version: version)
    }
}

extension RawSkeleton.RawJoint: BinaryCodable {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try self.id.encode(into: &data, version: version)
        try self.parent.encode(into: &data, version: version)
        try self.name.encode(into: &data, version: version)
        try self.localTransform.encode(into: &data, version: version)
    }
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        try self.id = .init(decoding: data, at: &offset, version: version)
        try self.parent = .init(decoding: data, at: &offset, version: version)
        try self.name = .init(decoding: data, at: &offset, version: version)
        try self.localTransform = .init(decoding: data, at: &offset, version: version)
    }
}
