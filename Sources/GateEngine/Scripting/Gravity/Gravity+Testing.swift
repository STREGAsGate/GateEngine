/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if DEBUG
import Gravity

@MainActor
internal func unittestCallback(
    vm: OpaquePointer!,
    errorType: error_type_t,
    desc: UnsafePointer<CChar>?,
    note: UnsafePointer<CChar>?,
    value: gravity_value_t,
    row: Int32,
    column: Int32,
    xdata: UnsafeMutableRawPointer?
) {
    Gravity.unitTestExpected = Gravity.Testing(
        description: String(cString: desc!),
        errorType: errorType,
        row: row,
        column: column,
        value: value
    )
}
extension Gravity {
    struct Testing {
        let description: String
        let errorType: error_type_t
        let row: Int32
        let column: Int32
        let value: gravity_value_t
    }
}
#endif
