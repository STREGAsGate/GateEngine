/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the purpose of a query heap. A query heap contains an array of individual queries.
public struct D3DQueryHeapDescription {
    public typealias RawValue = WinSDK.D3D12_QUERY_HEAP_DESC
    internal var rawValue: RawValue

    /// Specifies one member of D3D12_QUERY_HEAP_TYPE.
    public var `type`: D3DQueryHeapType {
        get {
            return D3DQueryHeapType(rawValue.Type)
        }
        set {
            rawValue.Type = newValue.rawValue
        }
    }

    /// Specifies the number of queries the heap should contain.
    public var count: UInt32 {
        get {
            return rawValue.Count
        }
        set {
            rawValue.Count = newValue
        }
    }

    /// For single GPU operation, set this to zero. If there are multiple GPU nodes, set a bit to identify the node (the device's physical adapter) to which the command queue applies. Each bit in the mask corresponds to a single node. Only 1 bit must be set. Refer to Multi-adapter systems.
    public var multipleAdapterNodeMask: UInt32 {
        get {
            return self.rawValue.NodeMask
        }
        set {
            self.rawValue.NodeMask = newValue
        }
    }

    /** Describes the purpose of a query heap. A query heap contains an array of individual queries.
    - parameter type: Specifies one member of D3D12_QUERY_HEAP_TYPE.
    - parameter count: Specifies the number of queries the heap should contain.
    - parameter multipleAdapterNodeMask: For single GPU operation, set this to zero. If there are multiple GPU nodes, set a bit to identify the node (the device's physical adapter) to which the query heap applies. Each bit in the mask corresponds to a single node. Only 1 bit must be set. Refer to Multi-adapter systems.
    */
    public init(type: D3DQueryHeapType, count: UInt32, multipleAdapterNodeMask: UInt32 = 0) {
        self.rawValue = RawValue()
        self.type = type
        self.count = count
        self.multipleAdapterNodeMask = multipleAdapterNodeMask
    }

    /// Describes the purpose of a query heap. A query heap contains an array of individual queries.
    public init() {
        self.rawValue = RawValue()
    }

    internal init(_ rawValue: WinSDK.D3D12_QUERY_HEAP_DESC) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DQueryHeapDescription")
public typealias D3D12_QUERY_HEAP_DESC = D3DQueryHeapDescription

#endif
