/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT
import Foundation
import WebAudio

internal class WAAudioMixerReference: AudioMixerReference {
    unowned let contextReference: WAContextReference
    let mixerNode: PannerNode
    let gainNode: GainNode
    
    init(_ contextReference: WAContextReference) {
        self.contextReference = contextReference
        
        self.mixerNode = contextReference.ctx.createPanner()
        self.gainNode = contextReference.ctx.createGain()
 
        mixerNode.connect(destinationNode: gainNode).connect(destinationNode: contextReference.ctx.destination)
    }

    @inlinable
    var volume: Float {
        get {
            return gainNode.gain.value
        }
        set {
            gainNode.gain.value = newValue
        }
    }
    
    @inlinable
    func createAudioTrackReference() -> AudioTrackReference {
        return WAAudioTrackReference(self)
    }
}
#endif

