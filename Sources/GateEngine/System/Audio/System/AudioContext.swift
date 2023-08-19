/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

internal protocol AudioContextBackend: AnyObject {
    func createSpacialMixerReference() -> any SpacialAudioMixerReference
    func createAudioMixerReference() -> any AudioMixerReference

    var endianness: Endianness { get }
    func supportsBitRate(_ bitRate: AudioBuffer.Format.BitRate) -> Bool
}

public class AudioContext {
    internal let reference: any AudioContextBackend

    internal init() {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        self.reference = CAContextReference()
        #elseif os(WASI)
        self.reference = WAContextReference()
        #elseif os(Linux)
        self.reference = OAContextReference()
        #elseif os(Windows) && swift(>=5.10)
        #warning("XAudio2 Not Implemented.")
        self.reference = XAContextReference()
        #elseif os(Windows)
        self.reference = OAContextReference()
        #else
        #error("Not Implemented.")
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
