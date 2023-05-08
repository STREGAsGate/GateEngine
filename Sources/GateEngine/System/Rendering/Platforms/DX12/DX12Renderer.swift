/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(WinSDK)
import WinSDK
import GameMath
import Shaders

class DX12Renderer: RendererBackend {
    func draw(_ drawCommand: DrawCommand, camera: Camera?, matrices: Matrices, renderTarget: RenderTarget) {
        let renderTarget: DX12RenderTarget = renderTarget.backend as! DX12RenderTarget
        let geometries: ContiguousArray<DX12Geometry> = ContiguousArray(drawCommand.geometries.map({$0 as! DX12Geometry}))
        
    }
}
#endif
