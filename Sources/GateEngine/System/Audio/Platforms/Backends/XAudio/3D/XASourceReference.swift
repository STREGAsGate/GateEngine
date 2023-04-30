/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if canImport(WinSDK)
import Foundation
import WinSDK

internal class XASourceReference: SpatialAudioSourceReference {
    unowned let mixerReference: XASpacialMixerReference
    
    init(_ mixerReference: XASpacialMixerReference) {
        self.mixerReference = mixerReference
        
    }
    
    var repeats: Bool = false
    var volume: Float {
        get {
            return 0
        }
        set {

        }
    }
    var pitch: Float {
        get {
            return 0
        }
        set {

        }
    }
    
    func play() {

    }
    func pause() {

    }
    func stop() {

    }
    
    func setPosition(x: Float, y: Float, z: Float) {

    }
    
    private weak var buffer: XABufferReference?

    func setBuffer(_ buffer: AudioBuffer) {
        self.buffer = buffer.reference as? XABufferReference
    }
}
#endif
