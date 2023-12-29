/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies texture layout options.
public enum D3DTextureLayout {
    public typealias RawValue = WinSDK.D3D12_TEXTURE_LAYOUT

    /**
    Indicates that the layout is unknown, and is likely adapter-dependent.
    During creation, the driver chooses the most efficient layout based on other resource properties, especially resource size and flags.
    Prefer this choice unless certain functionality is required from another texture layout.


    Zero-copy texture upload optimizations exist for UMA architectures; see ID3D12Resource::WriteToSubresource.
    */
    case unknown
    /**
    Indicates that data for the texture is stored in row-major order (sometimes called "pitch-linear order").


    This texture layout locates consecutive texels of a row contiguously in memory, before the texels of the next row.
    Similarly, consecutive texels of a particular depth or array slice are contiguous in memory before the texels of the next depth or array slice.
    Padding may exist between rows and between depth or array slices to align collections of data.
    A stride is the distance in memory between rows, depth, or array slices; and it includes any padding.


    This texture layout enables sharing of the texture data between multiple adapters, when other layouts aren't available.


    Many restrictions apply, because this layout is generally not efficient for extensive usage:



    The locality of nearby texels is not rotationally invariant.

    Only the following texture properties are supported:


    D3D12_RESOURCE_DIMENSION_TEXTURE_2D.

    A single mip level.

    A single array slice.

    64KB alignment.

    Non-MSAA.

    No D3D12_RESOURCE_FLAG_ALLOW_DEPTH_STENCIL.

    The format cannot be a YUV format.



    The texture must be created on a heap with D3D12_HEAP_FLAG_SHARED_CROSS_ADAPTER.


    Buffers are created with D3D12_TEXTURE_LAYOUT_ROW_MAJOR, because row-major texture data can be located in them without creating a texture object.
    This is commonly used for uploading or reading back texture data, especially for discrete/NUMA adapters.
    However, D3D12_TEXTURE_LAYOUT_ROW_MAJOR can also be used when marshaling texture data between GPUs or adapters.
    For examples of usage with ID3D12GraphicsCommandList::CopyTextureRegion, see some of the following topics:




    Default Texture Mapping and Standard Swizzle


    Predication


    Multi-engine synchronization


    Uploading Texture Data
    */
    case rowMajor
    /**
    Indicates that the layout within 64KB tiles and tail mip packing is up to the driver.
    No standard swizzle pattern.


    This texture layout is arranged into contiguous 64KB regions, also known as tiles, containing near equilateral amount of consecutive number of texels along each dimension.
    Tiles are arranged in row-major order.
    While there is no padding between tiles, there are typically unused texels within the last tile in each dimension.
    The layout of texels within the tile is undefined.
    Each subresource immediately follows where the previous subresource end, and the subresource order follows the same sequence as subresource ordinals.
    However, tail mip packing is adapter-specific.
    For more details, see tiled resource tier and ID3D12Device::GetResourceTiling.


    This texture layout enables partially resident or sparse texture scenarios when used together with virtual memory page mapping functionality.
    This texture layout must be used together with ID3D12Device::CreateReservedResourceto enable the usage of ID3D12CommandQueue::UpdateTileMappings.


    Some restrictions apply to textures with this layout:



    The adapter must support D3D12_TILED_RESOURCES_TIER 1 or greater.

    64KB alignment must be used.


    D3D12_RESOURCE_DIMENSION_TEXTURE1D is not supported, nor are all formats.

    The tiled resource tier indicates whether textures with D3D12_RESOURCE_DIMENSION_TEXTURE3D is supported.
    */
    case undefinedSwizzle64kb
    /**
    Indicates that a default texture uses the standardized swizzle pattern.


    This texture layout is arranged the same way that D3D12_TEXTURE_LAYOUT_64KB_UNDEFINED_SWIZZLE is, except that the layout of texels within the tile is defined.
    Tail mip packing is adapter-specific.


    This texture layout enables optimizations when marshaling data between multiple adapters or between the CPU and GPU.
    The amount of copying can be reduced when multiple components understand the texture memory layout.
    This layout is generally more efficient for extensive usage than row-major layout, due to the rotationally invariant locality of neighboring texels.
    This layout can typically only be used with adapters that support standard swizzle, but exceptions exist for cross-adapter shared heaps.


    The restrictions for this layout are that the following aren't supported:




    D3D12_RESOURCE_DIMENSION_TEXTURE1D

    Multi-sample anti-aliasing (MSAA)


    D3D12_RESOURCE_FLAG_ALLOW_DEPTH_STENCIL

    Formats within the DXGI_FORMAT_R32G32B32_TYPELESS group
    */
    case standardSwizzle64kb

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable @inline(__always)
    public var rawValue: RawValue {
        switch self {
        case .unknown:
            return WinSDK.D3D12_TEXTURE_LAYOUT_UNKNOWN
        case .rowMajor:
            return WinSDK.D3D12_TEXTURE_LAYOUT_ROW_MAJOR
        case .undefinedSwizzle64kb:
            return WinSDK.D3D12_TEXTURE_LAYOUT_64KB_UNDEFINED_SWIZZLE
        case .standardSwizzle64kb:
            return WinSDK.D3D12_TEXTURE_LAYOUT_64KB_STANDARD_SWIZZLE
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable @inline(__always)
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_TEXTURE_LAYOUT_UNKNOWN:
            self = .unknown
        case WinSDK.D3D12_TEXTURE_LAYOUT_ROW_MAJOR:
            self = .rowMajor
        case WinSDK.D3D12_TEXTURE_LAYOUT_64KB_UNDEFINED_SWIZZLE:
            self = .undefinedSwizzle64kb
        case WinSDK.D3D12_TEXTURE_LAYOUT_64KB_STANDARD_SWIZZLE:
            self = .standardSwizzle64kb
        default:
            self = ._unimplemented(rawValue)
        }
    }
}
  

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DTextureLayout")
public typealias D3D12_TEXTURE_LAYOUT = D3DTextureLayout


@available(*, deprecated, renamed: "D3DTextureLayout.unknown")
public let D3D12_TEXTURE_LAYOUT_UNKNOWN = D3DTextureLayout.unknown

@available(*, deprecated, renamed: "D3DTextureLayout.rowMajor")
public let D3D12_TEXTURE_LAYOUT_ROW_MAJOR = D3DTextureLayout.rowMajor

@available(*, deprecated, renamed: "D3DTextureLayout.undefinedSwizzle64kb")
public let D3D12_TEXTURE_LAYOUT_64KB_UNDEFINED_SWIZZLE = D3DTextureLayout.undefinedSwizzle64kb

@available(*, deprecated, renamed: "D3DTextureLayout.standardSwizzle64kb")
public let D3D12_TEXTURE_LAYOUT_64KB_STANDARD_SWIZZLE = D3DTextureLayout.standardSwizzle64kb

#endif
