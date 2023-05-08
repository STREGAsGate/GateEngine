/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(WinSDK)
import WinSDK
import Direct3D12
import GameMath

class DX12RenderTarget: RenderTargetBackend {
    var size: Size2 = Size2(2)
    var isFirstPass: Bool = true
    
    var colorTexture: D3DResource? = nil
    var depthStencilTexture: D3DResource! = nil

    private var dxClearColor: D3DColor = D3DColor(red: 0, green: 0, blue: 0, alpha: 1)
    var clearColor: Color {
        get {
            return Color(dxClearColor.red, dxClearColor.green, dxClearColor.blue, dxClearColor.alpha)
        }
        set {
            dxClearColor = D3DColor(red: newValue.red, green: newValue.green, blue: newValue.blue, alpha: newValue.alpha)
        }
    }

    @inline(__always)
    private var renderer: DX12Renderer {
        return Game.shared.renderer.backend
    }
    
    let commandAllocator: D3DCommandAllocator
    let commandList: D3DGraphicsCommandList
    let swapChain: DX12SwapChain?

    lazy var renderTargetViewHeap: D3DDescriptorHeap = {
        do {
            let desc: D3DDescriptorHeapDescription = D3DDescriptorHeapDescription(type: .renderTargetView, count: UInt32(swapChain?.bufferCount ?? 1), flags: [])
            return try renderer.device.createDescriptorHeap(description: desc)
        }catch{
            DX12Renderer.checkError(error)
        }
    }()
    lazy var depthStencilViewHeap: D3DDescriptorHeap = {
        do {
            let desc: D3DDescriptorHeapDescription = D3DDescriptorHeapDescription(type: .depthStencilView, count: 1, flags: [])
            return try renderer.device.createDescriptorHeap(description: desc)
        }catch{
            DX12Renderer.checkError(error)
        }
    }()
    
    init(windowBacking: WindowBacking?) {
        let windowBacking: Win32Window? = windowBacking as? Win32Window
        self.swapChain = windowBacking?.swapChain
        do {
            let device: D3DDevice = Game.shared.renderer.device
            let commandAllocator: D3DCommandAllocator = try device.createCommandAllocator(type: .direct)
            self.commandAllocator = commandAllocator
            self.commandList = try device.createGraphicsCommandList(type: .direct, commandAllocator: commandAllocator)
            try self.commandList.close()
        }catch{
            DX12Renderer.checkError(error)
        }
    }
    
    func reshape() {
        do {
            self.colorTexture = nil
            self.depthStencilTexture = nil

            let desc: D3DDescriptorHeapDescription = D3DDescriptorHeapDescription(type: .renderTargetView, count: UInt32(swapChain?.bufferCount ?? 1), flags: [])
            self.renderTargetViewHeap = try renderer.device.createDescriptorHeap(description: desc)

            var clearValue: D3DClearValue = D3DClearValue(format: .r8g8b8a8Unorm, color: dxClearColor, depthStencil: D3DDepthStencilValue(depth: 1, stencil: 0))

            var resourceDesciption: D3DResourceDescription = D3DResourceDescription()
            resourceDesciption.dimension = .texture2D
            resourceDesciption.width = UInt64(size.width)
            resourceDesciption.height = UInt32(size.height)
            resourceDesciption.depthOrArraySize = 1
            resourceDesciption.mipLevels = 1
            resourceDesciption.sampleDescription.count = 1
            resourceDesciption.layout = .unknown
            
            if let swapChain: DX12SwapChain = swapChain {
                swapChain.reshape(renderTarget: self)
            }else{
                resourceDesciption.format = .r8g8b8a8Unorm
                resourceDesciption.flags = .allowRenderTarget
                self.colorTexture = try renderer.device.createCommittedResource(description: resourceDesciption, properties: .forTexture, state: .renderTarget, clearValue: clearValue)
            
                let targetLocation: D3DCPUDescriptorHandle = renderTargetViewHeap.cpuDescriptorHandleForHeapStart
                renderer.device.createRenderTargetView(resource: colorTexture!, description: nil, destination: targetLocation)
            }
            
            // Reshape depthStencil

            clearValue.format = .d32Float
            resourceDesciption.format = .r32Typeless
            resourceDesciption.flags = .allowDepthStencil

            self.depthStencilTexture = try renderer.device.createCommittedResource(description: resourceDesciption, properties: .forTexture, state: .depthWrite, clearValue: clearValue)

            var depthDescription: D3DDepthStencilViewDescription = D3DDepthStencilViewDescription()
            depthDescription.format = .d32Float
            depthDescription.dimension = .texture2D
            depthDescription.texture2D = D3DTexture2DDepthStencilView(mipIndex: 0)
            let dsvLocation: D3DCPUDescriptorHandle = depthStencilViewHeap.cpuDescriptorHandleForHeapStart
            renderer.device.createDepthStencilView(resource: depthStencilTexture, description: depthDescription, destination: dsvLocation)
        }catch{
            DX12Renderer.checkError(error)
        }
    }
    
    func willBeginFrame() {
        self.isFirstPass = true
        if let swapChain: DX12SwapChain = swapChain {
            colorTexture = swapChain.currentBuffer
        }
        do {
            try self.commandAllocator.reset()
            try self.commandList.reset(usingOriginalAllocator: commandAllocator, withInitialState: nil)
            
            swapChain?.applyBarrier(with: commandList, start: true)
            
            var rtvLocation: D3DCPUDescriptorHandle = renderTargetViewHeap.cpuDescriptorHandleForHeapStart
            rtvLocation.pointer += UInt64(renderer.rtvIncermentSize * UInt32(swapChain?.current ?? 0))

            let dsvLocation: D3DCPUDescriptorHandle = depthStencilViewHeap.cpuDescriptorHandleForHeapStart
            self.commandList.setRenderTargets([rtvLocation], depthStencil: dsvLocation)

            self.commandList.clearRenderTargetView(rtvLocation, withColor: dxClearColor)
            self.commandList.clearDepthStencilView(dsvLocation)
            try self.commandList.close()
            renderer.commandQueue.executeCommandLists([self.commandList])
            try renderer.wait()
        }catch{
            DX12Renderer.checkError(error)
        }
    }
    
    func didEndFrame() {
       do {
            try self.commandList.reset(usingOriginalAllocator: commandAllocator, withInitialState: nil)

            var rtvLocation: D3DCPUDescriptorHandle = renderTargetViewHeap.cpuDescriptorHandleForHeapStart
            rtvLocation.pointer += UInt64(renderer.rtvIncermentSize * UInt32(swapChain?.current ?? 0))

            let dsvLocation: D3DCPUDescriptorHandle = depthStencilViewHeap.cpuDescriptorHandleForHeapStart
            self.commandList.setRenderTargets([rtvLocation], depthStencil: dsvLocation)

            swapChain?.applyBarrier(with: commandList, start: false)

            try self.commandList.close()
            renderer.commandQueue.executeCommandLists([self.commandList])

            if let swapChain: DX12SwapChain = swapChain {
                swapChain.present()
            }
        }catch{
            DX12Renderer.checkError(error)
        }
    }
    
    func willBeginContent(matrices: Matrices?, viewport: GameMath.Rect?) {
        do {
            try self.commandList.reset(usingOriginalAllocator: commandAllocator, withInitialState: nil)

            var rtvLocation: D3DCPUDescriptorHandle = renderTargetViewHeap.cpuDescriptorHandleForHeapStart
            rtvLocation.pointer += UInt64(renderer.rtvIncermentSize * UInt32(swapChain?.current ?? 0))

            let dsvLocation: D3DCPUDescriptorHandle = depthStencilViewHeap.cpuDescriptorHandleForHeapStart
            self.commandList.setRenderTargets([rtvLocation], depthStencil: dsvLocation)

            if let viewport: Rect = viewport {
                self.commandList.setViewports([D3DViewport(width: viewport.size.width, height: viewport.size.height)])
                self.commandList.setScissorRects([D3DRect(x: Int(viewport.position.x), y: Int(viewport.position.y), width: Int(viewport.size.width), height: Int(viewport.size.height))])
            }else{
                self.commandList.setViewports([D3DViewport(width: size.width, height: size.height)])
                self.commandList.setScissorRects([D3DRect(x: 0, y: 0, width: Int(size.width), height: Int(size.height))])
            }
        }catch{
            DX12Renderer.checkError(error)
        }
    }
    
    func didEndContent() {
        do {
            try self.commandList.close()
            renderer.commandQueue.executeCommandLists([self.commandList])
            try renderer.wait()
        }catch{
            DX12Renderer.checkError(error)
        }
    }
}
#endif
