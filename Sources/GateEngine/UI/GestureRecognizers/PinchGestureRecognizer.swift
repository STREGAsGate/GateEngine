//
//  PinchGestureRecognizer.swift
//  GateEngine
//
//  Created by Dustin Collins on 5/11/25.
//

final public class PinchGestureRecognizer: GestureRecognizer {
    public var touchCount: Int = 2
    private var actions: [(_ delta: Float)->()] = []
    var distance1: Float? = nil
    var distance2: Float? = nil
    
    public init(touchCount: Int = 2, recognized: @escaping (_ delta: Float)->()) {
        self.touchCount = touchCount
        self.actions = [recognized]
    }
    
    public override func invalidate() {
        super.invalidate()
        self.phase = .unrecognized
        self.touches.removeAll(keepingCapacity: true)
        self.surfaceTouches.removeAll(keepingCapacity: true)
        self.distance1 = nil
        self.distance2 = nil
        Log.info("PinchGestureRecognizer invalidated.")
    }
    
    public override func recognizesSimultaneously(with otherGestureRecognizer: some GestureRecognizer) -> Bool {
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

