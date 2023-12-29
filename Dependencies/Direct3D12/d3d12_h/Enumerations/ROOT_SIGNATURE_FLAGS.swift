/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies options for root signature layout.
public struct D3DRootSignatureFlags: OptionSet {
    public typealias RawType = WinSDK.D3D12_ROOT_SIGNATURE_FLAGS
    public var rawType: RawType {RawType(rawValue)}
    public typealias RawValue = WinSDK.D3D12_ROOT_SIGNATURE_FLAGS.RawValue
    public let rawValue: RawValue
    //Use an empty collection `[]` to represent none in Swift.
    ///// Indicates default behavior.
    //public static let none = D3DRootSignatureFlags(rawValue: WinSDK.D3D12_ROOT_SIGNATURE_FLAG_NONE.rawValue)

    ///	The app is opting in to using the Input Assembler (requiring an input layout that defines a set of vertex buffer bindings). Omitting this flag can result in one root argument space being saved on some hardware. Omit this flag if the Input Assembler is not required, though the optimization is minor.
    public static let allowInputAssemblerInputLayout = D3DRootSignatureFlags(rawValue: WinSDK.D3D12_ROOT_SIGNATURE_FLAG_ALLOW_INPUT_ASSEMBLER_INPUT_LAYOUT.rawValue)
    ///	Denies the vertex shader access to the root signature.
    public static let denyVertexShaderRootAccess = D3DRootSignatureFlags(rawValue: WinSDK.D3D12_ROOT_SIGNATURE_FLAG_DENY_VERTEX_SHADER_ROOT_ACCESS.rawValue)
    ///	Denies the hull shader access to the root signature.
    public static let denyHullShaderRootAccess = D3DRootSignatureFlags(rawValue: WinSDK.D3D12_ROOT_SIGNATURE_FLAG_DENY_HULL_SHADER_ROOT_ACCESS.rawValue)
    ///	Denies the domain shader access to the root signature.
    public static let denyDomainShaderRootAccess = D3DRootSignatureFlags(rawValue: WinSDK.D3D12_ROOT_SIGNATURE_FLAG_DENY_DOMAIN_SHADER_ROOT_ACCESS.rawValue)
    ///	Denies the geometry shader access to the root signature.
    public static let denyGeometryShaderRootAccess = D3DRootSignatureFlags(rawValue: WinSDK.D3D12_ROOT_SIGNATURE_FLAG_DENY_GEOMETRY_SHADER_ROOT_ACCESS.rawValue)
    ///	Denies the pixel shader access to the root signature.
    public static let denyPixelShaderRootAccess = D3DRootSignatureFlags(rawValue: WinSDK.D3D12_ROOT_SIGNATURE_FLAG_DENY_PIXEL_SHADER_ROOT_ACCESS.rawValue)
    ///	The app is opting in to using Stream Output. Omitting this flag can result in one root argument space being saved on some hardware. Omit this flag if Stream Output is not required, though the optimization is minor.
    public static let allowStreamOutput = D3DRootSignatureFlags(rawValue: WinSDK.D3D12_ROOT_SIGNATURE_FLAG_ALLOW_STREAM_OUTPUT.rawValue)
    ///	The root signature is to be used with raytracing shaders to define resource bindings sourced from shader records in shader tables. This flag cannot be combined with any other root signature flags, which are all related to the graphics pipeline. The absence of the flag means the root signature can be used with graphics or compute, where the compute version is also shared with raytracing’s global root signature.
    public static let localRootSignature = D3DRootSignatureFlags(rawValue: WinSDK.D3D12_ROOT_SIGNATURE_FLAG_LOCAL_ROOT_SIGNATURE.rawValue)

    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    public init(_ rawType: RawType) {
        self.rawValue = rawType.rawValue
    }
    public init() {
        self.rawValue = 0
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DRootSignatureFlags")
public typealias D3D12_ROOT_SIGNATURE_FLAGS = D3DRootSignatureFlags


@available(*, deprecated, message: "Use [] to represent none in Swift.")
public let D3D12_ROOT_SIGNATURE_FLAG_NONE: D3DRootSignatureFlags = []

@available(*, deprecated, renamed: "D3DRootSignatureFlags.allowInputAssemblerInputLayout")
public let D3D12_ROOT_SIGNATURE_FLAG_ALLOW_INPUT_ASSEMBLER_INPUT_LAYOUT = D3DRootSignatureFlags.allowInputAssemblerInputLayout

@available(*, deprecated, renamed: "D3DRootSignatureFlags.denyVertexShaderRootAccess")
public let D3D12_ROOT_SIGNATURE_FLAG_DENY_VERTEX_SHADER_ROOT_ACCESS = D3DRootSignatureFlags.denyVertexShaderRootAccess

@available(*, deprecated, renamed: "D3DRootSignatureFlags.denyHullShaderRootAccess")
public let D3D12_ROOT_SIGNATURE_FLAG_DENY_HULL_SHADER_ROOT_ACCESS = D3DRootSignatureFlags.denyHullShaderRootAccess

@available(*, deprecated, renamed: "D3DRootSignatureFlags.denyDomainShaderRootAccess")
public let D3D12_ROOT_SIGNATURE_FLAG_DENY_DOMAIN_SHADER_ROOT_ACCESS = D3DRootSignatureFlags.denyDomainShaderRootAccess

@available(*, deprecated, renamed: "D3DRootSignatureFlags.denyGeometryShaderRootAccess")
public let D3D12_ROOT_SIGNATURE_FLAG_DENY_GEOMETRY_SHADER_ROOT_ACCESS = D3DRootSignatureFlags.denyGeometryShaderRootAccess

@available(*, deprecated, renamed: "D3DRootSignatureFlags.denyPixelShaderRootAccess")
public let D3D12_ROOT_SIGNATURE_FLAG_DENY_PIXEL_SHADER_ROOT_ACCESS = D3DRootSignatureFlags.denyPixelShaderRootAccess

@available(*, deprecated, renamed: "D3DRootSignatureFlags.allowStreamOutput")
public let D3D12_ROOT_SIGNATURE_FLAG_ALLOW_STREAM_OUTPUT = D3DRootSignatureFlags.allowStreamOutput

@available(*, deprecated, renamed: "D3DRootSignatureFlags.localRootSignature")
public let D3D12_ROOT_SIGNATURE_FLAG_LOCAL_ROOT_SIGNATURE = D3DRootSignatureFlags.localRootSignature

#endif
