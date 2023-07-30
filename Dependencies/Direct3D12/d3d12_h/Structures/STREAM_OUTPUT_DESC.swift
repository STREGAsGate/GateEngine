/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes a streaming output buffer.
public struct D3DStreamOutputDescription {
    public typealias RawValue =  WinSDK.D3D12_STREAM_OUTPUT_DESC

    /// An array of D3D12_SO_DECLARATION_ENTRY structures. Can't be NULL if NumEntries > 0.
    public var declarationEntries: [D3DStreamOutputDeclarationEntry]?

    /// An array of buffer strides; each stride is the size of an element for that buffer.
    public var bufferStrides: [UInt32]

    /// The index number of the stream to be sent to the rasterizer stage.
    public var rasterizedStream: UInt32

    /** Describes a streaming output buffer.
    - parameter declarationEntries: An array of D3D12_SO_DECLARATION_ENTRY structures. Can't be NULL if NumEntries > 0.
    - parameter bufferStrides: An array of buffer strides; each stride is the size of an element for that buffer.
    - parameter rasterizedStream: The index number of the stream to be sent to the rasterizer stage.
    */
    @inlinable @inline(__always)
    public init(declarationEntries: [D3DStreamOutputDeclarationEntry]? = nil, bufferStrides: [UInt32] = [], rasterizedStream: UInt32 = 0) {
        self.declarationEntries = declarationEntries
        self.bufferStrides = bufferStrides
        self.rasterizedStream = rasterizedStream
    }

    @inlinable @inline(__always)
    internal func withUnsafeRawValue<ResultType>(_ body: (RawValue) throws -> ResultType) rethrows -> ResultType {
        return try (declarationEntries ?? []).map({$0.rawValue}).withUnsafeBufferPointer {pSODeclaration in
            let NumEntries = UInt32(declarationEntries?.count ?? 0)
            let pSODeclaration = pSODeclaration.baseAddress!
            return try bufferStrides.withUnsafeBufferPointer {pBufferStrides in
                let NumStrides = UInt32(bufferStrides.count)
                let pBufferStrides = pBufferStrides.baseAddress!
                let RasterizedStream = rasterizedStream
                let rawValue = RawValue(pSODeclaration: pSODeclaration, NumEntries: NumEntries, pBufferStrides: pBufferStrides, NumStrides: NumStrides, RasterizedStream: RasterizedStream)
                return try body(rawValue)
            }
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DStreamOutputDescription")
public typealias D3D12_STREAM_OUTPUT_DESC = D3DStreamOutputDescription

#endif
