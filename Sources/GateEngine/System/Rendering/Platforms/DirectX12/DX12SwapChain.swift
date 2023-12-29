/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(WinSDK)
import WinSDK
import Direct3D12

@MainActor internal class DX12SwapChain {
    let bufferCount: UInt = 2
    var current: UInt = 0
    let swapChain: DGISwapChain
    let hWnd: HWND
    init(hWnd: HWND) {
        do {
            let factory: DGIFactory = Game.shared.renderer.backend.factory
            let refreshRate: DGIRational = DGIRational(numerator: 60, denominator: 1)
            let sampleDesc: DGISampleDescription = DGISampleDescription(count: 1, quality: 0)
            let description: DGISwapChainDescription1 = DGISwapChainDescription1(
                width: 0,
                height: 0,
                format: .r8g8b8a8Unorm,
                isStereo: false,
                sampleDescription: sampleDesc,
                bufferUsage: .renderTargetOutput,
                bufferCount: UInt32(bufferCount),
                scaling: .none,
                swapEffect: .flipDiscard,
                alphaMode: .unspecified,
                flags: [.allowTearing]
            )
            let fullScreen: DGISwapChainFullscreenDescription = DGISwapChainFullscreenDescription(
                refreshRate: refreshRate
            )
            self.hWnd = hWnd
            self.swapChain = try factory.createSwapChain(
                description: description,
                window: hWnd,
                fullScreen: fullScreen,
                commandQueue: Game.shared.renderer.backend.commandQueue
            )
        } catch {
            DX12Renderer.checkError(error)
        }
    }

    func applyBarrier(with commandList: D3DGraphicsCommandList, start: Bool) {
        var barrier: D3DResourceBarrier = D3DResourceBarrier()
        barrier.type = .transition
        barrier.transition.resource = currentBuffer
        barrier.transition.subresourceIndex = nil
        if start {
            barrier.transition.stateBefore = .present
            barrier.transition.stateAfter = .renderTarget
        } else {
            barrier.transition.stateBefore = .renderTarget
            barrier.transition.stateAfter = .present
        }

        commandList.resourceBarrier([barrier])
    }

    var currentBuffer: D3DResource {
        return try! swapChain.backBuffer(at: UInt32(current))
    }

    func setBackgroundColor(_ color: D3DColor) {
        swapChain.setBackgroundColor(color)
    }

    func reshape(renderTarget: DX12RenderTarget) {
        do {
            try self.swapChain.resizeBuffers(flags: [.allowTearing])
            current = 0
            var targetLocation: D3DCPUDescriptorHandle = renderTarget.renderTargetViewHeap
                .cpuDescriptorHandleForHeapStart
            for index: UInt in 0 ..< bufferCount {
                let buffer: D3DResource = try swapChain.backBuffer(at: UInt32(index))
                Game.shared.renderer.device.createRenderTargetView(
                    resource: buffer,
                    description: nil,
                    destination: targetLocation
                )
                targetLocation.pointer += UInt64(Game.shared.renderer.backend.rtvIncermentSize)
            }
        } catch {
            DX12Renderer.checkError(error)
        }
    }

    func present() {
        do {
            try swapChain.present()
            try Game.shared.renderer.backend.wait()
            InvalidateRect(self.hWnd, nil, false)
        } catch {
            DX12Renderer.checkError(error)
        }
        current += 1
        if current == bufferCount {
            current = 0
        }
    }
}
#endif
