/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public typealias D3DRect = MSRect

public struct MSPosition: Equatable {
    public var x: Int
    public var y: Int

    @inlinable
    public static var zero: MSPosition {
        return MSPosition(x: 0, y: 0)
    }

    @inlinable
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    @inlinable
    public init(_ x: Int, _ y: Int) {
        self.init(x: x, y: y)
    }
}

public struct MSSize: Equatable {
    public var width: Int
    public var height: Int

    @inlinable
    public static var zero: MSSize {
        return MSSize(width: 0, height: 0)
    }

    @inlinable
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
    @inlinable
    public init(_ width: Int, _ height: Int) {
        self.init(width: width, height: height)
    }
}

public struct MSRect: Equatable {
    public var origin: MSPosition
    public var size: MSSize

    @inlinable public var minX: Int {origin.x}
    @inlinable public var minY: Int {origin.y}
    @inlinable public var maxX: Int {origin.x + size.width}
    @inlinable public var maxY: Int {origin.y + size.width}

    @inlinable
    public var center: MSPosition {
        get {
            return MSPosition(minX + (size.width / 2), minY + (size.height / 2))
        }
        set {
            origin.x = newValue.x - (size.width / 2)
            origin.y = newValue.y - (size.height / 2)
        }
    }
    
    @inlinable
    public init(origin: MSPosition = .zero, size: MSSize) {
        self.origin = origin
        self.size = size
    }
    @inlinable
    public init(x: Int, y: Int, width: Int, height: Int) {
        let origin = MSPosition(x: x, y: y)
        let size = MSSize(width: width, height: height)
        self.init(origin: origin, size: size)
    }

    @inlinable
    public func inset(horizontal x: Int, vertical y: Int) -> MSRect {
        var copy = self
        let halfHorizontal = x / 2
        copy.origin.x += halfHorizontal //Move left
        copy.size.width -= x            //Shrink left

        let halfVertical = y / 2
        copy.origin.y += halfVertical    //Move down
        copy.size.height -= y           //Shrink up
        return copy
    }

    @inlinable
    public func contains(_ rhs: MSRect) -> Bool {
        //Separating axis. If there is space between any edges, they can't overlap.
        guard self.maxX < rhs.minX else {return false}
        guard self.maxY < rhs.minY else {return false}
        guard self.minX < rhs.maxX else {return false}
        guard self.minY < rhs.maxY else {return false}
        //Since there is no space between any edge, we have to be inside.
        return true
    }

    @inlinable
    public static func mainScreenBounds() -> MSRect {
        let screenWidth = Int(GetSystemMetrics(SM_CXSCREEN))
        let screenHeight = Int(GetSystemMetrics(SM_CYSCREEN))
        return MSRect(size: MSSize(screenWidth, screenHeight))
    }
}

public extension MSRect {
    @inlinable
    func RECT() -> WinSDK.RECT {
        let left = Int32(origin.x)
        let top = Int32(origin.y)
        let right = Int32(size.width)
        let bottom = Int32(size.height)
        return WinSDK.RECT(left: left, top: top, right: right, bottom: bottom)
    }

    @inlinable
    init(_ RECT: WinSDK.RECT) {
        let origin = MSPosition(x: Int(RECT.x), y: Int(RECT.y))
        let size = MSSize(width: Int(RECT.width), height: Int(RECT.height))
        self.init(origin: origin, size: size)
    }
}

internal extension WinSDK.RECT {
    @inlinable var x: Int32 {self.left}
    @inlinable var y: Int32 {self.top}
    @inlinable var width: Int32 {self.right - self.left}
    @inlinable var height: Int32 {self.bottom - self.top}
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DRect")
public typealias D3D12_RECT = D3DRect 

#endif
