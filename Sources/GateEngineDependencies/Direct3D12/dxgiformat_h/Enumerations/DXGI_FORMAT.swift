/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Resource data formats, including fully-typed and typeless formats. A list of modifiers at the bottom of the page more fully describes each format type.
public enum DGIFormat {
    public typealias RawValue = WinSDK.DXGI_FORMAT

    ///	The format is not known.
    case unknown
    ///	A four-component, 128-bit typeless format that supports 32 bits per channel including alpha. ¹
    case r32g32b32a32Typeless
    ///	A four-component, 128-bit floating-point format that supports 32 bits per channel including alpha. 1,5,8
    case r32g32b32a32Float
    ///	A four-component, 128-bit unsigned-integer format that supports 32 bits per channel including alpha. ¹
    case r32g32b32a32UInt
    ///	A four-component, 128-bit signed-integer format that supports 32 bits per channel including alpha. ¹
    case r32g32b32a32Int
    ///	A three-component, 96-bit typeless format that supports 32 bits per color channel.
    case r32g32b32Typeless
    ///	A three-component, 96-bit floating-point format that supports 32 bits per color channel.5,8
    case r32g32b32Float
    ///	A three-component, 96-bit unsigned-integer format that supports 32 bits per color channel.
    case r32g32b32UInt	
    ///A three-component, 96-bit signed-integer format that supports 32 bits per color channel.
    case r32g32b32Int
    ///	A four-component, 64-bit typeless format that supports 16 bits per channel including alpha.
    case r16g16b16a16Typeless
    ///	A four-component, 64-bit floating-point format that supports 16 bits per channel including alpha.5,7
    case r16g16b16a16Float
    ///	A four-component, 64-bit unsigned-normalized-integer format that supports 16 bits per channel including alpha.
    case r16g16b16a16Unorm
    ///	A four-component, 64-bit unsigned-integer format that supports 16 bits per channel including alpha.
    case r16g16b16a16UInt
    ///	A four-component, 64-bit signed-normalized-integer format that supports 16 bits per channel including alpha.
    case r16g16b16a16Snorm
    ///	A four-component, 64-bit signed-integer format that supports 16 bits per channel including alpha.
    case r16g16b16a16Int
    ///	A two-component, 64-bit typeless format that supports 32 bits for the red channel and 32 bits for the green channel.
    case r32g32Typeless	
    /// A two-component, 64-bit floating-point format that supports 32 bits for the red channel and 32 bits for the green channel.5,8
    case r32g32Float	
    /// A two-component, 64-bit unsigned-integer format that supports 32 bits for the red channel and 32 bits for the green channel.
    case r32g32UInt	
    /// A two-component, 64-bit signed-integer format that supports 32 bits for the red channel and 32 bits for the green channel.
    case r32g32Int
    ///	A two-component, 64-bit typeless format that supports 32 bits for the red channel, 8 bits for the green channel, and 24 bits are unused.
    case r32g8x24Typeless
    ///	A 32-bit floating-point component, and two unsigned-integer components (with an additional 32 bits). This format supports 32-bit depth, 8-bit stencil, and 24 bits are unused.⁵
    case d32FloatS8x24UInt
    ///	A 32-bit floating-point component, and two typeless components (with an additional 32 bits). This format supports 32-bit red channel, 8 bits are unused, and 24 bits are unused.⁵
    case r32FloatX8x24Typeless
    ///	A 32-bit typeless component, and two unsigned-integer components (with an additional 32 bits). This format has 32 bits unused, 8 bits for green channel, and 24 bits are unused.
    case x32TypelessG8x24UInt
    ///	A four-component, 32-bit typeless format that supports 10 bits for each color and 2 bits for alpha.
    case r10g10b10a2Typeless
    ///	A four-component, 32-bit unsigned-normalized-integer format that supports 10 bits for each color and 2 bits for alpha.
    case r10g10b10a2Unorm
    ///	A four-component, 32-bit unsigned-integer format that supports 10 bits for each color and 2 bits for alpha.
    case r10g10b10a2UInt
    /**	
        Three partial-precision floating-point numbers encoded into a single 32-bit value (a variant of s10e5, which is sign bit, 10-bit mantissa, and 5-bit biased (15) exponent).
        There are no sign bits, and there is a 5-bit biased (15) exponent for each channel, 6-bit mantissa for R and G, and a 5-bit mantissa for B, as shown in the following illustration.5,7

        Illustration of the bits in the three partial-precision floating-point numbers
    */
    case r11g11b10Float
    ///	A four-component, 32-bit typeless format that supports 8 bits per channel including alpha.
    case r8g8b8a8Typeless
    ///	A four-component, 32-bit unsigned-normalized-integer format that supports 8 bits per channel including alpha.
    case r8g8b8a8Unorm
    ///	A four-component, 32-bit unsigned-normalized integer sRGB format that supports 8 bits per channel including alpha.
    case r8g8b8a8UnormSRGB
    ///	A four-component, 32-bit unsigned-integer format that supports 8 bits per channel including alpha.
    case r8g8b8a8UInt
    ///	A four-component, 32-bit signed-normalized-integer format that supports 8 bits per channel including alpha.
    case r8g8b8a8Snorm
    ///	A four-component, 32-bit signed-integer format that supports 8 bits per channel including alpha.
    case r8g8b8a8Int
    ///	A two-component, 32-bit typeless format that supports 16 bits for the red channel and 16 bits for the green channel.
    case r16g16Typeless
    ///	A two-component, 32-bit floating-point format that supports 16 bits for the red channel and 16 bits for the green channel.5,7
    case r16g16Float
    ///	A two-component, 32-bit unsigned-normalized-integer format that supports 16 bits each for the green and red channels.
    case r16g16Unorm
    ///	A two-component, 32-bit unsigned-integer format that supports 16 bits for the red channel and 16 bits for the green channel.
    case r16g16UInt
    ///	A two-component, 32-bit signed-normalized-integer format that supports 16 bits for the red channel and 16 bits for the green channel.
    case r16g16Snorm
    ///	A two-component, 32-bit signed-integer format that supports 16 bits for the red channel and 16 bits for the green channel.
    case r16g16Int
    ///	A single-component, 32-bit typeless format that supports 32 bits for the red channel.
    case r32Typeless
    ///	A single-component, 32-bit floating-point format that supports 32 bits for depth.5,8
    case d32Float
    ///	A single-component, 32-bit floating-point format that supports 32 bits for the red channel.5,8
    case r32Float
    ///	A single-component, 32-bit unsigned-integer format that supports 32 bits for the red channel.
    case r32UInt
    ///	A single-component, 32-bit signed-integer format that supports 32 bits for the red channel.
    case r32Int
    ///	A two-component, 32-bit typeless format that supports 24 bits for the red channel and 8 bits for the green channel.
    case r24g8Typeless
    ///	A 32-bit z-buffer format that supports 24 bits for depth and 8 bits for stencil.
    case d24UnormS8UInt
    ///	A 32-bit format, that contains a 24 bit, single-component, unsigned-normalized integer, with an additional typeless 8 bits. This format has 24 bits red channel and 8 bits unused.
    case r24UnormX8Typeless
    ///	A 32-bit format, that contains a 24 bit, single-component, typeless format, with an additional 8 bit unsigned integer component. This format has 24 bits unused and 8 bits green channel.
    case x24TypelessG8UInt
    ///	A two-component, 16-bit typeless format that supports 8 bits for the red channel and 8 bits for the green channel.
    case r8g8Typeless
    ///	A two-component, 16-bit unsigned-normalized-integer format that supports 8 bits for the red channel and 8 bits for the green channel.
    case r8g8Unorm
    ///	A two-component, 16-bit unsigned-integer format that supports 8 bits for the red channel and 8 bits for the green channel.
    case r8g8UInt
    ///	A two-component, 16-bit signed-normalized-integer format that supports 8 bits for the red channel and 8 bits for the green channel.
    case r8g8Snorm
    ///	A two-component, 16-bit signed-integer format that supports 8 bits for the red channel and 8 bits for the green channel.
    case r8g8Int
    ///	A single-component, 16-bit typeless format that supports 16 bits for the red channel.
    case r16Typeless
    ///	A single-component, 16-bit floating-point format that supports 16 bits for the red channel.5,7
    case r16Float
    ///	A single-component, 16-bit unsigned-normalized-integer format that supports 16 bits for depth.
    case d16Unorm
    ///	A single-component, 16-bit unsigned-normalized-integer format that supports 16 bits for the red channel.
    case r16Unorm
    ///	A single-component, 16-bit unsigned-integer format that supports 16 bits for the red channel.
    case r16UInt
    ///	A single-component, 16-bit signed-normalized-integer format that supports 16 bits for the red channel.
    case r16Snorm
    ///	A single-component, 16-bit signed-integer format that supports 16 bits for the red channel.
    case r16Int
    ///	A single-component, 8-bit typeless format that supports 8 bits for the red channel.
    case r8Typeless
    ///	A single-component, 8-bit unsigned-normalized-integer format that supports 8 bits for the red channel.
    case r8Unorm
    ///	A single-component, 8-bit unsigned-integer format that supports 8 bits for the red channel.
    case r8UInt
    ///	A single-component, 8-bit signed-normalized-integer format that supports 8 bits for the red channel.
    case r8Snorm
    ///	A single-component, 8-bit signed-integer format that supports 8 bits for the red channel.
    case r8Int
    ///	A single-component, 8-bit unsigned-normalized-integer format for alpha only.
    case a8Unorm
    ///	A single-component, 1-bit unsigned-normalized integer format that supports 1 bit for the red channel. ².
    case r1Unorm
    /**	
        Three partial-precision floating-point numbers encoded into a single 32-bit value all sharing the same 5-bit exponent (variant of s10e5, which is sign bit, 10-bit mantissa, and 5-bit biased (15) exponent).
        There is no sign bit, and there is a shared 5-bit biased (15) exponent and a 9-bit mantissa for each channel, as shown in the following illustration. 6,7.

        Illustration of the bits in the three partial-precision floating-point numbers
    */
    case r9g9b9e5SharedEXP
    /**
        A four-component, 32-bit unsigned-normalized-integer DGIFormat. This packed RGB format is analogous to the UYVY DGIFormat. Each 32-bit block describes a pair of pixels: (R8, G8, B8) and (R8, G8, B8) where the R8/B8 values are repeated, and the G8 values are unique to each pixel. ³

        Width must be even.
    */
    case r8g8B8g8Unorm
    /**
        A four-component, 32-bit unsigned-normalized-integer DGIFormat. This packed RGB format is analogous to the YUY2 DGIFormat. Each 32-bit block describes a pair of pixels: (R8, G8, B8) and (R8, G8, B8) where the R8/B8 values are repeated, and the G8 values are unique to each pixel. ³

        Width must be even.
    */
    case g8r8G8b8Unorm
    ///	Four-component typeless block-compression DGIFormat. For information about block-compression formats, see Texture Block Compression in Direct3D 11.
    case bc1Typeless
    ///	Four-component block-compression DGIFormat. For information about block-compression formats, see Texture Block Compression in Direct3D 11.
    case bc1Unorm
    ///	Four-component block-compression format for sRGB data. For information about block-compression formats, see Texture Block Compression in Direct3D 11.
    case bc1UnormSRGB
    ///	Four-component typeless block-compression DGIFormat. For information about block-compression formats, see Texture Block Compression in Direct3D 11.
    case bc2Typeless
    ///	Four-component block-compression DGIFormat. For information about block-compression formats, see Texture Block Compression in Direct3D 11.
    case bc2Unorm
    ///	Four-component block-compression format for sRGB data. For information about block-compression formats, see Texture Block Compression in Direct3D 11.
    case bc2UnormSRGB
    ///	Four-component typeless block-compression DGIFormat. For information about block-compression formats, see Texture Block Compression in Direct3D 11.
    case bc3Typeless
    ///	Four-component block-compression DGIFormat. For information about block-compression formats, see Texture Block Compression in Direct3D 11.
    case bc3Unorm
    ///	Four-component block-compression format for sRGB data. For information about block-compression formats, see Texture Block Compression in Direct3D 11.
    case bc3UnormSRGB
    ///	One-component typeless block-compression DGIFormat. For information about block-compression formats, see Texture Block Compression in Direct3D 11.
    case bc4Typeless
    ///	One-component block-compression DGIFormat. For information about block-compression formats, see Texture Block Compression in Direct3D 11.
    case bc4Unorm
    ///	One-component block-compression DGIFormat. For information about block-compression formats, see Texture Block Compression in Direct3D 11.
    case bc4Snorm
    ///	Two-component typeless block-compression DGIFormat. For information about block-compression formats, see Texture Block Compression in Direct3D 11.
    case bc5Typeless
    ///	Two-component block-compression DGIFormat. For information about block-compression formats, see Texture Block Compression in Direct3D 11.
    case bc5Unorm
    ///	Two-component block-compression DGIFormat. For information about block-compression formats, see Texture Block Compression in Direct3D 11.
    case bc5Snorm
    /**
        A three-component, 16-bit unsigned-normalized-integer format that supports 5 bits for blue, 6 bits for green, and 5 bits for red.

        Direct3D 10 through Direct3D 11:  This value is defined for DXGI. However, Direct3D 10, 10.1, or 11 devices do not support this DGIFormat.

        Direct3D 11.1:  This value is not supported until Windows 8.
    */
    case b5g6r5Unorm
    /**
        A four-component, 16-bit unsigned-normalized-integer format that supports 5 bits for each color channel and 1-bit alpha.

        Direct3D 10 through Direct3D 11:  This value is defined for DXGI. However, Direct3D 10, 10.1, or 11 devices do not support this DGIFormat.

        Direct3D 11.1:  This value is not supported until Windows 8.
    */
    case b5g5r5a1Unorm
    ///	A four-component, 32-bit unsigned-normalized-integer format that supports 8 bits for each color channel and 8-bit alpha.
    case b8g8r8a8Unorm
    ///	A four-component, 32-bit unsigned-normalized-integer format that supports 8 bits for each color channel and 8 bits unused.
    case b8g8r8x8Unorm
    ///	A four-component, 32-bit 2.8-biased fixed-point format that supports 10 bits for each color channel and 2-bit alpha.
    case r10g10b10XrBiasA2Unorm
    ///	A four-component, 32-bit typeless format that supports 8 bits for each channel including alpha. ⁴
    case b8g8r8a8Typeless
    ///	A four-component, 32-bit unsigned-normalized standard RGB format that supports 8 bits for each channel including alpha. ⁴
    case b8g8r8a8UnormSRGB
    ///	A four-component, 32-bit typeless format that supports 8 bits for each color channel, and 8 bits are unused. ⁴
    case b8g8r8x8Typeless
    ///	A four-component, 32-bit unsigned-normalized standard RGB format that supports 8 bits for each color channel, and 8 bits are unused. ⁴
    case b8g8r8x8UnormSRGB
    ///	A typeless block-compression DGIFormat. ⁴ For information about block-compression formats, see Texture Block Compression in Direct3D 11.
    case bc6hTypeless
    ///	A block-compression DGIFormat. ⁴ For information about block-compression formats, see Texture Block Compression in Direct3D 11.⁵
    case bc6hUf16
    ///	A block-compression DGIFormat. ⁴ For information about block-compression formats, see Texture Block Compression in Direct3D 11.⁵
    case bc6hSf16
    ///	A typeless block-compression DGIFormat. ⁴ For information about block-compression formats, see Texture Block Compression in Direct3D 11.
    case bc7Typeless
    ///	A block-compression DGIFormat. ⁴ For information about block-compression formats, see Texture Block Compression in Direct3D 11.
    case bc7Unorm
    ///	A block-compression DGIFormat. ⁴ For information about block-compression formats, see Texture Block Compression in Direct3D 11.
    case bc7UnormSRGB
    /**
        Most common YUV 4:4:4 video resource DGIFormat. Valid view formats for this video resource format are DXGI_FORMAT_R8G8B8A8_UNORM and DXGI_FORMAT_R8G8B8A8_UINT. For UAVs, an additional valid view format is DXGI_FORMAT_R32_UINT. By using DXGI_FORMAT_R32_UINT for UAVs, you can both read and write as opposed to just write for DXGI_FORMAT_R8G8B8A8_UNORM and DXGI_FORMAT_R8G8B8A8_UINT. Supported view types are SRV, RTV, and UAV. One view provides a straightforward mapping of the entire surface. The mapping to the view channel is V->R8,
        U->G8,
        Y->B8,
        and A->A8.

        For more info about YUV formats for video rendering, see Recommended 8-Bit YUV Formats for Video Rendering.

        Direct3D 11.1:  This value is not supported until Windows 8.
    */
    case ayuv
    /**
        10-bit per channel packed YUV 4:4:4 video resource DGIFormat. Valid view formats for this video resource format are DXGI_FORMAT_R10G10B10A2_UNORM and DXGI_FORMAT_R10G10B10A2_UINT. For UAVs, an additional valid view format is DXGI_FORMAT_R32_UINT. By using DXGI_FORMAT_R32_UINT for UAVs, you can both read and write as opposed to just write for DXGI_FORMAT_R10G10B10A2_UNORM and DXGI_FORMAT_R10G10B10A2_UINT. Supported view types are SRV and UAV. One view provides a straightforward mapping of the entire surface. The mapping to the view channel is U->R10,
        Y->G10,
        V->B10,
        and A->A2.

        For more info about YUV formats for video rendering, see Recommended 8-Bit YUV Formats for Video Rendering.

        Direct3D 11.1:  This value is not supported until Windows 8.
    */
    case y410
    /**
        16-bit per channel packed YUV 4:4:4 video resource DGIFormat. Valid view formats for this video resource format are DXGI_FORMAT_R16G16B16A16_UNORM and DXGI_FORMAT_R16G16B16A16_UINT. Supported view types are SRV and UAV. One view provides a straightforward mapping of the entire surface. The mapping to the view channel is U->R16,
        Y->G16,
        V->B16,
        and A->A16.

        For more info about YUV formats for video rendering, see Recommended 8-Bit YUV Formats for Video Rendering.

        Direct3D 11.1:  This value is not supported until Windows 8.
    */
    case y416
    /**
        Most common YUV 4:2:0 video resource DGIFormat. Valid luminance data view formats for this video resource format are DXGI_FORMAT_R8_UNORM and DXGI_FORMAT_R8_UINT. Valid chrominance data view formats (width and height are each 1/2 of luminance view) for this video resource format are DXGI_FORMAT_R8G8_UNORM and DXGI_FORMAT_R8G8_UINT. Supported view types are SRV, RTV, and UAV. For luminance data view, the mapping to the view channel is Y->R8. For chrominance data view, the mapping to the view channel is U->R8 and
        V->G8.

        For more info about YUV formats for video rendering, see Recommended 8-Bit YUV Formats for Video Rendering.

        Width and height must be even. Direct3D 11 staging resources and initData parameters for this format use (rowPitch * (height + (height / 2))) bytes. The first (SysMemPitch * height) bytes are the Y plane, the remaining (SysMemPitch * (height / 2)) bytes are the UV plane.

        An app using the YUY 4:2:0 formats must map the luma (Y) plane separately from the chroma (UV) planes. Developers do this by calling ID3D12Device::CreateShaderResourceView twice for the same texture and passing in 1-channel and 2-channel formats. Passing in a 1-channel format compatible with the Y plane maps only the Y plane. Passing in a 2-channel format compatible with the UV planes (together) maps only the U and V planes as a single resource view.

        Direct3D 11.1:  This value is not supported until Windows 8.
    */
    case nv12
    /**
        10-bit per channel planar YUV 4:2:0 video resource DGIFormat. Valid luminance data view formats for this video resource format are DXGI_FORMAT_R16_UNORM and DXGI_FORMAT_R16_UINT. The runtime does not enforce whether the lowest 6 bits are 0 (given that this video resource format is a 10-bit format that uses 16 bits). If required, application shader code would have to enforce this manually. From the runtime's point of view, DXGI_FORMAT_P010 is no different than DXGI_FORMAT_P016. Valid chrominance data view formats (width and height are each 1/2 of luminance view) for this video resource format are DXGI_FORMAT_R16G16_UNORM and DXGI_FORMAT_R16G16_UINT. For UAVs, an additional valid chrominance data view format is DXGI_FORMAT_R32_UINT. By using DXGI_FORMAT_R32_UINT for UAVs, you can both read and write as opposed to just write for DXGI_FORMAT_R16G16_UNORM and DXGI_FORMAT_R16G16_UINT. Supported view types are SRV, RTV, and UAV. For luminance data view, the mapping to the view channel is Y->R16. For chrominance data view, the mapping to the view channel is U->R16 and
        V->G16.

        For more info about YUV formats for video rendering, see Recommended 8-Bit YUV Formats for Video Rendering.

        Width and height must be even. Direct3D 11 staging resources and initData parameters for this format use (rowPitch * (height + (height / 2))) bytes. The first (SysMemPitch * height) bytes are the Y plane, the remaining (SysMemPitch * (height / 2)) bytes are the UV plane.

        An app using the YUY 4:2:0 formats must map the luma (Y) plane separately from the chroma (UV) planes. Developers do this by calling ID3D12Device::CreateShaderResourceView twice for the same texture and passing in 1-channel and 2-channel formats. Passing in a 1-channel format compatible with the Y plane maps only the Y plane. Passing in a 2-channel format compatible with the UV planes (together) maps only the U and V planes as a single resource view.

        Direct3D 11.1:  This value is not supported until Windows 8.
    */
    case p010
    /**
        16-bit per channel planar YUV 4:2:0 video resource DGIFormat. Valid luminance data view formats for this video resource format are DXGI_FORMAT_R16_UNORM and DXGI_FORMAT_R16_UINT. Valid chrominance data view formats (width and height are each 1/2 of luminance view) for this video resource format are DXGI_FORMAT_R16G16_UNORM and DXGI_FORMAT_R16G16_UINT. For UAVs, an additional valid chrominance data view format is DXGI_FORMAT_R32_UINT. By using DXGI_FORMAT_R32_UINT for UAVs, you can both read and write as opposed to just write for DXGI_FORMAT_R16G16_UNORM and DXGI_FORMAT_R16G16_UINT. Supported view types are SRV, RTV, and UAV. For luminance data view, the mapping to the view channel is Y->R16. For chrominance data view, the mapping to the view channel is U->R16 and
        V->G16.

        For more info about YUV formats for video rendering, see Recommended 8-Bit YUV Formats for Video Rendering.

        Width and height must be even. Direct3D 11 staging resources and initData parameters for this format use (rowPitch * (height + (height / 2))) bytes. The first (SysMemPitch * height) bytes are the Y plane, the remaining (SysMemPitch * (height / 2)) bytes are the UV plane.

        An app using the YUY 4:2:0 formats must map the luma (Y) plane separately from the chroma (UV) planes. Developers do this by calling ID3D12Device::CreateShaderResourceView twice for the same texture and passing in 1-channel and 2-channel formats. Passing in a 1-channel format compatible with the Y plane maps only the Y plane. Passing in a 2-channel format compatible with the UV planes (together) maps only the U and V planes as a single resource view.

        Direct3D 11.1:  This value is not supported until Windows 8.
    */
    case p016
    /**
        8-bit per channel planar YUV 4:2:0 video resource DGIFormat. This format is subsampled where each pixel has its own Y value, but each 2x2 pixel block shares a single U and V value. The runtime requires that the width and height of all resources that are created with this format are multiples of 2. The runtime also requires that the left, right, top, and bottom members of any RECT that are used for this format are multiples of 2. This format differs from DXGI_FORMAT_NV12 in that the layout of the data within the resource is completely opaque to applications. Applications cannot use the CPU to map the resource and then access the data within the resource. You cannot use shaders with this DGIFormat. Because of this behavior, legacy hardware that supports a non-NV12 4:2:0 layout (for example, YV12, and so on) can be used. Also, new hardware that has a 4:2:0 implementation better than NV12 can be used when the application does not need the data to be in a standard layout.

        For more info about YUV formats for video rendering, see Recommended 8-Bit YUV Formats for Video Rendering.

        Width and height must be even. Direct3D 11 staging resources and initData parameters for this format use (rowPitch * (height + (height / 2))) bytes.

        An app using the YUY 4:2:0 formats must map the luma (Y) plane separately from the chroma (UV) planes. Developers do this by calling ID3D12Device::CreateShaderResourceView twice for the same texture and passing in 1-channel and 2-channel formats. Passing in a 1-channel format compatible with the Y plane maps only the Y plane. Passing in a 2-channel format compatible with the UV planes (together) maps only the U and V planes as a single resource view.

        Direct3D 11.1:  This value is not supported until Windows 8.
    */
    case opaque420
    /**
        Most common YUV 4:2:2 video resource DGIFormat. Valid view formats for this video resource format are DXGI_FORMAT_R8G8B8A8_UNORM and DXGI_FORMAT_R8G8B8A8_UINT. For UAVs, an additional valid view format is DXGI_FORMAT_R32_UINT. By using DXGI_FORMAT_R32_UINT for UAVs, you can both read and write as opposed to just write for DXGI_FORMAT_R8G8B8A8_UNORM and DXGI_FORMAT_R8G8B8A8_UINT. Supported view types are SRV and UAV. One view provides a straightforward mapping of the entire surface. The mapping to the view channel is Y0->R8,
        U0->G8,
        Y1->B8,
        and V0->A8.

        A unique valid view format for this video resource format is DXGI_FORMAT_R8G8_B8G8_UNORM. With this view format, the width of the view appears to be twice what the DXGI_FORMAT_R8G8B8A8_UNORM or DXGI_FORMAT_R8G8B8A8_UINT view would be when hardware reconstructs RGBA automatically on read and before filtering. This Direct3D hardware behavior is legacy and is likely not useful any more. With this view format, the mapping to the view channel is Y0->R8,
        U0->
        G8[0],
        Y1->B8,
        and V0->
        G8[1].

        For more info about YUV formats for video rendering, see Recommended 8-Bit YUV Formats for Video Rendering.

        Width must be even.

        Direct3D 11.1:  This value is not supported until Windows 8.
    */
    case yuy2
    /**
        10-bit per channel packed YUV 4:2:2 video resource DGIFormat. Valid view formats for this video resource format are DXGI_FORMAT_R16G16B16A16_UNORM and DXGI_FORMAT_R16G16B16A16_UINT. The runtime does not enforce whether the lowest 6 bits are 0 (given that this video resource format is a 10-bit format that uses 16 bits). If required, application shader code would have to enforce this manually. From the runtime's point of view, DXGI_FORMAT_Y210 is no different than DXGI_FORMAT_Y216. Supported view types are SRV and UAV. One view provides a straightforward mapping of the entire surface. The mapping to the view channel is Y0->R16,
        U->G16,
        Y1->B16,
        and V->A16.

        For more info about YUV formats for video rendering, see Recommended 8-Bit YUV Formats for Video Rendering.

        Width must be even.

        Direct3D 11.1:  This value is not supported until Windows 8.
    */
    case y210
    /**
        16-bit per channel packed YUV 4:2:2 video resource DGIFormat. Valid view formats for this video resource format are DXGI_FORMAT_R16G16B16A16_UNORM and DXGI_FORMAT_R16G16B16A16_UINT. Supported view types are SRV and UAV. One view provides a straightforward mapping of the entire surface. The mapping to the view channel is Y0->R16,
        U->G16,
        Y1->B16,
        and V->A16.

        For more info about YUV formats for video rendering, see Recommended 8-Bit YUV Formats for Video Rendering.

        Width must be even.

        Direct3D 11.1:  This value is not supported until Windows 8.
    */
    case y216
    /**
        Most common planar YUV 4:1:1 video resource DGIFormat. Valid luminance data view formats for this video resource format are DXGI_FORMAT_R8_UNORM and DXGI_FORMAT_R8_UINT. Valid chrominance data view formats (width and height are each 1/4 of luminance view) for this video resource format are DXGI_FORMAT_R8G8_UNORM and DXGI_FORMAT_R8G8_UINT. Supported view types are SRV, RTV, and UAV. For luminance data view, the mapping to the view channel is Y->R8. For chrominance data view, the mapping to the view channel is U->R8 and
        V->G8.

        For more info about YUV formats for video rendering, see Recommended 8-Bit YUV Formats for Video Rendering.

        Width must be a multiple of 4. Direct3D11 staging resources and initData parameters for this format use (rowPitch * height * 2) bytes. The first (SysMemPitch * height) bytes are the Y plane, the next ((SysMemPitch / 2) * height) bytes are the UV plane, and the remainder is padding.

        Direct3D 11.1:  This value is not supported until Windows 8.
    */
    case nv11
    /**
        4-bit palletized YUV format that is commonly used for DVD subpicture.

        For more info about YUV formats for video rendering, see Recommended 8-Bit YUV Formats for Video Rendering.

        Direct3D 11.1:  This value is not supported until Windows 8.
    */
    case ai44
    /**
        4-bit palletized YUV format that is commonly used for DVD subpicture.

        For more info about YUV formats for video rendering, see Recommended 8-Bit YUV Formats for Video Rendering.

        Direct3D 11.1:  This value is not supported until Windows 8.
    */
    case ia44
    /**
        8-bit palletized format that is used for palletized RGB data when the processor processes ISDB-T data and for palletized YUV data when the processor processes BluRay data.

        For more info about YUV formats for video rendering, see Recommended 8-Bit YUV Formats for Video Rendering.

        Direct3D 11.1:  This value is not supported until Windows 8.
    */
    case p8
    /**
        8-bit palletized format with 8 bits of alpha that is used for palletized YUV data when the processor processes BluRay data.

        For more info about YUV formats for video rendering, see Recommended 8-Bit YUV Formats for Video Rendering.

        Direct3D 11.1:  This value is not supported until Windows 8.
    */
    case a8p8
    /**
        A four-component, 16-bit unsigned-normalized integer format that supports 4 bits for each channel including alpha.

        Direct3D 11.1:  This value is not supported until Windows 8.
    */
    case b4g4r4a4Unorm
    ///	A video format; an 8-bit version of a hybrid planar 4:2:2 DGIFormat.
    case p208
    ///	An 8 bit YCbCrA 4:4 rendering DGIFormat.
    case v208
    ///	An 8 bit YCbCrA 4:4:4:4 rendering DGIFormat.
    case v408
    /// Forces this enumeration to compile to 32 bits in size. Without this value, some compilers would allow this enumeration to compile to a size other than 32 bits. This value is not used.
    case forceUInt

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    public var rawValue: RawValue {
        switch self {
        case .unknown:
            return WinSDK.DXGI_FORMAT_UNKNOWN
        case .r32g32b32a32Typeless:
            return WinSDK.DXGI_FORMAT_R32G32B32A32_TYPELESS
        case .r32g32b32a32Float:
            return WinSDK.DXGI_FORMAT_R32G32B32A32_FLOAT
        case .r32g32b32a32UInt:
            return WinSDK.DXGI_FORMAT_R32G32B32A32_UINT
        case .r32g32b32a32Int:
            return WinSDK.DXGI_FORMAT_R32G32B32A32_SINT
        case .r32g32b32Typeless:
            return WinSDK.DXGI_FORMAT_R32G32B32_TYPELESS
        case .r32g32b32Float:
            return WinSDK.DXGI_FORMAT_R32G32B32_FLOAT
        case .r32g32b32UInt:
            return WinSDK.DXGI_FORMAT_R32G32B32_UINT
        case .r32g32b32Int:
            return WinSDK.DXGI_FORMAT_R32G32B32_SINT
        case .r16g16b16a16Typeless:
            return WinSDK.DXGI_FORMAT_R16G16B16A16_TYPELESS
        case .r16g16b16a16Float:
            return WinSDK.DXGI_FORMAT_R16G16B16A16_FLOAT
        case .r16g16b16a16Unorm:
            return WinSDK.DXGI_FORMAT_R16G16B16A16_UNORM
        case .r16g16b16a16UInt:
            return WinSDK.DXGI_FORMAT_R16G16B16A16_UINT
        case .r16g16b16a16Snorm:
            return WinSDK.DXGI_FORMAT_R16G16B16A16_SNORM
        case .r16g16b16a16Int:
            return WinSDK.DXGI_FORMAT_R16G16B16A16_SINT
        case .r32g32Typeless:
            return WinSDK.DXGI_FORMAT_R32G32_TYPELESS
        case .r32g32Float:
            return WinSDK.DXGI_FORMAT_R32G32_FLOAT
        case .r32g32UInt:
            return WinSDK.DXGI_FORMAT_R32G32_UINT
        case .r32g32Int:
            return WinSDK.DXGI_FORMAT_R32G32_SINT
        case .r32g8x24Typeless:
            return WinSDK.DXGI_FORMAT_R32G8X24_TYPELESS
        case .d32FloatS8x24UInt:
            return WinSDK.DXGI_FORMAT_D32_FLOAT_S8X24_UINT
        case .r32FloatX8x24Typeless:
            return WinSDK.DXGI_FORMAT_R32_FLOAT_X8X24_TYPELESS
        case .x32TypelessG8x24UInt:
            return WinSDK.DXGI_FORMAT_X32_TYPELESS_G8X24_UINT
        case .r10g10b10a2Typeless:
            return WinSDK.DXGI_FORMAT_R10G10B10A2_TYPELESS
        case .r10g10b10a2Unorm:
            return WinSDK.DXGI_FORMAT_R10G10B10A2_UNORM
        case .r10g10b10a2UInt:
            return WinSDK.DXGI_FORMAT_R10G10B10A2_UINT
        case .r11g11b10Float:
            return WinSDK.DXGI_FORMAT_R11G11B10_FLOAT
        case .r8g8b8a8Typeless:
            return WinSDK.DXGI_FORMAT_R8G8B8A8_TYPELESS
        case .r8g8b8a8Unorm:
            return WinSDK.DXGI_FORMAT_R8G8B8A8_UNORM
        case .r8g8b8a8UnormSRGB:
            return WinSDK.DXGI_FORMAT_R8G8B8A8_UNORM_SRGB
        case .r8g8b8a8UInt:
            return WinSDK.DXGI_FORMAT_R8G8B8A8_UINT
        case .r8g8b8a8Snorm:
            return WinSDK.DXGI_FORMAT_R8G8B8A8_SNORM
        case .r8g8b8a8Int:
            return WinSDK.DXGI_FORMAT_R8G8B8A8_SINT
        case .r16g16Typeless:
            return WinSDK.DXGI_FORMAT_R16G16_TYPELESS
        case .r16g16Float:
            return WinSDK.DXGI_FORMAT_R16G16_FLOAT
        case .r16g16Unorm:
            return WinSDK.DXGI_FORMAT_R16G16_UNORM
        case .r16g16UInt:
            return WinSDK.DXGI_FORMAT_R16G16_UINT
        case .r16g16Snorm:
            return WinSDK.DXGI_FORMAT_R16G16_SNORM
        case .r16g16Int:
            return WinSDK.DXGI_FORMAT_R16G16_SINT
        case .r32Typeless:
            return WinSDK.DXGI_FORMAT_R32_TYPELESS
        case .d32Float:
            return WinSDK.DXGI_FORMAT_D32_FLOAT
        case .r32Float:
            return WinSDK.DXGI_FORMAT_R32_FLOAT
        case .r32UInt:
            return WinSDK.DXGI_FORMAT_R32_UINT
        case .r32Int:
            return WinSDK.DXGI_FORMAT_R32_SINT
        case .r24g8Typeless:
            return WinSDK.DXGI_FORMAT_R24G8_TYPELESS
        case .d24UnormS8UInt:
            return WinSDK.DXGI_FORMAT_D24_UNORM_S8_UINT
        case .r24UnormX8Typeless:
            return WinSDK.DXGI_FORMAT_R24_UNORM_X8_TYPELESS
        case .x24TypelessG8UInt:
            return WinSDK.DXGI_FORMAT_X24_TYPELESS_G8_UINT
        case .r8g8Typeless:
            return WinSDK.DXGI_FORMAT_R8G8_TYPELESS
        case .r8g8Unorm:
            return WinSDK.DXGI_FORMAT_R8G8_UNORM
        case .r8g8UInt:
            return WinSDK.DXGI_FORMAT_R8G8_UINT
        case .r8g8Snorm:
            return WinSDK.DXGI_FORMAT_R8G8_SNORM
        case .r8g8Int:
            return WinSDK.DXGI_FORMAT_R8G8_SINT
        case .r16Typeless:
            return WinSDK.DXGI_FORMAT_R16_TYPELESS
        case .r16Float:
            return WinSDK.DXGI_FORMAT_R16_FLOAT
        case .d16Unorm:
            return WinSDK.DXGI_FORMAT_D16_UNORM
        case .r16Unorm:
            return WinSDK.DXGI_FORMAT_R16_UNORM
        case .r16UInt:
            return WinSDK.DXGI_FORMAT_R16_UINT
        case .r16Snorm:
            return WinSDK.DXGI_FORMAT_R16_SNORM
        case .r16Int:
            return WinSDK.DXGI_FORMAT_R16_SINT
        case .r8Typeless:
            return WinSDK.DXGI_FORMAT_R8_TYPELESS
        case .r8Unorm:
            return WinSDK.DXGI_FORMAT_R8_UNORM
        case .r8UInt:
            return WinSDK.DXGI_FORMAT_R8_UINT
        case .r8Snorm:
            return WinSDK.DXGI_FORMAT_R8_SNORM
        case .r8Int:
            return WinSDK.DXGI_FORMAT_R8_SINT
        case .a8Unorm:
            return WinSDK.DXGI_FORMAT_A8_UNORM
        case .r1Unorm:
            return WinSDK.DXGI_FORMAT_R1_UNORM
        case .r9g9b9e5SharedEXP:
            return WinSDK.DXGI_FORMAT_R9G9B9E5_SHAREDEXP
        case .r8g8B8g8Unorm:
            return WinSDK.DXGI_FORMAT_R8G8_B8G8_UNORM
        case .g8r8G8b8Unorm:
            return WinSDK.DXGI_FORMAT_G8R8_G8B8_UNORM
        case .bc1Typeless:
            return WinSDK.DXGI_FORMAT_BC1_TYPELESS
        case .bc1Unorm:
            return WinSDK.DXGI_FORMAT_BC1_UNORM
        case .bc1UnormSRGB:
            return WinSDK.DXGI_FORMAT_BC1_UNORM_SRGB
        case .bc2Typeless:
            return WinSDK.DXGI_FORMAT_BC2_TYPELESS
        case .bc2Unorm:
            return WinSDK.DXGI_FORMAT_BC2_UNORM
        case .bc2UnormSRGB:
            return WinSDK.DXGI_FORMAT_BC2_UNORM_SRGB
        case .bc3Typeless:
            return WinSDK.DXGI_FORMAT_BC3_TYPELESS
        case .bc3Unorm:
            return WinSDK.DXGI_FORMAT_BC3_UNORM
        case .bc3UnormSRGB:
            return WinSDK.DXGI_FORMAT_BC3_UNORM_SRGB
        case .bc4Typeless:
            return WinSDK.DXGI_FORMAT_BC4_TYPELESS
        case .bc4Unorm:
            return WinSDK.DXGI_FORMAT_BC4_UNORM
        case .bc4Snorm:
            return WinSDK.DXGI_FORMAT_BC4_SNORM
        case .bc5Typeless:
            return WinSDK.DXGI_FORMAT_BC5_TYPELESS
        case .bc5Unorm:
            return WinSDK.DXGI_FORMAT_BC5_UNORM
        case .bc5Snorm:
            return WinSDK.DXGI_FORMAT_BC5_SNORM
        case .b5g6r5Unorm:
            return WinSDK.DXGI_FORMAT_B5G6R5_UNORM
        case .b5g5r5a1Unorm:
            return WinSDK.DXGI_FORMAT_B5G5R5A1_UNORM
        case .b8g8r8a8Unorm:
            return WinSDK.DXGI_FORMAT_B8G8R8A8_UNORM
        case .b8g8r8x8Unorm:
            return WinSDK.DXGI_FORMAT_B8G8R8X8_UNORM
        case .r10g10b10XrBiasA2Unorm:
            return WinSDK.DXGI_FORMAT_R10G10B10_XR_BIAS_A2_UNORM
        case .b8g8r8a8Typeless:
            return WinSDK.DXGI_FORMAT_B8G8R8A8_TYPELESS
        case .b8g8r8a8UnormSRGB:
            return WinSDK.DXGI_FORMAT_B8G8R8A8_UNORM_SRGB
        case .b8g8r8x8Typeless:
            return WinSDK.DXGI_FORMAT_B8G8R8X8_TYPELESS
        case .b8g8r8x8UnormSRGB:
            return WinSDK.DXGI_FORMAT_B8G8R8X8_UNORM_SRGB
        case .bc6hTypeless:
            return WinSDK.DXGI_FORMAT_BC6H_TYPELESS
        case .bc6hUf16:
            return WinSDK.DXGI_FORMAT_BC6H_UF16
        case .bc6hSf16:
            return WinSDK.DXGI_FORMAT_BC6H_SF16
        case .bc7Typeless:
            return WinSDK.DXGI_FORMAT_BC7_TYPELESS
        case .bc7Unorm:
            return WinSDK.DXGI_FORMAT_BC7_UNORM
        case .bc7UnormSRGB:
            return WinSDK.DXGI_FORMAT_BC7_UNORM_SRGB
        case .ayuv:
            return WinSDK.DXGI_FORMAT_AYUV
        case .y410:
            return WinSDK.DXGI_FORMAT_Y410
        case .y416:
            return WinSDK.DXGI_FORMAT_Y416
        case .nv12:
            return WinSDK.DXGI_FORMAT_NV12
        case .p010:
            return WinSDK.DXGI_FORMAT_P010
        case .p016:
            return WinSDK.DXGI_FORMAT_P016
        case .opaque420:
            return WinSDK.DXGI_FORMAT_420_OPAQUE
        case .yuy2:
            return WinSDK.DXGI_FORMAT_YUY2
        case .y210:
            return WinSDK.DXGI_FORMAT_Y210
        case .y216:
            return WinSDK.DXGI_FORMAT_Y216
        case .nv11:
            return WinSDK.DXGI_FORMAT_NV11
        case .ai44:
            return WinSDK.DXGI_FORMAT_AI44
        case .ia44:
            return WinSDK.DXGI_FORMAT_IA44
        case .p8:
            return WinSDK.DXGI_FORMAT_P8
        case .a8p8:
            return WinSDK.DXGI_FORMAT_A8P8
        case .b4g4r4a4Unorm:
            return WinSDK.DXGI_FORMAT_B4G4R4A4_UNORM
        case .p208:
            return WinSDK.DXGI_FORMAT_P208
        case .v208:
            return WinSDK.DXGI_FORMAT_V208
        case .v408:
            return WinSDK.DXGI_FORMAT_V408
        case .forceUInt:
            return WinSDK.DXGI_FORMAT_FORCE_UINT
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }


    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.DXGI_FORMAT_UNKNOWN:
            self = .unknown
        case WinSDK.DXGI_FORMAT_R32G32B32A32_TYPELESS:
            self = .r32g32b32a32Typeless
        case WinSDK.DXGI_FORMAT_R32G32B32A32_FLOAT:
            self = .r32g32b32a32Float
        case WinSDK.DXGI_FORMAT_R32G32B32A32_UINT:
            self = .r32g32b32a32UInt
        case WinSDK.DXGI_FORMAT_R32G32B32A32_SINT:
            self = .r32g32b32a32Int
        case WinSDK.DXGI_FORMAT_R32G32B32_TYPELESS:
            self = .r32g32b32Typeless
        case WinSDK.DXGI_FORMAT_R32G32B32_FLOAT:
            self = .r32g32b32Float
        case WinSDK.DXGI_FORMAT_R32G32B32_UINT:
            self = .r32g32b32UInt
        case WinSDK.DXGI_FORMAT_R32G32B32_SINT:
            self = .r32g32b32Int
        case WinSDK.DXGI_FORMAT_R16G16B16A16_TYPELESS:
            self = .r16g16b16a16Typeless
        case WinSDK.DXGI_FORMAT_R16G16B16A16_FLOAT:
            self = .r16g16b16a16Float
        case WinSDK.DXGI_FORMAT_R16G16B16A16_UNORM:
            self = .r16g16b16a16Unorm
        case WinSDK.DXGI_FORMAT_R16G16B16A16_UINT:
            self = .r16g16b16a16UInt
        case WinSDK.DXGI_FORMAT_R16G16B16A16_SNORM:
            self = .r16g16b16a16Snorm
        case WinSDK.DXGI_FORMAT_R16G16B16A16_SINT:
            self = .r16g16b16a16Int
        case WinSDK.DXGI_FORMAT_R32G32_TYPELESS:
            self = .r32g32Typeless
        case WinSDK.DXGI_FORMAT_R32G32_FLOAT:
            self = .r32g32Float
        case WinSDK.DXGI_FORMAT_R32G32_UINT:
            self = .r32g32UInt
        case WinSDK.DXGI_FORMAT_R32G32_SINT:
            self = .r32g32Int
        case WinSDK.DXGI_FORMAT_R32G8X24_TYPELESS:
            self = .r32g8x24Typeless
        case WinSDK.DXGI_FORMAT_D32_FLOAT_S8X24_UINT:
            self = .d32FloatS8x24UInt
        case WinSDK.DXGI_FORMAT_R32_FLOAT_X8X24_TYPELESS:
            self = .r32FloatX8x24Typeless
        case WinSDK.DXGI_FORMAT_X32_TYPELESS_G8X24_UINT:
            self = .x32TypelessG8x24UInt
        case WinSDK.DXGI_FORMAT_R10G10B10A2_TYPELESS:
            self = .r10g10b10a2Typeless
        case WinSDK.DXGI_FORMAT_R10G10B10A2_UNORM:
            self = .r10g10b10a2Unorm
        case WinSDK.DXGI_FORMAT_R10G10B10A2_UINT:
            self = .r10g10b10a2UInt
        case WinSDK.DXGI_FORMAT_R11G11B10_FLOAT:
            self = .r11g11b10Float
        case WinSDK.DXGI_FORMAT_R8G8B8A8_TYPELESS:
            self = .r8g8b8a8Typeless
        case WinSDK.DXGI_FORMAT_R8G8B8A8_UNORM:
            self = .r8g8b8a8Unorm
        case WinSDK.DXGI_FORMAT_R8G8B8A8_UNORM_SRGB:
            self = .r8g8b8a8UnormSRGB
        case WinSDK.DXGI_FORMAT_R8G8B8A8_UINT:
            self = .r8g8b8a8UInt
        case WinSDK.DXGI_FORMAT_R8G8B8A8_SNORM:
            self = .r8g8b8a8Snorm
        case WinSDK.DXGI_FORMAT_R8G8B8A8_SINT:
            self = .r8g8b8a8Int
        case WinSDK.DXGI_FORMAT_R16G16_TYPELESS:
            self = .r16g16Typeless
        case WinSDK.DXGI_FORMAT_R16G16_FLOAT:
            self = .r16g16Float
        case WinSDK.DXGI_FORMAT_R16G16_UNORM:
            self = .r16g16Unorm
        case WinSDK.DXGI_FORMAT_R16G16_UINT:
            self = .r16g16UInt
        case WinSDK.DXGI_FORMAT_R16G16_SNORM:
            self = .r16g16Snorm
        case WinSDK.DXGI_FORMAT_R16G16_SINT:
            self = .r16g16Int
        case WinSDK.DXGI_FORMAT_R32_TYPELESS:
            self = .r32Typeless
        case WinSDK.DXGI_FORMAT_D32_FLOAT:
            self = .d32Float
        case WinSDK.DXGI_FORMAT_R32_FLOAT:
            self = .r32Float
        case WinSDK.DXGI_FORMAT_R32_UINT:
            self = .r32UInt
        case WinSDK.DXGI_FORMAT_R32_SINT:
            self = .r32Int
        case WinSDK.DXGI_FORMAT_R24G8_TYPELESS:
            self = .r24g8Typeless
        case WinSDK.DXGI_FORMAT_D24_UNORM_S8_UINT:
            self = .d24UnormS8UInt
        case WinSDK.DXGI_FORMAT_R24_UNORM_X8_TYPELESS:
            self = .r24UnormX8Typeless
        case WinSDK.DXGI_FORMAT_X24_TYPELESS_G8_UINT:
            self = .x24TypelessG8UInt
        case WinSDK.DXGI_FORMAT_R8G8_TYPELESS:
            self = .r8g8Typeless
        case WinSDK.DXGI_FORMAT_R8G8_UNORM:
            self = .r8g8Unorm
        case WinSDK.DXGI_FORMAT_R8G8_UINT:
            self = .r8g8UInt
        case WinSDK.DXGI_FORMAT_R8G8_SNORM:
            self = .r8g8Snorm
        case WinSDK.DXGI_FORMAT_R8G8_SINT:
            self = .r8g8Int
        case WinSDK.DXGI_FORMAT_R16_TYPELESS:
            self = .r16Typeless
        case WinSDK.DXGI_FORMAT_R16_FLOAT:
            self = .r16Float
        case WinSDK.DXGI_FORMAT_D16_UNORM:
            self = .d16Unorm
        case WinSDK.DXGI_FORMAT_R16_UNORM:
            self = .r16Unorm
        case WinSDK.DXGI_FORMAT_R16_UINT:
            self = .r16UInt
        case WinSDK.DXGI_FORMAT_R16_SNORM:
            self = .r16Snorm
        case WinSDK.DXGI_FORMAT_R16_SINT:
            self = .r16Int
        case WinSDK.DXGI_FORMAT_R8_TYPELESS:
            self = .r8Typeless
        case WinSDK.DXGI_FORMAT_R8_UNORM:
            self = .r8Unorm
        case WinSDK.DXGI_FORMAT_R8_UINT:
            self = .r8UInt
        case WinSDK.DXGI_FORMAT_R8_SNORM:
            self = .r8Snorm
        case WinSDK.DXGI_FORMAT_R8_SINT:
            self = .r8Int
        case WinSDK.DXGI_FORMAT_A8_UNORM:
            self = .a8Unorm
        case WinSDK.DXGI_FORMAT_R1_UNORM:
            self = .r1Unorm
        case WinSDK.DXGI_FORMAT_R9G9B9E5_SHAREDEXP:
            self = .r9g9b9e5SharedEXP
        case WinSDK.DXGI_FORMAT_R8G8_B8G8_UNORM:
            self = .r8g8B8g8Unorm
        case WinSDK.DXGI_FORMAT_G8R8_G8B8_UNORM:
            self = .g8r8G8b8Unorm
        case WinSDK.DXGI_FORMAT_BC1_TYPELESS:
            self = .bc1Typeless
        case WinSDK.DXGI_FORMAT_BC1_UNORM:
            self = .bc1Unorm
        case WinSDK.DXGI_FORMAT_BC1_UNORM_SRGB:
            self = .bc1UnormSRGB
        case WinSDK.DXGI_FORMAT_BC2_TYPELESS:
            self = .bc2Typeless
        case WinSDK.DXGI_FORMAT_BC2_UNORM:
            self = .bc2Unorm
        case WinSDK.DXGI_FORMAT_BC2_UNORM_SRGB:
            self = .bc2UnormSRGB
        case WinSDK.DXGI_FORMAT_BC3_TYPELESS:
            self = .bc3Typeless
        case WinSDK.DXGI_FORMAT_BC3_UNORM:
            self = .bc3Unorm
        case WinSDK.DXGI_FORMAT_BC3_UNORM_SRGB:
            self = .bc3UnormSRGB
        case WinSDK.DXGI_FORMAT_BC4_TYPELESS:
            self = .bc4Typeless
        case WinSDK.DXGI_FORMAT_BC4_UNORM:
            self = .bc4Unorm
        case WinSDK.DXGI_FORMAT_BC4_SNORM:
            self = .bc4Snorm
        case WinSDK.DXGI_FORMAT_BC5_TYPELESS:
            self = .bc5Typeless
        case WinSDK.DXGI_FORMAT_BC5_UNORM:
            self = .bc5Unorm
        case WinSDK.DXGI_FORMAT_BC5_SNORM:
            self = .bc5Snorm
        case WinSDK.DXGI_FORMAT_B5G6R5_UNORM:
            self = .b5g6r5Unorm
        case WinSDK.DXGI_FORMAT_B5G5R5A1_UNORM:
            self = .b5g5r5a1Unorm
        case WinSDK.DXGI_FORMAT_B8G8R8A8_UNORM:
            self = .b8g8r8a8Unorm
        case WinSDK.DXGI_FORMAT_B8G8R8X8_UNORM:
            self = .b8g8r8x8Unorm
        case WinSDK.DXGI_FORMAT_R10G10B10_XR_BIAS_A2_UNORM:
            self = .r10g10b10XrBiasA2Unorm
        case WinSDK.DXGI_FORMAT_B8G8R8A8_TYPELESS:
            self = .b8g8r8a8Typeless
        case WinSDK.DXGI_FORMAT_B8G8R8A8_UNORM_SRGB:
            self = .b8g8r8a8UnormSRGB
        case WinSDK.DXGI_FORMAT_B8G8R8X8_TYPELESS:
            self = .b8g8r8x8Typeless
        case WinSDK.DXGI_FORMAT_B8G8R8X8_UNORM_SRGB:
            self = .b8g8r8x8UnormSRGB
        case WinSDK.DXGI_FORMAT_BC6H_TYPELESS:
            self = .bc6hTypeless
        case WinSDK.DXGI_FORMAT_BC6H_UF16:
            self = .bc6hUf16
        case WinSDK.DXGI_FORMAT_BC6H_SF16:
            self = .bc6hSf16
        case WinSDK.DXGI_FORMAT_BC7_TYPELESS:
            self = .bc7Typeless
        case WinSDK.DXGI_FORMAT_BC7_UNORM:
            self = .bc7Unorm
        case WinSDK.DXGI_FORMAT_BC7_UNORM_SRGB:
            self = .bc7UnormSRGB
        case WinSDK.DXGI_FORMAT_AYUV:
            self = .ayuv
        case WinSDK.DXGI_FORMAT_Y410:
            self = .y410
        case WinSDK.DXGI_FORMAT_Y416:
            self = .y416
        case WinSDK.DXGI_FORMAT_NV12:
            self = .nv12
        case WinSDK.DXGI_FORMAT_P010:
            self = .p010
        case WinSDK.DXGI_FORMAT_P016:
            self = .p016
        case WinSDK.DXGI_FORMAT_420_OPAQUE:
            self = .opaque420
        case WinSDK.DXGI_FORMAT_YUY2:
            self = .yuy2
        case WinSDK.DXGI_FORMAT_Y210:
            self = .y210
        case WinSDK.DXGI_FORMAT_Y216:
            self = .y216
        case WinSDK.DXGI_FORMAT_NV11:
            self = .nv11
        case WinSDK.DXGI_FORMAT_AI44:
            self = .ai44
        case WinSDK.DXGI_FORMAT_IA44:
            self = .ia44
        case WinSDK.DXGI_FORMAT_P8:
            self = .p8
        case WinSDK.DXGI_FORMAT_A8P8:
            self = .a8p8
        case WinSDK.DXGI_FORMAT_B4G4R4A4_UNORM:
            self = .b4g4r4a4Unorm
        case WinSDK.DXGI_FORMAT_P208:
            self = .p208
        case WinSDK.DXGI_FORMAT_V208:
            self = .v208
        case WinSDK.DXGI_FORMAT_V408:
            self = .v408
        case WinSDK.DXGI_FORMAT_FORCE_UINT:
            self = .forceUInt
        default:
            self = ._unimplemented(rawValue)
        }
    }
}
  

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "DGIFormat")
public typealias DXGI_FORMAT = DGIFormat

@available(*, deprecated, renamed: "DGIFormat.unknown")
public let DXGI_FORMAT_UNKNOWN = DGIFormat.unknown

@available(*, deprecated, renamed: "DGIFormat.r32g32b32a32Typeless")
public let DXGI_FORMAT_R32G32B32A32_TYPELESS = DGIFormat.r32g32b32a32Typeless

@available(*, deprecated, renamed: "DGIFormat.r32g32b32a32Float")
public let DXGI_FORMAT_R32G32B32A32_FLOAT = DGIFormat.r32g32b32a32Float

@available(*, deprecated, renamed: "DGIFormat.r32g32b32a32UInt")
public let DXGI_FORMAT_R32G32B32A32_UINT = DGIFormat.r32g32b32a32UInt

@available(*, deprecated, renamed: "DGIFormat.r32g32b32a32Int")
public let DXGI_FORMAT_R32G32B32A32_SINT = DGIFormat.r32g32b32a32Int

@available(*, deprecated, renamed: "DGIFormat.r32g32b32Typeless")
public let DXGI_FORMAT_R32G32B32_TYPELESS = DGIFormat.r32g32b32Typeless

@available(*, deprecated, renamed: "DGIFormat.r32g32b32Float")
public let DXGI_FORMAT_R32G32B32_FLOAT = DGIFormat.r32g32b32Float

@available(*, deprecated, renamed: "DGIFormat.r32g32b32UInt")
public let DXGI_FORMAT_R32G32B32_UINT = DGIFormat.r32g32b32UInt

@available(*, deprecated, renamed: "DGIFormat.r32g32b32Int")
public let DXGI_FORMAT_R32G32B32_SINT = DGIFormat.r32g32b32Int

@available(*, deprecated, renamed: "DGIFormat.r16g16b16a16Typeless")
public let DXGI_FORMAT_R16G16B16A16_TYPELESS = DGIFormat.r16g16b16a16Typeless

@available(*, deprecated, renamed: "DGIFormat.r16g16b16a16Float")
public let DXGI_FORMAT_R16G16B16A16_FLOAT = DGIFormat.r16g16b16a16Float

@available(*, deprecated, renamed: "DGIFormat.r16g16b16a16Unorm")
public let DXGI_FORMAT_R16G16B16A16_UNORM = DGIFormat.r16g16b16a16Unorm

@available(*, deprecated, renamed: "DGIFormat.r16g16b16a16UInt")
public let DXGI_FORMAT_R16G16B16A16_UINT = DGIFormat.r16g16b16a16UInt

@available(*, deprecated, renamed: "DGIFormat.r16g16b16a16Snorm")
public let DXGI_FORMAT_R16G16B16A16_SNORM = DGIFormat.r16g16b16a16Snorm

@available(*, deprecated, renamed: "DGIFormat.r16g16b16a16Int")
public let DXGI_FORMAT_R16G16B16A16_SINT = DGIFormat.r16g16b16a16Int

@available(*, deprecated, renamed: "DGIFormat.r32g32Typeless")
public let DXGI_FORMAT_R32G32_TYPELESS = DGIFormat.r32g32Typeless

@available(*, deprecated, renamed: "DGIFormat.r32g32Float")
public let DXGI_FORMAT_R32G32_FLOAT = DGIFormat.r32g32Float

@available(*, deprecated, renamed: "DGIFormat.r32g32UInt")
public let DXGI_FORMAT_R32G32_UINT = DGIFormat.r32g32UInt

@available(*, deprecated, renamed: "DGIFormat.r32g32Int")
public let DXGI_FORMAT_R32G32_SINT = DGIFormat.r32g32Int

@available(*, deprecated, renamed: "DGIFormat.r32g8x24Typeless")
public let DXGI_FORMAT_R32G8X24_TYPELESS = DGIFormat.r32g8x24Typeless

@available(*, deprecated, renamed: "DGIFormat.d32FloatS8x24UInt")
public let DXGI_FORMAT_D32_FLOAT_S8X24_UINT = DGIFormat.d32FloatS8x24UInt

@available(*, deprecated, renamed: "DGIFormat.r32FloatX8x24Typeless")
public let DXGI_FORMAT_R32_FLOAT_X8X24_TYPELESS = DGIFormat.r32FloatX8x24Typeless

@available(*, deprecated, renamed: "DGIFormat.x32TypelessG8x24UInt")
public let DXGI_FORMAT_X32_TYPELESS_G8X24_UINT = DGIFormat.x32TypelessG8x24UInt

@available(*, deprecated, renamed: "DGIFormat.r10g10b10a2Typeless")
public let DXGI_FORMAT_R10G10B10A2_TYPELESS = DGIFormat.r10g10b10a2Typeless

@available(*, deprecated, renamed: "DGIFormat.r10g10b10a2Unorm")
public let DXGI_FORMAT_R10G10B10A2_UNORM = DGIFormat.r10g10b10a2Unorm

@available(*, deprecated, renamed: "DGIFormat.r10g10b10a2UInt")
public let DXGI_FORMAT_R10G10B10A2_UINT = DGIFormat.r10g10b10a2UInt

@available(*, deprecated, renamed: "DGIFormat.r11g11b10Float")
public let DXGI_FORMAT_R11G11B10_FLOAT = DGIFormat.r11g11b10Float

@available(*, deprecated, renamed: "DGIFormat.r8g8b8a8Typeless")
public let DXGI_FORMAT_R8G8B8A8_TYPELESS = DGIFormat.r8g8b8a8Typeless

@available(*, deprecated, renamed: "DGIFormat.r8g8b8a8Unorm")
public let DXGI_FORMAT_R8G8B8A8_UNORM = DGIFormat.r8g8b8a8Unorm

@available(*, deprecated, renamed: "DGIFormat.r8g8b8a8UnormSRGB")
public let DXGI_FORMAT_R8G8B8A8_UNORM_SRGB = DGIFormat.r8g8b8a8UnormSRGB

@available(*, deprecated, renamed: "DGIFormat.r8g8b8a8UInt")
public let DXGI_FORMAT_R8G8B8A8_UINT = DGIFormat.r8g8b8a8UInt

@available(*, deprecated, renamed: "DGIFormat.r8g8b8a8Snorm")
public let DXGI_FORMAT_R8G8B8A8_SNORM = DGIFormat.r8g8b8a8Snorm

@available(*, deprecated, renamed: "DGIFormat.r8g8b8a8Int")
public let DXGI_FORMAT_R8G8B8A8_SINT = DGIFormat.r8g8b8a8Int

@available(*, deprecated, renamed: "DGIFormat.r16g16Typeless")
public let DXGI_FORMAT_R16G16_TYPELESS = DGIFormat.r16g16Typeless

@available(*, deprecated, renamed: "DGIFormat.r16g16Float")
public let DXGI_FORMAT_R16G16_FLOAT = DGIFormat.r16g16Float

@available(*, deprecated, renamed: "DGIFormat.r16g16Unorm")
public let DXGI_FORMAT_R16G16_UNORM = DGIFormat.r16g16Unorm

@available(*, deprecated, renamed: "DGIFormat.r16g16UInt")
public let DXGI_FORMAT_R16G16_UINT = DGIFormat.r16g16UInt

@available(*, deprecated, renamed: "DGIFormat.r16g16Snorm")
public let DXGI_FORMAT_R16G16_SNORM = DGIFormat.r16g16Snorm

@available(*, deprecated, renamed: "DGIFormat.r16g16Int")
public let DXGI_FORMAT_R16G16_SINT = DGIFormat.r16g16Int

@available(*, deprecated, renamed: "DGIFormat.r32Typeless")
public let DXGI_FORMAT_R32_TYPELESS = DGIFormat.r32Typeless

@available(*, deprecated, renamed: "DGIFormat.d32Float")
public let DXGI_FORMAT_D32_FLOAT = DGIFormat.d32Float

@available(*, deprecated, renamed: "DGIFormat.r32Float")
public let DXGI_FORMAT_R32_FLOAT = DGIFormat.r32Float

@available(*, deprecated, renamed: "DGIFormat.r32UInt")
public let DXGI_FORMAT_R32_UINT = DGIFormat.r32UInt

@available(*, deprecated, renamed: "DGIFormat.r32Int")
public let DXGI_FORMAT_R32_SINT = DGIFormat.r32Int

@available(*, deprecated, renamed: "DGIFormat.r24g8Typeless")
public let DXGI_FORMAT_R24G8_TYPELESS = DGIFormat.r24g8Typeless

@available(*, deprecated, renamed: "DGIFormat.d24UnormS8UInt")
public let DXGI_FORMAT_D24_UNORM_S8_UINT = DGIFormat.d24UnormS8UInt

@available(*, deprecated, renamed: "DGIFormat.r24UnormX8Typeless")
public let DXGI_FORMAT_R24_UNORM_X8_TYPELESS = DGIFormat.r24UnormX8Typeless

@available(*, deprecated, renamed: "DGIFormat.x24TypelessG8UInt")
public let DXGI_FORMAT_X24_TYPELESS_G8_UINT = DGIFormat.x24TypelessG8UInt

@available(*, deprecated, renamed: "DGIFormat.r8g8Typeless")
public let DXGI_FORMAT_R8G8_TYPELESS = DGIFormat.r8g8Typeless

@available(*, deprecated, renamed: "DGIFormat.r8g8Unorm")
public let DXGI_FORMAT_R8G8_UNORM = DGIFormat.r8g8Unorm

@available(*, deprecated, renamed: "DGIFormat.r8g8UInt")
public let DXGI_FORMAT_R8G8_UINT = DGIFormat.r8g8UInt

@available(*, deprecated, renamed: "DGIFormat.r8g8Snorm")
public let DXGI_FORMAT_R8G8_SNORM = DGIFormat.r8g8Snorm

@available(*, deprecated, renamed: "DGIFormat.r8g8Int")
public let DXGI_FORMAT_R8G8_SINT = DGIFormat.r8g8Int

@available(*, deprecated, renamed: "DGIFormat.r16Typeless")
public let DXGI_FORMAT_R16_TYPELESS = DGIFormat.r16Typeless

@available(*, deprecated, renamed: "DGIFormat.r16Float")
public let DXGI_FORMAT_R16_FLOAT = DGIFormat.r16Float

@available(*, deprecated, renamed: "DGIFormat.d16Unorm")
public let DXGI_FORMAT_D16_UNORM = DGIFormat.d16Unorm

@available(*, deprecated, renamed: "DGIFormat.r16Unorm")
public let DXGI_FORMAT_R16_UNORM = DGIFormat.r16Unorm

@available(*, deprecated, renamed: "DGIFormat.r16UInt")
public let DXGI_FORMAT_R16_UINT = DGIFormat.r16UInt

@available(*, deprecated, renamed: "DGIFormat.r16Snorm")
public let DXGI_FORMAT_R16_SNORM = DGIFormat.r16Snorm

@available(*, deprecated, renamed: "DGIFormat.r16Int")
public let DXGI_FORMAT_R16_SINT = DGIFormat.r16Int

@available(*, deprecated, renamed: "DGIFormat.r8Typeless")
public let DXGI_FORMAT_R8_TYPELESS = DGIFormat.r8Typeless

@available(*, deprecated, renamed: "DGIFormat.r8Unorm")
public let DXGI_FORMAT_R8_UNORM = DGIFormat.r8Unorm

@available(*, deprecated, renamed: "DGIFormat.r8UInt")
public let DXGI_FORMAT_R8_UINT = DGIFormat.r8UInt

@available(*, deprecated, renamed: "DGIFormat.r8Snorm")
public let DXGI_FORMAT_R8_SNORM = DGIFormat.r8Snorm

@available(*, deprecated, renamed: "DGIFormat.r8Int")
public let DXGI_FORMAT_R8_SINT = DGIFormat.r8Int

@available(*, deprecated, renamed: "DGIFormat.a8Unorm")
public let DXGI_FORMAT_A8_UNORM = DGIFormat.a8Unorm

@available(*, deprecated, renamed: "DGIFormat.r1Unorm")
public let DXGI_FORMAT_R1_UNORM = DGIFormat.r1Unorm

@available(*, deprecated, renamed: "DGIFormat.r9g9b9e5SharedEXP")
public let DXGI_FORMAT_R9G9B9E5_SHAREDEXP = DGIFormat.r9g9b9e5SharedEXP

@available(*, deprecated, renamed: "DGIFormat.r8g8B8g8Unorm")
public let DXGI_FORMAT_R8G8_B8G8_UNORM = DGIFormat.r8g8B8g8Unorm

@available(*, deprecated, renamed: "DGIFormat.g8r8G8b8Unorm")
public let DXGI_FORMAT_G8R8_G8B8_UNORM = DGIFormat.g8r8G8b8Unorm

@available(*, deprecated, renamed: "DGIFormat.bc1Typeless")
public let DXGI_FORMAT_BC1_TYPELESS = DGIFormat.bc1Typeless

@available(*, deprecated, renamed: "DGIFormat.bc1Unorm")
public let DXGI_FORMAT_BC1_UNORM = DGIFormat.bc1Unorm

@available(*, deprecated, renamed: "DGIFormat.bc1UnormSRGB")
public let DXGI_FORMAT_BC1_UNORM_SRGB = DGIFormat.bc1UnormSRGB

@available(*, deprecated, renamed: "DGIFormat.bc2Typeless")
public let DXGI_FORMAT_BC2_TYPELESS = DGIFormat.bc2Typeless

@available(*, deprecated, renamed: "DGIFormat.bc2Unorm")
public let DXGI_FORMAT_BC2_UNORM = DGIFormat.bc2Unorm

@available(*, deprecated, renamed: "DGIFormat.bc2UnormSRGB")
public let DXGI_FORMAT_BC2_UNORM_SRGB = DGIFormat.bc2UnormSRGB

@available(*, deprecated, renamed: "DGIFormat.bc3Typeless")
public let DXGI_FORMAT_BC3_TYPELESS = DGIFormat.bc3Typeless

@available(*, deprecated, renamed: "DGIFormat.bc3Unorm")
public let DXGI_FORMAT_BC3_UNORM = DGIFormat.bc3Unorm

@available(*, deprecated, renamed: "DGIFormat.bc3UnormSRGB")
public let DXGI_FORMAT_BC3_UNORM_SRGB = DGIFormat.bc3UnormSRGB

@available(*, deprecated, renamed: "DGIFormat.bc4Typeless")
public let DXGI_FORMAT_BC4_TYPELESS = DGIFormat.bc4Typeless

@available(*, deprecated, renamed: "DGIFormat.bc4Unorm")
public let DXGI_FORMAT_BC4_UNORM = DGIFormat.bc4Unorm

@available(*, deprecated, renamed: "DGIFormat.bc4Snorm")
public let DXGI_FORMAT_BC4_SNORM = DGIFormat.bc4Snorm

@available(*, deprecated, renamed: "DGIFormat.bc5Typeless")
public let DXGI_FORMAT_BC5_TYPELESS = DGIFormat.bc5Typeless

@available(*, deprecated, renamed: "DGIFormat.bc5Unorm")
public let DXGI_FORMAT_BC5_UNORM = DGIFormat.bc5Unorm

@available(*, deprecated, renamed: "DGIFormat.bc5Snorm")
public let DXGI_FORMAT_BC5_SNORM = DGIFormat.bc5Snorm

@available(*, deprecated, renamed: "DGIFormat.b5g6r5Unorm")
public let DXGI_FORMAT_B5G6R5_UNORM = DGIFormat.b5g6r5Unorm

@available(*, deprecated, renamed: "DGIFormat.b5g5r5a1Unorm")
public let DXGI_FORMAT_B5G5R5A1_UNORM = DGIFormat.b5g5r5a1Unorm

@available(*, deprecated, renamed: "DGIFormat.b8g8r8a8Unorm")
public let DXGI_FORMAT_B8G8R8A8_UNORM = DGIFormat.b8g8r8a8Unorm

@available(*, deprecated, renamed: "DGIFormat.b8g8r8x8Unorm")
public let DXGI_FORMAT_B8G8R8X8_UNORM = DGIFormat.b8g8r8x8Unorm

@available(*, deprecated, renamed: "DGIFormat.r10g10b10XrBiasA2Unorm")
public let DXGI_FORMAT_R10G10B10_XR_BIAS_A2_UNORM = DGIFormat.r10g10b10XrBiasA2Unorm

@available(*, deprecated, renamed: "DGIFormat.b8g8r8a8Typeless")
public let DXGI_FORMAT_B8G8R8A8_TYPELESS = DGIFormat.b8g8r8a8Typeless

@available(*, deprecated, renamed: "DGIFormat.b8g8r8a8UnormSRGB")
public let DXGI_FORMAT_B8G8R8A8_UNORM_SRGB = DGIFormat.b8g8r8a8UnormSRGB

@available(*, deprecated, renamed: "DGIFormat.b8g8r8x8Typeless")
public let DXGI_FORMAT_B8G8R8X8_TYPELESS = DGIFormat.b8g8r8x8Typeless

@available(*, deprecated, renamed: "DGIFormat.b8g8r8x8UnormSRGB")
public let DXGI_FORMAT_B8G8R8X8_UNORM_SRGB = DGIFormat.b8g8r8x8UnormSRGB

@available(*, deprecated, renamed: "DGIFormat.bc6hTypeless")
public let DXGI_FORMAT_BC6H_TYPELESS = DGIFormat.bc6hTypeless

@available(*, deprecated, renamed: "DGIFormat.bc6hUf16")
public let DXGI_FORMAT_BC6H_UF16 = DGIFormat.bc6hUf16

@available(*, deprecated, renamed: "DGIFormat.bc6hSf16")
public let DXGI_FORMAT_BC6H_SF16 = DGIFormat.bc6hSf16

@available(*, deprecated, renamed: "DGIFormat.bc7Typeless")
public let DXGI_FORMAT_BC7_TYPELESS = DGIFormat.bc7Typeless

@available(*, deprecated, renamed: "DGIFormat.bc7Unorm")
public let DXGI_FORMAT_BC7_UNORM = DGIFormat.bc7Unorm

@available(*, deprecated, renamed: "DGIFormat.bc7UnormSRGB")
public let DXGI_FORMAT_BC7_UNORM_SRGB = DGIFormat.bc7UnormSRGB

@available(*, deprecated, renamed: "DGIFormat.ayuv")
public let DXGI_FORMAT_AYUV = DGIFormat.ayuv

@available(*, deprecated, renamed: "DGIFormat.y410")
public let DXGI_FORMAT_Y410 = DGIFormat.y410

@available(*, deprecated, renamed: "DGIFormat.y416")
public let DXGI_FORMAT_Y416 = DGIFormat.y416

@available(*, deprecated, renamed: "DGIFormat.nv12")
public let DXGI_FORMAT_NV12 = DGIFormat.nv12

@available(*, deprecated, renamed: "DGIFormat.p010")
public let DXGI_FORMAT_P010 = DGIFormat.p010

@available(*, deprecated, renamed: "DGIFormat.p016")
public let DXGI_FORMAT_P016 = DGIFormat.p016

@available(*, deprecated, renamed: "DGIFormat.opaque420")
public let DXGI_FORMAT_420_OPAQUE = DGIFormat.opaque420

@available(*, deprecated, renamed: "DGIFormat.yuy2")
public let DXGI_FORMAT_YUY2 = DGIFormat.yuy2

@available(*, deprecated, renamed: "DGIFormat.y210")
public let DXGI_FORMAT_Y210 = DGIFormat.y210

@available(*, deprecated, renamed: "DGIFormat.y216")
public let DXGI_FORMAT_Y216 = DGIFormat.y216

@available(*, deprecated, renamed: "DGIFormat.nv11")
public let DXGI_FORMAT_NV11 = DGIFormat.nv11

@available(*, deprecated, renamed: "DGIFormat.ai44")
public let DXGI_FORMAT_AI44 = DGIFormat.ai44

@available(*, deprecated, renamed: "DGIFormat.ia44")
public let DXGI_FORMAT_IA44 = DGIFormat.ia44

@available(*, deprecated, renamed: "DGIFormat.p8")
public let DXGI_FORMAT_P8 = DGIFormat.p8

@available(*, deprecated, renamed: "DGIFormat.a8p8")
public let DXGI_FORMAT_A8P8 = DGIFormat.a8p8

@available(*, deprecated, renamed: "DGIFormat.b4g4r4a4Unorm")
public let DXGI_FORMAT_B4G4R4A4_UNORM = DGIFormat.b4g4r4a4Unorm

@available(*, deprecated, renamed: "DGIFormat.p208")
public let DXGI_FORMAT_P208 = DGIFormat.p208

@available(*, deprecated, renamed: "DGIFormat.v208")
public let DXGI_FORMAT_V208 = DGIFormat.v208

@available(*, deprecated, renamed: "DGIFormat.v408")
public let DXGI_FORMAT_V408 = DGIFormat.v408

@available(*, deprecated, renamed: "DGIFormat.forceUInt")
public let DXGI_FORMAT_FORCE_UINT = DGIFormat.forceUInt

#endif
