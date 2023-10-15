/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@MainActor open class GestureRecognizer {
    public internal(set) var phase: Phase = .unrecognized
    public enum Phase {
        case unrecognized
        case recognizing
        case recognized
    }
    
    nonisolated internal init() {
        
    }
}

final public class RotateGestureRecognizer: GestureRecognizer {
    public struct Recognized {
        public enum Direction {
            case clockwise
            case counterClockwise
        }
        public var direction: Direction
        public var amount: Radians
    }
    private var oldTouches: Set<Touch> = []
    
    public nonisolated override init() {
        super.init()
    }
    
    public func update(_ touches: Set<Touch>, recognized: (_ gesture: Recognized)->()) {
        let touches = touches.filter({$0.phase == .down})
        if touches.count == 2 {
            if phase == .unrecognized {
                phase = .recognizing
                oldTouches = touches
                return
            }
        }else if touches.isEmpty {
            phase = .unrecognized
        }
        
        guard phase == .recognizing else {return}
        
        let currentMatching = touches.intersection(oldTouches).sorted(by: {$0.hashValue < $1.hashValue})
        let oldMatching = oldTouches.intersection(touches).sorted(by: {$0.hashValue < $1.hashValue})
        guard currentMatching.count == 2, oldMatching.count == 2 else {
            oldTouches.removeAll()
            phase = .unrecognized
            return
        }
        
        let d1 = Direction2(from: currentMatching[0].position, to: currentMatching[1].position)
        let d2 = Direction2(from: oldMatching[0].position, to: oldMatching[1].position)
       
        let t = d1.angleAroundZ - d2.angleAroundZ
        if abs(t) > 5° {
            phase = .recognized
            
            let direction: Recognized.Direction
            let angle: Radians
            if t > 0 {
                direction = .clockwise
                angle = d1.angle(to: d2)
            }else{
                direction = .counterClockwise
                angle = d1.angle(to: d2)
            }
            recognized(Recognized(direction: direction, amount: angle))
        }
    }
}
