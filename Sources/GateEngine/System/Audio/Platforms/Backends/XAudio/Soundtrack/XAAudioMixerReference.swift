/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if canImport(WinSDK)
import Foundation
import WinSDK

internal class XAAudioMixerReference: AudioMixerReference {
    unowned let contextReference: XAContextReference
    
    init(_ contextReference: XAContextReference) {
        self.contextReference = contextReference
    }

    var volume: Float {
        get {
            return 0
        }
        set {

        }
    }
    
    func createAudioTrackReference() -> AudioTrackReference {
        return XAAudioTrackReference(self)
    }
}
#endif

