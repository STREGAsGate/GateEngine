/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes a shader-resource view (SRV).
public struct D3DShaderResourceViewDescription {
    public typealias RawValue = WinSDK.D3D12_SHADER_RESOURCE_VIEW_DESC
    @usableFromInline
    internal var rawValue: RawValue

    /// A DXGI_FORMAT-typed value that specifies the viewing format. See remarks.
    @inlinable
    public var format: DGIFormat {
        get {
            return DGIFormat(rawValue.Format)
        }
        set {
            rawValue.Format = newValue.rawValue
        }
    }

    /// A D3D12_SRV_DIMENSION-typed value that specifies the resource type of the view. This type is the same as the resource type of the underlying resource. This member also determines which _SRV to use in the union below.
    @inlinable
    public var dimension: D3DShaderResourceViewDimension {
        get {
            return D3DShaderResourceViewDimension(rawValue.ViewDimension)
        }
        set {
            rawValue.ViewDimension = newValue.rawValue
        }
    }

    /// A value, constructed using the D3D12_ENCODE_SHADER_4_COMPONENT_MAPPING macro. The D3D12_SHADER_COMPONENT_MAPPING enumeration specifies what values from memory should be returned when the texture is accessed in a shader via this shader resource view (SRV). For example, it can route component 1 (green) from memory, or the constant 0, into component 2 (.b) of the value given to the shader.
    @inlinable
    public var componentMapping: D3DShaderComponentMap {
        get {
            return D3DShaderComponentMap(D3DShaderComponentMap.RawValue(rawValue.Shader4ComponentMapping))
        }
        set {
            rawValue.Shader4ComponentMapping = UInt32(newValue.rawValue)
        }
    }

    /// A D3D12_BUFFER_SRV structure that views the resource as a buffer.
    @inlinable
    public var buffer: D3DShaderResourceViewBuffer {
        get {
            return D3DShaderResourceViewBuffer(rawValue.Buffer)
        }
        set {
            rawValue.Buffer = newValue.rawValue
        }
    }

    /// A D3D12_TEX1D_SRV structure that views the resource as a 1D texture.
    @inlinable
    public var texture1D: D3DTexture1DShaderResourceView {
        get {
            return D3DTexture1DShaderResourceView(rawValue.Texture1D)
        }
        set {
            rawValue.Texture1D = newValue.rawValue
        }
    }

    /// A D3D12_TEX1D_ARRAY_SRV structure that views the resource as a 1D-texture array.
    @inlinable
    public var texture1DArray: D3DTexture1DArrayShaderResourceView {
        get {
            return D3DTexture1DArrayShaderResourceView(rawValue.Texture1DArray)
        }
        set {
            rawValue.Texture1DArray = newValue.rawValue
        }
    }

    /// A D3D12_TEX2D_SRV structure that views the resource as a 2D-texture.
    @inlinable
    public var texture2D: D3DTexture2DShaderResourceView {
        get {
            return D3DTexture2DShaderResourceView(rawValue.Texture2D)
        }
        set {
            rawValue.Texture2D = newValue.rawValue
        }
    }

    /// A D3D12_TEX2D_ARRAY_SRV structure that views the resource as a 2D-texture array.
    @inlinable
    public var texture2DArray: D3DTexture2DArrayShaderResourceView {
        get {
            return D3DTexture2DArrayShaderResourceView(rawValue.Texture2DArray)
        }
        set {
            rawValue.Texture2DArray = newValue.rawValue
        }
    }

    /// A D3D12_TEX2DMS_SRV structure that views the resource as a 2D-multisampled texture.
    @inlinable
    public var texture2DMultiSampled: D3DTexture2DMultiSampledShaderResourceView {
        get {
            return D3DTexture2DMultiSampledShaderResourceView(rawValue.Texture2DMS)
        }
        set {
            rawValue.Texture2DMS = newValue.rawValue
        }
    }

    /// A D3D12_TEX2DMS_ARRAY_SRV structure that views the resource as a 2D-multisampled-texture array.
    @inlinable
    public var texture2DMultiSampledArray: D3DTexture2DMultiSampledArrayShaderResourceView {
        get {
            return D3DTexture2DMultiSampledArrayShaderResourceView(rawValue.Texture2DMSArray)
        }
        set {
            rawValue.Texture2DMSArray = newValue.rawValue
        }
    }

    /// A D3D12_TEX3D_SRV structure that views the resource as a 3D texture.
    @inlinable
    public var texture3D: D3DTexture3DShaderResourceView {
        get {
            return D3DTexture3DShaderResourceView(rawValue.Texture3D)
        }
        set {
            rawValue.Texture3D = newValue.rawValue
        }
    }

    /// A D3D12_TEXCUBE_SRV structure that views the resource as a 3D-cube texture.
    @inlinable
    public var textureCube: D3DTextureCubeShaderResourceView {
        get {
            return D3DTextureCubeShaderResourceView(rawValue.TextureCube)
        }
        set {
            rawValue.TextureCube = newValue.rawValue
        }
    }

    /// A D3D12_TEXCUBE_ARRAY_SRV structure that views the resource as a 3D-cube-texture array.
    @inlinable
    public var textureCubeArray: D3DTextureCubeArrayShaderResourceView {
        get {
            return D3DTextureCubeArrayShaderResourceView(rawValue.TextureCubeArray)
        }
        set {
            rawValue.TextureCubeArray = newValue.rawValue
        }
    }

    /// A D3D12_RAYTRACING_ACCELERATION_STRUCTURE_SRV structure that views the resource as a raytracing acceleration structure.
    @inlinable
    public var raytracingAccelerationStructure: D3DRaytracingAccelerationStructureShaderResourceView {
        get {
            return D3DRaytracingAccelerationStructureShaderResourceView(rawValue.RaytracingAccelerationStructure)
        }
        set {
            rawValue.RaytracingAccelerationStructure = newValue.rawValue
        }
    }

    /** Describes a shader-resource view (SRV).
    - parameter format: A DXGI_FORMAT-typed value that specifies the viewing format. See remarks. 
    - parameter dimension: A D3D12_SRV_DIMENSION-typed value that specifies the resource type of the view. This type is the same as the resource type of the underlying resource. This member also determines which _SRV to use in the union below.
    - parameter componentMapping: A value, constructed using the D3D12_ENCODE_SHADER_4_COMPONENT_MAPPING macro. The D3D12_SHADER_COMPONENT_MAPPING enumeration specifies what values from memory should be returned when the texture is accessed in a shader via this shader resource view (SRV). For example, it can route component 1 (green) from memory, or the constant 0, into component 2 (.b) of the value given to the shader.
    - parameter buffer: A D3D12_BUFFER_SRV structure that views the resource as a buffer.
    - parameter texture1D: A D3D12_TEX1D_SRV structure that views the resource as a 1D texture.
    - parameter texture1DArray: A D3D12_TEX1D_ARRAY_SRV structure that views the resource as a 1D-texture array.
    - parameter texture2D: A D3D12_TEX2D_SRV structure that views the resource as a 2D-texture.
    - parameter texture2DArray: A D3D12_TEX2D_ARRAY_SRV structure that views the resource as a 2D-texture array.
    - parameter texture2DMultiSampled: A D3D12_TEX2DMS_SRV structure that views the resource as a 2D-multisampled texture.
    - parameter texture2DMultiSampledArray: A D3D12_TEX2DMS_ARRAY_SRV structure that views the resource as a 2D-multisampled-texture array.
    - parameter texture3D: A D3D12_TEX3D_SRV structure that views the resource as a 3D texture.
    - parameter textureCube: A D3D12_TEXCUBE_SRV structure that views the resource as a 3D-cube texture.
    - parameter textureCubeArray: A D3D12_TEXCUBE_ARRAY_SRV structure that views the resource as a 3D-cube-texture array.
    - parameter raytracingAccelerationStructure: A D3D12_RAYTRACING_ACCELERATION_STRUCTURE_SRV structure that views the resource as a raytracing acceleration structure.
    */
    @inlinable
    public init(format: DGIFormat,
                dimension: D3DShaderResourceViewDimension,
                componentMapping: D3DShaderComponentMap = .default,
                buffer: D3DShaderResourceViewBuffer,
                texture1D: D3DTexture1DShaderResourceView,
                texture1DArray: D3DTexture1DArrayShaderResourceView,
                texture2D: D3DTexture2DShaderResourceView,
                texture2DArray: D3DTexture2DArrayShaderResourceView,
                texture2DMultiSampled: D3DTexture2DMultiSampledShaderResourceView,
                texture2DMultiSampledArray: D3DTexture2DMultiSampledArrayShaderResourceView,
                texture3D: D3DTexture3DShaderResourceView,
                textureCube: D3DTextureCubeShaderResourceView,
                textureCubeArray: D3DTextureCubeArrayShaderResourceView,
                raytracingAccelerationStructure: D3DRaytracingAccelerationStructureShaderResourceView) {
        self.rawValue = RawValue()
        self.format = format
        self.dimension = dimension
        self.componentMapping = componentMapping
        self.buffer = buffer
        self.texture1D = texture1D
        self.texture1DArray = texture1DArray
        self.texture2D = texture2D
        self.texture2DArray = texture2DArray
        self.texture2DMultiSampled = texture2DMultiSampled
        self.texture2DMultiSampledArray = texture2DMultiSampledArray
        self.texture3D = texture3D
        self.textureCube = textureCube
        self.textureCubeArray = textureCubeArray
        self.raytracingAccelerationStructure = raytracingAccelerationStructure
    }

    @inlinable
    public init() {
        self.rawValue = RawValue()
    }

    @inlinable
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DShaderResourceViewDescription")
public typealias D3D12_SHADER_RESOURCE_VIEW_DESC = D3DShaderResourceViewDescription

#endif
