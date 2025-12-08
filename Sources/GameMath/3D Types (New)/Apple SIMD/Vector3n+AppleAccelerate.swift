/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GameMathUseSIMD && canImport(Accelerate)
public import Accelerate

/// A structure for tranparently working with the Accelerate framework
@usableFromInline
@frozen
internal struct Vector3nAccelerateBuffer<Scalar: Vector3n.ScalarType>: AccelerateBuffer, AccelerateMutableBuffer {
    public typealias Element = Scalar
    
    var x: Scalar
    var y: Scalar
    var z: Scalar
    var _pad: Scalar
    
    init(x: Scalar, y: Scalar, z: Scalar) {
        self.x = x
        self.y = y
        self.z = z
        self._pad = 0
    }
    
    @inlinable
    var count: Int {
        return 3
    }
    
    @inlinable
    func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Scalar>) throws -> R) rethrows -> R {
        try Swift.withUnsafeBytes(of: self) { buffer in
            let buffer = UnsafeBufferPointer(start: buffer.baseAddress!.assumingMemoryBound(to: Scalar.self), count: 3)
            return try body(buffer)
        }
    }
    
    @inlinable
    mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Scalar>) throws -> R) rethrows -> R {
        try Swift.withUnsafeMutableBytes(of: &self) { buffer in
            var buffer = UnsafeMutableBufferPointer(start: buffer.baseAddress!.assumingMemoryBound(to: Scalar.self), count: 3)
            return try body(&buffer)
        }
    }
}

#endif
