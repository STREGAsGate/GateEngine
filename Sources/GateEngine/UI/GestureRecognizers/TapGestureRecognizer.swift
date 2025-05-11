//
//  TapGestureRecognizer.swift
//  GateEngine
//
//  Created by Dustin Collins on 5/11/25.
//

final public class TapGestureRecognizer: GestureRecognizer {
    public var touchCount: Int = 1
    private var actions: [(_ position: Position2)->()] = []
    var distance1: Float? = nil
    var distance2: Float? = nil
    
    public init(touchCount: Int = 1, recognized: @escaping (_ position: Position2)->()) {
        self.touchCount = touchCount
        self.actions = [recognized]
    }
    
    public override func invalidate() {
        super.invalidate()
        self.phase = .unrecognized
        self.touches.removeAll(keepingCapacity: true)
        self.distance1 = nil
        self.distance2 = nil
        self.startPositions.removeAll(keepingCapacity: true)
        self.downInside = false
        Log.info("TapGestureRecognizer invalidated.")
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
        if self.touches.isEmpty == false {
            self.phase = .recognizing
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
        if self.touches.isEmpty {
            self.phase = .unrecognized
        }
    }
    public override func touchesCanceled(_ touches: Set<Touch>) {
        for touch in touches {
            self.touches.remove(touch)
            self.startPositions.removeValue(forKey: touch)
        }
        if self.touches.isEmpty {
            self.phase = .unrecognized
        }
    }
    
    var downInside: Bool = false
    public override func cursorButtonDown(button: MouseButton, mouse: Mouse) {
        guard let view else {return}
        guard let position = mouse.locationInView(view) else {return}
        guard view.bounds.contains(position) else {return}
        downInside = true
        self.phase = .recognizing
    }
    
    public override func cursorExited(_ cursor: Mouse) {
        downInside = false
        self.phase = .unrecognized
    }
    
    public override func cursorButtonUp(button: MouseButton, mouse: Mouse) {
        guard downInside else {
            downInside = false
            return
        }
        guard let view else {return}
        guard let position = mouse.locationInView(view) else {return}
        guard view.bounds.contains(position) else {return}
        
        self.phase = .recognized
        for action in actions {
            action(position)
        }
        self.phase = .unrecognized
    }
}
