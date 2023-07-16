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

internal class OAAudioMixerReference: AudioMixerReference {
    let context: OpenALContext
    
    init(_ contextReference: OAContextReference) {
        self.context = OpenALContext(stereoWithDevice: contextReference.device)
        try? context.listener.setPosition(x: 0, y: 0, z: 0)
        volume = 1
        context.resume()
    }
    
    var volume: Float {
        get {
            return context.gain
        }
        set {
            context.gain = newValue
        }
    }
    
    func createAudioTrackReference() -> AudioTrackReference {
        return OAAudioTrackReference(self)
    }
}

#endif
