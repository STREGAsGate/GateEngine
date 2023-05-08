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
import Shaders

class DX12Renderer: RendererBackend {
    let factory: DGIFactory
    let device: D3DDevice

    let commandQueue: D3DCommandQueue
    let backgroundCommandQueue: D3DCommandQueue

    let rtvIncermentSize: UInt32
    let dsvIncrementSize: UInt32
    let cbvIncrementSize: UInt32

    func draw(_ drawCommand: DrawCommand, camera: Camera?, matrices: Matrices, renderTarget: RenderTarget) {
        let renderTarget: DX12RenderTarget = renderTarget.backend as! DX12RenderTarget
        let geometries: ContiguousArray<DX12Geometry> = ContiguousArray(drawCommand.geometries.map({$0 as! DX12Geometry}))
        
    }

    init() {
        do {
            #if GATEENGINE_DEBUG_RENDERING
            try D3DDebug().enableDebugLayer()
            print("D3DDebug: Debug layer enabled.")
            #endif
            let factory: DGIFactory = try DGIFactory()
            let device: D3DDevice = try factory.createDefaultDevice()
            self.factory = factory
            self.device = device
            self.commandQueue = try device.createCommandQueue(type: .direct, priority: .high)
            self.backgroundCommandQueue = try device.createCommandQueue(type: .direct, priority: .normal)

            self.rtvIncermentSize = device.descriptorHandleIncrementSize(for: .renderTargetView)
            self.dsvIncrementSize = device.descriptorHandleIncrementSize(for: .depthStencilView)
            self.cbvIncrementSize = device.descriptorHandleIncrementSize(for: .constantBufferShaderResourceAndUnordererAccess)
        }catch{
            DX12Renderer.checkError(error)
        }
    }

    private var fence: D3DFence! = nil
    private var fenceValue: UInt64 = 0
    func wait() throws {
        if fence == nil {
            fence = try device.createFence()
        }
        fenceValue += 1
        try commandQueue.signal(fence: fence, value: fenceValue)
        if fence.value < fenceValue {
            let h: HANDLE? = WinSDK.CreateEventW(nil, false, false, nil)
            defer {_ = CloseHandle(h)}
            try fence.setCompletionEvent(h, whenValueIs: fenceValue)
            _ = WinSDK.WaitForSingleObject(h, INFINITE)
        }
    }
}

extension DX12Renderer {
    static func createBuffer<T>(withData data: [T], heapProperties: D3DHeapProperties, state: D3DResourceStates) -> D3DResource {
        var resourceDesciption: D3DResourceDescription = D3DResourceDescription()
        resourceDesciption.dimension = .buffer
        resourceDesciption.format = .unknown
        resourceDesciption.layout = .rowMajor
        resourceDesciption.width = UInt64(((MemoryLayout<T>.stride * data.count) + 255) & ~255)
        resourceDesciption.height = 1
        resourceDesciption.depthOrArraySize = 1
        resourceDesciption.mipLevels = 1
        resourceDesciption.sampleDescription.count = 1

        do {
            let resource: D3DResource = try Game.shared.renderer.device.createCommittedResource(description: resourceDesciption, properties: heapProperties, state: state)
            #if GATEENGINE_DEBUG_RENDERING
            try resource.setDebugName("\(type(of: self)).\(#function)")
            #endif
            try data.withUnsafeBytes {
                let buffer: UnsafeMutableRawPointer? = try resource.map()
                _ = memcpy(buffer, $0.baseAddress, $0.count)
                resource.unmap()
            }
            return resource
        }catch{
            DX12Renderer.checkError(error)
        }
    }

    static func checkError(_ error: Swift.Error, function: String = #function, line: Int = #line) -> Never {
        print("[GateEngine] Error: \(Self.self).\(#function)\n", error)
        do {
            try Game.shared.renderer.device.checkDeviceRemovedReason()
        }catch{
            print("[GateEngine] Device Removed Reason:\n", error)
        }
        fatalError()
    }
}

extension Renderer {
    @_transparent
    var backend: DX12Renderer {
        return self._backend as! DX12Renderer
    }
    @_transparent
    var device: D3DDevice {
        return backend.device
    }
    @_transparent
    var backgroundCommandQueue: D3DCommandQueue {
        return backend.backgroundCommandQueue
    }
}
#endif
