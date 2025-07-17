/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public import Foundation
public import GameMath

public final class PNGImporter: TextureImporter {
    var data: Data! = nil
    var size: Size2! = nil
    public required init() {}
    
    public func currentFileContainsMutipleResources() -> Bool {
        return false
    }
    
    public func synchronousPrepareToImportResourceFrom(path: String) throws(GateEngineError) {
        do {
            let data = try Platform.current.synchronousLoadResource(from: path)
            let png = try PNGDecoder().decode(data)
            self.data = png.data
            self.size = Size2(Float(png.width), Float(png.height))
        }catch{
            throw GateEngineError(error)
        }
    }
    public func prepareToImportResourceFrom(path: String) async throws(GateEngineError) {
        do {
            let data = try await Platform.current.loadResource(from: path)
            let png = try PNGDecoder().decode(data)
            self.data = png.data
            self.size = Size2(Float(png.width), Float(png.height))
        }catch{
            throw GateEngineError(error)
        }
    }

    public func loadTexture(options: TextureImporterOptions) throws(GateEngineError) -> (data: Data, size: Size2) {
        return (self.data, self.size)
    }

    public static func supportedFileExtensions() -> [String] {
        return ["png"]
    }
}

#if canImport(LibSPNG)
import LibSPNG

extension PNGImporter {
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
