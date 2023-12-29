/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

extension Music {
    public enum Kind: Hashable {
        /// A foreground track
        case soundTrack
        /// A background track not requiring user attention.
        case ambiance
    }
}
public struct Music {
    let path: String
    public init(path: String) {
        self.path = path
    }

    @discardableResult
    public static func play(
        _ music: Music,
        as kind: Kind = .soundTrack,
        config: ((_ activeMusic: ActiveMusic) -> Void)? = nil
    ) -> ActiveMusic {
        
        let handle = ActiveMusic()
        config?(handle)
        Task { @MainActor in
            #if os(Windows) 
                return
            #endif
            Game.shared.system(ofType: AudioSystem.self).queueMusic(music, as: kind, handle: handle)
        }
        return handle
    }
    
    @MainActor 
    public static func setVolume(_ volume: Float, for kind: Kind) {
        Game.shared.audio.musicMixer(for: kind).volume = volume
    }
}

extension Music: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.path = value
    }
}

extension Music: Equatable {
    public static func == (lhs: Music, rhs: Music) -> Bool {
        return lhs.path == rhs.path
    }
}
extension Music: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
}

public class ActiveMusic {
    private var playingWasSet: Bool = false
    weak var playing: AudioSystem.PlayingMusic? = nil {
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

    private var _repeats: Bool = true
    public var repeats: Bool {
        get {
            return playing?.track.repeats ?? _repeats
        }
        set {
            _repeats = newValue
            playing?.track.repeats = newValue
        }
    }

    var _stop: Bool = false
    public func stop() {
        _stop = true
        playing?.track.stop()
        playing?.forceRemove = true
    }

    var _pendingAction: AudioSystem.PlayingMusic.Action? = nil
    private func setAction(_ action: AudioSystem.PlayingMusic.Action) {
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
