/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes a vertex element in a vertex buffer in an output slot.
public struct D3DStreamOutputDeclarationEntry {
    public typealias RawValue = WinSDK.D3D12_SO_DECLARATION_ENTRY
    @usableFromInline
    internal var rawValue: RawValue

    /// Zero-based, stream number.
    @inlinable @inline(__always)
    public var streamIndex: UInt32 {
        get {
            return rawValue.Stream
        }
        set {
            rawValue.Stream = newValue
        }
    }

    /// Type of output element; possible values include: "POSITION", "NORMAL", or "TEXCOORD0". Note that if SemanticName is NULL then ComponentCount can be greater than 4 and the described entry will be a gap in the stream out where no data will be written.
    @inlinable @inline(__always)
    public var semanticName: String {
        get {
            return String(windowsUTF8: rawValue.SemanticName)
        }
        set {
            newValue.windowsUTF8.withUnsafeBufferPointer {
                rawValue.SemanticName = $0.baseAddress
            }
        }
    }

    /// Output element's zero-based index. Use, for example, if you have more than one texture coordinate stored in each vertex.
    @inlinable @inline(__always)
    public var semanticIndex: UInt32 {
        get {
            return rawValue.SemanticIndex
        }
        set {
            rawValue.SemanticIndex = newValue
        }
    }

    /// The component of the entry to begin writing out to. Valid values are 0 to 3. For example, if you only wish to output to the y and z components of a position, StartComponent is 1 and ComponentCount is 2.
    @inlinable @inline(__always)
    public var componentIndex: UInt8 {
        get {
            return rawValue.StartComponent
        }
        set {
            rawValue.StartComponent = newValue
        }
    }

    /// The number of components of the entry to write out to. Valid values are 1 to 4. For example, if you only wish to output to the y and z components of a position, StartComponent is 1 and ComponentCount is 2. Note that if SemanticName is NULL then ComponentCount can be greater than 4 and the described entry will be a gap in the stream out where no data will be written.    
    @inlinable @inline(__always)
    public var componentCount: UInt8 {
        get {
            return rawValue.ComponentCount
        }
        set {
            rawValue.ComponentCount = newValue
        }
    }

    /// The associated stream output buffer that is bound to the pipeline. The valid range for OutputSlot is 0 to 3.
    @inlinable @inline(__always)
    public var outputSlot: UInt8 {
        get {
            return rawValue.OutputSlot
        }
        set {
            rawValue.OutputSlot = newValue
        }
    }

    /** Describes a vertex element in a vertex buffer in an output slot.
    - parameter streamIndex: Zero-based, stream number.
    - parameter semanticName: Type of output element; possible values include: "POSITION", "NORMAL", or "TEXCOORD0". Note that if SemanticName is NULL then ComponentCount can be greater than 4 and the described entry will be a gap in the stream out where no data will be written.
    - parameter semanticIndex: Output element's zero-based index. Use, for example, if you have more than one texture coordinate stored in each vertex.
    - parameter componentIndex: The component of the entry to begin writing out to. Valid values are 0 to 3. For example, if you only wish to output to the y and z components of a position, StartComponent is 1 and ComponentCount is 2.
    - parameter componentCount: The number of components of the entry to write out to. Valid values are 1 to 4. For example, if you only wish to output to the y and z components of a position, StartComponent is 1 and ComponentCount is 2. Note that if SemanticName is NULL then ComponentCount can be greater than 4 and the described entry will be a gap in the stream out where no data will be written.
    - parameter outputSlot: The associated stream output buffer that is bound to the pipeline. The valid range for OutputSlot is 0 to 3.
    */
    @inlinable @inline(__always)
    public init(streamIndex: UInt32,
                semanticName: String,
                semanticIndex: UInt32,
                componentIndex: UInt8,
                componentCount: UInt8,
                outputSlot: UInt8) {
        self.rawValue = RawValue()
        self.streamIndex = streamIndex
        self.semanticName = semanticName
        self.semanticIndex = semanticIndex
        self.componentIndex = componentIndex
        self.componentCount = componentCount
        self.outputSlot = outputSlot
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DStreamOutputDeclarationEntry")
public typealias D3D12_SO_DECLARATION_ENTRY = D3DStreamOutputDeclarationEntry

#endif
