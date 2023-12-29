/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(AVFoundation)
import AVFoundation

internal final class CASpacialMixerReference: SpacialAudioMixerReference {
    unowned let contextReference: CAContextReference
    let environmentNode: AVAudioEnvironmentNode

    init(_ contextReference: CAContextReference) {
        self.contextReference = contextReference

        let environmentNode = AVAudioEnvironmentNode()
        if #available(macOS 10.15, iOS 13, tvOS 13, *) {
            environmentNode.renderingAlgorithm = .auto
        } else {
            environmentNode.renderingAlgorithm = .soundField
        }

        environmentNode.distanceAttenuationParameters.distanceAttenuationModel = .inverse

        let engine = contextReference.engine
        engine.attach(environmentNode)
        engine.connect(
            environmentNode,
            to: engine.mainMixerNode,
            format: engine.outputNode.inputFormat(forBus: 0)
        )

        self.environmentNode = environmentNode
    }

    @inline(__always)
    public var minimumAttenuationDistance: Float {
        get {
            return environmentNode.distanceAttenuationParameters.referenceDistance
        }
        set {
            environmentNode.distanceAttenuationParameters.referenceDistance = newValue
        }
    }

    @inline(__always)
    public var volume: Float {
        get {
            return environmentNode.volume
        }
        set {
            environmentNode.volume = newValue
        }
    }

    @inline(__always)
    func createListenerReference() -> any SpatialAudioListenerBackend {
        return CAListenerReference(environmentNode: environmentNode)
    }

    @inline(__always)
    func createSourceReference() -> any SpatialAudioSourceReference {
        return CASourceReference(self)
    }
}
#endif
