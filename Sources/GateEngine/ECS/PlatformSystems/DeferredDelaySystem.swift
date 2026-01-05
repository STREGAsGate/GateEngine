/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Collections

public typealias DeferredClosure = () -> Void
public typealias DelayClosure = () -> Void
struct Delay {
    let duration: Float
    var accumulatedTime: Float = 0
    let closure: DelayClosure
}

internal final class DeferredDelaySystem: PlatformSystem {
    var deferredClosures: [DeferredClosure] = []
    var delays: Deque<Delay> = []
    
    @inlinable
    func append(deferredClosure block: @escaping DeferredClosure) {
        deferredClosures.append(block)
    }
    
    @inlinable
    func append(delayDuration duration: Float, closure: @escaping DelayClosure) {
        delays.append(Delay(duration: duration, closure: closure))
    }

    override func update(context: ECSContext, input: HID, withTimePassed deltaTime: Float) async {
        for closure in deferredClosures {
            closure()
        }
        if deferredClosures.isEmpty == false {
            deferredClosures.removeAll(keepingCapacity: true)
        }
        
        for index in delays.indices.reversed() {
            delays[index].accumulatedTime += deltaTime
            let delay = delays[index]
            if delay.accumulatedTime > delay.duration {
                delay.closure()
                delays.remove(at: index)
            }
        }
    }

    public override class var phase: PlatformSystem.Phase { .postDeferred }
    override class func sortOrder() -> PlatformSystemSortOrder? { .deferredSystem }
}

extension ECSContext {
    public func `defer`(_ closure: @escaping DeferredClosure) {
        let system = self.system(ofType: DeferredDelaySystem.self)
        system.append(deferredClosure: closure)
    }
    
    public func delay(_ duration: Float, completion: @escaping ()->()) {
        let system = self.system(ofType: DeferredDelaySystem.self)
        system.append(delayDuration: duration, closure: completion)
    }
}

extension System {
    public func `defer`(_ closure: @escaping DeferredClosure) {
        if let system = context?.system(ofType: DeferredDelaySystem.self) {
            system.append(deferredClosure: closure)
        }
    }
    
    public func delay(_ duration: Float, completion: @escaping ()->()) {
        if let system = context?.system(ofType: DeferredDelaySystem.self) {
            system.append(delayDuration: duration, closure: completion)
        }
    }
}

extension PlatformSystem {
    func `defer`(_ closure: @escaping DeferredClosure) {
        if let system = context?.system(ofType: DeferredDelaySystem.self) {
            system.append(deferredClosure: closure)
        }
    }
    
    func delay(_ duration: Float, completion: @escaping ()->()) {
        if let system = context?.system(ofType: DeferredDelaySystem.self) {
            system.append(delayDuration: duration, closure: completion)
        }
    }
}

@MainActor extension Game {
    public func `defer`(_ closure: @escaping DeferredClosure) {
        let system = self.system(ofType: DeferredDelaySystem.self)
        system.append(deferredClosure: closure)
    }
    
    public func delay(_ duration: Float, _ closure: @escaping DeferredClosure) {
        let system = self.system(ofType: DeferredDelaySystem.self)
        system.append(delayDuration: duration, closure: closure)
    }
}

