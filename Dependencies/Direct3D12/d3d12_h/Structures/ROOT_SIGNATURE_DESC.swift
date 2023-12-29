/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the layout of a root signature version 1.0.
public struct D3DRootSignatureDescription {
    public typealias RawValue = WinSDK.D3D12_ROOT_SIGNATURE_DESC

    /// An array of D3D12_ROOT_PARAMETER structures for the slots in the root signature.    
    public var parameters: [D3DRootParameter]

    /// Pointer to one or more D3D12_STATIC_SAMPLER_DESC structures.
    public var staticSamplers: [D3DStaticSamplerDescription]

    /// A combination of D3D12_ROOT_SIGNATURE_FLAGS-typed values that are combined by using a bitwise OR operation. The resulting value specifies options for the root signature layout.
    public var flags: D3DRootSignatureFlags

    /** Describes the layout of a root signature version 1.0.
    - parameter parameters: An array of D3D12_ROOT_PARAMETER structures for the slots in the root signature.
    - parameter staticSamplers: Pointer to one or more D3D12_STATIC_SAMPLER_DESC structures.
    - parameter flags: A combination of D3D12_ROOT_SIGNATURE_FLAGS-typed values that are combined by using a bitwise OR operation. The resulting value specifies options for the root signature layout.
    */
    @inlinable @inline(__always)
    public init(parameters: [D3DRootParameter], staticSamplers: [D3DStaticSamplerDescription], flags: D3DRootSignatureFlags) {
        self.parameters = parameters
        self.staticSamplers = staticSamplers
        self.flags = flags
    }

    @inlinable @inline(__always)
    internal func withUnsafeRawValue<ResultType>(_ body: (RawValue) throws -> ResultType) rethrows -> ResultType {
        func withUnsafeParameter(at index: Int, _ pParameters: inout [D3DRootParameter.RawValue], _ body: (RawValue) throws -> ResultType) rethrows -> ResultType {
            if parameters.indices.isEmpty || index == parameters.indices.last! + 1 {
                return try pParameters.withUnsafeBufferPointer {
                    let pParameters = $0.baseAddress
                    let NumParameters = UInt32(parameters.count)
                    return try staticSamplers.map({$0.rawValue}).withUnsafeBufferPointer {
                        let pStaticSamplers = $0.baseAddress
                        let NumStaticSamplers = UInt32(staticSamplers.count)
                        let Flags = flags.rawType
                        let rawValue = RawValue(NumParameters: NumParameters,
                                                pParameters: pParameters,
                                                NumStaticSamplers: NumStaticSamplers,
                                                pStaticSamplers: pStaticSamplers,
                                                Flags: Flags)
                        return try body(rawValue)
                    }
                }
            }

            return try parameters[index].withUnsafeRawValue {
                pParameters.insert($0, at: index)
                return try withUnsafeParameter(at: index + 1, &pParameters, body)
            }
        }

        var pParameters: [D3DRootParameter.RawValue] = []
        pParameters.reserveCapacity(parameters.count)
        return try withUnsafeParameter(at: 0, &pParameters, body)
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DRootSignatureDescription")
public typealias D3D12_ROOT_SIGNATURE_DESC = D3DRootSignatureDescription

#endif
