/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

final public class PinchGestureRecognizer: GestureRecognizer {
    public var touchCount: Int = 2
    private var actions: [(_ position: Position2, _ delta: Float)->()] = []
    var distance1: Float? = nil
    var distance2: Float? = nil
    
    public init(recognizedSources: Sources = .all, touchCount: Int = 2, recognized: @escaping (_ position: Position2, _ delta: Float)->()) {
        self.touchCount = touchCount
        self.actions = [recognized]
        super.init(recognizedSources: recognizedSources)
    }
    
    public override func invalidate() {
        super.invalidate()
        self.phase = .unrecognized
        self.touches.removeAll(keepingCapacity: true)
        self.surfaceTouches.removeAll(keepingCapacity: true)
        self.distance1 = nil
        self.distance2 = nil
    }
    
    public override func recognizesSimultaneously(with otherGestureRecognizer: some GestureRecognizer) -> Bool {
        if otherGestureRecognizer is PinchGestureRecognizer {
            return true
        }
        if otherGestureRecognizer is PanGestureRecognizer {
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
                distance1 = nil
                distance2 = nil
            }
        }
    }
    
    func performRecognition() {
        guard touches.count >= self.touchCount else {return}
        guard let view else {return}
        let touches = Array(touches)
        
        if distance1 == nil {
            distance1 = touches[0].position.distance(from: touches[1].position)
        }else if distance2 == nil {
            distance2 = touches[0].position.distance(from: touches[1].position)
        
            let delta = -(distance1! - distance2!)
            self.phase = .recognized
            
            let position = (touches[0].locationInView(view) + touches[1].locationInView(view)) / 2
            for action in actions {
                action(position, delta)
            }
            distance1 = distance2
            distance2 = nil
        }
    }
    
    public override func touchesBegan(_ touches: Set<Touch>) {
        guard recognizedSources.contains(.screen) else {return}
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
            if surfaceTouches.isEmpty == false && surfaceTouches.count <= touchCount {
                if phase == .recognized {
                    self.invalidate()
                }else{
                    self.phase = .recognizing
                }
            }else{
                self.phase = .unrecognized
                distance1 = nil
                distance2 = nil
            }
        }
    }

    func performSurfaceRecognition() {
        guard surfaceTouches.count >= self.touchCount else {return}
        guard let view else {return}
        guard let position = Game.shared.hid.mouse.locationInView(view) else {return}
        let touches = Array(surfaceTouches)
        
        if distance1 == nil {
            distance1 = touches[0].position.distance(from: touches[1].position)
        }else if distance2 == nil {
            distance2 = touches[0].position.distance(from: touches[1].position)

            let delta: Float = -(distance1! - distance2!) * 750
            self.phase = .recognized
            
            for action in actions {
                action(position, delta)
            }
            
            distance1 = distance2
            distance2 = nil
        }
    }
    
    public override func surfaceTouchesBegan(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        guard recognizedSources.contains(.surface) else {return}
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

