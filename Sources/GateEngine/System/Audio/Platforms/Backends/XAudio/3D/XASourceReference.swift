/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if canImport(WinSDK) && canImport(XAudio2)
import WinSDK
import XAudio2

internal class XASourceReference: SpatialAudioSourceReference {
    unowned let mixerReference: XASpacialMixerReference

    init(_ mixerReference: XASpacialMixerReference) {
        self.mixerReference = mixerReference

    }

    var repeats: Bool = false
    var volume: Float {
        get {
            return 0
        }
        set {
            fatalError()
        }
    }
    var pitch: Float {
        get {
            return 0
        }
        set {
            fatalError()
        }
    }

    func play() {
        fatalError()
    }
    func pause() {
        fatalError()
    }
    func stop() {
        fatalError()
    }

    func setPosition(_ position: Position3) {
        fatalError()
    }

    private weak var buffer: XABufferReference?

    func setBuffer(_ buffer: AudioBuffer) {
        self.buffer = buffer.reference as? XABufferReference
    }
}
#endif
