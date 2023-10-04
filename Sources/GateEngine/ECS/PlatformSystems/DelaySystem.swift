/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Collections

public typealias DelayClosure = () -> Void

struct Delay {
    let duration: Float
    var accumulatedTime: Float = 0
    let closure: DelayClosure
}

internal final class DelaySystem: PlatformSystem {

    var delays: Deque<Delay> = []
    
    @inline(__always)
    func append(duration: Float, closure: @escaping DelayClosure) {
        delays.append(Delay(duration: duration, closure: closure))
    }
    
    override func update(game: Game, input: HID, withTimePassed deltaTime: Float) async {
        for index in delays.indices.reversed() {
            delays[index].accumulatedTime += deltaTime
            let delay = delays[index]
            if delay.accumulatedTime > delay.duration {
                delay.closure()
                delays.remove(at: index)
            }
        }
    }
    
    override class var phase: PlatformSystem.Phase { .preUpdating }
    override nonisolated class func sortOrder() -> PlatformSystemSortOrder? {
        return .delaySystem
    }
}

public extension System {
    @inline(__always)
    func delay(_ duration: Float, completion: @escaping ()->()) {
        Game.shared.system(ofType: DelaySystem.self).append(duration: duration, closure: completion)
    }
}

internal extension PlatformSystem {
    @_transparent
    func delay(_ duration: Float, completion: @escaping ()->()) {
        Game.shared.system(ofType: DelaySystem.self).append(duration: duration, closure: completion)
    }
}
