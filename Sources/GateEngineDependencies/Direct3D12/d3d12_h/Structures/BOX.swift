/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public struct D3DBox {
    public typealias RawValue = WinSDK.D3D12_BOX
    internal var rawValue: RawValue

    /// The x position of the left hand side of the box.
    public var left: UInt32 {
        get {
            return rawValue.left
        }
        set {
            rawValue.left = newValue
        }
    }

    /// The y position of the top of the box.
    public var top: UInt32 {
        get {
            return rawValue.top
        }
        set {
            rawValue.top = newValue
        }
    }

    /// The z position of the front of the box.
    public var front: UInt32 {
        get {
            return rawValue.front
        }
        set {
            rawValue.front = newValue
        }
    }

    /// The x position of the right hand side of the box, plus 1. This means that right - left equals the width of the box.
    public var right: UInt32 {
        get {
            return rawValue.right
        }
        set {
            rawValue.right = newValue
        }
    }

    /// The y position of the bottom of the box, plus 1. This means that top - bottom equals the height of the box.
    public var bottom: UInt32 {
        get {
            return rawValue.bottom
        }
        set {
            rawValue.bottom = newValue
        }
    }

    /// The z position of the back of the box, plus 1. This means that front - back equals the depth of the box.
    public var back: UInt32 {
        get {
            return rawValue.back
        }
        set {
            rawValue.back = newValue
        }
    }
    
    /** Describes a 3D box.
    - parameter left: The x position of the left hand side of the box.
    - parameter top: The y position of the top of the box.
    - parameter front: The z position of the front of the box.
    - parameter right: The x position of the right hand side of the box, plus 1. This means that right - left equals the width of the box.
    - parameter bottom: The y position of the bottom of the box, plus 1. This means that top - bottom equals the height of the box.
    - parameter back: The z position of the back of the box, plus 1. This means that front - back equals the depth of the box.
    */
    public init(left: UInt32 = 0, top: UInt32 = 0, front: UInt32 = 0, right: UInt32 = 0, bottom: UInt32 = 0, back: UInt32 = 0) {
        self.rawValue = RawValue(left: left, top: top, front: front, right: right, bottom: bottom, back: back)
    }

    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DBox")
public typealias D3D12_BOX = D3DBox 

#endif
