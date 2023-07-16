/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if !os(WASI) && canImport(Vorbis)
import Vorbis

func oggCallbackRead(buffer: UnsafeMutableRawPointer!, elementSize: Int, elementCount: Int, dataSource: UnsafeMutableRawPointer!) -> Int {
    assert(elementSize == 1)
    var stream = dataSource.assumingMemoryBound(to: Stream.self).pointee
    return stream.read(elementCount, into: buffer)
}
func oggCallbackSeek(dataSource: UnsafeMutableRawPointer!, offset: ogg_int64_t, whence: Int32) -> Int32 {
    var stream = dataSource.assumingMemoryBound(to: Stream.self).pointee
    stream.seek(offset: Int(offset), style: Stream.SeekStyle(rawValue: Int(whence))!)
    return 0
}
func oggCallbackClose(dataSource: UnsafeMutableRawPointer?) -> Int32 {
    fatalError()
}

#if os(Windows)
func oggCallbackTell(dataSource: UnsafeMutableRawPointer!) -> Int32 {
    let stream = dataSource.assumingMemoryBound(to: Stream.self).pointee
    return Int32(stream.tell())
}
#else
func oggCallbackTell(dataSource: UnsafeMutableRawPointer!) -> Int {
    let stream = dataSource.assumingMemoryBound(to: Stream.self).pointee
    return stream.tell()
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
        data.withUnsafeBytes { (data: UnsafeRawBufferPointer) -> () in
            buffer.copyMemory(from: data.baseAddress!.advanced(by: position), byteCount: count)
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

class VorbisFile {
    let channelCount: Int16
    let samplesPerSecond: Int32
    let bitsPerSample: Int16
    
    let audio: Data
    
    func format() -> AudioBuffer.Format {
        return AudioBuffer.Format(channels: channelCount == 2 ? .stereo(interleved: true) : .mono, bitRate: .int16, sampleRate: Double(samplesPerSecond))
    }
    
    required init?(_ data: Data, context: AudioContext) {
        var stream = Stream(data)
        let values: (channelCount: Int16, samplesPerSecond: Int32, bitsPerSample: Int16, audio: Data)? = withUnsafeMutablePointer(to: &stream) { stream in
            var vorbisFile: OggVorbis_File = Vorbis.OggVorbis_File()
            let callbacks = Vorbis.ov_callbacks(read_func: oggCallbackRead(buffer:elementSize:elementCount:dataSource:),
                                                seek_func: oggCallbackSeek(dataSource:offset:whence:),
                                                close_func: nil,
                                                tell_func: oggCallbackTell(dataSource:))
            
            Vorbis.ov_open_callbacks(stream, &vorbisFile, nil, 0, callbacks)
            
            guard let info = Vorbis.ov_info(&vorbisFile, 0)?.pointee else {return nil}
            let channelCount = Int16(info.channels)
            let samplesPerSecond = Int32(info.rate)
            
            var chains: Bool = false
            for link: Int32 in 0 ..< Int32(Vorbis.ov_streams(&vorbisFile)) {
                let info = Vorbis.ov_info(&vorbisFile, link).pointee
                if (info.channels == channelCount && info.rate == samplesPerSecond) {
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
                if context.reference.supportsBitRate(.int16){
                    return Int16(MemoryLayout<Int16>.size * 8)
                }else{
                    return Int16(MemoryLayout<Int8>.size * 8)
                }
            }()
            
            let nsamples = Vorbis.ov_pcm_total(&vorbisFile, chains ? -1 : 0)
            var end: Bool = false
            var current_section: Int32 = 0
            
            var position: Int = 0
            var data: [CChar] = Array(repeating: 0, count: Int(nsamples) * Int(channelCount) * Int(bitsPerSample/8))
            while(end == false) {
                let ret: Int = data.withUnsafeMutableBufferPointer { (pointer) -> Int in
                    return Int(Vorbis.ov_read(&vorbisFile, pointer.baseAddress?.advanced(by: position), 4096, endianness, Int32(bitsPerSample / 8), 1, &current_section))
                }
                
                if (ret == 0) {
                    end = true
                }else if ret < 0 {
                    Log.error("Failed to read Vorbis stream.")
                    return nil
                }else{
                    position += ret
                }
            }
            let audio = data.withUnsafeBufferPointer { (buffer) -> Data in
                return Data(buffer: buffer)
            }
            
            Vorbis.ov_clear(&vorbisFile)
            return (channelCount, samplesPerSecond, bitsPerSample, audio)
        }
        
        if let values {
            self.channelCount = values.channelCount
            self.samplesPerSecond = values.samplesPerSecond
            self.bitsPerSample = values.bitsPerSample
            self.audio = values.audio
        }else{
            return nil
        }
    }
}
#endif
