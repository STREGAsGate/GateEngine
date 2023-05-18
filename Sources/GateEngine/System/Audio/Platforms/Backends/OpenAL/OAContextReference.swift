/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(OpenALSoft) && !os(WASI)

import Foundation
import OpenALSoft

internal class OAContextReference: AudioContextBackend {
    let device: OpenALDevice!
    
    init() {
        self.device = OpenALDevice()
    }
    
    func createSpacialMixerReference() -> SpacialAudioMixerReference {
        return OASpacialMixerReference(self)
    }
    
    func createAudioMixerReference() -> AudioMixerReference {
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
