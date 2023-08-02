/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(AVFoundation)
import AVFoundation

internal class CAAudioTrackReference: AudioTrackReference {
    unowned let mixerReference: CAAudioMixerReference
    let playerNode: AVAudioPlayerNode

    @usableFromInline
    init(_ mixerReference: CAAudioMixerReference) {
        self.mixerReference = mixerReference

        let engine = mixerReference.contextReference.engine
        let playerNode = AVAudioPlayerNode()
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            playerNode.renderingAlgorithm = .auto
            playerNode.sourceMode = .spatializeIfMono
        }
        engine.attach(playerNode)
        engine.connect(playerNode, to: mixerReference.mixerNode, format: nil)
        self.playerNode = playerNode
    }

    var repeats: Bool = false {
        didSet {
            if playerNode.isPlaying, let buffer = self.buffer {
                if repeats {
                    playerNode.scheduleBuffer(
                        buffer.pcmBuffer,
                        at: nil,
                        options: [.loops, .interruptsAtLoop]
                    )
                } else {
                    playerNode.scheduleBuffer(
                        buffer.pcmBuffer,
                        at: playerNode.lastRenderTime,
                        options: [.interrupts]
                    )
                }
            }
        }
    }
    @inlinable
    var volume: Float {
        get {
            return playerNode.volume
        }
        set {
            playerNode.volume = newValue
        }
    }
    @inlinable
    var pitch: Float {
        get {
            return playerNode.rate
        }
        set {
            playerNode.rate = newValue
        }
    }

    @inlinable
    func play() {
        playerNode.play()
    }
    @inlinable
    func pause() {
        playerNode.pause()
    }
    @inlinable
    func stop() {
        playerNode.stop()
    }

    private weak var buffer: CABufferReference?

    @inlinable
    func setBuffer(_ alBuffer: AudioBuffer) {
        let buffer = alBuffer.reference as! CABufferReference
        let engine = mixerReference.contextReference.engine
        let mixerNode = mixerReference.mixerNode
        engine.disconnectNodeOutput(playerNode)
        engine.connect(playerNode, to: mixerNode, format: buffer.format)
        playerNode.scheduleBuffer(
            buffer.pcmBuffer,
            at: nil,
            options: repeats ? [.loops, .interrupts] : [.interrupts]
        )
        self.buffer = buffer
    }
}

#endif
