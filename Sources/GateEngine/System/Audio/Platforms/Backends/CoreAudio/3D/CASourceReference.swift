/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(AVFoundation)
import Foundation
import AVFoundation
import GameMath

internal class CASourceReference: SpatialAudioSourceReference {
    unowned let mixerReference: CASpacialMixerReference
    let playerNode: AVAudioPlayerNode
    
    @usableFromInline
    init(_ mixerReference: CASpacialMixerReference) {
        self.mixerReference = mixerReference
        
        let engine = mixerReference.contextReference.engine
        let playerNode = AVAudioPlayerNode()
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            playerNode.sourceMode = .pointSource
        }
        engine.attach(playerNode)
//        engine.connect(playerNode, to: mixerReference.environmentNode, format: nil)
        self.playerNode = playerNode
    }
    
    var repeats: Bool = false {
        didSet {
            if playerNode.isPlaying, let buffer = self.buffer {
                if repeats {
                    playerNode.scheduleBuffer(buffer.pcmBuffer, at: nil, options: [.loops, .interruptsAtLoop])
                }else{
                    playerNode.scheduleBuffer(buffer.pcmBuffer, at: playerNode.lastRenderTime, options: [.interrupts])
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
    
    @inlinable
    func setPosition(_ position: Position3) {
        playerNode.position = AVAudio3DPoint(x: position.x, y: position.y, z: position.z)
    }

    private weak var buffer: CABufferReference? = nil
    
    @inlinable
    func setBuffer(_ buffer: AudioBuffer) {
        let buffer = buffer.reference as! CABufferReference
        let engine = mixerReference.contextReference.engine
        let environmentNode = mixerReference.environmentNode
        engine.connect(playerNode, to: environmentNode, format: buffer.format)
        playerNode.scheduleBuffer(buffer.pcmBuffer, at: nil, options: repeats ? [.loops, .interrupts] : [.interrupts])
        self.buffer = buffer
    }
}
#endif
