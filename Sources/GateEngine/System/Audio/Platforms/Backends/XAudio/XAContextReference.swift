/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if canImport(WinSDK) && canImport(XAudio29)
import WinSDK
import XAudio29

internal class XAContextReference: AudioContextBackend {

    init() {

    }

    func createSpacialMixerReference() -> any SpacialAudioMixerReference {
        return XASpacialMixerReference(self)
    }
    func createAudioMixerReference() -> any AudioMixerReference {
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
