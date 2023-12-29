/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct BitStream: Sendable {
    @usableFromInline let bytes: ContiguousArray<UInt8>
    @usableFromInline var byteOffset: Int {offset / 8}
    @usableFromInline var bitOffset: Int {offset % 8}
    @usableFromInline var offset: Int = 0
    
    /**
     Create a new BitStream
     - parameter array: The data to read bits from.
     */
    @inlinable
    public init<T>(_ array: Array<T>) {
        self.bytes = array.withUnsafeBytes({ bufferPointer -> ContiguousArray<UInt8> in
            return ContiguousArray<UInt8>(bufferPointer)
        })
    }
    
    /**
     Create a new BitStream
     - parameter array: The data to read bits from.
     */
    @inlinable
    public init<T>(_ array: ContiguousArray<T>) {
        self.bytes = array.withUnsafeBytes({ bufferPointer -> ContiguousArray<UInt8> in
            return ContiguousArray<UInt8>(bufferPointer)
        })
    }
    
    @inlinable
    public init(_ data: UnsafeRawBufferPointer) {
        self.bytes = ContiguousArray<UInt8>(data)
    }
    
    /**
     Create a new BitStream
     - parameter data: The data to read bits from.
     */
    @inlinable @_disfavoredOverload
    public init(_ data: Any) {
        self.bytes = withUnsafeBytes(of: data, { bufferPointer -> ContiguousArray<UInt8> in
            return ContiguousArray<UInt8>(bufferPointer)
        })
    }

    /**
     Get a bit from an index
     - parameter index: The index of the desired bit
     - returns: A Bool representing the bit. true for 1, false for 0.
     */
    @inlinable
    @inline(__always)
    public subscript (index: Int) -> Bool {
        return bytes.withUnsafeBytes { bytes in
            let byte = bytes[byteOffset]
            return (byte >> index) % 2 == 1
        }
    }

    /**
     Read bits into a value
     - parameter numBits: The number of bits to read
     - returns: A FixedWidthInteger containing the value of the requested bits
     */
    @_transparent
    public mutating func readBits<T: FixedWidthInteger>(_ numBits: Int) -> T {
        assert(numBits > 0, "Cannot read zero bits.")
        
        var result: [Bool] = []  // result accumulator
        result.reserveCapacity(numBits)
        
        bytes.withUnsafeBytes { bytes in
            for _ in 0 ..< numBits {
                let byteOffset = self.byteOffset
                assert(bytes.count > byteOffset, "Index out of range.")
                let byte = bytes[byteOffset]
                let v = (byte >> bitOffset) % 2 == 1
                result.append(v)
                offset += 1
            }
        }
        
        return T.init(littleEndian: T.init("\(String(result.reversed().map { $0 ? "1" : "0" }))", radix: 2)!)
    }
    
    /**
     Move the current read position.
     - parameter numBits: The number of bits to move the read position.
     */
    @_transparent
    public mutating func seekBits(_ numBits: Int) {
        offset += numBits
    }
}
