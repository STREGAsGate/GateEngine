/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(AVFoundation)
import AVFoundation

internal final class CAContextReference: AudioContextBackend {
    let engine: AVAudioEngine

    @objc func engineChanged(_ notification: Notification?) {
        do {
            engine.pause()
            try engine.start()
        } catch {
            Log.fatalError("AVAudioEngine Error: \(error)")
        }
    }

    init() {
        engine = AVAudioEngine()
        _ = engine.mainMixerNode

        engineChanged(nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(engineChanged(_:)),
            name: .AVAudioEngineConfigurationChange,
            object: engine
        )
    }

    @inline(__always)
    func createSpacialMixerReference() -> any SpacialAudioMixerReference {
        return CASpacialMixerReference(self)
    }
    @inline(__always)
    func createAudioMixerReference() -> any AudioMixerReference {
        return CAAudioMixerReference(self)
    }

    @inline(__always)
    var endianness: Endianness {
        return .native
    }

    @inline(__always)
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
