/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

extension Data {
    fileprivate func boundTo<T>(_ type: T.Type) -> T? {
        guard self.count == MemoryLayout<T>.stride else { return nil }
        return self.withUnsafeBytes({ (pointer) in
            return pointer.baseAddress?.assumingMemoryBound(to: type).pointee
        })
    }

    fileprivate func swapEndianness(withUnitByteCount bytes: Int) -> Data {
        var data = self
        let count = data.count / bytes
        data.withUnsafeMutableBytes { (ptr) in
            for i in 0 ..< count {
                ptr[i] = ptr[i].byteSwapped
            }
        }
        return data
    }
}

class WaveFile {
    let channelCount: Int16
    let samplesPerSecond: Int32
    let bitsPerSample: Int16
    let isIEEEFloat: Bool

    let audio: Data

    func format() -> AudioBuffer.Format {
        if isIEEEFloat {
            guard bitsPerSample == 32 else { fatalError("Only 32 bit Float format is supported.") }
            return AudioBuffer.Format(
                channels: channelCount == 2 ? .stereo(interleved: true) : .mono,
                bitRate: .float32,
                sampleRate: Double(samplesPerSecond)
            )
        }
        if bitsPerSample == 8 {
            return AudioBuffer.Format(
                channels: channelCount == 2 ? .stereo(interleved: true) : .mono,
                bitRate: .uint8,
                sampleRate: Double(samplesPerSecond)
            )
        } else if bitsPerSample == 16 {
            return AudioBuffer.Format(
                channels: channelCount == 2 ? .stereo(interleved: true) : .mono,
                bitRate: .int16,
                sampleRate: Double(samplesPerSecond)
            )
        } else if bitsPerSample == 32 {
            return AudioBuffer.Format(
                channels: channelCount == 2 ? .stereo(interleved: true) : .mono,
                bitRate: .int32,
                sampleRate: Double(samplesPerSecond)
            )
        } else {
            fatalError(
                "\(bitsPerSample)-bit \(channelCount)CH PCM Not Supported. Must be 8-bit, 16-bit, or 32-bit and 1 or 2 channels."
            )
        }
    }

    required init?(_ data: Data, context: AudioContext) {
        guard String(bytes: data[0 ..< 4], encoding: .ascii) == "RIFF" else { return nil }
        guard String(bytes: data[8 ..< 12], encoding: .ascii) == "WAVE" else { return nil }
        guard String(bytes: data[12 ..< 16], encoding: .ascii) == "fmt " else {
            Log.error("Failed to read WAVE file.")
            return nil
        }

        if data[20 ..< 22].boundTo(Int16.self) == 0x0001
            || data[20 ..< 22].boundTo(Int16.self) == 0x0003
        {
            let channelCount = data[22 ..< 24].boundTo(Int16.self) ?? 0
            self.samplesPerSecond = data[24 ..< 28].boundTo(Int32.self) ?? 0
            self.bitsPerSample = data[34 ..< 36].boundTo(Int16.self) ?? 0
            self.channelCount = channelCount

            var dataPos = 36
            while String(bytes: data[dataPos ..< dataPos + 4], encoding: .ascii) != "data"
                || dataPos > data.indices.upperBound
            {
                dataPos += 4
            }
            dataPos += 4
            let audioSize = data[dataPos ..< dataPos + 4].boundTo(Int32.self) ?? 0
            let audioRange = (dataPos + 4) ..< Int(audioSize)
            let audio = Data(data[audioRange])

            let swapEndianness =
                (context.reference.endianness == .big)
                || (context.reference.endianness == .native && 1.bigEndian == 1)
            if swapEndianness {
                self.audio = audio.swapEndianness(withUnitByteCount: Int(bitsPerSample / 8))
            } else {
                self.audio = audio
            }

            self.isIEEEFloat = data[20 ..< 22].boundTo(Int16.self) == 0x0003
        } else {
            Log.error("WAV file must be PCM or IEEE-Float encoded (uncompressed).")
            return nil
        }
    }
}
