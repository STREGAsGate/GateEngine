/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(macOS)
import GLKit

extension OpenGLRenderer {
    @inline(__always)
    class var pixelFormat: NSOpenGLPixelFormat {
        return NSOpenGLPixelFormat(attributes: [
            UInt32(NSOpenGLPFAAccelerated),
            UInt32(NSOpenGLPFADoubleBuffer),
            UInt32(NSOpenGLPFADepthSize), UInt32(32),
            UInt32(NSOpenGLPFAOpenGLProfile),
            UInt32(NSOpenGLProfileVersion4_1Core),
            UInt32(0),
        ]) ?? NSOpenGLPixelFormat(attributes: [
            UInt32(NSOpenGLPFAAccelerated),
            UInt32(NSOpenGLPFADoubleBuffer),
            UInt32(NSOpenGLPFADepthSize), UInt32(32),
            UInt32(NSOpenGLPFAOpenGLProfile),
            UInt32(NSOpenGLProfileVersion3_2Core),
            UInt32(0),
        ]) ?? NSOpenGLPixelFormat(attributes: [
            UInt32(NSOpenGLPFAAllRenderers),
            UInt32(NSOpenGLPFAOpenGLProfile),
            UInt32(NSOpenGLProfileVersion3_2Core),
            UInt32(0),
        ])!
    }
    static let sharedOpenGLContext: NSOpenGLContext = NSOpenGLContext(
        format: pixelFormat,
        share: nil
    )!
    func setup() {
        guard let ctx = Self.sharedOpenGLContext.cglContextObj else { fatalError() }
        CGLSetCurrentContext(ctx)
        CGLEnable(ctx, kCGLCECrashOnRemovedFunctions)
        CGLFlushDrawable(ctx)
    }
}
#elseif os(iOS) || os(tvOS)
extension OpenGLRenderer {
    func setup() {

    }
}
#endif
