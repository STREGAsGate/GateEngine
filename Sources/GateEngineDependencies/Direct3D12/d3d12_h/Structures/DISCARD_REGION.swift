/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes details for the discard-resource operation.
public struct D3DDiscardRegion {
    public typealias RawValue = WinSDK.D3D12_DISCARD_REGION
    internal var rawValue: RawValue

    /// An array of D3D12_RECT structures for the rectangles in the resource to discard. If NULL, DiscardResource discards the entire resource.
    @inlinable @inline(__always)
    public var regions: [D3DRect] {
        get {
            return withUnsafePointer(to: rawValue.pRects) {p in
                let buffer = UnsafeBufferPointer(start: p, count: Int(rawValue.NumRects))
                return buffer.map({D3DRect($0!.pointee)})
            }
        }
        set {
            _regions = newValue.map({$0.RECT()})
            _regions.withUnsafeBufferPointer{p in
                rawValue.pRects = p.baseAddress!
            }
            rawValue.NumRects = UInt32(newValue.count)
        }
    }
    @usableFromInline
    private var _regions: [WinSDK.RECT]! = nil

    /// Index of the first subresource in the resource to discard.
    @inlinable @inline(__always)
    public var subresourceIndex: UInt32 {
        get {
            return rawValue.FirstSubresource
        }
        set {
            rawValue.FirstSubresource = newValue
        }
    }

    /// The number of subresources in the resource to discard.
    @inlinable @inline(__always)
    public var subresourceCount: UInt32 {
        get {
            return rawValue.NumSubresources
        }
        set {
            rawValue.NumSubresources = newValue
        }
    }

    /** Describes details for the discard-resource operation.
    - parameter regions: An array of D3D12_RECT structures for the rectangles in the resource to discard. If NULL, DiscardResource discards the entire resource.
    - parameter subresourceIndex: Index of the first subresource in the resource to discard.
    = parameter subresourceCount: The number of subresources in the resource to discard.
    */
    @inlinable @inline(__always)
    public init(regions: [D3DRect], subresourceIndex: UInt32, subresourceCount: UInt32) {
        self.rawValue = RawValue()
        self.regions = regions
        self.subresourceIndex = subresourceIndex
        self.subresourceCount = subresourceCount
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DDiscardRegion")
public typealias D3D12_DISCARD_REGION = D3DDiscardRegion

#endif
