/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if (canImport(OpenALSoft) || canImport(LinuxSupport)) && !os(WASI)
#if canImport(OpenALSoft) 
import OpenALSoft
#elseif canImport(LinuxSupport)
import LinuxSupport
#endif

internal class OASourceReference: SpatialAudioSourceReference {
    unowned let mixerReference: OASpacialMixerReference
    let source: OpenALSource
    
    init(_ mixerReference: OASpacialMixerReference) {
        self.mixerReference = mixerReference
        self.source = mixerReference.context.createNewSource()
    }
    
    var repeats: Bool {
        get {
            return source.repeats
        }
        set {
            source.repeats = newValue
        }
    }
    var volume: Float {
        get {
            return source.gain
        }
        set {
            source.gain = newValue
        }
    }
    var pitch: Float {
        get {
            return source.pitch
        }
        set {
            source.pitch = newValue
        }
    }
    
    func play() {
        source.play()
    }
    func pause() {
        source.pause()
    }
    func stop() {
        source.stop()
    }
    
    func setPosition(_ position: GameMath.Position3) {
        source.setPosition(x: position.x, y: position.y, z: position.z)
    }
    
    func setBuffer(_ buffer: AudioBuffer) {
        let buffer = buffer.reference as! OABufferReference
        source.setBuffer(buffer)
    }
}

#endif
