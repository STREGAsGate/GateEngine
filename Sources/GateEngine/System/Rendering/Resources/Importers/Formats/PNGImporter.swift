/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

//#if os(WASI)
//
//import Foundation
//import GameMath
//import JavaScriptKit
//import DOM
//import WebAPIBase
//
//public class PNGImporter: TextureImporter {
//    public required init() {}
//    public func loadData(path: String, options: TextureImporterOptions) async throws -> (data: Data, size: Size2?) {
//        let document: Document = globalThis.document
//        let image = HTMLImageElement(from: document.createElement(localName: "img"))!
//        let newPath = await Game.shared.platform.locateResource(from: path) ?? path
//        image.src = newPath
//        let tagID = UUID().uuidString
//        image.id = tagID
//
//        await withCheckedContinuation { continuation in
//            image.onload = { event -> JSValue in
//                #if DEBUG
//                print("[GateEngine] Loading Resource: \"\(newPath)\"")
//                #endif
//                continuation.resume()
//                return nil
//            }
//        }
//        image.hidden = .bool(true)
//        _ = document.body!.appendChild(node: image)
//        print("size:", path)
//        return (tagID.data(using: .utf8)!, Size2(Float(image.width), Float(image.height)))
//    }
//    public func process(data: Data, size: Size2?, options: TextureImporterOptions) throws -> (data: Data, size: Size2) {
//        print("size:", size)
//        return (data, size!)
//    }
//    public class func supportedFileExtensions() -> [String] {
//        return ["png"]
//    }
//}
//#else
//#if canImport(spng)

import Foundation
import GameMath
import libspng

public class PNGImporter: TextureImporter {
    public required init() {}
    
    public func process(data: Data, size: Size2?, options: TextureImporterOptions) throws -> (data: Data, size: Size2) {
        return try data.withUnsafeBytes { data in
            /* Create a context */
            let ctx = spng_ctx_new(0)
            defer {
                /* Free context memory */
                spng_ctx_free(ctx)
            }
            
            /* Set an input buffer */
            let set_buffer_err = spng_set_png_buffer(ctx, data.baseAddress, data.count)
            if set_buffer_err != 0 {
                throw String(cString: spng_strerror(set_buffer_err))
            }
            
            /* Determine output image size */
            var out_size: Int = -1
            let out_size_err = spng_decoded_image_size(ctx, Int32(SPNG_FMT_RGBA8.rawValue), &out_size)
            if out_size_err != 0 {
                throw String(cString: spng_strerror(out_size_err))
            }
            
            /* Decode to 8-bit RGBA */
            var out = Data(repeatElement(0, count: out_size))
            let decode_err = out.withUnsafeMutableBytes({ data in
                return spng_decode_image(ctx, data.baseAddress, out_size, Int32(SPNG_FMT_RGBA8.rawValue), 0)
            })
            if decode_err != 0 {
                throw String(cString: spng_strerror(decode_err))
            }
            
            var header: spng_ihdr = spng_ihdr()
            let header_err = spng_get_ihdr(ctx, &header)
            if header_err != 0 {
                throw String(cString: spng_strerror(header_err))
            }
          
            return (Data(out), Size2(width: Float(header.width), height: Float(header.height)))
        }
    }

    public class func supportedFileExtensions() -> [String] {
        return ["png"]
    }
}

//#endif
