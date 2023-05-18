/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(OpenALSoft)

import Foundation
import OpenALSoft

internal enum OpenALError {
    case unknown
    case noError
    case invalidName
    case invalidEnum
    case invalidValue
    case invalidOperation
    case outOfMemory
    
    var value: ALenum {
        switch self {
        case .noError: return AL_NO_ERROR
        case .invalidName: return AL_INVALID_NAME
        case .invalidEnum: return AL_INVALID_ENUM
        case .invalidValue: return AL_INVALID_VALUE
        case .invalidOperation: return AL_INVALID_OPERATION
        case .outOfMemory: return AL_OUT_OF_MEMORY
        case .unknown: return -1
        }
    }
    
    static func from(_ value: ALenum) -> OpenALError {
        switch value {
        case AL_NO_ERROR: return .noError
        case AL_INVALID_NAME: return .invalidName
        case AL_INVALID_ENUM: return .invalidEnum
        case AL_INVALID_OPERATION: return .invalidOperation
        case AL_OUT_OF_MEMORY: return .outOfMemory
        default: return .unknown
        }
    }
}

internal func alCheckError() -> OpenALError {
    let error = OpenALError.from(alGetError())
    if error != .noError {
        print("OpenAL Error:", error)
    }
    return error
}

#endif
