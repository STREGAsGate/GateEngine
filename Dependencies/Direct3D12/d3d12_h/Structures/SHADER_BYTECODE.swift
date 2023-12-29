/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes shader data.
public struct D3DShaderBytecode {
    public typealias RawValue = WinSDK.D3D12_SHADER_BYTECODE

    /// A pointer to a memory block that contains the shader data.
    public var blob: D3DBlob?

    /** Describes shader data.
    - parameter byteCodeBlob: A pointer to a memory block that contains the shader data.
    */
    @inlinable @inline(__always)
    public init(byteCodeBlob blob: D3DBlob?) {
        self.blob = blob
    }

    @inlinable @inline(__always)
    internal func withUnsafeRawValue<ResultType>(_ body: (RawValue) throws -> ResultType) rethrows -> ResultType {
        let rawValue = RawValue(pShaderBytecode: blob?.bufferPointer, BytecodeLength: blob?.bufferSize ?? 0)
        return try body(rawValue)
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DShaderBytecode")
public typealias D3D12_SHADER_BYTECODE = D3DShaderBytecode

#endif
