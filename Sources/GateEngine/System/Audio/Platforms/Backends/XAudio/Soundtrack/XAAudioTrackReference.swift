/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if canImport(WinSDK) && canImport(XAudio2)
import WinSDK
import XAudio2

internal class XAAudioTrackReference: AudioTrackReference {
    unowned let mixerReference: XAAudioMixerReference

    init(_ mixerReference: XAAudioMixerReference) {
        self.mixerReference = mixerReference
    }

    var repeats: Bool = false
    var volume: Float {
        get {
            return 0
        }
        set {

        }
    }
    var pitch: Float {
        get {
            return 0
        }
        set {

        }
    }

    func play() {

    }
    func pause() {

    }
    func stop() {

    }

    private weak var buffer: XABufferReference? = nil

    func setBuffer(_ alBuffer: AudioBuffer) {
        self.buffer = alBuffer.reference as? XABufferReference
    }
}

#endif
