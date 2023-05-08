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

    public var x: Float {
        get {rawValue.TopLeftX}
        set {rawValue.TopLeftX = newValue}
    }

    public var y: Float {
        get {rawValue.TopLeftY}
        set {rawValue.TopLeftY = newValue}
    }

    public var width: Float {
        get {rawValue.Width}
        set {rawValue.Width = newValue}
    }

    public var height: Float {
        get {rawValue.Height}
        set {rawValue.Height = newValue}
    }

    public var minDepth: Float {
        get {rawValue.MinDepth}
        set {rawValue.MinDepth = newValue}
    }

    public var maxDepth: Float {
        get {rawValue.MaxDepth}
        set {rawValue.MaxDepth = newValue}
    }

    public init(x: Float = 0, y: Float = 0, width: Float, height: Float, minDepth: Float = 0, maxDepth: Float = 1) {
        self.rawValue = RawValue(TopLeftX: x,
                                 TopLeftY: y,
                                 Width: width,
                                 Height: height,
                                 MinDepth: minDepth,
                                 MaxDepth: maxDepth)
    }

    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DViewport")
public typealias D3D12_VIEWPORT = D3DViewport

#endif
