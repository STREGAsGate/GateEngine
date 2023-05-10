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
import Foundation

final class DX12Texture: TextureBackend {
    var dxTexture: D3DResource?

    var size: Size2 {
        if let desc: D3DResourceDescription = dxTexture?.resourceDescription {
            return Size2(Float(desc.width), Float(desc.height))
        }
        return .zero
    }
    
    required init(renderTargetBackend: RenderTargetBackend) {
        let renderTarget: DX12RenderTarget = renderTargetBackend as! DX12RenderTarget
        dxTexture = renderTarget.colorTexture
    }
    
    required init(data: Data, size: Size2, mipMapping: MipMapping) {
        let device: D3DDevice =  Game.shared.renderer.device
        do {
            let textureResourceDesc: D3DResourceDescription = Self.textureResourceDesc(size: size, mipMapping: mipMapping)
            self.dxTexture = try device.createCommittedResource(description: textureResourceDesc, properties: .forTexture, state: .copyDestination)
            try self.processTexture(data: data, size: size, textureResourceDesc: textureResourceDesc)
        }catch{
            DX12Renderer.checkError(error)
        }
    }

    func replaceData(with data: Data, size: Size2, mipMapping: MipMapping) {
        let device: D3DDevice =  Game.shared.renderer.device
        do {
            let textureResourceDesc: D3DResourceDescription = Self.textureResourceDesc(size: size, mipMapping: mipMapping)
            self.dxTexture = try device.createCommittedResource(description: textureResourceDesc, properties: .forTexture, state: .copyDestination)
            try self.processTexture(data: data, size: size, textureResourceDesc: textureResourceDesc)
        }catch{
            DX12Renderer.checkError(error)
        }
    }
    @inline(__always)
    static func textureResourceDesc(size: Size2, mipMapping: MipMapping) -> D3DResourceDescription {
        var textureResourceDesc: D3DResourceDescription = D3DResourceDescription()
        textureResourceDesc.mipLevels = 1
        textureResourceDesc.format = .r8g8b8a8Unorm
        textureResourceDesc.width = UInt64(size.width)
        textureResourceDesc.height = UInt32(size.height)
        textureResourceDesc.depthOrArraySize = 1
        textureResourceDesc.sampleDescription.count = 1
        textureResourceDesc.dimension = .texture2D
        textureResourceDesc.flags = []

        switch mipMapping {
        case .none:
            textureResourceDesc.mipLevels = 1
        case let .auto(levels):
            var size: Int = Int(size.width / 2)
            while size > 32 && textureResourceDesc.mipLevels <= levels {
                size /= 2
                textureResourceDesc.mipLevels += 1
            }
        }
        return textureResourceDesc
    }

    private func processTexture(data: Data, size: Size2, textureResourceDesc: D3DResourceDescription) throws {
        let renderer: DX12Renderer = Game.shared.renderer.backend
        let device: D3DDevice = renderer.device
        let fence: D3DFence = try device.createFence()
        let commandAllocator: D3DCommandAllocator = try device.createCommandAllocator(type: .direct)
        let commandList: D3DGraphicsCommandList = try device.createGraphicsCommandList(type: .direct, commandAllocator: commandAllocator)

        let pitch: UInt32 = {
            let alignment: UInt32 = UInt32(D3D12_TEXTURE_DATA_PITCH_ALIGNMENT)
            let count: UInt32 = UInt32(ceil(Float(size.width) / Float(alignment)))
            return alignment * count * 4
        }()

        let uploadHeap: D3DResource = {
            let heapProperties: D3DHeapProperties = D3DHeapProperties(type: .upload)
            var resourceDescription: D3DResourceDescription = D3DResourceDescription()
            resourceDescription.dimension = .buffer
            resourceDescription.width = UInt64(UInt(pitch) * UInt(size.height))
            resourceDescription.height = 1
            resourceDescription.depthOrArraySize = 1
            resourceDescription.mipLevels = 1
            resourceDescription.format = .unknown
            resourceDescription.sampleDescription.count = 1
            resourceDescription.layout = .rowMajor
            resourceDescription.flags = []
            do {
                let heap: D3DResource = try device.createCommittedResource(description: resourceDescription, properties: heapProperties, state: .genericRead)
                
                var pitchedData: Data = Data(repeating: 0, count: Int(resourceDescription.width))
                let pitch: Int = Int(pitch)
                let width: Int = Int(size.width)
                let rowSize: Int = MemoryLayout<Int8>.size * 4 * width
                for row: Int in 0 ..< Int(size.height) {
                    let srcStart: Int = row * rowSize
                    let subSource: Data = data.subdata(in: srcStart ..< srcStart + rowSize)
                    let dstStart: Int = pitch * row
                    pitchedData.replaceSubrange(dstStart ..< dstStart + rowSize, with: Data(subSource))
                }
                try pitchedData.withUnsafeBytes {
                    let buffer: UnsafeMutableRawPointer = try heap.map()!
                    memcpy(buffer, $0.baseAddress!, $0.count)
                    heap.unmap()
                }
                return heap
            }catch{
                DX12Renderer.checkError(error)
            }
        }()
        
        var rect: D3DBox = D3DBox()
        rect.right = UInt32(size.width)
        rect.bottom = UInt32(size.height)
        rect.back = 1

        let footprint: D3DSubresourceFootprint = D3DSubresourceFootprint(format: .r8g8b8a8Unorm, width: UInt32(size.width), height: UInt32(size.height), depth: 1, rowPitch: pitch)
        let suresourceFootprint: D3DPlacedSubresourceFootprint = D3DPlacedSubresourceFootprint(offset: 0, footprint: footprint)
        let source: D3DTextureCopyLocation = D3DTextureCopyLocation(resource: uploadHeap, type: .placedFootprint, placedFootprint: suresourceFootprint, subresourceIndex: 0)
        let blockDestination: D3DTextureCopyLocation = D3DTextureCopyLocation(resource: dxTexture, type: .subresourceIndex, placedFootprint: suresourceFootprint, subresourceIndex: 0)

        commandList.copyTextureRegion(rect, from: source, to: blockDestination)
        // commandList.copyResource(uploadHeap, to: dxTexture!)
        #warning("Not generating mipmaps")
        //TODO: Generate mipmaps with a compute shader

        var barrier: D3DResourceBarrier = D3DResourceBarrier()
        barrier.type = .transition
        barrier.transition.resource = dxTexture
        barrier.transition.stateBefore = .copyDestination
        barrier.transition.stateAfter = .pixelShaderResource

        commandList.resourceBarrier([barrier])

        try commandList.close()
        renderer.backgroundCommandQueue.executeCommandLists([commandList])
        func wait() throws {
            try renderer.backgroundCommandQueue.signal(fence: fence, value: 1)
            if fence.value < 1 {
                let h: HANDLE? = WinSDK.CreateEventW(nil, false, false, nil)
                defer {_ = CloseHandle(h)}
                try fence.setCompletionEvent(h, whenValueIs: 1)
                _ = WinSDK.WaitForSingleObject(h, INFINITE)
            }
        }
        try wait()
    }
}
#endif
