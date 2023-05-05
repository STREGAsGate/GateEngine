/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation
#if os(WASI) || GATEENGINE_WASI_IDE_SUPPORT
import WebAudio
import JavaScriptKit
import DOM
#endif

internal protocol AudioBufferBackend: AnyObject {
    var duration: Double {get}
    init(path: String, context: AudioContext, audioBuffer: AudioBuffer)
}

public class AudioBuffer: OldResource {
    internal var reference: AudioBufferBackend! = nil
    
    internal init(path: String, context: AudioContext) {
        super.init()
        self.reference = getBackend(path: path, context: context, audioBuffer: self)
    }
    
    var duration: Double {
        if state == .ready {
            return reference.duration
        }
        return 0
    }
    
    public struct Format: Equatable, CustomStringConvertible {
        public enum BitRate {
            case uint8
            case int8
            case int16
            case int32
            case float32
        }
        public enum Channels: Equatable {
            case mono
            case stereo(interleved: Bool)
            
            var count: Int {
                return self == .mono ? 1 : 2
            }
            var interleved: Bool {
                return self == .stereo(interleved: true)
            }
        }
        var channels: Channels
        var bitRate: BitRate
        var sampleRate: Double
        
        public init(channels: Channels, bitRate: BitRate, sampleRate: Double) {
            self.channels = channels
            self.bitRate = bitRate
            self.sampleRate = sampleRate
        }
        
        public func bySetting(channels: Channels? = nil, bitRate: BitRate? = nil, sampleRate: Double? = nil, interlevedIfStereo interleved: Bool? = nil) -> Self {
            var copy = self
            if let channels = channels {
                copy.channels = channels
            }
            if let bitRate = bitRate {
                copy.bitRate = bitRate
            }
            if let sampleRate = sampleRate {
                copy.sampleRate = sampleRate
            }
            if let interleved = interleved {
                if copy.channels != .mono {
                    copy.channels = .stereo(interleved: interleved)
                }
            }
            return copy
        }
        
        public var description: String {
            var out = ""
            switch bitRate {
            case .uint8:
                out += "8-bit Unsigned Integer"
            case .int8:
                out += "8-bit Signed Integer"
            case .int16:
                out += "16-bit Signed Integer"
            case .int32:
                out += "32-bit Signed Integer"
            case .float32:
                out += "32-bit Floating Point"
            }
            out += " \(channels.count)CH"
            if channels.interleved {
                out += "-Interleved"
            }
            out += " \(Int64(sampleRate))Hz"
            return out
        }
    }
}

@_transparent
fileprivate func getBackend(path: String, context: AudioContext, audioBuffer: AudioBuffer) -> AudioBufferBackend {
    #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    return CABufferReference(path: path, context: context, audioBuffer: audioBuffer)
    #elseif os(WASI)
    return WABufferReference(path: path, context: context, audioBuffer: audioBuffer)
    #elseif os(Linux)
    #error("Not implemented")
    #elseif os(Windows)
    switch backend {
    case .openAL:
        bufferReference = OABufferReference(url: url, context: self)
    case .xAudio:
        bufferReference = XABufferReference(url: url, context: self)
    }
    #else
    fatalError()
    #endif
}
