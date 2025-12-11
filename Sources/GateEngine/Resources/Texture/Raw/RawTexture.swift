/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
 
public struct RawTexture: Sendable {
    public var imageSize: Size2i
    public var imageData: Data
    
    public init(imageSize: Size2i, imageData: Data) {
        self.imageSize = imageSize
        self.imageData = imageData
    }
}

public extension RawTexture {
    @inlinable
    nonmutating func color(at pixelCoordinate: Position2i) -> Color {
        return self[index(for: pixelCoordinate)]
    }
    
    @inlinable
    mutating func setColor(_ color: Color, at pixelCoordinate: Position2i) {
        self[index(for: pixelCoordinate)] = color
    }
    
    @inlinable
    subscript(pixelCoordinate: Position2i) -> Color {
        nonmutating get {
            return self.color(at: pixelCoordinate)
        }
        mutating set {
            self.setColor(newValue, at: pixelCoordinate)
        }
    }
}

public extension RawTexture {
    /// The UV position for the pixel
    @inlinable
    func textureCoordinate(at pixelCoordinate: Position2i) -> Position2f {
        return Position2f(
            x: Float(pixelCoordinate.x) / Float(imageSize.width),
            y: Float(pixelCoordinate.y) / Float(imageSize.height)
        )
    }
    
    @inlinable
    func pixelCoordinate(at textureCoordinate: Position2f) -> Position2i {
        return Position2i(
            x: Int(Float(imageSize.width) * textureCoordinate.x),
            y: Int(Float(imageSize.height) * textureCoordinate.y)
        )
    }
    
    @inlinable
    func index(for pixelCoordinate: Position2i) -> Int {
        return ((self.imageSize.width * pixelCoordinate.y) + pixelCoordinate.x)
    }
}

extension RawTexture: RandomAccessCollection, MutableCollection {
    public typealias Element = Color
    
    @inlinable
    public var startIndex: Int {
        nonmutating get {
            return 0
        }
    }
    
    @inlinable
    public var endIndex: Int {
        nonmutating get {
            return self.imageSize.width * self.imageSize.height
        }
    }
    
    @inlinable
    public subscript(index: Int) -> Color {
        nonmutating get {
            return self.color(at: index)
        }
        mutating set {
            self.setColor(newValue, at: index)
        }
    }
}

internal extension RawTexture {
    @safe // <- Bounds is checked
    @inlinable
    nonmutating func color(at index: Int) -> Color {
        let offset = index * 4
        precondition(self.imageData.indices.contains(offset), "Index out of range.")
        return self.imageData.withUnsafeBytes { data in
            let rgba8 = data.baseAddress!.advanced(by: offset).load(as: (r: UInt8, g: UInt8, b: UInt8, a: UInt8).self)
            return Color(eightBitRed: rgba8.r, green: rgba8.g, blue: rgba8.b, alpha: rgba8.a)
        }
    }
    
    @safe // <- Bounds is checked
    @inlinable
    mutating func setColor(_ color: Color, at index: Int) {
        let offset = index * 4
        precondition(self.imageData.indices.contains(offset), "Index out of range.")
        self.imageData.withUnsafeMutableBytes { data in
            let rgba8 = (r: color.eightBitRed, g: color.eightBitGreen, b: color.eightBitBlue, a: color.eightBitAlpha)
            withUnsafePointer(to: rgba8) { color in
                data.baseAddress!.advanced(by: offset).copyMemory(from: color, byteCount: 4)
            }
        }
    }
}
