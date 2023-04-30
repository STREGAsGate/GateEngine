/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation
import GameMath

@MainActor public final class SpriteAnimation {
    public let spriteSheet: SpriteSheet
    public let spriteSize: Size2
    public let duration: Float
    public var repeats: Bool
    public var scale: Float = 1
    internal var spriteSheetRow: UInt
    internal var spriteSheetColumnStart: UInt
    internal var spriteSheetColumnEnd: UInt
    internal var accumulatedTime: Float
    
    public var progress: Float {
        get {
            max(0, min(1, accumulatedTime / duration))
        }
        set {
            accumulatedTime = duration * max(0, min(1, newValue))
        }
    }

    public var isFinished: Bool {
        assert(repeats == false, "A repeating animation is never finished. Checking this property is likely a programming error.")
        return progress == 1
    }

    public init(spriteSheet: SpriteSheet, spriteSize: Size2, row: UInt, column: UInt, frames: UInt, duration: Float, repeats: Bool = true) {
        self.spriteSheet = spriteSheet
        self.spriteSize = spriteSize
        self.duration = duration
        self.repeats = repeats
        self.spriteSheetRow = row
        self.spriteSheetColumnStart = column
        self.spriteSheetColumnEnd = column + frames - 1
        self.accumulatedTime = 0
    }

    public func appendTime(_ deltaTime: Float) {
        accumulatedTime += deltaTime * scale
        while accumulatedTime > duration {
            if repeats {
                accumulatedTime -= duration
            }else{
                accumulatedTime = duration
            }
        }
    }

    public func currentSprite() -> Sprite? {
        guard spriteSheet.texture.state == .ready else {return nil}
        let factor = (1.0 / duration) * accumulatedTime
        let frame = Float(spriteSheetColumnStart).interpolated(to: Float(spriteSheetColumnEnd), .linear(factor))
        return spriteSheet.sprite(at: Position2(round(frame), Float(spriteSheetRow)), withSpriteSize: spriteSize)
    }
}
