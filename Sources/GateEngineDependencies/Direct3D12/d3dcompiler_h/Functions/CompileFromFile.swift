/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation
import WinSDK

public func compileFromFile(_ url: URL, functionName: String, target: String) throws -> D3DBlob {
    let pFileName = url.withUnsafeFileSystemRepresentation {
        return String(cString: $0!).windowsUTF16
    }

    let pDefines: [D3D_SHADER_MACRO] = [D3D_SHADER_MACRO(Name: nil, Definition: nil)]
    let D3D_COMPILE_STANDARD_FILE_INCLUDE = UnsafeMutablePointer<WinSDK.ID3DInclude>(bitPattern: UInt(1))
    let pInclude: UnsafeMutablePointer<WinSDK.ID3DInclude>? = D3D_COMPILE_STANDARD_FILE_INCLUDE
    let pEntrypoint = functionName.windowsUTF8
    let pTarget = target.windowsUTF8
    #if DEBUG
    let Flags: UINT = UINT(D3DCOMPILE_DEBUG | D3DCOMPILE_SKIP_OPTIMIZATION)
    #else
    let Flags: UINT = 0
    #endif    
    var ppCode: UnsafeMutablePointer<WinSDK.ID3DBlob>?
    var ppErrorMsgs: UnsafeMutablePointer<WinSDK.ID3DBlob>?
    let hresult = WinSDK.D3DCompileFromFile(pFileName, pDefines, pInclude, pEntrypoint, pTarget, Flags, 0, &ppCode, &ppErrorMsgs)
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
