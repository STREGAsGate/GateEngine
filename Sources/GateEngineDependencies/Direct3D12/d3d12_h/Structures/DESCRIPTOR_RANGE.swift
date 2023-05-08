/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes a descriptor range.
public struct D3DDescriptorRange {
    public typealias RawValue = WinSDK.D3D12_DESCRIPTOR_RANGE

    /// A D3D12_DESCRIPTOR_RANGE_TYPE-typed value that specifies the type of descriptor range.
    public var `type`: D3DDescriptorRangeType

    /// The number of descriptors in the range. Use -1 or UINT_MAX to specify an unbounded size. If a given descriptor range is unbounded, then it must either be the last range in the table definition, or else the following range in the table definition must have a value for OffsetInDescriptorsFromTableStart that is not D3D12_DESCRIPTOR_RANGE_OFFSET_APPEND.
    public var descriptorCount: UInt32

    /// The base shader register in the range. For example, for shader-resource views (SRVs), 3 maps to ": register(t3);" in HLSL.
    public var baseShaderRegister: UInt32

    /// The register space. Can typically be 0, but allows multiple descriptor arrays of unknown size to not appear to overlap. For example, for SRVs, by extending the example in the BaseShaderRegister member description, 5 maps to ": register(t3,space5);" in HLSL.
    public var registerSpace: UInt32

    /// The offset in descriptors, from the start of the descriptor table which was set as the root argument value for this parameter slot. This value can be D3D12_DESCRIPTOR_RANGE_OFFSET_APPEND, which indicates this range should immediately follow the preceding range.
    public var offsetInDescriptorsFromTableStart: UInt32

    /** Describes a descriptor range.
    - parameter type: A D3D12_DESCRIPTOR_RANGE_TYPE-typed value that specifies the type of descriptor range.
    - parameter descriptorCount: The number of descriptors in the range. Use -1 or UINT_MAX to specify an unbounded size. If a given descriptor range is unbounded, then it must either be the last range in the table definition, or else the following range in the table definition must have a value for OffsetInDescriptorsFromTableStart that is not D3D12_DESCRIPTOR_RANGE_OFFSET_APPEND.
    - parameter baseShaderRegister: The base shader register in the range. For example, for shader-resource views (SRVs), 3 maps to ": register(t3);" in HLSL.
    - parameter offsetInDescriptorsFromTableStart: The offset in descriptors, from the start of the descriptor table which was set as the root argument value for this parameter slot. This value can be D3D12_DESCRIPTOR_RANGE_OFFSET_APPEND, which indicates this range should immediately follow the preceding range.
    */
    public init(type: D3DDescriptorRangeType,
                descriptorCount: UInt32,
                baseShaderRegister: UInt32,
                registerSpace: UInt32 = 0,
                offsetInDescriptorsFromTableStart: UInt32 = D3D12_DESCRIPTOR_RANGE_OFFSET_APPEND) {
        self.type = type
        self.descriptorCount = descriptorCount
        self.baseShaderRegister = baseShaderRegister
        self.registerSpace = registerSpace
        self.offsetInDescriptorsFromTableStart = offsetInDescriptorsFromTableStart
    }

    internal func withUnsafeRawValue<ResultType>(_ body: (RawValue) throws -> ResultType) rethrows -> ResultType {
        let RangeType = type.rawValue
        let NumDescriptors = descriptorCount
        let BaseShaderRegister = baseShaderRegister
        let RegisterSpace = registerSpace
        let OffsetInDescriptorsFromTableStart = offsetInDescriptorsFromTableStart
        let rawValue = RawValue(RangeType: RangeType,
                                NumDescriptors: NumDescriptors,
                                BaseShaderRegister: BaseShaderRegister,
                                RegisterSpace: RegisterSpace,
                                OffsetInDescriptorsFromTableStart: OffsetInDescriptorsFromTableStart)
        return try body(rawValue)
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DDescriptorRange")
public typealias D3D12_DESCRIPTOR_RANGE = D3DDescriptorRange

#endif
