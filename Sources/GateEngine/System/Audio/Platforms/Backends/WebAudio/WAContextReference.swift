/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if HTML5
import JavaScriptKit
import DOM
import WebAudio

internal class WAContextReference: AudioContextBackend {
    let ctx: WebAudio.AudioContext

    init() {
        ctx = WebAudio.AudioContext()
    }

    @inlinable
    func createSpacialMixerReference() -> any SpacialAudioMixerReference {
        return WASpacialMixerReference(self)
    }
    @inlinable
    func createAudioMixerReference() -> any AudioMixerReference {
        return WAAudioMixerReference(self)
    }

    @inlinable
    var endianness: Endianness {
        return .native
    }

    @inlinable
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
