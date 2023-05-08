/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(WinSDK)

import WinSDK
import GameMath
import Foundation

final class DX12Texture: TextureBackend {
    
    var size: Size2 {
        fatalError()
    }
    
    required init(renderTargetBackend: RenderTargetBackend) {

    }
    
    required init(data: Data, size: Size2, mipMapping: MipMapping) {
        
    }

    func replaceData(with data: Data, size: Size2, mipMapping: MipMapping) {
        
    }
}
#endif
