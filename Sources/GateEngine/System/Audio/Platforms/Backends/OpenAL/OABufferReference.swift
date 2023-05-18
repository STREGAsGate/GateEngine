/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(OpenALSoft)

import Foundation
import OpenALSoft

internal class OABufferReference: AudioBufferReference {
    let bufferID: ALuint
    
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
        var id: [ALuint] = [0]
        alGenBuffers(1, &id)
        assert(alCheckError() == .noError)
        self.bufferID = id[0]
        
        var data = BufferConverter(data: data, format: format).reformat(as: format.bySetting(interlevedIfStereo: true))
        var alFormat: Int32 {
            switch format.bitRate {
            case .int8:
                return format.channels == .mono ? AL_FORMAT_MONO8 : AL_FORMAT_STEREO8
            case .int16:
                return format.channels == .mono ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16
            default:
                data = BufferConverter(data: data, format: format).reformat(as: format.bySetting(bitRate: .int16, interlevedIfStereo: true))
                return format.channels == .mono ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16
            }
        }
        
        data.withUnsafeBytes { (bytes) in
            alBufferData(bufferID, alFormat, bytes.baseAddress, ALsizei(data.count), ALsizei(format.sampleRate))
            assert(alCheckError() == .noError)
        }
    }
    
    deinit {
        alDeleteBuffers(1, [bufferID])
        assert(alCheckError() == .noError)
    }
}

#endif
