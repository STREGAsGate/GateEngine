/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if (canImport(OpenALSoft) || canImport(LinuxSupport)) && !os(WASI)

import Foundation
#if canImport(OpenALSoft) 
import OpenALSoft
#elseif canImport(LinuxSupport)
import LinuxSupport
#endif

internal class OpenALSource {
    internal enum State {
        case initial
        case playing
        case paused
        case stopped
        case unknown
    }
    private let context: OpenALContext
    private let sourceID: ALuint
    init(_ context: OpenALContext) {
        var sourceID: [ALuint] = [0]
        if context.becomeCurrent() {
            alGenSources(1, &sourceID)
            assert(alCheckError() == .noError)
        }
        self.context = context
        self.sourceID = sourceID[0]
        self.pitch = 1
        self.gain = 1
        self.repeats = false
        self.isRelative = false
        self.setPosition(x: 0, y: 0, z: 0)
        self.setVelocity(x: 0, y: 0, z: 0)
    }
    
    internal var state: State {
        var value: ALenum = 0
        if self.context.becomeCurrent() {
            alGetSourcei(sourceID, AL_SOURCE_STATE, &value)
            assert(alCheckError() == .noError)
        }
        switch value {
        case AL_INITIAL: return .initial
        case AL_PLAYING: return .playing
        case AL_PAUSED: return .paused
        case AL_STOPPED: return .stopped
        default: return .unknown
        }
    }
    
    internal func play() {
        if self.context.becomeCurrent() {
            alSourcePlay(sourceID)
            assert(alCheckError() == .noError)
        }
    }
    internal func pause() {
        if self.context.becomeCurrent() {
            alSourcePause(sourceID)
            assert(alCheckError() == .noError)
        }
    }
    internal func stop() {
        if self.context.becomeCurrent() {
            alSourceStop(sourceID)
            assert(alCheckError() == .noError)
        }
    }
    
    internal var pitch: Float {
        set {
            if self.context.becomeCurrent() {
                alSourcef(sourceID, AL_PITCH, newValue)
                assert(alCheckError() == .noError)
            }
        }
        get {
            var value: ALfloat = 0
            if self.context.becomeCurrent() {
                alGetSourcef(sourceID, AL_PITCH, &value)
                assert(alCheckError() == .noError)
            }
            return value
        }
    }
    
    internal var gain: Float {
        set {
            if self.context.becomeCurrent() {
                alSourcef(sourceID, AL_GAIN, newValue)
                assert(alCheckError() == .noError)
            }
        }
        get {
            var value: ALfloat = 0
            if self.context.becomeCurrent() {
                alGetSourcef(sourceID, AL_GAIN, &value)
                assert(alCheckError() == .noError)
            }
            return value
        }
    }
    
    func setPosition(x: Float, y: Float, z: Float) {
        if self.context.becomeCurrent() {
            alSource3f(sourceID, AL_POSITION, x, y, z)
            assert(alCheckError() == .noError)
        }
    }
    func setVelocity(x: Float, y: Float, z: Float) {
        if self.context.becomeCurrent() {
            alSource3f(sourceID, AL_VELOCITY, x, y, z)
            assert(alCheckError() == .noError)
        }
    }
    
    internal var repeats: Bool {
        set {
            if self.context.becomeCurrent() {
                alSourcei(sourceID, AL_LOOPING, newValue ? AL_TRUE : AL_FALSE)
                assert(alCheckError() == .noError)
            }
        }
        get {
            var value: ALint = 0
            if self.context.becomeCurrent() {
                alGetSourcei(sourceID, AL_LOOPING, &value)
                assert(alCheckError() == .noError)
            }
            return value == 1
        }
    }
    
    internal var isRelative: Bool {
        set {
            if self.context.becomeCurrent() {
                alSourcei(sourceID, AL_SOURCE_RELATIVE, newValue ? AL_TRUE : AL_FALSE)
                assert(alCheckError() == .noError)
            }
        }
        get {
            var value: ALint = 0
            if self.context.becomeCurrent() {
                alGetSourcei(sourceID, AL_SOURCE_RELATIVE, &value)
                assert(alCheckError() == .noError)
            }
            return value == 1
        }
    }
    
    internal var referenceDistance: Float {
        set {
            if self.context.becomeCurrent() {
                alSourcef(sourceID, AL_REFERENCE_DISTANCE, newValue)
                assert(alCheckError() == .noError)
            }
        }
        get {
            var value: Float = 0
            if self.context.becomeCurrent() {
                alGetSourcef(sourceID, AL_REFERENCE_DISTANCE, &value)
                assert(alCheckError() == .noError)
            }
            return value
        }
    }
    
    private var buffer: OABufferReference? = nil
    internal func setBuffer(_ buffer: OABufferReference?) {
        if self.context.becomeCurrent() {
            alSourceStop(sourceID)
            alSourcei(sourceID, AL_BUFFER, ALint(buffer?.bufferID ?? 0))
            assert(alCheckError() == .noError)
        }

        // Keep a reference so the buffer doesn't deallocate while playing
        self.buffer = buffer
    }
    
    deinit {
        if self.context.becomeCurrent() {
            alDeleteSources(1, [sourceID])
            assert(alCheckError() == .noError)
        }
    }
}

#endif
