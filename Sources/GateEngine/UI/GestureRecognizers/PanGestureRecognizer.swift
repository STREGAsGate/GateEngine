/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

final public class PanGestureRecognizer: GestureRecognizer {
    public var touchCount: Int = 2
    public var touchKinds: TouchKinds = .anyOf([.physical, .simulated])
    public var mouseButtons: MouseButtons = .none
    private var actions: [(_ position: Position2, _ delta: Position2)->()] = []
    var position1: Position2? = nil
    var position2: Position2? = nil
    
    public enum MouseButtons {
        case none
        case any
        case exactly(_ buttons: [GateEngine.MouseButton])
        case anyOf(_ buttons: [GateEngine.MouseButton])
    }
    public enum TouchKinds {
        case none
        case any
        case exactly(_ touchKind: GateEngine.TouchKind)
        case anyOf(_ touchKinds: Set<GateEngine.TouchKind>)
    }
    
    public init(recognizedSources: Sources = .all, touchCount: Int = 2, touchKinds: TouchKinds = .anyOf([.physical, .simulated]), mouseButtons: MouseButtons = .none, recognized: @escaping (_ position: Position2, _ delta: Position2)->()) {
        self.touchCount = touchCount
        self.mouseButtons = mouseButtons
        self.touchKinds = touchKinds
        self.actions = [recognized]
        super.init(recognizedSources: recognizedSources)
    }
    
    public override func invalidate() {
        super.invalidate()
        self.phase = .unrecognized
        self.touches.removeAll(keepingCapacity: true)
        self.surfaceTouches.removeAll(keepingCapacity: true)
        self.position1 = nil
        self.position2 = nil
    }
    
    public override func recognizesSimultaneously(with otherGestureRecognizer: some GestureRecognizer) -> Bool {
        if otherGestureRecognizer is PanGestureRecognizer {
            return true
        }
        if otherGestureRecognizer is PinchGestureRecognizer {
            return true
        }
        if otherGestureRecognizer is RotateGestureRecognizer {
            return true
        }
        return false
    }
    
    var touches: Set<Touch> = [] {
        didSet {
            if touches.isEmpty == false && touches.count <= touchCount {
                if phase == .recognized {
                    self.invalidate()
                }else{
                    self.phase = .recognizing
                }
            }else{
                self.phase = .unrecognized
                position1 = nil
                position2 = nil
            }
        }
    }
    
    func performRecognition() {
        guard self.touches.count == touchCount else {return}
        guard let view else {return}
        func avgTouchPosition() -> Position2 {
            var p: Position2 = .zero
            for touch in touches {
                p += touch.locationInView(view)
            }
            p /= Float(touches.count)
            return p
        }
        
        if position1 == nil {
            position1 = avgTouchPosition()
        }else if position2 == nil {
            position2 = avgTouchPosition()
        
            let delta = position1! - position2!
            
            if phase != .recognized {
                // Require the pan gesture to move before activating
                // This allows other gestures to activate first
                if abs(delta.length) <= 2 { 
                    position2 = nil
                    return
                }
            }
            
            self.phase = .recognized
            for action in actions {
                action(position2!, delta)
            }
            position1 = position2
            position2 = nil
        }
    }
    
    public override func touchesBegan(_ touches: Set<Touch>) {
        guard recognizedSources.contains(.screen) else {return}
        guard let view else {return}
        
        for touch in touches {
            switch touchKinds {
            case .none:
                return
            case .any:
                break
            case .exactly(let kind):
                if kind != touch.kind {
                    continue
                }
            case .anyOf(let kinds):
                if kinds.contains(touch.kind) == false {
                    continue
                }
            }
            let p = touch.locationInView(view)
            if view.bounds.contains(p) {
                self.touches.insert(touch)
            }
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
            if surfaceTouches.isEmpty == false && surfaceTouches.count <= touchCount {
                if phase == .recognized {
                    self.invalidate()
                }else{
                    self.phase = .recognizing
                }
            }else{
                self.phase = .unrecognized
                position1 = nil
                position2 = nil
            }
        }
    }
    
    var mouseButtonsMatch: Bool = false {
        didSet {
            if mouseButtonsMatch == false {
                self.invalidate()
            }
        }
    }
    var mouseButtonsDown: [GateEngine.MouseButton] = [] {
        didSet {
            switch self.mouseButtons {
            case .none:
                self.mouseButtonsMatch = mouseButtonsDown.isEmpty
            case .any:
                self.mouseButtonsMatch = mouseButtonsDown.isEmpty == false
            case .exactly(let buttons):
                for button in buttons {
                    if self.mouseButtonsDown.contains(button) == false {
                        self.mouseButtonsMatch = false
                        return
                    }
                }
                self.mouseButtonsMatch = true
            case .anyOf(let buttons):
                for button in buttons {
                    if self.mouseButtonsDown.contains(button) == false {
                        self.mouseButtonsMatch = true
                        return
                    }
                }
            }
        }
    }

    func performSurfaceRecognition() {
        guard self.surfaceTouches.count == touchCount else {return}
        func avgTouchPosition() -> Position2 {
            var p: Position2 = .zero
            for touch in surfaceTouches {
                p += touch.position
            }
            p /= Float(surfaceTouches.count)
            return p
        }
        
        guard self.mouseButtonsMatch else {
            //self.phase = .unrecognized
            return
        }
        
        if self.position1 == nil {
            self.position1 = avgTouchPosition()
            self.phase = .recognizing
        }else if self.position2 == nil {
            self.position2 = avgTouchPosition()
            
            #if os(macOS) || os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
            // Good for Magic Trackpad
            let delta = (self.position1! - self.position2!) * 750
            #else
            let delta = (self.position1! - self.position2!)
            #endif
            
            if self.phase != .recognized {
                // Require the pan gesture to move before activating
                // This allows other gestures to activate first
                if abs(delta.length) <= 2 { 
                    self.position2 = nil
                    return
                }
            }
            
            self.phase = .recognized
            for action in self.actions {
                action(self.position2!, delta)
            }
            self.position1 = self.position2
            self.position2 = nil
        }
    }
    
    public override func cursorButtonDown(button: MouseButton, mouse: Mouse) {
        guard recognizedSources.contains(.mouse) else {return}
        mouseButtonsDown.append(button)
    }
    
    public override func cursorButtonUp(button: MouseButton, mouse: Mouse) {
        mouseButtonsDown.removeAll(where: {$0 == button})
    }
    
    public override func surfaceTouchesBegan(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        guard recognizedSources.contains(.surface) else {return}
        for touch in touches {
            surfaceTouches.insert(touch)
        }
    }
    public override func surfaceTouchesMoved(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        self.performSurfaceRecognition()
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
