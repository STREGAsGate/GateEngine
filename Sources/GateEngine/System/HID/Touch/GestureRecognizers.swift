/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@MainActor open class GestureRecognizer {
    weak var view: View? = nil
    public internal(set) var phase: Phase = .unrecognized
    public enum Phase {
        case unrecognized
        case recognizing
        case recognized
    }
    
    nonisolated public init() {
        
    }
    
    open func touchesBegan(_ touches: Set<Touch>) {

    }
    open func touchesMoved(_ touches: Set<Touch>) {
        
    }
    open func touchesEnded(_ touches: Set<Touch>) {
        
    }
    open func touchesCanceled(_ touches: Set<Touch>) {
        
    }
    
    open func surfaceTouchesBegan(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        
    }
    open func surfaceTouchesMoved(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        
    }
    open func surfaceTouchesEnded(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        
    }
    open func surfaceTouchesCanceled(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        
    }
    
    open func cursorEntered(_ cursor: Mouse) {
        
    }
    open func cursorMoved(_ cursor: Mouse) {
        
    }
    open func cursorExited(_ cursor: Mouse) {
        
    }
    
    open func cursorButtonDown(button: MouseButton, mouse: Mouse) {
        
    }
    open func cursorButtonUp(button: MouseButton, mouse: Mouse) {
        
    }
    
    open func scrolled(_ delta: Position2, isPlatformGeneratedMomentum isMomentum: Bool) {
        
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


final public class PanGestureRecognizer: GestureRecognizer {
    public var touchCount: Int = 2
    public var mouseButtons: MouseButtons = .none
    private var actions: [(_ delta: Position2)->()] = []
    var position1: Position2? = nil
    var position2: Position2? = nil
    
    public enum MouseButtons {
        case none
        case any
        case exactly(_ buttons: [GateEngine.MouseButton])
        case anyOf(_ buttons: [GateEngine.MouseButton])
    }
    
    public init(touchCount: Int = 2, mouseButtons: MouseButtons = .none, recognized: @escaping (_ delta: Position2)->()) {
        self.touchCount = touchCount
        self.mouseButtons = mouseButtons
        self.actions = [recognized]
    }
    
    var touches: Set<Touch> = [] {
        didSet {
            if touches.count == touchCount {
                self.phase = .recognizing
            }else{
                self.phase = .unrecognized
                position1 = nil
                position2 = nil
            }
        }
    }
    
    func performRecognition() {
        func avgTouchPosition() -> Position2 {
            var p: Position2 = .zero
            for touch in touches {
                p += touch.position
            }
            p /= Float(touches.count)
            return p
        }
        
        if position1 == nil {
            position1 = avgTouchPosition()
        }else if position2 == nil {
            position2 = avgTouchPosition()
        
            let delta = position1! - position2!
            self.phase = .recognized
            for action in actions {
                action(delta)
            }
            position1 = position2
            position2 = nil
        }
    }
    
    public override func touchesBegan(_ touches: Set<Touch>) {
        for touch in touches {
            self.touches.insert(touch)
        }
    }
    public override func touchesMoved(_ touches: Set<Touch>) {
        if self.phase == .recognizing || self.phase == .recognized {
            performRecognition()
        }
    }
    public override func touchesEnded(_ touches: Set<Touch>) {
        for touch in touches {
            self.touches.remove(touch)
        }
    }
    public override func touchesCanceled(_ touches: Set<Touch>) {
        for touch in touches {
            self.touches.remove(touch)
        }
    }
    
    var surfaceTouches: Set<SurfaceTouch> = [] {
        didSet {
            if surfaceTouches.count == touchCount {
                self.phase = .recognizing
            }else{
                self.phase = .unrecognized
                position1 = nil
                position2 = nil
            }
        }
    }

    func performSurfaceRecognition() {
        let touches = surfaceTouches

        func avgTouchPosition() -> Position2 {
            var p: Position2 = .zero
            for touch in touches {
                p += touch.position
            }
            p /= Float(touches.count)
            return p
        }
        
        if position1 == nil {
            position1 = avgTouchPosition()
        }else if position2 == nil {
            position2 = avgTouchPosition()
            
            #if os(macOS) || os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
            // Good for Magic Trackpad
            let delta = (position1! - position2!) * 750
            #else
            let delta = (position1! - position2!)
            #endif
            self.phase = .recognized
            for action in actions {
                action(delta)
            }
            position1 = position2
            position2 = nil
        }
    }
    
    public override func surfaceTouchesBegan(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        for touch in touches {
            surfaceTouches.insert(touch)
        }
    }
    public override func surfaceTouchesMoved(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        if self.phase == .recognizing || self.phase == .recognized {
            switch mouseButtons {
            case .none:
                break
            case .any:
                if mouse.buttons.values.first(where: {$0.isPressed == true}) == nil {
                    if phase == .recognized {
                        self.phase = .recognizing
                    }
                    position1 = nil
                    position2 = nil
                    return
                }
            case .exactly(let buttons):
                for button in buttons {
                    if mouse.buttons[button]?.isPressed == false {
                        if phase == .recognized {
                            self.phase = .recognizing
                        }
                        position1 = nil
                        position2 = nil
                        return
                    }
                }
            case .anyOf(let buttons):
                var hit = false
                for button in buttons {
                    if mouse.buttons[button]?.isPressed == true {
                        hit = true
                        break
                    }
                }
                if buttons.isEmpty == false {
                    if hit == false {
                        if phase == .recognized {
                            self.phase = .recognizing
                        }
                        position1 = nil
                        position2 = nil
                        return
                    }
                }
            }
            performSurfaceRecognition()
        }
    }
    public override func surfaceTouchesEnded(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        for touch in touches {
            surfaceTouches.remove(touch)
        }
    }
    public override func surfaceTouchesCanceled(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        for touch in touches {
            surfaceTouches.remove(touch)
        }
    }
}

final public class ZoomGestureRecognizer: GestureRecognizer {
    public var touchCount: Int = 2
    private var actions: [(_ delta: Float)->()] = []
    var distance1: Float? = nil
    var distance2: Float? = nil
    
    public init(touchCount: Int = 2, recognized: @escaping (_ delta: Float)->()) {
        self.touchCount = touchCount
        self.actions = [recognized]
    }
    
    var touches: Set<Touch> = [] {
        didSet {
            if touches.count == touchCount {
                self.phase = .recognizing
            }else{
                self.phase = .unrecognized
                distance1 = nil
                distance2 = nil
            }
        }
    }
    
    func performRecognition() {
        let touches = Array(touches)
        
        if distance1 == nil {
            distance1 = touches[0].position.distance(from: touches[1].position)
        }else if distance2 == nil {
            distance2 = touches[0].position.distance(from: touches[1].position)
        
            let delta = -(distance1! - distance2!)
            self.phase = .recognized
            for action in actions {
                action(delta)
            }
            distance1 = distance2
            distance2 = nil
        }
    }
    
    public override func touchesBegan(_ touches: Set<Touch>) {
        for touch in touches {
            self.touches.insert(touch)
        }
    }
    public override func touchesMoved(_ touches: Set<Touch>) {
        if self.phase == .recognizing || self.phase == .recognized {
            performRecognition()
        }
    }
    public override func touchesEnded(_ touches: Set<Touch>) {
        for touch in touches {
            self.touches.remove(touch)
        }
    }
    public override func touchesCanceled(_ touches: Set<Touch>) {
        for touch in touches {
            self.touches.remove(touch)
        }
    }
    
    var surfaceTouches: Set<SurfaceTouch> = [] {
        didSet {
            if surfaceTouches.count == touchCount {
                self.phase = .recognizing
            }else{
                self.phase = .unrecognized
                distance1 = nil
                distance2 = nil
            }
        }
    }

    func performSurfaceRecognition() {
        let touches = Array(surfaceTouches)
        
        if distance1 == nil {
            distance1 = touches[0].position.distance(from: touches[1].position)
        }else if distance2 == nil {
            distance2 = touches[0].position.distance(from: touches[1].position)
        
            let delta: Float = -(distance1! - distance2!) * 750
            self.phase = .recognized
            for action in actions {
                action(delta)
            }
            
            distance1 = distance2
            distance2 = nil
        }
    }
    
    public override func surfaceTouchesBegan(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        for touch in touches {
            surfaceTouches.insert(touch)
        }
    }
    public override func surfaceTouchesMoved(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        if self.phase == .recognizing || self.phase == .recognized {
            performSurfaceRecognition()
        }
    }
    public override func surfaceTouchesEnded(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        for touch in touches {
            surfaceTouches.remove(touch)
        }
    }
    public override func surfaceTouchesCanceled(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        for touch in touches {
            surfaceTouches.remove(touch)
        }
    }
}

final public class TapGestureRecognizer: GestureRecognizer {
    public var touchCount: Int = 1
    private var actions: [(_ position: Position2)->()] = []
    var distance1: Float? = nil
    var distance2: Float? = nil
    
    public init(touchCount: Int = 1, recognized: @escaping (_ position: Position2)->()) {
        self.touchCount = touchCount
        self.actions = [recognized]
    }
    
    var touches: Set<Touch> = [] {
        didSet {
            if touches.count == touchCount {
                self.phase = .recognizing
            }else{
                self.phase = .unrecognized
                distance1 = nil
                distance2 = nil
            }
        }
    }
    
    var startPositions: [Touch: Position2] = [:]
    
    func performRecognition() {
        guard touches.count == touchCount else { return }
        guard let view else {return}

        
        var position: Position2 = .zero
        for touch in self.touches {
            let distance = touch.position.distance(from: startPositions[touch]!)
            if distance > 10 {return}

            position += touch.locationInView(view)
        }
               
        position /= Float(touches.count)
        guard view.bounds.contains(position) else {return}
        
        self.phase = .recognized
        for action in actions {
            action(position)
        }
    }
    
    public override func touchesBegan(_ touches: Set<Touch>) {
        for touch in touches {
            self.touches.insert(touch)
            startPositions[touch] = touch.position
        }
    }
    public override func touchesMoved(_ touches: Set<Touch>) {
        
    }
    public override func touchesEnded(_ touches: Set<Touch>) {
        performRecognition()
        for touch in touches {
            self.touches.remove(touch)
            self.startPositions.removeValue(forKey: touch)
        }
    }
    public override func touchesCanceled(_ touches: Set<Touch>) {
        for touch in touches {
            self.touches.remove(touch)
            self.startPositions.removeValue(forKey: touch)
        }
    }
    
    var downInside: Bool = false
    public override func cursorButtonDown(button: MouseButton, mouse: Mouse) {
        guard let view else {return}
        guard let position = mouse.locationInView(view) else {return}
        guard view.bounds.contains(position) else {return}
        downInside = true
    }
    
    public override func cursorExited(_ cursor: Mouse) {
        downInside = false
    }
    
    public override func cursorButtonUp(button: MouseButton, mouse: Mouse) {
        guard downInside else {
            downInside = false
            return
        }
        guard let view else {return}
        guard let position = mouse.locationInView(view) else {return}
        guard view.bounds.contains(position) else {return}
        for action in actions {
            action(position)
        }
    }
}
