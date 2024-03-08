/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

open class Button: View {
    open override func canBeHit() -> Bool {
        return true
    }
    
    public struct Event: OptionSet, Hashable {
        public var rawValue: RawValue
        
        public static let pressed = Event(rawValue: 1 << 0)
        
        public typealias RawValue = UInt
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    
    private var eventActionStorage: [Event: [()->()]] = [:]
    
    public final func sendActions(forEvent event: Event) {
        if let eventActionStorage = eventActionStorage[event] {
            for block in eventActionStorage {
                block()
            }
        }
    }
    
    public final func action(completion: @escaping ()->()) {
        var array = eventActionStorage[.pressed] ?? []
        array.append(completion)
        eventActionStorage[.pressed] = array
    }
    
    public enum State {
        case normal
        case highlighted
        case selected
    }
    public var state: State = .normal {
        didSet {
            if state != oldValue {
                self.stateDidChange()
            }
        }
    }
    
    open func stateDidChange() {
        
    }
    
    open override func cursorEntered(_ cursor: Mouse) {
        self.state = .highlighted
    }
    
    open override func cursorExited(_ cursor: Mouse) {
        self.state = .normal
    }
    
    open override func cursorButtonDown(button: MouseButton, mouse: Mouse) {
        if let mouseLocation = mouse.loactionInView(self) {
            if self.bounds.contains(mouseLocation) {
                self.sendActions(forEvent: .pressed)
            }
        }
        self.state = .selected
    }
    
    open override func cursorButtonUp(button: MouseButton, mouse: Mouse) {
        if mouse.isInsideView(self) {
            self.state = .highlighted
        }else{
            self.state = .normal
        }
    }
    
    open override func touchesBegan(_ touches: Set<Touch>) {
        self.state = .selected
    }
    
    open override func touchesMoved(_ touches: Set<Touch>) {
        self.state = .normal
        for touch in touches {
            if touch.isInsideView(self) {
                self.state = .selected
            }
        }
    }
    
    open override func touchesEnded(_ touches: Set<Touch>) {
        self.state = .normal
        for touch in touches {
            if touch.isInsideView(self) {
                self.sendActions(forEvent: .pressed)
                break
            }
        }
    }
    
    open override func touchesCanceled(_ touches: Set<Touch>) {
        self.state = .normal
    }
    
    public init(action: (()->())? = nil) {
        super.init()
        if let action {
            self.eventActionStorage[.pressed] = [action]
        }
        self.stateDidChange()
    }
}


