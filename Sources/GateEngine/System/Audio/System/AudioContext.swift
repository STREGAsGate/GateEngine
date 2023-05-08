/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

internal protocol AudioContextBackend: AnyObject {
    func createSpacialMixerReference() -> SpacialAudioMixerReference
    func createAudioMixerReference() -> AudioMixerReference
    
    var endianness: Endianness {get}
    func supportsBitRate(_ bitRate: AudioBuffer.Format.BitRate) -> Bool
}

public class AudioContext {
    internal let reference: AudioContextBackend
    let backend: Backend
    
    internal init(preferredBackend backend: Backend = .default) {
        self.backend = backend
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        self.reference = CAContextReference()
        #elseif os(WASI)
        self.reference = WAContextReference()
        #elseif os(Linux)
        switch backend {
        case .openAL:
            self.reference = OAContextReference()
        }
        #elseif os(Windows)
        self.reference = XAContextReference()
        #endif
    }
    
    ///Generates a brand new audio mixer 3D positional audio. You must store the returned object yourself, it is not retained by the ALContext.
    public func createSpacialMixer() -> SpatialAudioMixer {
        return SpatialAudioMixer(self)
    }
    
    ///Generates a brand new audio mixer for multi-channel audio. You must store the returned object yourself, it is not retained by the ALContext.
    public func createAudioMixer() -> AudioMixer {
        return AudioMixer(self)
    }
    
    public func createBuffer(path: String) -> AudioBuffer {
        return AudioBuffer(path: path, context: self)
    }
}

public extension AudioContext {
    enum Backend {
        #if canImport(AVFoundation)
        case coreAudio
        #endif
        #if canImport(WinSDK)
        case xAudio
        #endif
        #if os(WASI) && canImport(WebAudio)
        case webAudio
        #endif
        public static var `default`: Backend {
            #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            return .coreAudio
            #elseif os(WASI)
            return .webAudio
            #elseif os(Windows)
            return .xAudio
            #else
            #error("Platform not supported. No supported audio backends available.")
            #endif
        }
    }
}
