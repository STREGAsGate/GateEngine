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
        return self[index(at: pixelCoordinate)]
    }
    
    @inlinable
    mutating func setColor(_ color: Color, at pixelCoordinate: Position2i) {
        self[index(at: pixelCoordinate)] = color
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
    func textureCoordinate(at index: Index) -> Position2f {
        return self.textureCoordinate(at: self.pixelCoordinate(at: index))
    }
    
    @inlinable
    func pixelCoordinate(at textureCoordinate: Position2f) -> Position2i {
        return Position2i(
            x: Int(Float(imageSize.width) * textureCoordinate.x),
            y: Int(Float(imageSize.height) * textureCoordinate.y)
        )
    }
    
    @inlinable
    func pixelCoordinate(at index: Index) -> Position2i {
        return Position2i(
            x: index % self.imageSize.width,
            y: index / self.imageSize.width
        )
    }
    
    @inlinable
    func index(at pixelCoordinate: Position2i) -> Index {
        return ((self.imageSize.width * pixelCoordinate.y) + pixelCoordinate.x)
    }
}

extension RawTexture: RandomAccessCollection, MutableCollection {
    public typealias Element = Color
    public typealias Index = Int
    
    @inlinable
    public var startIndex: Index {
        nonmutating get {
            return 0
        }
    }
    
    @inlinable
    public var endIndex: Index {
        nonmutating get {
            return self.imageSize.width * self.imageSize.height
        }
    }
    
    @inlinable
    public subscript(index: Index) -> Color {
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
    nonmutating func color(at index: Index) -> Color {
        let offset = index * 4
        precondition(self.imageData.indices.contains(offset), "Index out of range.")
        return self.imageData.withUnsafeBytes { data in
            let rgba8 = data.baseAddress!.advanced(by: offset).load(as: (r: UInt8, g: UInt8, b: UInt8, a: UInt8).self)
            return Color(eightBitRed: rgba8.r, green: rgba8.g, blue: rgba8.b, alpha: rgba8.a)
        }
    }
    
    @safe // <- Bounds is checked
    @inlinable
    mutating func setColor(_ color: Color, at index: Index) {
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
