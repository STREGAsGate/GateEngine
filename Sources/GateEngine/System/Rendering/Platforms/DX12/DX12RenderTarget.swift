/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(WinSDK)

import WinSDK
import GameMath

class DX12RenderTarget: RenderTargetBackend {
    var size: Size2 = Size2(2)
    var isFirstPass = true
    
    var clearColor: Color {
        get {
            return .black
        }
        set {
            fatalError()
        }
    }
    
    
    init(windowBacking: WindowBacking?) {
        if let windowBacking {

        }else{
            
        }
    }
    
    func reshape() {

    }
    
    func willBeginFrame() {
        self.isFirstPass = true

    }
    
    func didEndFrame() {

    }
    
    func willBeginContent(matrices: Matrices?, viewport: GameMath.Rect?) {
        if self.isFirstPass {
            self.isFirstPass = false

        }else{

        }
        if let viewport {

        }
    }
    
    func didEndContent() {

    }
}
#endif
