/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

extension Sound {
    public enum Kind: Hashable {
        /// A sound that is clearly emitted from an object.
        case soundEffect
        /// A background sound not requiring user attention.
        case ambientNoise
        /// A character speaking clearly.
        case audibleSpeech
    }
}
public struct Sound {
    let path: String
    public init(path: String) {
        self.path = path
    }
}

extension Sound: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.path = value
    }
}

extension Sound: Equatable {
    public static func == (lhs: Sound, rhs: Sound) -> Bool {
        return lhs.path == rhs.path
    }
}
extension Sound: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
}

public class ActiveSound {
    private var playingWasSet: Bool = false
    weak var playing: AudioSystem.PlayingSound? = nil {
        didSet {
            playingWasSet = true
        }
    }
    internal init() {

    }

    /**
     Indicates if this sound is still active.
     When false the sound can never play again and this object can be discarded.
     */
    var isValid: Bool {
        return playing != nil || playingWasSet == false
    }

    private var _repeats: Bool = false
    public var repeats: Bool {
        get {
            return playing?.source.repeats ?? _repeats
        }
        set {
            _repeats = newValue
            playing?.source.repeats = newValue
        }
    }

    var _stop: Bool = false
    public func stop() {
        _stop = true
        playing?.source.stop()
        playing?.forceRemove = true
    }

    var _pendingAction: AudioSystem.PlayingSound.Action? = nil
    private func setAction(_ action: AudioSystem.PlayingSound.Action) {
        _pendingAction = action
        playing?.pendingAction = action
    }

    public func fadeOut(_ duration: Float) {
        setAction(.fadeOut(duration: duration))
    }
    public func fadeIn(_ duration: Float) {
        setAction(.fadeIn(duration: duration))
    }
}

extension Sound {
    @discardableResult
    public static func play(
        _ sound: Sound,
        as kind: Sound.Kind = .soundEffect,
        from entity: Entity? = nil,
        volume: Float = 1,
        config: ((_ activeSound: ActiveSound) -> Void)? = nil
    ) -> ActiveSound {
        let active = ActiveSound()
        Task { @MainActor in
            #if os(Windows) 
                return
            #endif
            Game.shared.system(ofType: AudioSystem.self).queueSound(
                sound,
                as: kind,
                entity: entity,
                volume: volume,
                handle: active
            )
        }
        config?(active)
        return active
    }
    
    @MainActor 
    public static func setVolume(_ volume: Float, for kind: Kind) {
        Game.shared.audio.spatialMixer(for: kind).volume = volume
    }
}

extension Entity {
    /**
     Makes the entity a tracked object representing the "ears" or thing listening to Sounds.

     This will default to the active camera and will automatically reset to the active camera if the Entity being tracked disappears.
     */
    public func becomeListener() {
        Task(priority: .medium) { @MainActor in
            Game.shared.system(ofType: AudioSystem.self).listenerID = self.id
        }
    }

    @MainActor
    @discardableResult
    func playSound(_ sound: Sound, as kind: Sound.Kind = .soundEffect, volume: Float = 1, config: ((_ sound: ActiveSound)->())? = nil) -> ActiveSound {
        let active = ActiveSound()
        Task { @MainActor in
            #if os(Windows) 
                return
            #endif
            Game.shared.system(ofType: AudioSystem.self).queueSound(
                sound,
                as: kind,
                entity: self,
                volume: volume,
                handle: active
            )
        }
        config?(active)
        return active
    }
}
