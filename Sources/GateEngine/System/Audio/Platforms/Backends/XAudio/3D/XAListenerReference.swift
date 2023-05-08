/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if canImport(WinSDK)
import Foundation
import WinSDK

internal class XAListenerReference: SpatialAudioListenerBackend {
    init() {}
    
    func setPosition(_ position: Position3) {
        fatalError()
    }

    func setOrientation(forward: Direction3, up: Direction3) {
        fatalError()
    }
}
#endif
