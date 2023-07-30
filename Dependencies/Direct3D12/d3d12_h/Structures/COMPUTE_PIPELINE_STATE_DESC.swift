/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes a compute pipeline state object.
public struct D3DComputePipelineStateDescription {
    public typealias RawValue = WinSDK.D3D12_COMPUTE_PIPELINE_STATE_DESC

    /// A pointer to the ID3D12RootSignature object.
    public var rootSignature: D3DRootSignature?

    /// A D3D12_SHADER_BYTECODE structure that describes the compute shader.
    public var shaderBytecode: D3DShaderBytecode

    /// For single GPU operation, set this to zero. If there are multiple GPU nodes, set a bit to identify the node (the device's physical adapter) to which the command queue applies. Each bit in the mask corresponds to a single node. Only 1 bit must be set. Refer to Multi-adapter systems.
    public var multipleAdapterNodeMask: UInt32

    /// A cached pipeline state object, as a D3D12_CACHED_PIPELINE_STATE structure. pCachedBlob and CachedBlobSizeInBytes may be set to NULL and 0 respectively.
    public var cachedPipelineSate: D3DCachedPipelineState

    /// A D3D12_PIPELINE_STATE_FLAGS enumeration constant such as for "tool debug".
    public var flags: D3DPipelineStateFlags

    /** Describes a compute pipeline state object.
    - parameter rootSignature: A pointer to the ID3D12RootSignature object.
    - parameter shaderBytecode: A D3D12_SHADER_BYTECODE structure that describes the compute shader.
    - parameter multipleAdapterNodeMask: For single GPU operation, set this to zero. If there are multiple GPU nodes, set bits to identify the nodes (the device's physical adapters) for which the compute pipeline state is to apply. Each bit in the mask corresponds to a single node. Refer to Multi-adapter systems.
    - parameter cachedPipelineSate: A cached pipeline state object, as a D3D12_CACHED_PIPELINE_STATE structure. pCachedBlob and CachedBlobSizeInBytes may be set to NULL and 0 respectively.
    - parameter flags: A D3D12_PIPELINE_STATE_FLAGS enumeration constant such as for "tool debug".
    */
    @inlinable @inline(__always)
    public init(rootSignature: D3DRootSignature, shaderBytecode: D3DShaderBytecode, multipleAdapterNodeMask: UInt32 = 0, cachedPipelineSate: D3DCachedPipelineState = D3DCachedPipelineState(), flags: D3DPipelineStateFlags = []) {
        self.rootSignature = rootSignature
        self.shaderBytecode = shaderBytecode
        self.multipleAdapterNodeMask = multipleAdapterNodeMask
        self.cachedPipelineSate = cachedPipelineSate
        self.flags = flags
    }

    @inlinable @inline(__always)
    internal func withUnsafeRawValue<ResultType>(_ body: (RawValue) throws -> ResultType) rethrows -> ResultType {
        let pRootSignature = rootSignature?.performFatally(as: D3DRootSignature.RawValue.self){$0}
        return try shaderBytecode.withUnsafeRawValue {CS in
            let NodeMask = multipleAdapterNodeMask
            let CachedPSO = cachedPipelineSate.rawValue
            let Flags = flags.rawType
            let rawValue = RawValue(pRootSignature: pRootSignature, CS: CS, NodeMask: NodeMask, CachedPSO: CachedPSO, Flags: Flags)
            return try body(rawValue)
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DComputePipelineStateDescription")
public typealias D3D12_COMPUTE_PIPELINE_STATE_DESC = D3DComputePipelineStateDescription 

#endif
