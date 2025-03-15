//
//  PNGCoder.swift
//  GateEngine
//
//  Created by Dustin Collins on 3/15/25.
//


public final class PNGDecoder {
    public func decode(_ data: Data) throws -> Image {
#if canImport(LibSPNG)
        try LibSPNG.decode(data: data)
#else
        fatalError("PNGDecoder is not supported on this platform.")
#endif
    }
    
    public struct Image {
        let width: Int
        let height: Int
        let data: Data
    }
    
    public init() {
        
    }
    
    static var isSupported: Bool {
#if canImport(LibSPNG)
        return true
#else
        false
#endif
    }
}

public final class PNGEncoder {
    /// - note: Assumes RGBA8 data
    public func encode(_ data: Data, width: Int, height: Int) throws -> Data {
#if canImport(LibSPNG)
        try LibSPNG.encode(data: data, width: width, height: height)
#else
        fatalError("PNGEncoder is not supported on this platform.")
#endif
    }
    
    public enum EncodingError: Error {
        case failedToEncode(_ string: String)
    }
    
    public init() {
        
    }
}


#if canImport(LibSPNG)
import LibSPNG

enum LibSPNG {
    @inline(__always)
    static func encode(data: Data, width: Int, height: Int) throws -> Data {
        return try data.withUnsafeBytes({ (bytes: UnsafeRawBufferPointer) throws -> Data in
            /* Create a context */
            let ctx: OpaquePointer? = spng_ctx_new(Int32(SPNG_CTX_ENCODER.rawValue))
            defer {
                /* Free context memory */
                spng_ctx_free(ctx)
            }
            
            spng_set_option(ctx, SPNG_ENCODE_TO_BUFFER, 1)
            
            var ihdr = spng_ihdr(
                width: UInt32(width),
                height: UInt32(height),
                bit_depth: 8,
                color_type: UInt8(SPNG_COLOR_TYPE_TRUECOLOR_ALPHA.rawValue),
                compression_method: 0,
                filter_method: UInt8(SPNG_FILTER_NONE.rawValue),
                interlace_method: UInt8(SPNG_INTERLACE_NONE.rawValue)
            )
            spng_set_ihdr(ctx, &ihdr)
            
            spng_encode_image(ctx, bytes.baseAddress, data.count, Int32(SPNG_FMT_PNG.rawValue), Int32(SPNG_ENCODE_FINALIZE.rawValue))
            
            var length: Int = 0
            var error: Int32 = 0
            if let buffer = spng_get_png_buffer(ctx, &length, &error), error == SPNG_OK.rawValue {
                let data = Data(bytes: buffer, count: length)
                free(buffer)
                return data
            }

            throw PNGEncoder.EncodingError.failedToEncode(String(cString: spng_strerror(error)))
        })
    }
    @inline(__always)
    static func decode(data: Data) throws -> PNGDecoder.Image {
        return try data.withUnsafeBytes { data in
            /* Create a context */
            let ctx: OpaquePointer? = spng_ctx_new(0)
            defer {
                /* Free context memory */
                spng_ctx_free(ctx)
            }

            /* Set an input buffer */
            let set_buffer_err: Int32 = spng_set_png_buffer(ctx, data.baseAddress, data.count)
            if set_buffer_err != 0 {
                throw GateEngineError.failedToDecode(String(cString: spng_strerror(set_buffer_err)))
            }

            /* Determine output image size */
            var out_size: Int = -1
            let out_size_err: Int32 = spng_decoded_image_size(
                ctx,
                Int32(SPNG_FMT_RGBA8.rawValue),
                &out_size
            )
            if out_size_err != 0 {
                throw GateEngineError.failedToDecode(String(cString: spng_strerror(out_size_err)))
            }

            /* Decode to 8-bit RGBA */
            var out: Data = Data(repeatElement(0, count: out_size))
            let decode_err: Int32 = out.withUnsafeMutableBytes({ data in
                return spng_decode_image(
                    ctx,
                    data.baseAddress,
                    out_size,
                    Int32(SPNG_FMT_RGBA8.rawValue),
                    0
                )
            })
            if decode_err != 0 {
                throw GateEngineError.failedToDecode(String(cString: spng_strerror(decode_err)))
            }

            var header: spng_ihdr = spng_ihdr()
            let header_err: Int32 = spng_get_ihdr(ctx, &header)
            if header_err != 0 {
                throw GateEngineError.failedToDecode(String(cString: spng_strerror(header_err)))
            }

            return PNGDecoder.Image(width: Int(header.width), height: Int(header.height), data: out)
        }
    }
}

#endif
