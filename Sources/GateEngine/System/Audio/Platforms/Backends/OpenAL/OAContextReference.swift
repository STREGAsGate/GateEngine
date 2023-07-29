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

internal class OAContextReference: AudioContextBackend {
    let device: OpenALDevice!
    
    init() {
        self.device = OpenALDevice()
    }
    
    func createSpacialMixerReference() -> any SpacialAudioMixerReference {
        return OASpacialMixerReference(self)
    }
    
    func createAudioMixerReference() -> any AudioMixerReference {
        return OAAudioMixerReference(self)
    }
    
    var endianness: Endianness {
        return .little
    }
    
    func supportsBitRate(_ bitRate: AudioBuffer.Format.BitRate) -> Bool {
        switch bitRate {
        case .int8, .int16:
            return true
        default:
            return false
        }
    }
}

#endif
