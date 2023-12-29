/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(WinSDK)
import WinSDK
import Direct3D12
import GameMath
import struct Foundation.Date

class DX12RenderTarget: RenderTargetBackend {
    var size: Size2 = Size2(2)
    var isFirstPass: Bool = true

    var colorTexture: D3DResource? = nil
    var depthStencilTexture: D3DResource! = nil

    var wantsReshape: Bool = true
    private var dxClearValue: D3DClearValue = D3DClearValue(format: .r8g8b8a8Unorm, color: .black)
    private var lastColorChange = Date.distantPast
    var clearColor: Color {
        get {
            return Color(
                dxClearValue.color.red,
                dxClearValue.color.green,
                dxClearValue.color.blue,
                dxClearValue.color.alpha
            )
        }
        set {
            let new: D3DColor = D3DColor(
                red: newValue.red,
                green: newValue.green,
                blue: newValue.blue,
                alpha: newValue.alpha
            )
            if dxClearValue.color != new {
                if lastColorChange.timeIntervalSinceNow < -0.5 {
                    // Redraw for optimized clear if the color is changed infrequently
                    wantsReshape = true
                }
                lastColorChange = Date()
                dxClearValue.color = new
            }
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
            let desc: D3DDescriptorHeapDescription = D3DDescriptorHeapDescription(
                type: .renderTargetView,
                count: UInt32(swapChain?.bufferCount ?? 1),
                flags: []
            )
            return try renderer.device.createDescriptorHeap(description: desc)
        } catch {
            DX12Renderer.checkError(error)
        }
    }()
    lazy var depthStencilViewHeap: D3DDescriptorHeap = {
        do {
            let desc: D3DDescriptorHeapDescription = D3DDescriptorHeapDescription(
                type: .depthStencilView,
                count: 1,
                flags: []
            )
            return try renderer.device.createDescriptorHeap(description: desc)
        } catch {
            DX12Renderer.checkError(error)
        }
    }()

    init(windowBacking: (any WindowBacking)?) {
        if let windowBacking {
            let windowBacking: Win32Window = windowBacking as! Win32Window
            self.swapChain = windowBacking.swapChain
        } else {
            self.swapChain = nil
        }
        do {
            let device: D3DDevice = Game.shared.renderer.device
            let commandAllocator: D3DCommandAllocator = try device.createCommandAllocator(
                type: .direct
            )
            self.commandAllocator = commandAllocator
            self.commandList = try device.createGraphicsCommandList(
                type: .direct,
                commandAllocator: commandAllocator
            )
            try self.commandList.close()
        } catch {
            DX12Renderer.checkError(error)
        }
    }

    func reshape() {
        wantsReshape = false

        do {
            // Buffers must be released before reshape
            self.colorTexture = nil
            self.depthStencilTexture = nil

            let desc: D3DDescriptorHeapDescription = D3DDescriptorHeapDescription(
                type: .renderTargetView,
                count: UInt32(swapChain?.bufferCount ?? 1),
                flags: []
            )
            self.renderTargetViewHeap = try renderer.device.createDescriptorHeap(description: desc)

            var resourceDescription: D3DResourceDescription = D3DResourceDescription()
            resourceDescription.dimension = .texture2D
            resourceDescription.width = UInt64(size.width)
            resourceDescription.height = UInt32(size.height)
            resourceDescription.depthOrArraySize = 1
            resourceDescription.mipLevels = 1
            resourceDescription.sampleDescription.count = 1
            resourceDescription.layout = .unknown

            if let swapChain: DX12SwapChain = swapChain {
                swapChain.reshape(renderTarget: self)
            } else {
                resourceDescription.format = dxClearValue.format
                resourceDescription.flags = .allowRenderTarget
                self.colorTexture = try renderer.device.createCommittedResource(
                    description: resourceDescription,
                    properties: .forTexture,
                    state: .renderTarget,
                    clearValue: dxClearValue
                )

                let targetLocation: D3DCPUDescriptorHandle = renderTargetViewHeap
                    .cpuDescriptorHandleForHeapStart
                renderer.device.createRenderTargetView(
                    resource: colorTexture!,
                    description: nil,
                    destination: targetLocation
                )
            }

            // Reshape depthStencil
            let depthClearValue: D3DClearValue = D3DClearValue(
                format: .d32Float,
                color: dxClearValue.color
            )
            resourceDescription.format = depthClearValue.format
            resourceDescription.flags = .allowDepthStencil

            self.depthStencilTexture = try renderer.device.createCommittedResource(
                description: resourceDescription,
                properties: .forTexture,
                state: .depthWrite,
                clearValue: depthClearValue
            )

            var depthDescription: D3DDepthStencilViewDescription = D3DDepthStencilViewDescription()
            depthDescription.format = .d32Float
            depthDescription.dimension = .texture2D
            depthDescription.texture2D = D3DTexture2DDepthStencilView(mipIndex: 0)
            let dsvLocation: D3DCPUDescriptorHandle = depthStencilViewHeap
                .cpuDescriptorHandleForHeapStart
            renderer.device.createDepthStencilView(
                resource: depthStencilTexture,
                description: depthDescription,
                destination: dsvLocation
            )
        } catch {
            DX12Renderer.checkError(error)
        }
    }

    func willBeginFrame(_ frame: UInt) {
        self.isFirstPass = true
        if let swapChain: DX12SwapChain = swapChain {
            colorTexture = swapChain.currentBuffer
        }
        do {
            try self.commandAllocator.reset()
            try self.commandList.reset(
                usingOriginalAllocator: commandAllocator,
                withInitialState: nil
            )

            swapChain?.applyBarrier(with: commandList, start: true)

            var rtvLocation: D3DCPUDescriptorHandle = renderTargetViewHeap
                .cpuDescriptorHandleForHeapStart
            rtvLocation.pointer += UInt64(
                renderer.rtvIncermentSize * UInt32(swapChain?.current ?? 0)
            )

            let dsvLocation: D3DCPUDescriptorHandle = depthStencilViewHeap
                .cpuDescriptorHandleForHeapStart
            self.commandList.setRenderTargets([rtvLocation], depthStencil: dsvLocation)

            self.commandList.clearRenderTargetView(rtvLocation, withColor: dxClearValue.color)
            self.commandList.clearDepthStencilView(dsvLocation, flags: [.depth, .stencil])
            try self.commandList.close()
            renderer.commandQueue.executeCommandLists([self.commandList])
            try renderer.wait()
        } catch {
            DX12Renderer.checkError(error)
        }
    }

    func didEndFrame(_ frame: UInt) {
        do {
            try self.commandList.reset(
                usingOriginalAllocator: commandAllocator,
                withInitialState: nil
            )

            var rtvLocation: D3DCPUDescriptorHandle = renderTargetViewHeap
                .cpuDescriptorHandleForHeapStart
            rtvLocation.pointer += UInt64(
                renderer.rtvIncermentSize * UInt32(swapChain?.current ?? 0)
            )

            let dsvLocation: D3DCPUDescriptorHandle = depthStencilViewHeap
                .cpuDescriptorHandleForHeapStart
            self.commandList.setRenderTargets([rtvLocation], depthStencil: dsvLocation)

            swapChain?.applyBarrier(with: commandList, start: false)

            try self.commandList.close()
            renderer.commandQueue.executeCommandLists([self.commandList])

            if let swapChain: DX12SwapChain = swapChain {
                swapChain.present()
            }
        } catch {
            DX12Renderer.checkError(error)
        }

        renderer.cachedContent.removeAll(keepingCapacity: true)
    }

    func willBeginContent(matrices: Matrices?, viewport: GameMath.Rect?, scissorRect: GameMath.Rect?) {
        do {
            try self.commandList.reset(
                usingOriginalAllocator: commandAllocator,
                withInitialState: nil
            )

            var rtvLocation: D3DCPUDescriptorHandle = renderTargetViewHeap
                .cpuDescriptorHandleForHeapStart
            rtvLocation.pointer += UInt64(
                renderer.rtvIncermentSize * UInt32(swapChain?.current ?? 0)
            )

            let dsvLocation: D3DCPUDescriptorHandle = depthStencilViewHeap
                .cpuDescriptorHandleForHeapStart
            self.commandList.setRenderTargets([rtvLocation], depthStencil: dsvLocation)

            if let viewport: Rect = viewport {
                self.commandList.setViewports([
                    D3DViewport(width: viewport.size.width, height: viewport.size.height)
                ])
            } else {
                self.commandList.setViewports([D3DViewport(width: size.width, height: size.height)])
            }
            
            if let scissorRect: Rect = scissorRect {
                self.commandList.setScissorRects([
                    D3DRect(
                        x: Int(scissorRect.position.x),
                        y: Int(scissorRect.position.y),
                        width: Int(scissorRect.size.width),
                        height: Int(scissorRect.size.height)
                    )
                ])
            } else {
                self.commandList.setScissorRects([
                    D3DRect(x: 0, y: 0, width: Int(size.width), height: Int(size.height))
                ])
            }
        } catch {
            DX12Renderer.checkError(error)
        }
    }

    func didEndContent() {
        do {
            try self.commandList.close()
            renderer.commandQueue.executeCommandLists([self.commandList])
            try renderer.wait()
        } catch {
            DX12Renderer.checkError(error)
        }
    }
}
#endif
