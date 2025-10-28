/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
 
public import GameMath
public import GateUtilities
 
public struct RawSkeletalAnimation: BinaryCodable {
    public var name: String
    public var duration: Float
    public var animations: [RawSkeleton.RawJoint.ID: Self.JointAnimation]

    public init(name: String, duration: Float, animations: [RawSkeleton.RawJoint.ID: Self.JointAnimation]) {
        self.name = name
        self.duration = duration
        self.animations = animations
    }
    
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try self.name.encode(into: &data, version: version)
        try self.duration.encode(into: &data, version: version)

        let keys = Array(self.animations.keys)
        let values = keys.map({animations[$0]!})
        try RawSkeleton.RawJoint.ID.encodeArray(keys, into: &data, version: version)
        try Self.JointAnimation.encodeArray(values, into: &data, version: version)
    }
    
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        self.name = try String(decoding: data, at: &offset, version: version)
        self.duration = try Float(decoding: data, at: &offset, version: version)
        
        let keys = try RawSkeleton.RawJoint.ID.decodeArray(data, offset: &offset, version: version)
        let values = try Self.JointAnimation.decodeArray(data, offset: &offset, version: version)
        self.animations = Dictionary(uniqueKeysWithValues: zip(keys, values))
    }
}

public extension RawSkeletalAnimation {
    struct JointAnimation: BinaryCodable, Sendable {
        public enum Interpolation: BinaryCodable, Sendable {
            case step
            case linear
            
            public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
                switch self {
                case .step:
                    try UInt8(0).encode(into: &data, version: version)
                case .linear:
                    try UInt8(1).encode(into: &data, version: version)
                }
            }
            
            public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
                let value: UInt8 = try UInt8(decoding: data, at: &offset, version: version)
                switch value {
                case 0:
                    self = .step
                case 1:
                    self = .linear
                default:
                    throw GateEngineError.failedToDecode("Unexpected raw animation interpolation value: \(value)")
                }
            }
        }

        public init() {

        }

        public mutating func setPositions(
            _ positions: [Position3],
            times: [Float],
            interpolation: Interpolation
        ) {
            assert(positions.count == times.count)
            self.positionOutput.positions = positions
            self.positionOutput.times = times
            self.positionOutput.interpolation = interpolation
        }
        public mutating func setRotations(
            _ rotations: [Quaternion],
            times: [Float],
            interpolation: Interpolation
        ) {
            assert(rotations.count == times.count)
            self.rotationOutput.rotations = rotations
            self.rotationOutput.times = times
            self.rotationOutput.interpolation = interpolation
        }
        public mutating func setScales(
            _ scales: [Size3], 
            times: [Float], 
            interpolation: Interpolation
        ) {
            assert(scales.count == times.count)
            self.scaleOutput.scales = scales
            self.scaleOutput.times = times
            self.scaleOutput.interpolation = interpolation
        }

        var positionOutput: PositionOutput = PositionOutput(
            times: [],
            interpolation: .linear,
            positions: []
        )
        struct PositionOutput: BinaryCodable, Sendable {
            var times: [Float]
            var interpolation: Interpolation
            var positions: [Position3]
            var bind: Position3 = .zero
            
            init(times: [Float], interpolation: Interpolation, positions: [Position3]) {
                self.times = times
                self.interpolation = interpolation
                self.positions = positions
            }
            
            func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
                try Float.encodeArray(times, into: &data, version: version)
                try interpolation.encode(into: &data, version: version)
                try Position3.encodeArray(positions, into: &data, version: version)
                try bind.encode(into: &data, version: version)
            }
            
            init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
                self.times = try Float.decodeArray(data, offset: &offset, version: version)
                self.interpolation = try Interpolation(decoding: data, at: &offset, version: version)
                self.positions = try Position3.decodeArray(data, offset: &offset, version: version)
                self.bind = try Position3(decoding: data, at: &offset, version: version)
            }
        }
        var rotationOutput: RotationOutput = RotationOutput(
            times: [],
            interpolation: .linear,
            rotations: []
        )
        struct RotationOutput: Sendable {
            var times: [Float]
            var interpolation: Interpolation
            var rotations: [Quaternion]
            var bind: Quaternion = .zero
            
            init(times: [Float], interpolation: Interpolation, rotations: [Quaternion]) {
                self.times = times
                self.interpolation = interpolation
                self.rotations = rotations
            }
            
            func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
                try Float.encodeArray(times, into: &data, version: version)
                try interpolation.encode(into: &data, version: version)
                try Quaternion.encodeArray(rotations, into: &data, version: version)
                try bind.encode(into: &data, version: version)
            }
            
            init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
                self.times = try Float.decodeArray(data, offset: &offset, version: version)
                self.interpolation = try Interpolation(decoding: data, at: &offset, version: version)
                self.rotations = try Quaternion.decodeArray(data, offset: &offset, version: version)
                self.bind = try Quaternion(decoding: data, at: &offset, version: version)
            }
        }

        var scaleOutput: ScaleOutput = ScaleOutput(times: [], interpolation: .linear, scales: [])
        struct ScaleOutput: Sendable {
            var times: [Float]
            var interpolation: Interpolation
            var scales: [Size3]
            var bind: Size3 = .one
            
            init(times: [Float], interpolation: Interpolation, scales: [Size3]) {
                self.times = times
                self.interpolation = interpolation
                self.scales = scales
            }
            
            func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
                try Float.encodeArray(times, into: &data, version: version)
                try interpolation.encode(into: &data, version: version)
                try Size3.encodeArray(scales, into: &data, version: version)
                try bind.encode(into: &data, version: version)
            }
            
            init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
                self.times = try Float.decodeArray(data, offset: &offset, version: version)
                self.interpolation = try Interpolation(decoding: data, at: &offset, version: version)
                self.scales = try Size3.decodeArray(data, offset: &offset, version: version)
                self.bind = try Size3(decoding: data, at: &offset, version: version)
            }
        }
        
        
        
        public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
            try self.positionOutput.encode(into: &data, version: version)
            try self.rotationOutput.encode(into: &data, version: version)
            try self.scaleOutput.encode(into: &data, version: version)
        }
        
        public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
            self.positionOutput = try PositionOutput(decoding: data, at: &offset, version: version)
            self.rotationOutput = try RotationOutput(decoding: data, at: &offset, version: version)
            self.scaleOutput = try ScaleOutput(decoding: data, at: &offset, version: version)
        }
    }
}
