/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public typealias DeferredBlock = () -> Void

internal final class DeferredSystem: PlatformSystem {
    var deferredBlocks: [DeferredBlock] = []
    
    @inline(__always)
    func insert(_ block: @escaping DeferredBlock) {
        deferredBlocks.append(block)
    }
    
    override func update(game: Game, input: HID, withTimePassed deltaTime: Float) {
        for block in deferredBlocks {
            block()
        }
        deferredBlocks.removeAll(keepingCapacity: true)
    }
    
    public override class var phase: PlatformSystem.Phase {.postDeffered}
    override class func sortOrder() -> PlatformSystemSortOrder? {.defferedSystem}
}

public extension System {
    @_transparent
    func `defer`(_ block: @escaping DeferredBlock) {
        Game.shared.defer(block)
    }
}

internal extension PlatformSystem {
    @_transparent
    func `defer`(_ block: @escaping DeferredBlock) {
        Game.shared.defer(block)
    }
}

@MainActor internal extension Game {
    @usableFromInline @inline(__always)
    func `defer`(_ block: @escaping DeferredBlock) {
        let system = self.system(ofType: DeferredSystem.self)
        system.insert(block)
    }
}
