/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(WinSDK)
import WinSDK

public extension Rect {
    func RECT() -> WinSDK.RECT {
        let left: Int32 = Int32(position.x)
        let top: Int32 = Int32(position.y)
        let right: Int32 = Int32(position.x + size.width)
        let bottom: Int32 = Int32(position.y + size.height)
        return WinSDK.RECT(left: left, top: top, right: right, bottom: bottom)
    }

    init(_ RECT: WinSDK.RECT) {
        let position: Position2 = Position2(x: Float(RECT.left), y: Float(RECT.top))
        let size: Size2 = Size2(width: Float(RECT.width), height: Float(RECT.height))
        self.init(position: position, size: size)
    }
}


public extension WinSDK.RECT {
    @_transparent
    var x: Int32 {self.left}
    @_transparent 
    var y: Int32 {self.top}
    @_transparent 
    var width: Int32 {self.right - self.left}
    @_transparent 
    var height: Int32 {self.bottom - self.top}
}

#endif
