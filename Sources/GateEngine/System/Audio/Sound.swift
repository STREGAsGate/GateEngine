/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public extension Sound {
    enum Kind: Hashable {
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
    public static func ==(lhs: Sound, rhs: Sound) -> Bool {
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
    public static func play(_ sound: Sound, as kind: Sound.Kind = .soundEffect, from entity: Entity? = nil, config: ((_ sound: ActiveSound)->())? = nil) -> ActiveSound {
        let active = ActiveSound()
        Task {@MainActor in
            Game.shared.system(ofType: AudioSystem.self).queueSound(sound, as: kind, entity: entity, handle: active)
        }
        config?(active)
        return active
    }
}
