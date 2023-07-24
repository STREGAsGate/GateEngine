/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GravityC

internal func errorCallback(vm: OpaquePointer?, errorType: error_type_t, description: UnsafePointer<CChar>?, errorDesc: error_desc_t, xdata: UnsafeMutableRawPointer?) -> Void {
    guard let description = description else {return}
    let string = String(cString: description)
    
    guard let gravity = Gravity(unwrappingVM: vm) ?? unsafeBitCast(xdata, to: Optional<Gravity>.self) else {return}
    
    #if DEBUG // When running unit tests throw everything
    if gravity.unitTestExpected != nil {
        if gravity.recentError == nil {
            let fileName = gravity.filenameForID(errorDesc.fileid) ?? "UNKNOWN_GRAVITY_FILE"
            gravity.recentError = Gravity.Error(errorType: errorType, fileName: fileName, row: Int32(errorDesc.lineno), column: Int32(errorDesc.colno), explanation: string, details: errorDesc)
        }
        return
    }
    #endif
    
    if errorType == GRAVITY_WARNING || errorType == GRAVITY_ERROR_NONE {
        print("Gravity:", string) // Dont throw warnings or not-error errors
    }else if gravity.recentError == nil {
        // Multiple errors can be emmited from gravity before Swift gets a chance to throw,
        // se we only store the first error.
        let fileName = gravity.filenameForID(errorDesc.fileid) ?? "UNKNOWN_GRAVITY_FILE"
        gravity.recentError = Gravity.Error(errorType: errorType, fileName: fileName, row: Int32(errorDesc.lineno), column: Int32(errorDesc.colno), explanation: string, details: errorDesc)
    }
}
extension Gravity {
    public struct Error: Swift.Error, CustomStringConvertible {
        let errorType: error_type_t
        let fileName: String
        let row: Int32
        let column: Int32
        public let explanation: String
        public let details: error_desc_t
        
        public var description: String {
            lazy var suffix = "\(fileName):\(details.lineno):\(details.colno) " + explanation
            switch errorType {
            case GRAVITY_ERROR_SYNTAX:
                return "Gravity Syntax: " + suffix
            case GRAVITY_ERROR_SEMANTIC:
                return "Gravity Semantic: " + suffix
            case GRAVITY_ERROR_RUNTIME:
                return "Gravity Runtime: " + explanation
            case GRAVITY_ERROR_IO:
                return "Gravity IO: " + suffix
            default:
                return "Gravity: " + suffix
            }
        }
    }
}

extension String: Error {}
