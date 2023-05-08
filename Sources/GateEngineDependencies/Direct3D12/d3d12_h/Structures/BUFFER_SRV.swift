/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the elements in a buffer resource to use in a shader-resource view.
public struct D3DShaderResourceViewBuffer {
    public typealias RawValue = WinSDK.D3D12_BUFFER_SRV
    internal var rawValue: RawValue

    /// The index of the first element to be accessed by the view.
    public var index: UInt64 {
        get {
            return rawValue.FirstElement
        }
        set {
            rawValue.FirstElement = newValue
        }
    }

    /// The number of elements in the resource.
    public var count: UInt32 {
        get {
            return rawValue.NumElements
        }
        set {
            rawValue.NumElements = newValue
        }
    }

    /// The size of each element in the buffer structure (in bytes) when the buffer represents a structured buffer.
    public var stride: UInt32 {
        get {
            return rawValue.StructureByteStride
        }
        set {
            rawValue.StructureByteStride = newValue
        }
    }

    /// A D3D12_BUFFER_SRV_FLAGS-typed value that identifies view options for the buffer. Currently, the only option is to identify a raw view of the buffer. For more info about raw viewing of buffers, see Raw Views of Buffers.
    public var flags: D3DBufferShaderResourceViewFlags {
        get {
            return D3DBufferShaderResourceViewFlags(rawValue.Flags)
        }
        set {
            rawValue.Flags = newValue.rawType
        }
    }

    /** Describes the elements in a buffer resource to use in a shader-resource view.
    - parameter index: The index of the first element to be accessed by the view.
    - parameter count: The number of elements in the resource.
    - parameter stride: The size of each element in the buffer structure (in bytes) when the buffer represents a structured buffer.
    - parameter flags: A D3D12_BUFFER_SRV_FLAGS-typed value that identifies view options for the buffer. Currently, the only option is to identify a raw view of the buffer. For more info about raw viewing of buffers, see Raw Views of Buffers.
    */
    public init(index: UInt64, count: UInt32, stride: UInt32, flags: D3DBufferShaderResourceViewFlags) {
        self.rawValue = RawValue()
        self.index = index
        self.count = count
        self.stride = stride
        self.flags = flags
    }

    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DShaderResourceViewBuffer")
public typealias D3D12_BUFFER_SRV = D3DShaderResourceViewBuffer 

#endif
