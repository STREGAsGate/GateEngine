/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(OpenALSoft)

import Foundation
import OpenALSoft

internal class OAListenerReference: SpatialAudioListenerReference {
    unowned let context: OpenALContext
    
    init(_ mixerReference: OASpacialMixerReference) {
        self.context = mixerReference.context
    }
    
    func setPosition(x: Float, y: Float, z: Float) {
        try? context.listener.setPosition(x: x, y: y, z: z)
    }
    
    func setOrientation(forward: (x: Float, y: Float, z: Float), up: (x: Float, y: Float, z: Float)) {
        try? context.listener.setOrientation(forward: forward, up: up)
    }
}

#endif
