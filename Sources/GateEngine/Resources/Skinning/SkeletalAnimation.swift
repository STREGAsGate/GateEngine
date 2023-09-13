/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public class SkeletalAnimation {
    public let name: String
    public let duration: Float
    let animations: [Skeleton.Joint.ID: JointAnimation]

    public init(name: String, duration: Float, animations: [Skeleton.Joint.ID: JointAnimation]) {
        self.name = name
        self.duration = duration
        self.animations = animations
    }
}

extension SkeletalAnimation {
    public class JointAnimation {
        public enum Interpolation {
            case step
            case linear
        }

        public init() {

        }

        public func setPositions(
            _ positions: [Position3],
            times: [Float],
            interpolation: Interpolation
        ) {
            assert(positions.count == times.count)
            self.positionOutput.positions = positions
            self.positionOutput.times = times
            self.positionOutput.interpolation = interpolation
        }
        public func setRotations(
            _ rotations: [Quaternion],
            times: [Float],
            interpolation: Interpolation
        ) {
            assert(rotations.count == times.count)
            self.rotationOutput.rotations = rotations
            self.rotationOutput.times = times
            self.rotationOutput.interpolation = interpolation
        }
        public func setScales(_ scales: [Size3], times: [Float], interpolation: Interpolation) {
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
        struct PositionOutput {
            var times: [Float]
            var interpolation: Interpolation
            var positions: [Position3]

            func position(forTime time: Float, duration: Float, repeating: Bool) -> Position3? {
                guard positions.isEmpty == false else { return nil }
                if let index = times.firstIndex(where: { $0 == time }) {
                    // perfect frame time
                    return positions[index]
                }
                if times.count == 1, times[0] < time {
                    return positions[0]
                }

                if let firstIndex = times.lastIndex(where: { $0 < time }) {
                    if let lastIndex = times.firstIndex(where: { $0 > time }) {
                        let time1 = times[firstIndex]
                        let time2 = times[lastIndex]

                        let position1 = positions[firstIndex]
                        let position2 = positions[lastIndex]

                        let currentTime = Float(time2 - time)
                        let currentDuration = Float(time2 - time1)

                        let factor: Float = 1 - (currentTime / currentDuration)
                        guard factor.isFinite else { return position2 }

                        switch interpolation {
                        case .linear:
                            return position1.interpolated(
                                to: position2,
                                .linear(factor, options: [.shortest])
                            )
                        case .step:
                            if factor < 0.5 {
                                return position1
                            }
                            return position2
                        }
                    }
                    return positions[firstIndex]
                }
                if repeating {
                    let time1: Float = 0
                    let time2: Float = times[0]

                    let position1 = positions.last!
                    let position2 = positions[0]

                    let currentTime = Float(time2 - time)
                    let currentDuration = Float(time2 - time1)

                    let factor: Float = 1 - (currentTime / currentDuration)
                    guard factor.isFinite else { return position2 }

                    switch interpolation {
                    case .linear:
                        return position1.interpolated(
                            to: position2,
                            .linear(factor, options: [.shortest])
                        )
                    case .step:
                        if factor < 0.5 {
                            return position1
                        }
                        return position2
                    }
                }
                return positions.first
            }
        }
        var rotationOutput: RotationOutput = RotationOutput(
            times: [],
            interpolation: .linear,
            rotations: []
        )
        struct RotationOutput {
            var times: [Float]
            var interpolation: Interpolation
            var rotations: [Quaternion]

            func rotation(forTime time: Float, duration: Float, repeating: Bool) -> Quaternion? {
                guard rotations.isEmpty == false else { return nil }
                if let index = times.firstIndex(where: { $0 == time }) {
                    // perfect frame time
                    return rotations[index]
                }
                if times.count == 1, times[0] < time {
                    return rotations[0]
                }

                if let firstIndex = times.lastIndex(where: { $0 < time }) {
                    if let lastIndex = times.firstIndex(where: { $0 > time }) {
                        let time1 = times[firstIndex]
                        let time2 = times[lastIndex]

                        let rotation1 = rotations[firstIndex]
                        let rotation2 = rotations[lastIndex]

                        let currentTime = Float(time2 - time)
                        let currentDuration = Float(time2 - time1)

                        let factor: Float = 1 - (currentTime / currentDuration)
                        guard factor.isFinite else { return rotation2 }

                        switch interpolation {
                        case .linear:
                            return rotation1.interpolated(
                                to: rotation2,
                                .linear(factor, options: [.shortest])
                            )
                        case .step:
                            if factor < 0.5 {
                                return rotation1
                            }
                            return rotation2
                        }
                    }
                    return rotations[firstIndex]
                }
                if repeating {
                    let time1: Float = 0
                    let time2: Float = times[0]

                    let rotation1 = rotations.last!
                    let rotation2 = rotations[0]

                    let currentTime = Float(time2 - time)
                    let currentDuration = Float(time2 - time1)

                    let factor: Float = 1 - (currentTime / currentDuration)
                    guard factor.isFinite else { return rotation2 }

                    switch interpolation {
                    case .linear:
                        return rotation1.interpolated(
                            to: rotation2,
                            .linear(factor, options: [.shortest])
                        )
                    case .step:
                        if factor < 0.5 {
                            return rotation1
                        }
                        return rotation2
                    }
                }
                return rotations.first
            }
        }

        var scaleOutput: ScaleOutput = ScaleOutput(times: [], interpolation: .linear, scales: [])
        struct ScaleOutput {
            var times: [Float]
            var interpolation: Interpolation
            var scales: [Size3]

            func scale(forTime time: Float, duration: Float, repeating: Bool) -> Size3? {
                guard scales.isEmpty == false else { return nil }
                if let index = times.firstIndex(where: { $0 == time }) {
                    // perfect frame time
                    return scales[index]
                }
                if times.count == 1, times[0] < time {
                    return scales[0]
                }

                if let firstIndex = times.lastIndex(where: { $0 < time }) {
                    if let lastIndex = times.firstIndex(where: { $0 > time }) {
                        let time1 = times[firstIndex]
                        let time2 = times[lastIndex]

                        let scale1 = scales[firstIndex]
                        let scale2 = scales[lastIndex]

                        let currentTime = Float(time2 - time)
                        let currentDuration = Float(time2 - time1)

                        let factor: Float = 1 - (currentTime / currentDuration)
                        guard factor.isFinite else { return scale2 }

                        switch interpolation {
                        case .linear:
                            return scale1.interpolated(
                                to: scale2,
                                .linear(factor, options: [.shortest])
                            )
                        case .step:
                            if factor < 0.5 {
                                return scale1
                            }
                            return scale2
                        }
                    }
                    return scales[firstIndex]
                }
                if repeating {
                    let time1: Float = 0
                    let time2: Float = times[0]

                    let scale1 = scales.last!
                    let scale2 = scales[0]

                    let currentTime = Float(time2 - time)
                    let currentDuration = Float(time2 - time1)

                    let factor: Float = 1 - (currentTime / currentDuration)
                    guard factor.isFinite else { return scale2 }

                    switch interpolation {
                    case .linear:
                        return scale1.interpolated(
                            to: scale2,
                            .linear(factor, options: [.shortest])
                        )
                    case .step:
                        if factor < 0.5 {
                            return scale1
                        }
                        return scale2
                    }
                }
                return scales.first
            }
        }

        func updateTransform(
            _ transform: inout Transform3,
            withTime time: Float,
            duration: Float,
            repeating: Bool
        ) -> KeyedComponents {
            var keyedComponents: KeyedComponents = []
            if let position = positionOutput.position(
                forTime: time,
                duration: duration,
                repeating: repeating
            ) {
                assert(position.isFinite)
                transform.position = position
                keyedComponents.insert(.position)
            }
            if let rotation = rotationOutput.rotation(
                forTime: time,
                duration: duration,
                repeating: repeating
            ) {
                assert(rotation.isFinite)
                transform.rotation = rotation
                keyedComponents.insert(.rotation)
            }
            if let scale = scaleOutput.scale(
                forTime: time,
                duration: duration,
                repeating: repeating
            ) {
                assert(scale.isFinite)
                transform.scale = scale
                keyedComponents.insert(.scale)
            }
            return keyedComponents
        }
    }

    struct KeyedComponents: OptionSet {
        typealias RawValue = UInt8
        let rawValue: RawValue
        static let position = KeyedComponents(rawValue: 1 << 1)
        static let rotation = KeyedComponents(rawValue: 1 << 2)
        static let scale = KeyedComponents(rawValue: 1 << 3)

        @_transparent
        var isFull: Bool {
            return self == [.position, .rotation, .scale]
        }
    }
}


// MARK: - Resource Manager

public protocol SkeletalAnimationImporter: AnyObject {
    init()

    func loadData(path: String, options: SkeletalAnimationImporterOptions) async throws -> SkeletalAnimation

    static func canProcessFile(_ file: URL) -> Bool
}

public struct SkeletalAnimationImporterOptions: Equatable, Hashable {
    public var subobjectName: String? = nil

    public static func named(_ name: String) -> Self {
        return SkeletalAnimationImporterOptions(subobjectName: name)
    }

    public static var none: SkeletalAnimationImporterOptions {
        return SkeletalAnimationImporterOptions()
    }
}

extension ResourceManager {
    public func addSkeletalAnimationImporter(_ type: any SkeletalAnimationImporter.Type) {
        guard importers.skeletalAnimationImporters.contains(where: { $0 == type }) == false else {
            return
        }
        importers.skeletalAnimationImporters.insert(type, at: 0)
    }

    fileprivate func importerForFile(_ file: URL) -> (any SkeletalAnimationImporter)? {
        for type in self.importers.skeletalAnimationImporters {
            if type.canProcessFile(file) {
                return type.init()
            }
        }
        return nil
    }
}

extension SkeletalAnimation {
    public convenience init(path: String, options: SkeletalAnimationImporterOptions = .none)
        async throws
    {
        let file = URL(fileURLWithPath: path)
        guard
            let importer: any SkeletalAnimationImporter = await Game.shared.resourceManager
                .importerForFile(file)
        else {
            throw GateEngineError.failedToLoad("No importer for \(file.pathExtension).")
        }

        do {
            let animation = try await importer.loadData(path: path, options: options)
            self.init(
                name: animation.name,
                duration: animation.duration,
                animations: animation.animations
            )
        } catch {
            throw GateEngineError(decodingError: error)
        }
    }
}

