/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if (canImport(OpenALSoft) || canImport(LinuxSupport)) && !os(WASI)
#if canImport(OpenALSoft) 
import OpenALSoft
#elseif canImport(LinuxSupport)
import LinuxSupport
#endif

internal class OpenALContext {
    let device: OpenALDevice
    fileprivate let contextID: OpaquePointer
    internal init(spatialWithDevice device: OpenALDevice) {
        self.device = device
        self.contextID = alcCreateContext(device.deviceID, nil)!
        _ = becomeCurrent()
        alDistanceModel(AL_INVERSE_DISTANCE_CLAMPED)
        assert(alCheckError() == .noError)
    }
    internal init(stereoWithDevice device: OpenALDevice) {
        self.device = device
        self.contextID = alcCreateContext(device.deviceID, nil)!
    }
    
    internal lazy var listener = OpenALListener(context: self)
    
    internal func createNewSource() -> OpenALSource {
        return OpenALSource(self)
    }
    
    func becomeCurrent() -> Bool {
        let success = alcMakeContextCurrent(contextID)
        assert(alCheckError() == .noError)
        return success != 0
    }
    
    func resume() {
        alcProcessContext(contextID)
    }
    
    func suspend() {
        alcSuspendContext(contextID)
    }
    
    var gain: Float {
        set {
            if becomeCurrent() {
                alListenerf(AL_GAIN, newValue)
                assert(alCheckError() == .noError)
            }
        }
        get {
            if becomeCurrent() {
                var value: ALfloat = 0
                alGetListenerf(AL_GAIN, &value)
                assert(alCheckError() == .noError)
                return value
            }
            return 0
        }
    }
    
    var referenceDistance: Float {
        get {
            if becomeCurrent() {
                var value: ALfloat = 0
                alGetListenerf(AL_REFERENCE_DISTANCE, &value)
                assert(alCheckError() == .noError)
                return value
            }
            return 0
        }
        set {
            if becomeCurrent() {
                alListenerf(AL_REFERENCE_DISTANCE, newValue)
                assert(alCheckError() == .noError)
            }
        }
    }
    
    deinit {
        alcDestroyContext(contextID)
        assert(alCheckError() == .noError)
    }
}

extension OpenALContext {
    internal struct OpenALListener {
        unowned internal var context: OpenALContext
        func setPosition(x: Float, y: Float, z: Float) throws {
            if context.becomeCurrent() {
                alListener3f(AL_POSITION, x, y, z)
                assert(alCheckError() == .noError)
            }
        }
        func setVelocity(x: Float, y: Float, z: Float) throws {
            if context.becomeCurrent() {
                alListener3f(AL_VELOCITY, x, y, z)
                assert(alCheckError() == .noError)
            }
        }
        func setOrientation(forward: (x: Float, y: Float, z: Float), up: (x: Float, y: Float, z: Float)) throws {
            if context.becomeCurrent() {
                alListenerfv(AL_ORIENTATION, [forward.x, forward.y, forward.z, up.x, up.y, up.z])
                assert(alCheckError() == .noError)
            }
        }
    }
}

#endif
