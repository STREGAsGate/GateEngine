/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT
import DOM
import JavaScriptKit
import WebAudio

internal class WASpacialMixerReference: SpacialAudioMixerReference {
    unowned let contextReference: WAContextReference
    let mixerNode: PannerNode
    let gainNode: GainNode
    
    init(_ contextReference: WAContextReference) {
        self.contextReference = contextReference

        self.mixerNode = contextReference.ctx.createPanner()
        self.gainNode = contextReference.ctx.createGain()
        
        gainNode.connect(destinationNode: mixerNode).connect(destinationNode: contextReference.ctx.destination)
    }
    
    public var minimumAttenuationDistance: Float {
        get {
            return Float(mixerNode.refDistance)
        }
        set {
            mixerNode.refDistance = Double(newValue)
        }
    }

    public var volume: Float {
        get {
            return gainNode.gain.value
        }
        set {
            gainNode.gain.value = newValue
        }
    }
    
    @inlinable
    func createListenerReference() -> any SpatialAudioListenerBackend {
        return WAListenerReference(self)
    }
    @inlinable
    func createSourceReference() -> any SpatialAudioSourceReference {
        return WASourceReference(self)
    }
}
#endif
