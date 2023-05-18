/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(OpenALSoft)

import Foundation
import OpenALSoft

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
