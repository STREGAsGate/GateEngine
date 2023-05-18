/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(OpenALSoft)

import Foundation
import OpenALSoft

internal class OAAudioTrackReference: AudioTrackReference {
    unowned let mixerReference: OAAudioMixerReference
    let source: OpenALSource
    
    init(_ mixerReference: OAAudioMixerReference) {
        self.mixerReference = mixerReference
        self.source = mixerReference.context.createNewSource()
        //Bring it forward a little
        source.setPosition(x: 0, y: 0, z: -0.001)
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
    
    func setBuffer(_ buffer: AudioBuffer) {
        let buffer = buffer.reference as! OABufferReference
        source.setBuffer(buffer)
    }
}

#endif
