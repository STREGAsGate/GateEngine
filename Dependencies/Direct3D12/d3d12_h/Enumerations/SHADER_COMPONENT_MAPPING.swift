/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Implements the D3D12_ENCODE_SHADER_4_COMPONENT_MAPPING, D3D12_DECODE_SHADER_4_COMPONENT_MAPPING, and D3D12_DEFAULT_SHADER_4_COMPONENT_MAPPING macros.
public struct D3DShaderComponentMap {
    public typealias RawValue = Int32
    public let rawValue: RawValue

    public func component(mappedTo mapping: D3DShaderComponentMapping) -> D3DShaderComponentMapping {
        return D3DShaderComponentMapping(D3DShaderComponentMapping.RawValue(D3DShaderComponentMap.decodeComponent(mappedTo: mapping, from: rawValue)))
    }

    public init(mapRedTo src0: D3DShaderComponentMapping, mapGreenTo src1: D3DShaderComponentMapping, mapBlueTo src2: D3DShaderComponentMapping, mapAlphaTo src3: D3DShaderComponentMapping) {
        self.rawValue = Self.encode(src0.rawValue.rawValue, src1.rawValue.rawValue, src2.rawValue.rawValue, src3.rawValue.rawValue)
    }

    public init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public static let `default` = D3DShaderComponentMap(mapRedTo: .red, mapGreenTo: .green, mapBlueTo: .blue, mapAlphaTo: .alpha)

    @inlinable @inline(__always)
    public static func encode(_ src0: RawValue, _ src1: RawValue, _ src2: RawValue, _ src3: RawValue) -> RawValue {
        let D3D12_SHADER_COMPONENT_MAPPING_MASK: RawValue = 0x7
        let D3D12_SHADER_COMPONENT_MAPPING_SHIFT: RawValue = 3
        return ((((src0)&D3D12_SHADER_COMPONENT_MAPPING_MASK) | (((src1)&D3D12_SHADER_COMPONENT_MAPPING_MASK)<<D3D12_SHADER_COMPONENT_MAPPING_SHIFT) | (((src2)&D3D12_SHADER_COMPONENT_MAPPING_MASK)<<(D3D12_SHADER_COMPONENT_MAPPING_SHIFT*2)) | (((src3)&D3D12_SHADER_COMPONENT_MAPPING_MASK)<<(D3D12_SHADER_COMPONENT_MAPPING_SHIFT*3)) | (1<<(D3D12_SHADER_COMPONENT_MAPPING_SHIFT*4))))
    }

    @inlinable @inline(__always)
    public static func decodeComponent(mappedTo mapping: D3DShaderComponentMapping, from rawValue: RawValue) -> RawValue {
        let D3D12_SHADER_COMPONENT_MAPPING_MASK: RawValue = 0x7
        let D3D12_SHADER_COMPONENT_MAPPING_SHIFT: RawValue = 3
        let ComponentToExtract: RawValue = mapping.rawValue.rawValue/// it'll end up as 0, 1, 2, or 3
        assert(ComponentToExtract < 4, "mappedTo must be red, green, blue, or alpha")
        return ((RawValue)(mapping.rawValue.rawValue >> (D3D12_SHADER_COMPONENT_MAPPING_SHIFT*ComponentToExtract) & D3D12_SHADER_COMPONENT_MAPPING_MASK))
    }
}

/// Specifies how memory gets routed by a shader resource view (SRV).
public enum D3DShaderComponentMapping {
    public typealias RawValue = WinSDK.D3D12_SHADER_COMPONENT_MAPPING

    ///	Indicates return component 0 (red).
    case red
    ///	Indicates return component 1 (green).
    case green
    ///	Indicates return component 2 (blue).
    case blue
    ///	Indicates return component 3 (alpha).
    case alpha
    ///	Indicates forcing the resulting value to 0.
    case forceZero
    ///	Indicates forcing the resulting value 1. The value of forcing 1 is either 0x1 or 1.0f depending on the format type for that component in the source format.
    case forceOne

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable @inline(__always)
    public var rawValue: RawValue {
        switch self {
        case .red:
            return WinSDK.D3D12_SHADER_COMPONENT_MAPPING_FROM_MEMORY_COMPONENT_0
        case .green:
            return WinSDK.D3D12_SHADER_COMPONENT_MAPPING_FROM_MEMORY_COMPONENT_1
        case .blue:
            return WinSDK.D3D12_SHADER_COMPONENT_MAPPING_FROM_MEMORY_COMPONENT_2
        case .alpha:
            return WinSDK.D3D12_SHADER_COMPONENT_MAPPING_FROM_MEMORY_COMPONENT_3
        case .forceZero:
            return WinSDK.D3D12_SHADER_COMPONENT_MAPPING_FORCE_VALUE_0
        case .forceOne:
            return WinSDK.D3D12_SHADER_COMPONENT_MAPPING_FORCE_VALUE_1
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable @inline(__always)
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_SHADER_COMPONENT_MAPPING_FROM_MEMORY_COMPONENT_0:
            self = .red
        case WinSDK.D3D12_SHADER_COMPONENT_MAPPING_FROM_MEMORY_COMPONENT_1:
            self = .green
        case WinSDK.D3D12_SHADER_COMPONENT_MAPPING_FROM_MEMORY_COMPONENT_2:
            self = .blue
        case WinSDK.D3D12_SHADER_COMPONENT_MAPPING_FROM_MEMORY_COMPONENT_3:
            self = .alpha
        case WinSDK.D3D12_SHADER_COMPONENT_MAPPING_FORCE_VALUE_0:
            self = .forceZero
        case WinSDK.D3D12_SHADER_COMPONENT_MAPPING_FORCE_VALUE_1:
            self = .forceOne
        default:
            self = ._unimplemented(rawValue)
        }
    }
}
  

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DShaderComponentMapping.D3DShaderComponentMapping")
public typealias D3D12_SHADER_COMPONENT_MAPPING = D3DShaderComponentMapping


@available(*, deprecated, renamed: "D3DShaderComponentMapping.red")
public let D3D12_SHADER_COMPONENT_MAPPING_FROM_MEMORY_COMPONENT_0 = D3DShaderComponentMapping.red

@available(*, deprecated, renamed: "D3DShaderComponentMapping.green")
public let D3D12_SHADER_COMPONENT_MAPPING_FROM_MEMORY_COMPONENT_1 = D3DShaderComponentMapping.green
    
@available(*, deprecated, renamed: "D3DShaderComponentMapping.blue")
public let D3D12_SHADER_COMPONENT_MAPPING_FROM_MEMORY_COMPONENT_2 = D3DShaderComponentMapping.blue
    
@available(*, deprecated, renamed: "D3DShaderComponentMapping.alpha")
public let D3D12_SHADER_COMPONENT_MAPPING_FROM_MEMORY_COMPONENT_3 = D3DShaderComponentMapping.alpha
    
@available(*, deprecated, renamed: "D3DShaderComponentMapping.forceZero")
public let D3D12_SHADER_COMPONENT_MAPPING_FORCE_VALUE_0 = D3DShaderComponentMapping.forceZero
    
@available(*, deprecated, renamed: "D3DShaderComponentMapping.forceOne")
public let D3D12_SHADER_COMPONENT_MAPPING_FORCE_VALUE_1 = D3DShaderComponentMapping.forceOne

#endif
