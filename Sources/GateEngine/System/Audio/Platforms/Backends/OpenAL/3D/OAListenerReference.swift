/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if GATEENGINE_USE_OPENAL
#if canImport(OpenALSoft)
import OpenALSoft
#elseif canImport(LinuxSupport)
import LinuxSupport
#endif
import GameMath

internal class OAListenerReference: SpatialAudioListenerBackend {
    unowned let context: OpenALContext

    init(_ mixerReference: OASpacialMixerReference) {
        self.context = mixerReference.context
    }

    func setPosition(_ position: Position3) {
        try? context.listener.setPosition(x: position.x, y: position.y, z: position.z)
    }

    func setOrientation(forward: Direction3, up: Direction3) {
        let forward = (forward.x, forward.y, forward.z)
        let up = (up.x, up.y, up.z)
        try? context.listener.setOrientation(forward: forward, up: up)
    }
    func setOrientation(forward: (x: Float, y: Float, z: Float), up: (x: Float, y: Float, z: Float))
    {

    }
}

#endif
