/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(AVFoundation)
import AVFoundation

extension AudioBuffer.Format {
    init(_ avFormat: AVAudioFormat) {
        self.channels =
            avFormat.channelCount == 2 ? .stereo(interleved: avFormat.isInterleaved) : .mono
        switch avFormat.commonFormat {
        case .pcmFormatFloat32:
            self.bitRate = .float32
        case .pcmFormatInt16:
            self.bitRate = .int16
        case .pcmFormatInt32:
            self.bitRate = .int32
        default:
            fatalError()
        }
        self.sampleRate = avFormat.sampleRate
    }
}

internal final class CABufferReference: AudioBufferBackend {
    unowned let audioBuffer: AudioBuffer
    var pcmBuffer: AVAudioPCMBuffer! = nil
    var format: AVAudioFormat! = nil

    lazy private(set) var duration: Double = {
        return Double(pcmBuffer.frameLength) / format.sampleRate
    }()

    required init(path: String, context: AudioContext, audioBuffer: AudioBuffer) {
        self.audioBuffer = audioBuffer
        Task(priority: .utility) {
            do {
                guard let located = await Game.shared.platform.locateResource(from: path) else {
                    throw GateEngineError.failedToLocate
                }
                do {  // Allow CoreAudio an chance to load files the way it prefers
                    let file = try AVAudioFile(forReading: URL(fileURLWithPath: located))
                    if let buffer = AVAudioPCMBuffer(
                        pcmFormat: file.processingFormat,
                        frameCapacity: AVAudioFrameCount(file.length)
                    ) {
                        try file.read(into: buffer)
                        self.pcmBuffer = buffer
                        self.format = file.processingFormat
                        self.audioBuffer.state = .ready
                        return
                    }
                } catch {
                    // If CoreAudio can't load the file fallback to manual below and don't throw any errors
                }

                let data = try await Game.shared.platform.loadResource(from: path)
                #if canImport(Vorbis)
                let lowercasePath = path.lowercased()
                if lowercasePath.hasSuffix("ogg") || lowercasePath.hasSuffix("oga") {
                    let ogg = try VorbisFile(data, context: context)
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
                throw GateEngineError.failedToDecode(
                    "Audio format not supported for resource: \(path)"
                )
            } catch let error as GateEngineError {
                Log.debug("Resource \"\(path)\" failed ->", error)
                self.audioBuffer.state = .failed(error: error)
            } catch {
                Log.fatalError("error must be a GateEngineError")
            }
        }
    }

    func load(data: Data, format: AudioBuffer.Format) {
        let newFormat = format.bySetting(bitRate: .float32, interlevedIfStereo: false)
        let convertedData: Data = BufferConverter(data: data, format: format).reformat(
            as: newFormat
        )
        let channelLayout = AVAudioChannelLayout(
            layoutTag: newFormat.channels == .mono
                ? kAudioChannelLayoutTag_Mono : kAudioChannelLayoutTag_Stereo
        )!
        let avFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: newFormat.sampleRate,
            interleaved: false,
            channelLayout: channelLayout
        )

        let streamDesc = avFormat.streamDescription.pointee
        let frameCapacity =
            UInt32(convertedData.count) / streamDesc.mBytesPerFrame
            / (avFormat.isInterleaved ? 1 : avFormat.channelCount)
        self.pcmBuffer = AVAudioPCMBuffer(pcmFormat: avFormat, frameCapacity: frameCapacity)!
        self.pcmBuffer.frameLength = frameCapacity
        self.format = avFormat

        @_transparent
        func writeData<T: Numeric>(
            _ data: Data,
            to pointer: UnsafePointer<UnsafeMutablePointer<T>>?
        ) {
            if avFormat.isInterleaved == false {
                let pointer = UnsafeMutablePointer(mutating: pointer)
                let countPerChannel = data.count / Int(avFormat.channelCount)
                let channels = UnsafeMutableBufferPointer(
                    start: pointer,
                    count: Int(avFormat.channelCount)
                )
                for index in channels.indices {
                    let channel = UnsafeMutableBufferPointer(
                        start: channels[index],
                        count: countPerChannel
                    )
                    let start = countPerChannel * index
                    _ = data[start ..< start + countPerChannel].copyBytes(
                        to: channel,
                        count: countPerChannel
                    )
                }
            } else {
                let pointer = UnsafeMutablePointer(mutating: pointer)
                let channels = UnsafeMutableBufferPointer(start: pointer, count: 1)
                let channel = UnsafeMutableBufferPointer(start: channels[0], count: data.count)
                _ = data.copyBytes(to: channel)
            }
        }

        writeData(convertedData, to: pcmBuffer.floatChannelData)
    }
}

#endif
