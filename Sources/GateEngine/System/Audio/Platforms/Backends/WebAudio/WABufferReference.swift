/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT
import Foundation
import WebAudio

internal class WABufferReference: AudioBufferBackend {
    unowned let audioBuffer: AudioBuffer
    var buffer: WebAudio.AudioBuffer! = nil
    
    @inlinable
    var duration: Double {
        return buffer.duration
    }
    
    required init(path: String, context: AudioContext, audioBuffer: AudioBuffer) {
        self.audioBuffer = audioBuffer
        Task(priority: .utility) {
            let platform: WASIPlatform = await Game.shared.internalPlatform as! WASIPlatform
            let context = (context.reference as! WAContextReference).ctx
            
            
            let audioBuffer = try await context.decodeAudioData(audioData: try await platform.loadResource(from: path), successCallback: { buffer in
                Task {@MainActor in
                    self.audioBuffer.state = .ready
                }
            }, errorCallback: { error in
                Log.error("Failed audio decode for", path, error)
                Task {@MainActor in
                    #if DEBUG
                    Log.warn("Resource \"\(path)\" failed ->", error)
                    #endif
                    self.audioBuffer.state = .failed(reason: "\(error)")
                }
            })
            
            self.buffer = audioBuffer
        }
    }
}

#endif
