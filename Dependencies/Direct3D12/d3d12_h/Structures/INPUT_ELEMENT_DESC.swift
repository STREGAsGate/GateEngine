/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes a single element for the input-assembler stage of the graphics pipeline.
public struct D3DInputElementDescription {
    public typealias RawValue = WinSDK.D3D12_INPUT_ELEMENT_DESC

    /// The HLSL semantic associated with this element in a shader input-signature.
    public var semanticName: String

    /// The semantic index for the element. A semantic index modifies a semantic, with an integer index number. A semantic index is only needed in a case where there is more than one element with the same semantic. For example, a 4x4 matrix would have four components each with the semantic name matrix, however each of the four component would have different semantic indices (0, 1, 2, and 3).
    public var semanticIndex: UInt32

    /// A DXGI_FORMAT-typed value that specifies the format of the element data.
    public var format: DGIFormat

    /// An integer value that identifies the input-assembler. For more info, see Input Slots. Valid values are between 0 and 15.
    public var inputSlot: UInt32

    /// Optional. Offset, in bytes, to this element from the start of the vertex. Use D3D12_APPEND_ALIGNED_ELEMENT (0xffffffff) for convenience to define the current element directly after the previous one, including any packing if necessary.
    public var alignedByteOffset: UInt32

    /// A value that identifies the input data class for a single input slot.
    public var inputSlotClassification: D3DInputClassification

    /// The number of instances to draw using the same per-instance data before advancing in the buffer by one element. This value must be 0 for an element that contains per-vertex data (the slot class is set to the D3D12_INPUT_PER_VERTEX_DATA member of D3D12_INPUT_CLASSIFICATION).
    public var instanceDataStepRate: UInt32

    /** Describes a single element for the input-assembler stage of the graphics pipeline.
    - parameter semanticName: The HLSL semantic associated with this element in a shader input-signature.
    - parameter semanticIndex: The semantic index for the element. A semantic index modifies a semantic, with an integer index number. A semantic index is only needed in a case where there is more than one element with the same semantic. For example, a 4x4 matrix would have four components each with the semantic name matrix, however each of the four component would have different semantic indices (0, 1, 2, and 3).
    - parameter format: A DXGI_FORMAT-typed value that specifies the format of the element data.
    - parameter inputSlot: An integer value that identifies the input-assembler. For more info, see Input Slots. Valid values are between 0 and 15.
    - parameter alignedByteOffset: Optional. Offset, in bytes, to this element from the start of the vertex. Use D3D12_APPEND_ALIGNED_ELEMENT (0xffffffff) for convenience to define the current element directly after the previous one, including any packing if necessary.
    - parameter inputSlotClassification: A value that identifies the input data class for a single input slot.
    - parameter instanceDataStepRate: The number of instances to draw using the same per-instance data before advancing in the buffer by one element. This value must be 0 for an element that contains per-vertex data (the slot class is set to the D3D12_INPUT_PER_VERTEX_DATA member of D3D12_INPUT_CLASSIFICATION).
    */
    @inlinable @inline(__always)
    public init(semanticName: String,
                semanticIndex: UInt32 = 0,
                format: DGIFormat,
                inputSlot: UInt32,
                alignedByteOffset: UInt32,
                inputSlotClassification: D3DInputClassification,
                instanceDataStepRate: UInt32 = 0) {
        self.semanticName = semanticName
        self.semanticIndex = semanticIndex
        self.format = format
        self.inputSlot = inputSlot
        self.alignedByteOffset = alignedByteOffset
        self.inputSlotClassification = inputSlotClassification
        self.instanceDataStepRate = instanceDataStepRate
    }

    @inlinable @inline(__always)
    internal func withUnsafeRawValue<ResultType>(_ body: (RawValue) throws -> ResultType) rethrows -> ResultType {
        return try semanticName.windowsUTF8.withUnsafeBufferPointer {SemanticName in
            let SemanticName = SemanticName.baseAddress!
            let SemanticIndex = semanticIndex
            let Format = format.rawValue
            let InputSlot = inputSlot
            let AlignedByteOffset = alignedByteOffset
            let InputSlotClass = inputSlotClassification.rawValue
            let InstanceDataStepRate = instanceDataStepRate
            let rawValue = RawValue(SemanticName: SemanticName,
                                    SemanticIndex: SemanticIndex,
                                    Format: Format,
                                    InputSlot: InputSlot,
                                    AlignedByteOffset: AlignedByteOffset,
                                    InputSlotClass: InputSlotClass,
                                    InstanceDataStepRate: InstanceDataStepRate)
            return try body(rawValue)
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DInputElementDescription")
public typealias D3D12_INPUT_ELEMENT_DESC = D3DInputElementDescription

#endif
