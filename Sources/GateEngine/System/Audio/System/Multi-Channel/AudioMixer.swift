/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

internal protocol AudioMixerReference: AnyObject {
    var volume: Float {get set}
    func createAudioTrackReference() -> any AudioTrackReference
}

/*!
 A mixer for multi-channel audio
 */
public class AudioMixer {
    internal unowned let context: AudioContext
    internal var reference: any AudioMixerReference
    
    internal init(_ context: AudioContext) {
        self.context = context
        self.reference = context.reference.createAudioMixerReference()
    }
    
    public var volume: Float {
        get {
            return reference.volume
        }
        set {
            reference.volume = newValue
        }
    }
    
    ///Generates a brand new audio source. You must store the returned object yourself, it is not retained by the mixer.
    public func createAudioTrack() -> AudioTrack {
        return AudioTrack(self)
    }
}
