/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(AVFoundation)
import AVFoundation

internal class CAContextReference: AudioContextBackend {
    let engine: AVAudioEngine
    
    @objc func engineChanged(_ notification: Notification?) {
        do {
            try engine.start()
        }catch{
            Log.fatalError("AVAudioEngine Error: \(error)")
        }
    }
    
    init() {
        engine = AVAudioEngine()
        _ = engine.mainMixerNode
        
        engineChanged(nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(engineChanged(_:)), name: .AVAudioEngineConfigurationChange, object: engine)
    }
    
    @inlinable
    func createSpacialMixerReference() -> SpacialAudioMixerReference {
        return CASpacialMixerReference(self)
    }
    @inlinable
    func createAudioMixerReference() -> AudioMixerReference {
        return CAAudioMixerReference(self)
    }
    
    @inlinable
    var endianness: Endianness {
        return .native
    }
    
    @inlinable
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
