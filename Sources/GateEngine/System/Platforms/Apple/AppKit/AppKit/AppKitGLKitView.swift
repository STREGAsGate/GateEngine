/**
 * Copyright (c) 2022 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 * Licensed under Apache License v2.0
 * 
 * http://stregasgate.com
 */
#if canImport(AppKit) && canImport(GLKit) && !targetEnvironment(macCatalyst)
import GLKit

internal class GLKitView: NSOpenGLView {
    unowned let viewController: AppKitViewController
        
    init(viewController: AppKitViewController, size: CGSize) {
        self.viewController = viewController
        
        let context = NSOpenGLContext(format: OpenGLRenderer.pixelFormat, share: OpenGLRenderer.sharedOpenGLContext)!
        super.init(frame: NSRect(origin: .zero, size: size), pixelFormat: context.pixelFormat)!
        self.openGLContext = context
        self.setup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }
        
    func setup() {
        if let context = self.openGLContext?.cglContextObj {
            CGLSetCurrentContext(context)
        }
        
        self.wantsLayer = true
        self.wantsBestResolutionOpenGLSurface = true
        
        if #available(macOS 10.12.2, *) {
            self.allowedTouchTypes = [.direct, .indirect]
        }else{
            self.acceptsTouchEvents = true
        }
    }
    
    override func prepareOpenGL() {
        guard let context = self.openGLContext else {fatalError()}
        guard let obj = context.cglContextObj else {fatalError()}
        context.setValues([GLint(4)], for: .swapInterval)
        CGLEnable(obj, kCGLCECrashOnRemovedFunctions)
        CGLSetCurrentContext(obj)
        CGLFlushDrawable(obj)
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        self.update()
    }
    
    override func update() {
        super.update()
        if let window = self.viewController.window {
            let scale = window.interfaceScaleFactor
            self.viewController.window?.window?.newPixelSize = Size2(Float(self.bounds.size.width), Float(self.bounds.size.height)) * scale
        }
    }

    override open func draw(_ dirtyRect: NSRect) {
        drawOpenGL()
    }

    func drawOpenGL() {
        guard let window = viewController.window?.window else {return}
        guard let ctxObj = self.openGLContext?.cglContextObj else {return}
        
        CGLLockContext(ctxObj)
        CGLSetCurrentContext(ctxObj)
        
        window.vSyncCalled()
        if window.didDrawSomething == true {
            CGLFlushDrawable(ctxObj)
        }
        CGLUnlockContext(ctxObj)
    }

    override var isFlipped: Bool {
        true
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        for trackingArea in trackingAreas {
            self.removeTrackingArea(trackingArea)
        }

        let trackingArea = NSTrackingArea(rect: self.bounds, options: [.activeAlways,
                                                                       .mouseEnteredAndExited,
                                                                       .mouseMoved,
                                                                       .cursorUpdate],
                                          owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
    }
}
#endif
