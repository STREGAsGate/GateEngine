/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

/// Recognizes Touch and Click HID events
final public class TapGestureRecognizer: GestureRecognizer {
    public var touchCount: Int = 1
    private var actions: [(_ position: Position2)->()] = []
    
    public init(recognizedSources: Sources = .all, touchCount: Int = 1, recognized: @escaping (_ position: Position2)->()) {
        self.touchCount = touchCount
        self.actions = [recognized]
        super.init(recognizedSources: recognizedSources)
    }
        
    public override func invalidate() {
        super.invalidate()
        self.phase = .unrecognized
        self.touches.removeAll(keepingCapacity: true)
        self.startPositions.removeAll(keepingCapacity: true)
        self.downInside = false
    }
    
    public override func recognizesSimultaneously(with otherGestureRecognizer: some GestureRecognizer) -> Bool {
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
        guard recognizedSources.contains(.screen) else {return}
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
        guard recognizedSources.contains(.mouse) else {return}
        guard let view else {return}
        guard let position = mouse.locationInView(view) else {return}
        guard view.bounds.contains(position) else {return}
        self.downInside = true
        self.phase = .recognizing
    }
    
    public override func cursorExited(_ cursor: Mouse) {
        self.downInside = false
        self.phase = .unrecognized
    }
    
    public override func cursorButtonUp(button: MouseButton, mouse: Mouse) {
        guard self.downInside else {
            self.downInside = false
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
