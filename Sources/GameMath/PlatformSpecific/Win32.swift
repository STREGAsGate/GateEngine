/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(WinSDK)
import WinSDK

public extension Rect {
    @inlinable
    func RECT() -> WinSDK.RECT {
        let left: Int32 = Int32(position.x)
        let top: Int32 = Int32(position.y)
        let right: Int32 = Int32(position.x + size.width)
        let bottom: Int32 = Int32(position.y + size.height)
        return WinSDK.RECT(left: left, top: top, right: right, bottom: bottom)
    }

    @inlinable
    init(_ RECT: WinSDK.RECT) {
        let position: Position2 = Position2(x: Float(RECT.left), y: Float(RECT.top))
        let size: Size2 = Size2(width: Float(RECT.width), height: Float(RECT.height))
        self.init(position: position, size: size)
    }
}


public extension WinSDK.RECT {
    @inlinable
    var x: Int32 {self.left}
    @inlinable 
    var y: Int32 {self.top}
    @inlinable 
    var width: Int32 {self.right - self.left}
    @inlinable 
    var height: Int32 {self.bottom - self.top}
}

#endif
