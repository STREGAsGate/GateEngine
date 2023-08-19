/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

internal class BufferConverter {
    let data: Data
    let format: AudioBuffer.Format
    init(data: Data, format: AudioBuffer.Format) {
        self.data = data
        self.format = format
    }

    func reformat(as newFormat: AudioBuffer.Format) -> Data {
        guard format != newFormat else { return data }

        switch newFormat.bitRate {
        case .uint8:
            switch format.bitRate {
            case .uint8:
                return convertIntToInt(UInt8.self, UInt8.self, newFormat: newFormat)
            case .int8:
                return convertIntToInt(Int8.self, UInt8.self, newFormat: newFormat)
            case .int16:
                return convertIntToInt(Int16.self, UInt8.self, newFormat: newFormat)
            case .int32:
                return convertIntToInt(Int32.self, UInt8.self, newFormat: newFormat)
            case .float32:
                return convertToIntFromFloat(UInt8.self, newFormat: newFormat)
            }
        case .int8:
            switch format.bitRate {
            case .uint8:
                return convertIntToInt(UInt8.self, Int8.self, newFormat: newFormat)
            case .int8:
                return convertIntToInt(Int8.self, Int8.self, newFormat: newFormat)
            case .int16:
                return convertIntToInt(Int16.self, Int8.self, newFormat: newFormat)
            case .int32:
                return convertIntToInt(Int32.self, Int8.self, newFormat: newFormat)
            case .float32:
                return convertToIntFromFloat(Int8.self, newFormat: newFormat)
            }
        case .int16:
            switch format.bitRate {
            case .uint8:
                return convertIntToInt(UInt8.self, Int16.self, newFormat: newFormat)
            case .int8:
                return convertIntToInt(Int8.self, Int16.self, newFormat: newFormat)
            case .int16:
                return convertIntToInt(Int16.self, Int16.self, newFormat: newFormat)
            case .int32:
                return convertIntToInt(Int32.self, Int16.self, newFormat: newFormat)
            case .float32:
                return convertToIntFromFloat(Int16.self, newFormat: newFormat)
            }
        case .int32:
            switch format.bitRate {
            case .uint8:
                return convertIntToInt(UInt8.self, Int32.self, newFormat: newFormat)
            case .int8:
                return convertIntToInt(Int8.self, Int32.self, newFormat: newFormat)
            case .int16:
                return convertIntToInt(Int16.self, Int32.self, newFormat: newFormat)
            case .int32:
                return convertIntToInt(Int32.self, Int32.self, newFormat: newFormat)
            case .float32:
                return convertToIntFromFloat(Int32.self, newFormat: newFormat)
            }
        case .float32:
            switch format.bitRate {
            case .uint8:
                return convertToFloatFrom(UInt8.self, newFormat: newFormat)
            case .int8:
                return convertToFloatFrom(Int8.self, newFormat: newFormat)
            case .int16:
                return convertToFloatFrom(Int16.self, newFormat: newFormat)
            case .int32:
                return convertToFloatFrom(Int32.self, newFormat: newFormat)
            case .float32:
                return convertToFloatFromFloat(newFormat: newFormat)
            }
        }
    }
}

// Mark: - Int to Float
extension BufferConverter {
    fileprivate func convertToFloatFrom<T: FixedWidthInteger>(
        _ source: T.Type,
        newFormat: AudioBuffer.Format
    ) -> Data {
        let divisor = 1 / (Float(T.max) + 1)
        var array: [Float32] = data.withUnsafeBytes { bytes -> [T] in
            return Array(bytes.assumingMemoryBound(to: T.self))
        }.map { integer -> Float in
            return divisor * Float(integer)
        }

        if newFormat.channels != .mono {
            if format.channels.interleved != newFormat.channels.interleved {
                if format.channels.interleved == false && newFormat.channels.interleved == true {
                    array = convertFromNoninterlevedToInterleave(array)
                } else {
                    array = convertFromInterlevedToNoninterleave(array)
                }
            }
        }
        return array.withUnsafeBufferPointer { (buffer) -> Data in
            return Data(buffer: buffer)
        }
    }

    fileprivate func convertToIntFromFloat<D: FixedWidthInteger>(
        _ destination: D.Type,
        newFormat: AudioBuffer.Format
    ) -> Data {
        var array: [D] = data.withUnsafeBytes { (bytes) in
            return Array(bytes.bindMemory(to: Float32.self))
        }.map {
            let float = max(-1.0, min(1.0, $0))
            return D(float * Float(D.max - 1))
        }

        if newFormat.channels != .mono {
            if format.channels.interleved != newFormat.channels.interleved {
                if format.channels.interleved == false && newFormat.channels.interleved == true {
                    array = convertFromNoninterlevedToInterleave(array)
                } else {
                    array = convertFromInterlevedToNoninterleave(array)
                }
            }
        }
        return array.withUnsafeBufferPointer { (buffer) -> Data in
            return Data(buffer: buffer)
        }
    }

    fileprivate func convertToFloatFromFloat(newFormat: AudioBuffer.Format) -> Data {
        var array: [Float32] = data.withUnsafeBytes { (bytes) in
            return Array(bytes.bindMemory(to: Float32.self))
        }
        if newFormat.channels != .mono {
            if format.channels.interleved != newFormat.channels.interleved {
                if format.channels.interleved == false && newFormat.channels.interleved == true {
                    array = convertFromNoninterlevedToInterleave(array)
                } else {
                    array = convertFromInterlevedToNoninterleave(array)
                }
            }
        }
        return array.withUnsafeBufferPointer { (buffer) -> Data in
            return Data(buffer: buffer)
        }
    }
}

// Mark: Int to Int
extension BufferConverter {
    fileprivate func convertIntToInt<S: FixedWidthInteger, D: FixedWidthInteger>(
        _ source: S.Type,
        _ destination: D.Type,
        newFormat: AudioBuffer.Format ) -> Data {
        var array: [D] = {
            guard source != destination else {
                return self.data.withUnsafeBytes({ Array($0.bindMemory(to: destination)) })
            }

            var array: [D] = []
            array.reserveCapacity(data.count)

            func appendArray<IntegerType: FixedWidthInteger>(unsignedSType: IntegerType.Type) {
                for value in self.data.withUnsafeBytes({ Array($0.bindMemory(to: unsignedSType)) }) {
                    let m = Float(value) / Float(unsignedSType.max)
                    switch D.bitWidth {
                    case 8:
                        let v = Float(UInt8.max) * m
                        array.append(Int8(bitPattern: UInt8(v)) as! D)
                    case 16:
                        array.append((D(value) - 0x80) << 8)
                    case 32:
                        let v = Float(UInt32.max) * m
                        array.append(Int32(bitPattern: UInt32(v)) as! D)
                    case 64:
                        let v = Float(UInt64.max) * m
                        array.append(Int64(bitPattern: UInt64(v)) as! D)
                    default:
                        fatalError()
                    }
                }
            }

            switch S.bitWidth {
            case 8:
                appendArray(unsignedSType: UInt8.self)
            case 16:
                appendArray(unsignedSType: UInt16.self)
            case 32:
                appendArray(unsignedSType: UInt32.self)
            case 64:
                appendArray(unsignedSType: UInt64.self)
            default:
                fatalError()
            }

            return array
        }()

        if newFormat.channels != .mono {  //Interleaved must have more then 1 channel
            if format.channels.interleved != newFormat.channels.interleved {  //Skip if there's no change
                if format.channels.interleved == false && newFormat.channels.interleved == true {
                    array = convertFromNoninterlevedToInterleave(array)
                } else {
                    array = convertFromInterlevedToNoninterleave(array)
                }
            }
        }

        return array.withUnsafeBufferPointer { (buffer) -> Data in
            return Data(buffer: buffer)
        }
    }
}

//Mark: - Interleave
extension BufferConverter {
    fileprivate func convertFromNoninterlevedToInterleave<T>(_ source: [T]) -> [T] {
        var interleaved: [T] = []

        let left = source[0 ..< source.indices.upperBound / 2]
        let right = source[(source.indices.upperBound / 2)...]

        assert(left.count == right.count)

        for index in left.indices {
            interleaved.append(left[index])
            interleaved.append(right[left.count + index])
        }

        return interleaved
    }

    fileprivate func convertFromInterlevedToNoninterleave<T: Numeric>(_ source: [T]) -> [T] {
        var out: [T] = Array(repeating: 0, count: source.count)
        let half: Int = source.count / 2
        for index in 0 ..< half {
            out[index] = source[index * 2]
            out[half + index] = source[index * 2 + 1]
        }
        return out
    }
}

//Mark: - Deinterleave and to float32
extension BufferConverter {
    static func convertToDeinterleavedFloat<T: FixedWidthInteger>(
        _ data: Data,
        fromType source: T.Type
    ) -> Data {
        let array: [T] = data.withUnsafeBytes { (bytes) in
            return Array(bytes.bindMemory(to: T.self))
        }

        let divisor = Float32(Int32(T.max) + 1)
        func toFloat(_ i: T) -> Float32 {
            let f = Float(i) / divisor
            return min(1.0, max(-1.0, f))
        }

        var out: [Float32] = Array(repeating: 0, count: array.count)
        let half: Int = array.count / 2
        for index in 0 ..< half {
            out[index] = toFloat(array[index * 2])
            out[half + index] = toFloat(array[index * 2 + 1])
        }

        return out.withUnsafeBufferPointer { (buffer) -> Data in
            return Data(buffer: buffer)
        }
    }
}
