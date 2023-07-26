/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the root signature 1.0 layout of a descriptor table as a collection of descriptor ranges that are all relative to a single base descriptor handle.
public struct D3DRootDescriptorTable {
    public typealias RawValue = WinSDK.D3D12_ROOT_DESCRIPTOR_TABLE

    /// An array of D3D12_DESCRIPTOR_RANGE structures that describe the descriptor ranges.
    public var descriptorRanges: [D3DDescriptorRange]

    /** Describes the root signature 1.0 layout of a descriptor table as a collection of descriptor ranges that are all relative to a single base descriptor handle.
    - parameter descriptorRanges: An array of D3D12_DESCRIPTOR_RANGE structures that describe the descriptor ranges.
    */
    @inlinable @inline(__always)
    public init(descriptorRanges: [D3DDescriptorRange]) {
        self.descriptorRanges = descriptorRanges
    }

    @inlinable @inline(__always)
    internal func withUnsafeRawValue<ResultType>(_ body: (RawValue) throws -> ResultType) rethrows -> ResultType {
        @inline(__always)
        func withUnsafeParameter(at index: Int, _ pDescriptorRanges: inout [D3DDescriptorRange.RawValue], _ body: (RawValue) throws -> ResultType) rethrows -> ResultType {
            if descriptorRanges.isEmpty || index == descriptorRanges.count {
                return try pDescriptorRanges.withUnsafeBufferPointer {pDescriptorRanges in
                    let NumDescriptorRanges = UInt32(descriptorRanges.count)
                    let pDescriptorRanges = pDescriptorRanges.baseAddress!
                    let rawValue = RawValue(NumDescriptorRanges: NumDescriptorRanges, pDescriptorRanges: pDescriptorRanges)
                    return try body(rawValue)
                }
            }

            return try descriptorRanges[index].withUnsafeRawValue {
                pDescriptorRanges.append($0)
                return try withUnsafeParameter(at: index + 1, &pDescriptorRanges, body)
            }
        }

        var pDescriptorRanges: [D3DDescriptorRange.RawValue] = []
        pDescriptorRanges.reserveCapacity(descriptorRanges.count)
        return try withUnsafeParameter(at: 0, &pDescriptorRanges, body)
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DRootDescriptorTable")
public typealias D3D12_ROOT_DESCRIPTOR_TABLE = D3DRootDescriptorTable

#endif
