/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(CoreGraphics)

import CoreGraphics

public extension Position2 {
    @inlinable
    init(_ cgPoint: CGPoint) {
        self.init(x: Float(cgPoint.x), y: Float(cgPoint.y))
    }
    @inlinable
    var cgPoint: CGPoint {
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}

public extension Size2 {
    @inlinable
    init(_ cgSize: CGSize) {
        self.init(width: Float(cgSize.width), height: Float(cgSize.height))
    }
    @inlinable
    var cgSize: CGSize {
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
}

public extension Rect {
    @inlinable
    init(_ cgRect: CGRect) {
        let position = Position2(cgRect.origin)
        let size = Size2(cgRect.size)
        self.init(position: position, size: size)
    }
    @inlinable
    var cgRect: CGRect {
        return CGRect(origin: position.cgPoint, size: size.cgSize)
    }
}

public extension CGPoint {
    @inlinable
    init(_ point: Position2) {
        self.init(x: CGFloat(point.x), y: CGFloat(point.y))
    }
}

public extension CGSize {
    @inlinable
    init(_ size: Size2) {
        self.init(width: CGFloat(size.width), height: CGFloat(size.height))
    }
}

extension CGRect {
    @inlinable
    init(_ rect: Rect) {
        self.init(origin: CGPoint(rect.position), size: CGSize(rect.size))
    }
}

#endif
