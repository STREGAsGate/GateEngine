/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

internal class AudioSystem: PlatformSystem {
    let audioContext = AudioContext()
    var listenerID: ObjectIdentifier? = nil
    
    var musicMixers: [Music.Kind:AudioMixer] = [:]
    var musicPlaying: ContiguousArray<PlayingMusic> = []
    var musicWaitingToPlay: ContiguousArray<WaitingMusic> = []
    var unusedMusicMixers: ContiguousArray<AudioMixer> = []
    var unusedMusicTracks: [ObjectIdentifier:[AudioTrack]] = [:]

    var spatialMixers: [Sound.Kind:SpatialAudioMixer] = [:]
    var soundsPlaying: ContiguousArray<PlayingSound> = []
    var soundsWaitingToPlay: ContiguousArray<WaitingSound> = []
    var unusedSpatialSources: [ObjectIdentifier:[SpatialAudioSource]] = [:]
    
    var cache: [String:AudioBuffer] = [:]
    func buffer(for path: String) -> AudioBuffer {
        if let existing = cache[path] {
            return existing
        }
        let new = audioContext.createBuffer(path: path)
        cache[path] = new
        return new
    }
    override func setup(game: Game, input: HID) {
        
    }
    
    override func update(game: Game, input: HID, withTimePassed deltaTime: Float) {
        updateSounds(game: game, withTimePassed: deltaTime)
        updateMusic(withTimePassed: deltaTime)
    }

    override class var phase: PlatformSystem.Phase {.postDeffered}
    override class func sortOrder() -> PlatformSystemSortOrder? {.audioSystem}
}

// MARK: - Music
extension AudioSystem {
    @inlinable
    func updateMusic(withTimePassed deltaTime: Float) {
        for index in musicPlaying.indices.reversed() {
            let music = musicPlaying[index]
            
            music.update(deltaTime)
            
            if music.isDone, case .failed(_) = music.buffer.state {
                let playing = musicPlaying.remove(at: index)
                markUnusedMusicTrack(from: playing)
            }
        }
        if musicWaitingToPlay.isEmpty == false {
            let waitingToPlay = musicWaitingToPlay.removeFirst()
            // If `stop()` was called already skip loading
            if waitingToPlay.handle._stop == false {
                let mixer = musicMixer(for: waitingToPlay.kind)
                if let track = musicTrack(for: mixer) {
                    let playing = PlayingMusic(music: waitingToPlay.music,
                                               mixerID: ObjectIdentifier(mixer),
                                               track: track,
                                               buffer: buffer(for: waitingToPlay.music.path),
                                               accumulatedTime: 0)
                    
                    track.repeats = waitingToPlay.handle.repeats
                    playing.pendingAction = waitingToPlay.handle._pendingAction
                    
                    musicPlaying.append(playing)
                    waitingToPlay.handle.playing = playing
                }
            }
        }
    }
    @inlinable
    func musicMixer(for kind: Music.Kind) -> AudioMixer {
        if let existing = musicMixers[kind] {
            return existing
        }
        let mixer = audioContext.createAudioMixer()
        musicMixers[kind] = mixer
        return mixer
    }
    @inlinable
    func musicTrack(for mixer: AudioMixer) -> AudioTrack? {
        #if !os(WASI)
        let mixerID = ObjectIdentifier(mixer)
        if unusedMusicTracks[mixerID]?.isEmpty == false, let existing = unusedMusicTracks[mixerID]?.removeLast() {
            return existing
        }
        #endif
        return mixer.createAudioTrack()
    }
    @inlinable
    func markUnusedMusicTrack(from playingMusic: PlayingMusic) {
        #if !os(WASI)
        let source = playingMusic.track
        source.stop()
        let mixerID = playingMusic.mixerID
        var sources: [AudioTrack] = unusedMusicTracks[mixerID] ?? []
        sources.append(source)
        unusedMusicTracks[mixerID] = sources
        #endif
    }
    class PlayingMusic {
        enum Action {
            case fadeOut(duration: Float)
            case fadeIn(duration: Float, endVolume: Float = 1)
//            case crossFade(duration: Float)
        }
        var pendingAction: Action? = nil
        var currentAction: Action? = nil
        var currentActionAccumulator: Float = 0
        var actionStartVolume: Float = 0
        var actionEndVolume: Float = 1
        @inlinable
        func processAction(deltaTime: Float) {
            if let pendingAction {
                self.pendingAction = nil
                currentAction = pendingAction
                currentActionAccumulator = 0
                switch pendingAction {
                case let .fadeIn(_, volume):
                    guard accumulatedTime == 0 else {
                        currentAction = nil
                        return
                    }
                    actionStartVolume = 0
                    actionEndVolume = volume
                case .fadeOut(_):
                    actionStartVolume = track.volume
                    actionEndVolume = 0
                }
            }
            if let currentAction {
                var actionDuration: Float
                switch currentAction {
                case let .fadeOut(duration):
                    actionDuration = duration
                case let .fadeIn(duration, _):
                    actionDuration = duration
                }
                let bufferDuration = Float(buffer.duration)
                if bufferDuration < actionDuration {
                    actionDuration = bufferDuration
                }
                track.volume = actionStartVolume.interpolated(to: actionEndVolume, .linear(currentActionAccumulator / actionDuration))
                if currentActionAccumulator > actionDuration {
                    self.currentAction = nil
                    if case .fadeOut(_) = currentAction {
                        track.repeats = false
                    }
                }
            }
            currentActionAccumulator += deltaTime
        }
        
        let music: Music
        let mixerID: ObjectIdentifier
        let track: AudioTrack
        let buffer: AudioBuffer
        var accumulatedTime: Double
        var duration: Double {
            return buffer.duration
        }
        
        var forceRemove: Bool = false
        var isDone: Bool {
            guard forceRemove == false else {return true}
            guard track.repeats == false else {return false}
            return accumulatedTime > duration
        }
        
        init(music: Music, mixerID: ObjectIdentifier, track: AudioTrack, buffer: AudioBuffer, accumulatedTime: Double) {
            self.music = music
            self.mixerID = mixerID
            self.track = track
            self.buffer = buffer
            self.accumulatedTime = accumulatedTime
        }
        
        @inlinable
        func update(_ deltaTime: Float) {
            guard buffer.state == .ready else {return}
            if accumulatedTime == 0 {
                Task(priority: .medium) {
                    track.setBuffer(buffer)
                    track.play()
                }
            }
            self.processAction(deltaTime: deltaTime)
            self.accumulatedTime += Double(deltaTime)
        }
    }
    
    struct WaitingMusic {
        let music: Music
        let kind: Music.Kind
        let handle: ActiveMusic
    }
    func queueMusic(_ music: Music, as kind: Music.Kind, handle: ActiveMusic) {
        let waiting = WaitingMusic(music: music, kind: kind, handle: handle)
        musicWaitingToPlay.append(waiting)
    }
}

// MARK: - Sounds
extension AudioSystem {
    @inlinable
    func updateSounds(game: Game, withTimePassed deltaTime: Float) {
        updateListener(game: game)
        for index in soundsPlaying.indices.reversed() {
            let sound = soundsPlaying[index]
            
            sound.update(deltaTime)
                        
            var remove = sound.isDone
            if case .failed(_) = sound.buffer.state {
                remove = true
                cache.removeValue(forKey: sound.sound.path)
            }
            if remove {
                let playingSound = soundsPlaying.remove(at: index)
                markUnusedSpacialSource(from: playingSound)
            }
        }
        if soundsWaitingToPlay.isEmpty == false {
            let waitingToPlay = soundsWaitingToPlay.removeFirst()
            // If `stop()` was called already skip loading
            if waitingToPlay.handle._stop == false {
                // If the entity doesn't exist anymore skip playing
                let mixer = spatialMixer(for: waitingToPlay.kind)
                if let source = spacialSource(for: mixer) {
                    let playing = PlayingSound(sound: waitingToPlay.sound,
                                               mixerID: ObjectIdentifier(mixer),
                                               source: source,
                                               entity: waitingToPlay.entity,
                                               buffer: buffer(for: waitingToPlay.sound.path),
                                               accumulatedTime: 0)
                    
                    source.repeats = waitingToPlay.handle.repeats
                    playing.pendingAction = waitingToPlay.handle._pendingAction
                    
                    soundsPlaying.append(playing)
                    waitingToPlay.handle.playing = playing
                }
            }
        }
    }
    
    @inlinable
    func spatialMixer(for kind: Sound.Kind) -> SpatialAudioMixer {
        if let existing = spatialMixers[kind] {
            return existing
        }
        let mixer = audioContext.createSpacialMixer()
        spatialMixers[kind] = mixer
        return mixer
    }
    @inlinable
    func spacialSource(for mixer: SpatialAudioMixer) -> SpatialAudioSource? {
        #if !os(WASI)
        let mixerID = ObjectIdentifier(mixer)
        if unusedSpatialSources[mixerID]?.isEmpty == false, let existing = unusedSpatialSources[mixerID]?.removeLast() {
            return existing
        }
        #endif
        return mixer.createSource()
    }
    @inlinable
    func markUnusedSpacialSource(from playingSound: PlayingSound) {
        #if !os(WASI)
        let source = playingSound.source
        source.stop()
        let mixerID = playingSound.mixerID
        var sources: [SpatialAudioSource] = unusedSpatialSources[mixerID] ?? []
        sources.append(source)
        unusedSpatialSources[mixerID] = sources
        #endif
    }
    
    class PlayingSound {
        enum Action {
            case fadeOut(duration: Float)
            case fadeIn(duration: Float, endVolume: Float = 1)
        }
        var pendingAction: Action? = nil
        var currentAction: Action? = nil
        var currentActionAccumulator: Float = 0
        var actionStartVolume: Float = 0
        var actionEndVolume: Float = 1
        
        @inlinable
        func processAction(deltaTime: Float) {
            if let pendingAction {
                self.pendingAction = nil
                currentAction = pendingAction
                currentActionAccumulator = 0
                switch pendingAction {
                case let .fadeIn(_, volume):
                    guard accumulatedTime == 0 else {
                        currentAction = nil
                        return
                    }
                    actionStartVolume = 0
                    actionEndVolume = volume
                case .fadeOut(_):
                    actionStartVolume = source.volume
                    actionEndVolume = 0
                }
            }
            if let currentAction {
                var actionDuration: Float
                switch currentAction {
                case let .fadeOut(duration):
                    actionDuration = duration
                case let .fadeIn(duration, _):
                    actionDuration = duration
                }
                let bufferDuration = Float(buffer.duration)
                if bufferDuration < actionDuration {
                    actionDuration = bufferDuration
                }
                source.volume = actionStartVolume.interpolated(to: actionEndVolume, .linear(currentActionAccumulator / actionDuration))
                if currentActionAccumulator > actionDuration {
                    self.currentAction = nil
                    if case .fadeOut(_) = currentAction {
                        source.repeats = false
                    }
                }
            }
            currentActionAccumulator += deltaTime
        }
        
        let sound: Sound
        let mixerID: ObjectIdentifier
        let source: SpatialAudioSource
        weak var entity: Entity?
        let buffer: AudioBuffer
        var accumulatedTime: Double
        @inlinable
        public var duration: Double {
            return buffer.duration
        }
        
        var forceRemove: Bool = false
        @inlinable
        public var isDone: Bool {
            guard forceRemove == false else {return true}
            guard source.repeats == false else {return false}
            return accumulatedTime > duration
        }
        
        init(sound: Sound, mixerID: ObjectIdentifier, source: SpatialAudioSource, entity: Entity?, buffer: AudioBuffer, accumulatedTime: Double) {
            self.sound = sound
            self.mixerID = mixerID
            self.source = source
            self.entity = entity
            self.buffer = buffer
            self.accumulatedTime = accumulatedTime
        }
        
        @inlinable
        @MainActor func update(_ deltaTime: Float) {
            guard buffer.state == .ready else {return}
            if accumulatedTime == 0 {
                Task(priority: .medium) {
                    source.setBuffer(buffer)
                    source.play()
                }
            }
            if let position = entity?.position3 {
                source.setPosition(position)
            }else if let camera = Game.shared.cameraEntity {
                source.setPosition(camera.position3.moved(0.001, toward: camera.rotation.forward))
            }else{
                source.setPosition(Position3(0, 0, -0.001))
            }
            self.processAction(deltaTime: deltaTime)
            self.accumulatedTime += Double(deltaTime)
        }
    }
    
    struct WaitingSound {
        let sound: Sound
        let kind: Sound.Kind
        weak var entity: Entity?
        let handle: ActiveSound
    }
    func queueSound(_ sound: Sound, as kind: Sound.Kind, entity: Entity?, handle: ActiveSound) {
        let waiting = WaitingSound(sound: sound, kind: kind, entity: entity, handle: handle)
        soundsWaitingToPlay.append(waiting)
    }

    func updateListener(game: Game) {
        var entity: Entity? = nil
        if let listenerID {
            entity = game.entity(withID: listenerID)
        }
        if entity == nil {
            listenerID = nil
            entity = game.cameraEntity
        }
        if let entity {
            let position = entity.position3
            let up = entity.rotation.up
            let forward = entity.rotation.forward
            for mixer in spatialMixers.values {
                mixer.listener.setOrientation(forward: forward, up: up)
                mixer.listener.setPosition(position)
            }
        }
    }
}

public extension Entity {
    /**
     Makes the entity a tracked object representing the "ears" or thing listening to Sounds.
     
     This will default to the active camera and will automatically reset to the active camera if the Entity being tracked dissapears.
     */
    func becomeListener() {
        Task(priority: .medium) {@MainActor in
            Game.shared.system(ofType: AudioSystem.self).listenerID = self.id
        }
    }
    
//    @discardableResult
//    func playSound(_ sound: Sound, as kind: Sound.Kind = .soundEffect, config: ((_ sound: ActiveSound)->())? = nil) -> ActiveSound {
//        let active = ActiveSound()
//        Task {@MainActor in
//            Game.shared.system(ofType: AudioSystem.self).queueSound(sound, as: kind, entity: self, handle: active)
//        }
//        config?(active)
//        return active
//    }
}

internal extension Game {
    @_transparent
    var audio: AudioSystem {
        return system(ofType: AudioSystem.self)
    }
}
