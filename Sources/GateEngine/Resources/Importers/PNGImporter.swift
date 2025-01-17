/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class PNGImporter: TextureImporter {
    public required init() {}

    public func process(data: Data, size: Size2?, options: TextureImporterOptions) throws -> (
        data: Data, size: Size2
    ) {
        return try decode(data: data, size: size, options: options)
    }

    public static func canProcessFile(_ file: URL) -> Bool {
        return file.pathExtension.caseInsensitiveCompare("png") == .orderedSame
    }
}

#if canImport(LibSPNG)
import LibSPNG

extension PNGImporter {
    @_transparent
    func decode(data: Data, size: Size2?, options: TextureImporterOptions) throws -> (
        data: Data, size: Size2
    ) {
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

            return (Data(out), Size2(width: Float(header.width), height: Float(header.height)))
        }
    }
}

#endif
