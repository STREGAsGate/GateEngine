/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if HTML5
import WebAudio

internal class WAListenerReference: SpatialAudioListenerBackend {
    let listener: AudioListener

    @usableFromInline
    init(_ mixer: WASpacialMixerReference) {
        self.listener = mixer.contextReference.ctx.listener
    }

    @inlinable
    func setPosition(_ position: Position3) {
        listener.setPosition(x: position.x, y: position.y, z: position.z)
    }

    @inlinable
    func setOrientation(forward: Direction3, up: Direction3) {
        listener.setOrientation(
            x: forward.x,
            y: forward.y,
            z: forward.z,
            xUp: up.x,
            yUp: up.y,
            zUp: up.z
        )
    }
}
#endif
