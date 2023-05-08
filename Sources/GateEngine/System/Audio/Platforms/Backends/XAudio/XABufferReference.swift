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
    var duration: Double {
        fatalError()
    }

    required init(path: String, context: AudioContext, audioBuffer: AudioBuffer) {
        // let data = try await Game.shared.internalPlatform.loadResource(from: path)
        // #if canImport(Vorbis)
        // if let ogg = VorbisFile(data, context: context) {
        //     self.load(data: ogg.audio, format: ogg.format())
        //     self.audioBuffer.state = .ready
        //     return
        // }
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
