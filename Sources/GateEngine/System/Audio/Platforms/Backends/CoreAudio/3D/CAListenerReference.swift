/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(AVFoundation)
import AVFoundation

internal final class CAListenerReference: SpatialAudioListenerBackend {
    unowned let environmentNode: AVAudioEnvironmentNode

    @usableFromInline
    init(environmentNode: AVAudioEnvironmentNode) {
        self.environmentNode = environmentNode
    }

    @inlinable
    func setPosition(_ position: Position3) {
        environmentNode.listenerPosition = AVAudio3DPoint(
            x: position.x,
            y: position.y,
            z: position.z
        )
    }

    @inlinable
    func setOrientation(forward: Direction3, up: Direction3) {
        let forward = AVAudio3DVector(x: forward.x, y: forward.y, z: forward.z)
        let up = AVAudio3DVector(x: up.x, y: up.y, z: up.z)
        environmentNode.listenerVectorOrientation = AVAudio3DVectorOrientation(
            forward: forward,
            up: up
        )
    }
}
#endif
