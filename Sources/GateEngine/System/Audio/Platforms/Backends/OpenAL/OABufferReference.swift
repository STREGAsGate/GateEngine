/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if (canImport(OpenALSoft) || canImport(LinuxSupport)) && !os(WASI)
#if canImport(OpenALSoft) 
import OpenALSoft
#elseif canImport(LinuxSupport)
import LinuxSupport
#endif

internal class OABufferReference: AudioBufferBackend {
    var bufferID: ALuint! = nil
    unowned let audioBuffer: AudioBuffer
    lazy private(set) var duration: Double = {
        fatalError("Not implemented")
    }()
    
    required init(path: String, context: AudioContext, audioBuffer: AudioBuffer) {
        self.audioBuffer = audioBuffer
        Task(priority: .utility) {
            do {
                guard let path = await Game.shared.platform.locateResource(from: path) else {
                    throw GateEngineError.failedToLocate
                }

                let data = try await Game.shared.platform.loadResource(from: path)
                #if canImport(Vorbis)
                if let ogg = VorbisFile(data, context: context) {
                    self.load(data: ogg.audio, format: ogg.format())
                    self.audioBuffer.state = .ready
                    return
                }
                #endif
                if let wav = WaveFile(data, context: context) {
                    self.load(data: wav.audio, format: wav.format())
                    self.audioBuffer.state = .ready
                    return
                }
                throw GateEngineError.failedToDecode("Audio format not supported for resource: \"\(path)\"")
            }catch{
                Log.warn("Resource \"\(path)\" failed ->", error)
                self.audioBuffer.state = .failed(reason: error.localizedDescription)
            }
        }
    }
    
    func load(data: Data, format: AudioBuffer.Format) {
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
