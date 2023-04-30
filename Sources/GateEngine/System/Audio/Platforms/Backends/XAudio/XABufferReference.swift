/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if canImport(WinSDK)
import Foundation
import WinSDK

internal class XABufferReference: AudioBufferBackend {
    
    required convenience init?(url: URL, context: AudioContext) {
        if let ogg = VorbisFile(url, context: context) {
            self.init(data: ogg.audio, format: ogg.format())
        }else if let wav = WaveFile(url, context: context) {
            self.init(data: wav.audio, format: wav.format())
        }else{
            return nil
        }
    }
    
    required init(data: Data, format: AudioBuffer.Format) {
        
    }
}

#endif
