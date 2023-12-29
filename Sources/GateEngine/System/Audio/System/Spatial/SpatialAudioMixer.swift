/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

internal protocol SpacialAudioMixerReference: AnyObject {
    var minimumAttenuationDistance: Float { get set }
    var volume: Float { get set }
    func createListenerReference() -> any SpatialAudioListenerBackend
    func createSourceReference() -> any SpatialAudioSourceReference
}

/*!
 A mixer for 3D audio
 */
public final class SpatialAudioMixer {
    internal unowned let context: AudioContext
    internal var reference: any SpacialAudioMixerReference

    ///This is where audio sources are heard from
    public private(set) lazy var listener = SpatialAudioListener(self)

    internal init(_ context: AudioContext) {
        self.context = context
        self.reference = context.reference.createSpacialMixerReference()
    }

    public var minimumAttenuationDistance: Float {
        get {
            return reference.minimumAttenuationDistance
        }
        set {
            reference.minimumAttenuationDistance = newValue
        }
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
    @inlinable
    public func createSource() -> SpatialAudioSource {
        return SpatialAudioSource(self)
    }
}
