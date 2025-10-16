/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public struct RawSkeleton: Equatable, Hashable, Codable, BinaryCodable {
    public var joints: [RawJoint] = []
    
    public struct RawJoint: Equatable, Hashable, Identifiable, Codable, BinaryCodable {
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
