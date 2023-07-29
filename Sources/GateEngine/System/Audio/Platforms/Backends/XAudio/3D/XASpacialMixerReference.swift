/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if canImport(WinSDK) && canImport(XAudio29)
import WinSDK
import XAudio29

internal class XASpacialMixerReference: SpacialAudioMixerReference {
    unowned let contextReference: XAContextReference

    init(_ contextReference: XAContextReference) {
        self.contextReference = contextReference
    }
    
    public var minimumAttenuationDistance: Float {
        get {
            return 0
        }
        set {

        }
    }

    public var volume: Float {
        get {
            return 0
        }
        set {

        }
    }
    
    func createListenerReference() -> any SpatialAudioListenerBackend {
        return XAListenerReference()
    }
    
    func createSourceReference() -> any SpatialAudioSourceReference {
        return XASourceReference(self)
    }
}
#endif
