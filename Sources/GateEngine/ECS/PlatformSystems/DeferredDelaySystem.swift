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
    
    @inline(__always)
    func append(deferredClosure block: @escaping DeferredClosure) {
        deferredClosures.append(block)
    }
    
    @inline(__always)
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
    @inline(__always)
    public func `defer`(_ closure: @escaping DeferredClosure) {
        let _system = self.system(ofType: DeferredDelaySystem.self)
        let system = unsafeDowncast(_system, to: DeferredDelaySystem.self)
        system.append(deferredClosure: closure)
    }
    
    @inline(__always)
    public func delay(_ duration: Float, completion: @escaping ()->()) {
        let _system = self.system(ofType: DeferredDelaySystem.self)
        let system = unsafeDowncast(_system, to: DeferredDelaySystem.self)
        system.append(delayDuration: duration, closure: completion)
    }
}

extension System {
    @inline(__always)
    public func `defer`(_ closure: @escaping DeferredClosure) {
        let _system = context.system(ofType: DeferredDelaySystem.self)
        let system = unsafeDowncast(_system, to: DeferredDelaySystem.self)
        system.append(deferredClosure: closure)
    }
    
    @inline(__always)
    public func delay(_ duration: Float, completion: @escaping ()->()) {
        let _system = context.system(ofType: DeferredDelaySystem.self)
        let system = unsafeDowncast(_system, to: DeferredDelaySystem.self)
        system.append(delayDuration: duration, closure: completion)
    }
}

extension PlatformSystem {
    @_transparent
    func `defer`(_ closure: @escaping DeferredClosure) {
        let _system = context.system(ofType: DeferredDelaySystem.self)
        let system = unsafeDowncast(_system, to: DeferredDelaySystem.self)
        system.append(deferredClosure: closure)
    }
    
    @_transparent
    func delay(_ duration: Float, completion: @escaping ()->()) {
        let _system = context.system(ofType: DeferredDelaySystem.self)
        let system = unsafeDowncast(_system, to: DeferredDelaySystem.self)
        system.append(delayDuration: duration, closure: completion)
    }
}

@MainActor extension Game {
    @inline(__always)
    public func `defer`(_ closure: @escaping DeferredClosure) {
        let _system = self.system(ofType: DeferredDelaySystem.self)
        let system = unsafeDowncast(_system, to: DeferredDelaySystem.self)
        system.append(deferredClosure: closure)
    }
    
    @inline(__always)
    public func delay(_ duration: Float, _ closure: @escaping DeferredClosure) {
        let _system = self.system(ofType: DeferredDelaySystem.self)
        let system = unsafeDowncast(_system, to: DeferredDelaySystem.self)
        system.append(delayDuration: duration, closure: closure)
    }
}

