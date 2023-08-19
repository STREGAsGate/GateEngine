/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT
import WebAudio

internal class WASourceReference: SpatialAudioSourceReference {
    unowned let mixerReference: WASpacialMixerReference
    let playerNode: AudioBufferSourceNode
    let pannerNode: PannerNode
    let gainNode: GainNode

    @usableFromInline
    init(_ mixerReference: WASpacialMixerReference) {
        self.mixerReference = mixerReference

        self.playerNode = AudioBufferSourceNode(context: mixerReference.contextReference.ctx)
        self.gainNode = mixerReference.contextReference.ctx.createGain()
        self.pannerNode = mixerReference.contextReference.ctx.createPanner()

        playerNode.connect(destinationNode: gainNode).connect(destinationNode: pannerNode).connect(
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
    func setPosition(_ position: Position3) {
        pannerNode.setPosition(x: position.x, y: position.y, z: position.z)
    }
    @inlinable
    func setBuffer(_ buffer: AudioBuffer) {
        let buffer = buffer.reference as! WABufferReference
        playerNode.buffer = buffer.buffer
    }
}
#endif
