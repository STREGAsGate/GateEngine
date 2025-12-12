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
    
    public init(imageSize: Size2i) {
        self.imageSize = imageSize
        self.imageData = Data(repeating: 0, count: imageSize.width * imageSize.height * 4)
        for alphaIndex in stride(from: 3, to: self.imageData.count, by: 4) {
            self.imageData[alphaIndex] = .max
        }
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
    @inlinable
    nonmutating func color(at textureCoordinate: Position2f) -> Color {
        let pixelCoord = self.pixelCoordinate(for: textureCoordinate)
        return self.color(at: pixelCoord)
    }
    
    @inlinable
    mutating func setColor(_ color: Color, at textureCoordinate: Position2f) {
        let pixelCoord = self.pixelCoordinate(for: textureCoordinate)
        self.setColor(color, at: pixelCoord)
    }
    
    @inlinable
    subscript(textureCoordinate: Position2f) -> Color {
        nonmutating get {
            return self.color(at: textureCoordinate)
        }
        mutating set {
            self.setColor(newValue, at: textureCoordinate)
        }
    }
}

public extension RawTexture {
    func isAlphaChannelSubMax(at index: Int) -> Bool {
        return imageData[(index * 4) + 3] < .max
    }
}

public extension RawTexture {
    /// The UV space size of a single pixel
    @inlinable
    var pixelSize: Size2f {
        return Size2f.one / Size2f(self.imageSize)
    }
    /// The UV position for the pixel
    @inlinable
    func textureCoordinate(for pixelCoordinate: Position2i) -> Position2f {
        let pixelSize = self.pixelSize
        return (Position2f(pixelCoordinate) * pixelSize) + (pixelSize / 2)
    }
    
    @inlinable
    func textureCoordinate(for index: Index) -> Position2f {
        return self.textureCoordinate(for: self.pixelCoordinate(for: index))
    }
    
    @inlinable
    func index(for textureCoordinate: Position2f) -> Index {
        return self.index(for: self.pixelCoordinate(for: textureCoordinate))
    }
    
    @inlinable
    func pixelCoordinate(for textureCoordinate: Position2f) -> Position2i {
        let pixelSize = self.pixelSize
        return Position2i(textureCoordinate / pixelSize)
    }
    
    @inlinable
    func pixelCoordinate(for index: Index) -> Position2i {
        return Position2i(
            x: index % self.imageSize.width,
            y: index / self.imageSize.width
        )
    }
    
    @inlinable
    func index(for pixelCoordinate: Position2i) -> Index {
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
