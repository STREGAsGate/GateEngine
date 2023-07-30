/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public typealias DeferredClosure = () -> Void

internal final class DeferredSystem: PlatformSystem {
    var deferredClosures: [DeferredClosure] = []
    
    @inline(__always)
    func insert(_ block: @escaping DeferredClosure) {
        deferredClosures.append(block)
    }
    
    override func update(game: Game, input: HID, withTimePassed deltaTime: Float) async {
        for closure in deferredClosures {
            closure()
        }
        deferredClosures.removeAll(keepingCapacity: true)
    }
    
    public override class var phase: PlatformSystem.Phase {.postDeferred}
    override class func sortOrder() -> PlatformSystemSortOrder? {.deferredSystem}
}

public extension System {
    @_transparent
    func `defer`(_ closure: @escaping DeferredClosure) {
        Game.shared.defer(closure)
    }
}

internal extension PlatformSystem {
    @_transparent
    func `defer`(_ closure: @escaping DeferredClosure) {
        Game.shared.defer(closure)
    }
}

@MainActor internal extension Game {
    @usableFromInline @inline(__always)
    func `defer`(_ closure: @escaping DeferredClosure) {
        let system = self.system(ofType: DeferredSystem.self)
        system.insert(closure)
    }
}
