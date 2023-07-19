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

internal class OpenALDevice {
    let deviceID: OpaquePointer
    
    init?(named: String) {
        guard let cString = named.cString(using: .ascii) else {return nil}
        guard let devicePointer = alcOpenDevice(cString) else {return nil}
        deviceID = devicePointer
    }
    
    init() {
        deviceID = alcOpenDevice(nil)!
    }
    
    deinit {
        alcCloseDevice(deviceID)
        assert(alCheckError() == .noError)
    }
}

#endif
