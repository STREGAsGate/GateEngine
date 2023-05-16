/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public struct D3DViewport {
    public typealias RawValue = WinSDK.D3D12_VIEWPORT
    internal var rawValue: RawValue

    @inlinable @inline(__always)
    public var x: Float {
        get {rawValue.TopLeftX}
        set {rawValue.TopLeftX = newValue}
    }

    @inlinable @inline(__always)
    public var y: Float {
        get {rawValue.TopLeftY}
        set {rawValue.TopLeftY = newValue}
    }

    @inlinable @inline(__always)
    public var width: Float {
        get {rawValue.Width}
        set {rawValue.Width = newValue}
    }

    @inlinable @inline(__always)
    public var height: Float {
        get {rawValue.Height}
        set {rawValue.Height = newValue}
    }

    @inlinable @inline(__always)
    public var minDepth: Float {
        get {rawValue.MinDepth}
        set {rawValue.MinDepth = newValue}
    }

    @inlinable @inline(__always)
    public var maxDepth: Float {
        get {rawValue.MaxDepth}
        set {rawValue.MaxDepth = newValue}
    }

    @inlinable @inline(__always)
    public init(x: Float = 0, y: Float = 0, width: Float, height: Float, minDepth: Float = 0, maxDepth: Float = 1) {
        self.rawValue = RawValue(TopLeftX: x,
                                 TopLeftY: y,
                                 Width: width,
                                 Height: height,
                                 MinDepth: minDepth,
                                 MaxDepth: maxDepth)
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DViewport")
public typealias D3D12_VIEWPORT = D3DViewport

#endif
