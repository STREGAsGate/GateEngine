/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(AVFoundation)
import AVFoundation

internal final class CAAudioMixerReference: AudioMixerReference {
    unowned let contextReference: CAContextReference
    let mixerNode: AVAudioMixerNode

    init(_ contextReference: CAContextReference) {
        self.contextReference = contextReference

        let engine = contextReference.engine
        let mixerNode = AVAudioMixerNode()
        if #available(macOS 10.15, iOS 13, tvOS 13, *) {
            mixerNode.renderingAlgorithm = .auto
        } else {
            mixerNode.renderingAlgorithm = .stereoPassThrough
        }
        engine.attach(mixerNode)
        engine.connect(
            mixerNode,
            to: engine.mainMixerNode,
            format: engine.outputNode.inputFormat(forBus: 0)
        )

        self.mixerNode = mixerNode
    }

    @inlinable
    var volume: Float {
        get {
            return mixerNode.volume
        }
        set {
            mixerNode.volume = newValue
        }
    }

    @inlinable
    func createAudioTrackReference() -> any AudioTrackReference {
        return CAAudioTrackReference(self)
    }
}
#endif
