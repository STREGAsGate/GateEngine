/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(MetalKit)

import MetalKit
import GameMath

class MetalRenderTarget: RenderTargetBackend {
    var size: Size2 = Size2(2)
    var isFirstPass = true
    
    internal var commandBuffer: (any MTLCommandBuffer)! = nil
    internal var commandEncoder: (any MTLRenderCommandEncoder)! = nil
    
    internal private(set) var colorTexture: (any MTLTexture)? = nil
    internal private(set) var depthTexture: (any MTLTexture)! = nil
    
    private var mtlClearColor: MTLClearColor = MTLClearColor(red: Double(Color.clear.red),
                                                             green: Double(Color.clear.green),
                                                             blue: Double(Color.clear.blue),
                                                             alpha: Double(Color.clear.alpha))
    var clearColor: Color {
        get {
            return Color(red: Float(mtlClearColor.red),
                         green: Float(mtlClearColor.green),
                         blue: Float(mtlClearColor.blue),
                         alpha: Float(mtlClearColor.alpha))
        }
        set {
            mtlClearColor = MTLClearColor(red: Double(newValue.red),
                                          green: Double(newValue.green),
                                          blue: Double(newValue.blue),
                                          alpha: Double(newValue.alpha))
        }
    }
    
    let metalView: MTKView?
    init(windowBacking: (any WindowBacking)?) {
        if let windowBacking {
            #if canImport(AppKit)
            metalView = ((windowBacking as! AppKitWindow).nsWindowController.contentViewController!.view as! MTKView)
            #elseif canImport(UIKit)
            metalView = ((windowBacking as! UIKitWindow).uiWindow.rootViewController!.view as! MTKView)
            #endif
        }else{
            self.metalView = nil
        }
    }
    
    private let reshapeDescriptor: MTLTextureDescriptor = {
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.resourceOptions = .storageModePrivate
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        return textureDescriptor
    }()
    func reshape() {
        reshapeDescriptor.width = Int(size.width)
        reshapeDescriptor.height = Int(size.height)
        reshapeDescriptor.pixelFormat = .bgra8Unorm
        if metalView == nil {
            self.colorTexture = Game.shared.renderer.device.makeTexture(descriptor: reshapeDescriptor)!
        }

        reshapeDescriptor.pixelFormat = .depth32Float
        self.depthTexture = Game.shared.renderer.device.makeTexture(descriptor: reshapeDescriptor)!
    }
    
    func willBeginFrame(_ frame: UInt) {
        self.isFirstPass = true
        self.commandBuffer = Game.shared.renderer.commandQueue.makeCommandBuffer()!
    }
    
    func didEndFrame(_ frame: UInt) {
        if let drawable = metalView?.currentDrawable {
            commandBuffer.present(drawable)
        }
        self.commandBuffer.commit()
    }
    
    func willBeginContent(matrices: Matrices?, viewport: GameMath.Rect?) {
        if self.isFirstPass {
            self.isFirstPass = false
            self.commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: firstPassRenderPassDescriptor)
        }else{
            self.commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        }
        if let viewport {
            let mtlViewport = MTLViewport(originX: Double(viewport.position.x),
                                          originY: Double(viewport.position.y),
                                          width: Double(viewport.size.width),
                                          height: Double(viewport.size.height),
                                          znear: 0,
                                          zfar: 1)
            self.commandEncoder.setViewport(mtlViewport)
        }
    }
    
    func didEndContent() {
        self.commandEncoder.endEncoding()
    }
    
    @inline(__always)
    private var renderPassDescriptor: MTLRenderPassDescriptor {
        var descriptor: MTLRenderPassDescriptor

        if let metalView = self.metalView {
            descriptor = metalView.currentRenderPassDescriptor!
            
            descriptor.colorAttachments[0].texture = metalView.currentDrawable!.texture
            descriptor.colorAttachments[0].clearColor = mtlClearColor
            descriptor.colorAttachments[0].loadAction = .load
            descriptor.colorAttachments[0].storeAction = .store
        }else{
            descriptor = MTLRenderPassDescriptor()

            descriptor.colorAttachments[0].texture = self.colorTexture
            descriptor.colorAttachments[0].clearColor = mtlClearColor
            descriptor.colorAttachments[0].loadAction = .load
            descriptor.colorAttachments[0].storeAction = .store
        }
        
        descriptor.depthAttachment.loadAction = .load
        descriptor.depthAttachment.storeAction = .store
        descriptor.depthAttachment.texture = self.depthTexture

        return descriptor
    }
    
    @inline(__always)
    private var firstPassRenderPassDescriptor: MTLRenderPassDescriptor {
        let descriptor: MTLRenderPassDescriptor = renderPassDescriptor

        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].storeAction = .store
        
        descriptor.depthAttachment.loadAction = .clear
        descriptor.depthAttachment.storeAction = .store

        return descriptor
    }
}
#endif
