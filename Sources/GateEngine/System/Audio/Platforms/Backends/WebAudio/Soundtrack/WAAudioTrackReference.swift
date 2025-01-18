/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT
import WebAudio

internal class WAAudioTrackReference: AudioTrackReference {
    unowned let mixerReference: WAAudioMixerReference
    let playerNode: AudioBufferSourceNode
    let gainNode: GainNode

    @usableFromInline
    init(_ mixerReference: WAAudioMixerReference) {
        self.mixerReference = mixerReference

        self.playerNode = AudioBufferSourceNode(context: mixerReference.contextReference.ctx)
        self.gainNode = mixerReference.contextReference.ctx.createGain()

        playerNode.connect(destinationNode: gainNode).connect(
            destinationNode: mixerReference.mixerNode
        )
    }

    @inlinable
    var repeats: Bool {
        get {
            return playerNode.loop
        }
        set {
            playerNode.loop = newValue
        }
    }
    @inlinable
    var volume: Float {
        get {
            return gainNode.gain.value
        }
        set {
            gainNode.gain.value = newValue
        }
    }
    @inlinable
    var pitch: Float {
        get {
            return playerNode.playbackRate.value
        }
        set {
            playerNode.playbackRate.value = newValue
        }
    }

    @inlinable
    func play() {
        playerNode.start()
    }
    @inlinable
    func pause() {
        playerNode.stop()
    }
    @inlinable
    func stop() {
        playerNode.stop()
    }

    @inlinable
    func setBuffer(_ buffer: AudioBuffer) {
        let buffer = buffer.reference as! WABufferReference
        playerNode.buffer = buffer.buffer
    }
}

#endif
