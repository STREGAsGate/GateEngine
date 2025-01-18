/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
import GameMath

@usableFromInline
internal protocol SpatialAudioSourceReference: AnyObject {
    var repeats: Bool { get set }
    var volume: Float { get set }
    var pitch: Float { get set }

    func play()
    func pause()
    func stop()

    func setPosition(_ position: Position3)
    func setBuffer(_ buffer: AudioBuffer)
}

public class SpatialAudioSource {
    internal unowned let mixer: SpatialAudioMixer
    @usableFromInline
    internal let reference: any SpatialAudioSourceReference

    @usableFromInline
    internal init(_ mixer: SpatialAudioMixer) {
        self.mixer = mixer
        self.reference = mixer.reference.createSourceReference()
    }

    @inlinable
    public var repeats: Bool {
        get {
            return reference.repeats
        }
        set {
            reference.repeats = newValue
        }
    }
    @inlinable
    public var volume: Float {
        get {
            return reference.volume
        }
        set {
            reference.volume = newValue
        }
    }
    @inlinable
    public var pitch: Float {
        get {
            return reference.pitch
        }
        set {
            reference.pitch = newValue
        }
    }

    @inlinable
    public func play() {
        reference.play()
    }
    @inlinable
    public func pause() {
        reference.pause()
    }
    @inlinable
    public func stop() {
        reference.stop()
    }

    @inlinable
    public func setPosition(_ position: Position3) {
        reference.setPosition(position)
    }

    @inlinable
    public func setBuffer(_ buffer: AudioBuffer) {
        reference.setBuffer(buffer)
    }
}
