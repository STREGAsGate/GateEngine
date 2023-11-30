/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(AVFoundation)
import AVFoundation

internal final class CASourceReference: SpatialAudioSourceReference {
    unowned let mixerReference: CASpacialMixerReference
    let playerNode: AVAudioPlayerNode

    init(_ mixerReference: CASpacialMixerReference) {
        self.mixerReference = mixerReference

        let engine = mixerReference.contextReference.engine
        let playerNode = AVAudioPlayerNode()
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            playerNode.sourceMode = .pointSource
        }
        engine.attach(playerNode)
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
    @inline(__always)
    var volume: Float {
        get {
            return playerNode.volume
        }
        set {
            playerNode.volume = newValue
        }
    }
    @inline(__always)
    var pitch: Float {
        get {
            return playerNode.rate
        }
        set {
            playerNode.rate = newValue
        }
    }

    @inline(__always)
    func play() {
        playerNode.play()
    }
    @inline(__always)
    func pause() {
        playerNode.pause()
    }
    @inline(__always)
    func stop() {
        playerNode.stop()
    }

    @inline(__always)
    func setPosition(_ position: Position3) {
        playerNode.position = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)
    }

    private weak var buffer: CABufferReference? = nil
    func setBuffer(_ buffer: AudioBuffer) {
        let buffer = buffer.reference as! CABufferReference
        let engine = mixerReference.contextReference.engine
        let environmentNode = mixerReference.environmentNode
        let bufferFormatDifferrent = playerNode.outputFormat(forBus: 0) != buffer.format
        if bufferFormatDifferrent || engine.outputConnectionPoints(for: playerNode, outputBus: 0).isEmpty {
            engine.connect(playerNode, to: environmentNode, format: buffer.format)
        }
        if engine.outputConnectionPoints(for: environmentNode, outputBus: 0).isEmpty {
            engine.connect(environmentNode, to: engine.mainMixerNode, format: nil)
        }
        playerNode.scheduleBuffer(
            buffer.pcmBuffer,
            at: nil,
            options: repeats ? [.loops, .interrupts] : [.interrupts]
        )
        self.buffer = buffer
    }
}
#endif
