/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if canImport(WinSDK) && canImport(XAudio2)
import WinSDK
import XAudio2

internal class XABufferReference: AudioBufferBackend {
    var duration: Double {
        fatalError()
    }

    required init(path: String, context: AudioContext, audioBuffer: AudioBuffer) {
        // let data = try await Game.shared.internalPlatform.loadResource(from: path)
        // #if canImport(Vorbis)
//        let lowercasePath = path.lowercased()
//        if lowercasePath.hasSuffix("ogg") || lowercasePath.hasSuffix("oga") {
//            let ogg = try VorbisFile(data, context: context)
//            self.load(data: ogg.audio, format: ogg.format())
//            self.audioBuffer.state = .ready
//            return
//        }
        // #endif
        // if let wav = WaveFile(data, context: context) {
        //     self.load(data: wav.audio, format: wav.format())
        //     self.audioBuffer.state = .ready
        //     return
        // }
        // throw "Audio format not supported for resource: \(path)"
    }
}

#endif
