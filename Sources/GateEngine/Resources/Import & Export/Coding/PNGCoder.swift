/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class PNGDecoder {
    public func decode(_ data: Data) throws(GateEngineError) -> Image {
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

/**
 Encodes raw pixel data as PNG formatted data.
 */
public final class PNGEncoder {
    /**
     - parameter data: RGBA8 formatted image data
     - parameter width: The count of pixel columns for `data`
     - parameter height: The count of pixel rows for `data`
     - parameter sacrificePerformanceToShrinkData: `true` if extra processingshould be done to produce smaller PNG data.
     */
    public func encode(_ data: Data, width: Int, height: Int, sacrificePerformanceToShrinkData: Bool = false) throws(GateEngineError) -> Data {
#if canImport(LibSPNG)
        if sacrificePerformanceToShrinkData {
            try LibSPNG.encodeSmallest(data: data, width: width, height: height)
        }else{
            try LibSPNG.encodeRGBA(data: data, width: width, height: height, optimizeAlpha: false)
        }
#else
        fatalError("PNGEncoder is not supported on this platform.")
#endif
    }
    
    public init() {
        
    }
}


#if canImport(LibSPNG)
import LibSPNG

enum LibSPNG {
    /// Tries encoding as RGB/RGBA and Indexed and returns the smaller data.
    /// A quick and dirty method of creating a smaller PNG by creating multiple PNGs and picking the smallest.
    /// This is intended for compiling assets. The minor file size reduction is not worth the energy used, making this inappropriate for runtime.
    // TODO: Give users more customizability to allow for more predictability for runtime use.
    @inlinable
    static func encodeSmallest(data: Data, width: Int, height: Int) throws(GateEngineError) -> Data {
        let indexed = try encodeIndexed(data: data, width: width, height: height)
        let rgba: Data = try encodeRGBA(data: data, width: width, height: height, optimizeAlpha: true)
        
        if rgba.count <= indexed.count {
            return rgba
        }
        return indexed
    }
    
    /// Makes a PNG with full color data. This creates efficient PNG data representing photos or images with many unique colors.
    @inlinable
    static func encodeRGBA(data: Data, width: Int, height: Int, optimizeAlpha: Bool) throws(GateEngineError) -> Data {
        do {
            return try data.withUnsafeBytes({ (bytes: UnsafeRawBufferPointer) throws -> Data in
                /* Create a context */
                let ctx: OpaquePointer? = spng_ctx_new(Int32(SPNG_CTX_ENCODER.rawValue))
                defer {
                    /* Free context memory */
                    spng_ctx_free(ctx)
                }
                
                spng_set_option(ctx, SPNG_ENCODE_TO_BUFFER, 1)
                
                let colorType: UInt8
                if optimizeAlpha {
                    var hasAlpha: Bool = false
                    for index in stride(from: 3, to: data.count, by: 4) {
                        if data[index] < .max {
                            // If any alpha value is less then 100% we need to store the alpha
                            hasAlpha = true
                            break
                        }
                    }
                    if hasAlpha {
                        colorType = UInt8(SPNG_COLOR_TYPE_TRUECOLOR_ALPHA.rawValue)
                    }else{
                        colorType = UInt8(SPNG_COLOR_TYPE_TRUECOLOR.rawValue)
                    }
                }else{
                    colorType = UInt8(SPNG_COLOR_TYPE_TRUECOLOR_ALPHA.rawValue)
                }
                
                var ihdr = spng_ihdr(
                    width: UInt32(width),
                    height: UInt32(height),
                    bit_depth: 8,
                    color_type: colorType,
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
                
                throw GateEngineError.failedToEncode(String(cString: spng_strerror(error)))
            })
        }catch let error as GateEngineError {
            throw error // Typed throws not supported by closures as of Swift 6.2
        }catch{
            fatalError() // Impossible, see above
        }
    }
    
    /// Makes a PNG with an color table backend. This creates efficient PNG data representing pixel art or other images with few unique colors.
    @inlinable
    static func encodeIndexed(data: Data, width: Int, height: Int) throws(GateEngineError) -> Data {
        do {
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
                    color_type: UInt8(SPNG_COLOR_TYPE_INDEXED.rawValue),
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
                
                throw GateEngineError.failedToEncode(String(cString: spng_strerror(error)))
            })
        }catch let error as GateEngineError {
            throw error // Typed throws not supported by closures as of Swift 6.2
        }catch{
            fatalError() // Impossible, see above
        }
    }
    
    @inlinable
    static func decode(data: Data) throws(GateEngineError) -> PNGDecoder.Image {
        do {
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
        }catch let error as GateEngineError {
            throw error // Typed throws not supported by closures as of Swift 6.2
        }catch{
            fatalError() // Impossible, see above
        }
    }
}

#endif
