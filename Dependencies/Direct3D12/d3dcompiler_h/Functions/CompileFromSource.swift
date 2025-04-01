/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation
import WinSDK

@inlinable
public func compileFromSource(_ source: String, functionName: String, target: String, forDebug: Bool) throws -> D3DBlob {
    let source: [CChar] = source.cString(using: .ascii)!

    let pDefines: [D3D_SHADER_MACRO] = [D3D_SHADER_MACRO(Name: nil, Definition: nil)]
    let D3D_COMPILE_STANDARD_FILE_INCLUDE: UnsafeMutablePointer<ID3DInclude>? = UnsafeMutablePointer<WinSDK.ID3DInclude>(bitPattern: UInt(1))
    let pInclude: UnsafeMutablePointer<WinSDK.ID3DInclude>? = D3D_COMPILE_STANDARD_FILE_INCLUDE
    let pEntrypoint: [CHAR] = functionName.windowsUTF8
    let pTarget: [CHAR] = target.windowsUTF8

    let flags: UINT = forDebug ? UINT(D3DCOMPILE_DEBUG | D3DCOMPILE_SKIP_OPTIMIZATION) : 0

    var ppCode: UnsafeMutablePointer<WinSDK.ID3DBlob>?
    var ppErrorMsgs: UnsafeMutablePointer<WinSDK.ID3DBlob>?

    let hresult = WinSDK.D3DCompile(source, SIZE_T(source.count), nil, pDefines, pInclude, pEntrypoint, pTarget, flags, 0, &ppCode, &ppErrorMsgs)
    if hresult.isSuccess == false {
        if let error = D3DBlob(winSDKPointer: ppErrorMsgs) {
            if let string = error.stringValue {
                print("HLSL Error: ", string)
            }
        }
        try hresult.checkResult(nil, #function)
    }
    guard let v = D3DBlob(winSDKPointer: ppCode) else {throw Error(.invalidArgument)}
    return v
}
