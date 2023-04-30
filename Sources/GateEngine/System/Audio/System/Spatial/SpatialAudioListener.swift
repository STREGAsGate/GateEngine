/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
import GameMath

internal protocol SpatialAudioListenerBackend {
    func setPosition(_ position: Position3)
    func setOrientation(forward: Direction3, up: Direction3)
}

public struct SpatialAudioListener {
    internal unowned let mixer: SpatialAudioMixer
    internal let reference: SpatialAudioListenerBackend
    
    init(_ mixer: SpatialAudioMixer) {
        self.mixer = mixer
        self.reference = mixer.reference.createListenerReference()
    }
    
    public func setPosition(_ position: Position3) {
        reference.setPosition(position)
    }
        
    public func setOrientation(forward: Direction3, up: Direction3) {
        reference.setOrientation(forward: forward, up: up)
    }
}
