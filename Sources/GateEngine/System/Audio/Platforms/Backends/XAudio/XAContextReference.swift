/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if canImport(WinSDK)
import Foundation
import WinSDK

internal class XAContextReference: AudioContextBackend {
    
    init() {

    }
    
    func createSpacialMixerReference() -> SpacialAudioMixerReference {
        return XASpacialMixerReference(self)
    }
    func createAudioMixerReference() -> AudioMixerReference {
        return XAAudioMixerReference(self)
    }
    
    var endianness: Endianness {
        return .native
    }
    
    func supportsBitRate(_ bitRate: AudioBuffer.Format.BitRate) -> Bool {
        switch bitRate {
        case .int16, .int32, .float32:
            return true
        default:
            return false
        }
    }
}
#endif
