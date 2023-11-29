/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

internal protocol AudioTrackReference: AnyObject {
    var repeats: Bool { get set }
    var volume: Float { get set }
    var pitch: Float { get set }
    func play()
    func pause()
    func stop()
    func setBuffer(_ buffer: AudioBuffer)
}

public final class AudioTrack {
    internal unowned let mixer: AudioMixer
    internal let reference: any AudioTrackReference

    internal init(_ mixer: AudioMixer) {
        self.mixer = mixer
        self.reference = mixer.reference.createAudioTrackReference()
    }

    public var repeats: Bool {
        get {
            return reference.repeats
        }
        set {
            reference.repeats = newValue
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
    public var pitch: Float {
        get {
            return reference.pitch
        }
        set {
            reference.pitch = newValue
        }
    }

    public func play() {
        reference.play()
    }
    public func pause() {
        reference.pause()
    }
    public func stop() {
        reference.stop()
    }

    public func setBuffer(_ buffer: AudioBuffer) {
        reference.setBuffer(buffer)
    }
}
