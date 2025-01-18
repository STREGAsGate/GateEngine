/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if !os(WASI) && canImport(Vorbis)
import Vorbis

fileprivate func oggCallbackRead(
    buffer: UnsafeMutableRawPointer!,
    elementSize: Int,
    elementCount: Int,
    dataSource: UnsafeMutableRawPointer!
) -> Int {
    assert(elementSize == 1)
    var stream = dataSource.assumingMemoryBound(to: Stream.self).pointee
    let ret = stream.read(elementCount, into: buffer)
    dataSource.assumingMemoryBound(to: Stream.self).pointee = stream
    return ret
}
fileprivate func oggCallbackSeek(
    dataSource: UnsafeMutableRawPointer!, 
    offset: ogg_int64_t, 
    whence: Int32
) -> Int32 {
    var stream = dataSource.assumingMemoryBound(to: Stream.self).pointee
    stream.seek(offset: Int(offset), style: Stream.SeekStyle(rawValue: Int(whence))!)
    dataSource.assumingMemoryBound(to: Stream.self).pointee = stream
    return 0
}
fileprivate func oggCallbackClose(
    dataSource: UnsafeMutableRawPointer?
) -> Int32 {
    fatalError()
}

#if os(Windows)
fileprivate func oggCallbackTell(
    dataSource: UnsafeMutableRawPointer!
) -> Int32 {
    return Int32(dataSource.assumingMemoryBound(to: Stream.self).pointee.tell())
}
#else
fileprivate func oggCallbackTell(
    dataSource: UnsafeMutableRawPointer!
) -> Int {
    return dataSource.assumingMemoryBound(to: Stream.self).pointee.tell()
}
#endif

fileprivate struct Stream {
    var position: Int = 0
    let data: Data
    init(_ data: Data) {
        self.data = data
    }

    mutating func read(_ count: Int, into buffer: UnsafeMutableRawPointer!) -> Int {
        let count = min(count, data.count - position)
        data.withUnsafeBytes { (data: UnsafeRawBufferPointer) -> Void in
            let start = data.baseAddress!.advanced(by: position)
            buffer.copyMemory(from: start, byteCount: count)
        }
        self.position += count
        return count
    }

    enum SeekStyle: Int {
        case becomeCurrent
        case fromCurrent
        case fromEndOfFile
    }

    mutating func seek(offset: Int, style: SeekStyle) {
        switch style {
        case .becomeCurrent:
            self.position = offset
        case .fromCurrent:
            self.position += offset
        case .fromEndOfFile:
            self.position = data.indices.last! + offset
        }
    }

    func tell() -> Int {
        return position
    }
}

final class VorbisFile {
    let channelCount: Int16
    let samplesPerSecond: Int32
    let bitsPerSample: Int16

    let audio: Data

    func format() -> AudioBuffer.Format {
        return AudioBuffer.Format(
            channels: channelCount == 2 ? .stereo(interleved: true) : .mono,
            bitRate: .int16,
            sampleRate: Double(samplesPerSecond)
        )
    }

    required init(_ data: Data, context: AudioContext) throws {
        var stream = Stream(data)
        let values: (channelCount: Int16, samplesPerSecond: Int32, bitsPerSample: Int16, audio: Data) = try withUnsafeMutablePointer(to: &stream) { stream throws in
            var vorbisFile: OggVorbis_File = Vorbis.OggVorbis_File()
            let callbacks = Vorbis.ov_callbacks(
                read_func: oggCallbackRead(buffer:elementSize:elementCount:dataSource:),
                seek_func: oggCallbackSeek(dataSource:offset:whence:),
                close_func: nil,
                tell_func: oggCallbackTell(dataSource:)
            )
            
            let error = Vorbis.ov_open_callbacks(stream, &vorbisFile, nil, 0, callbacks)
            switch error {
            case 0://Success
                break
            case OV_EREAD:
                throw GateEngineError.failedToDecode("A read from media returned an error.")
            case OV_ENOTVORBIS:
                throw GateEngineError.failedToDecode("Bitstream does not contain any Vorbis data.")
            case OV_EVERSION:
                throw GateEngineError.failedToDecode("Vorbis version mismatch.")
            case OV_EBADHEADER:
                throw GateEngineError.failedToDecode("Invalid Vorbis bitstream header.")
            case OV_EFAULT:
                throw GateEngineError.failedToDecode("Internal logic fault; indicates a bug or heap/stack corruption.")
            default:
                throw GateEngineError.failedToDecode("Vorbis error code: \(error).")
            }
            
            guard let info = Vorbis.ov_info(&vorbisFile, 0)?.pointee else {
                throw GateEngineError.failedToDecode("Unknown Vorbis Error.")
            }
            let channelCount = Int16(info.channels)
            let samplesPerSecond = Int32(info.rate)
            
            var chains: Bool = false
            for link: Int32 in 0 ..< Int32(Vorbis.ov_streams(&vorbisFile)) {
                let info = Vorbis.ov_info(&vorbisFile, link).pointee
                if info.channels == channelCount && info.rate == samplesPerSecond {
                    chains = true
                    break
                }
            }
            
            let endianness: Int32 = {
                switch context.reference.endianness {
                case .native:
                    return Int32(1.bigEndian == 1 ? 1 : 0)
                case .little:
                    return 0
                case .big:
                    return 1
                }
            }()
            
            let bitsPerSample: Int16 = {
                if context.reference.supportsBitRate(.int16) {
                    return Int16(MemoryLayout<Int16>.size * 8)
                } else {
                    return Int16(MemoryLayout<Int8>.size * 8)
                }
            }()
            
            let nsamples = Vorbis.ov_pcm_total(&vorbisFile, chains ? -1 : 0)
            var end: Bool = false
            var current_section: Int32 = 0
            
            var position: Int = 0
            var data: [CChar] = Array(
                repeating: 0,
                count: Int(nsamples) * Int(channelCount) * Int(bitsPerSample / 8)
            )
            while end == false {
                let ret: Int = data.withUnsafeMutableBufferPointer { (pointer) -> Int in
                    return Int(
                        Vorbis.ov_read(
                            &vorbisFile,
                            pointer.baseAddress?.advanced(by: position),
                            4096,
                            endianness,
                            Int32(bitsPerSample / 8),
                            1,
                            &current_section
                        )
                    )
                }
                
                if ret == 0 {
                    end = true
                } else if ret < 0 {
                    throw GateEngineError.failedToDecode("Failed to read Vorbis stream.")
                } else {
                    position += ret
                }
            }
            let audio = data.withUnsafeBufferPointer { (buffer) -> Data in
                return Data(buffer: buffer)
            }
            
            Vorbis.ov_clear(&vorbisFile)
            return (channelCount, samplesPerSecond, bitsPerSample, audio)
        }
        
        self.channelCount = values.channelCount
        self.samplesPerSecond = values.samplesPerSecond
        self.bitsPerSample = values.bitsPerSample
        self.audio = values.audio
    }
}
#endif
