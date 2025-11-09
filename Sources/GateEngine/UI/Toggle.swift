/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

open class Toggle: Control {
    public var value: Bool = false {
        didSet {
            if self.state != .highlighted {
                if value {
                    self.state = .selected
                }else{
                    self.state = .normal
                }
            }
        }
    }
    
    private var backgroundColors: [State: Color] = [
        .highlighted:.lightBlue,
        .normal:.blue,
        .selected:.darkBlue,
    ]
    public func setBackgroundColor(_ color: Color, forState state: State) {
        backgroundColors[state] = color
        if self.state == state {
            self.backgroundColor = color
        }
    }
    public func setBackgroundColor(_ color: Color) {
        self.backgroundColor = color
        self.backgroundColors[.normal] = color
        self.backgroundColors[.highlighted] = color.interpolated(to: .lightGray, .linear(0.25))
        self.backgroundColors[.selected] = color.interpolated(to: .darkGray, .linear(0.25))
    }
    
    private var textColors: [State: Color] = [
        .highlighted:.white,
        .normal:.white,
        .selected:.white,
    ]
    public func setTextColor(_ color: Color, forState state: State) {
        textColors[state] = color
        if self.state == state {
            self.label.textColor = color
        }
    }
    
    open override func canBeHit() -> Bool {
        return true
    }
    
    public struct Event: OptionSet, Hashable, Sendable {
        public typealias RawValue = UInt
        public var rawValue: RawValue
        
        public static let changed = Self(rawValue: 1 << 0)
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    
    private var eventActionStorage: [Event: [(Toggle)->()]] = [:]
    
    public final func sendActions(forEvent event: Toggle.Event) {
        if let eventActionStorage = eventActionStorage[event] {
            unowned let unownedSelf = self
            for block in eventActionStorage {
                block(unownedSelf)
            }
        }
    }
    
    public final func action(completion: @escaping (Toggle)->()) {
        var array = eventActionStorage[.changed] ?? []
        array.append(completion)
        eventActionStorage[.changed] = array
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
                if let color = backgroundColors[state] {
                    self.backgroundColor = color
                }
                if labelCreated {
                    if let color = textColors[state] {
                        self.label.textColor = color
                    }
                }
            }
        }
    }
    
    open func stateDidChange() {
        
    }
    
    open override func cursorEntered(_ cursor: Mouse) {
        self.state = .highlighted
    }
    
    open override func cursorExited(_ cursor: Mouse) {
        if value {
            self.state = .selected
        }else{
            self.state = .normal
        }
    }
    
    open override func cursorButtonDown(button: MouseButton, mouse: Mouse) {
        if let mouseLocation = mouse.locationInView(self) {
            if self.bounds.contains(mouseLocation) {
                self.value.toggle()
                self.sendActions(forEvent: Self.Event.changed)
            }
        }
        self.state = .selected
    }
    
    open override func cursorButtonUp(button: MouseButton, mouse: Mouse) {
        if mouse.isInsideView(self) {
            self.state = .highlighted
        }else if value {
            self.state = .selected
        }else{
            self.state = .normal
        }
    }
    
    open override func touchesBegan(_ touches: Set<Touch>) {
        self.state = .selected
    }
    
    open override func touchesMoved(_ touches: Set<Touch>) {
        if value {
            self.state = .selected
        }else{
            self.state = .normal
        }
        for touch in touches {
            if touch.isInsideView(self) {
                self.state = .selected
            }
        }
    }
    
    open override func touchesEnded(_ touches: Set<Touch>) {
        if value {
            self.state = .selected
        }else{
            self.state = .normal
        }
        for touch in touches {
            if touch.isInsideView(self) {
                self.value.toggle()
                self.sendActions(forEvent: Self.Event.changed)
                break
            }
        }
    }
    
    open override func touchesCanceled(_ touches: Set<Touch>) {
        if value {
            self.state = .selected
        }else{
            self.state = .normal
        }
    }
    
    public init(size: Size2? = nil, label: String? = nil, textColor: Color = .white, backgroundColor: Color = .blue, cornorRadius: Float? = nil, action: ((Toggle)->())? = nil) {
        super.init()
        
        self.clipToBounds = true
        
        if let size {
            self.widthAnchor.constrain(to: size.width)
            self.heightAnchor.constrain(to: size.height)
        }
        
        self.setBackgroundColor(backgroundColor)
        
        self.textColors[.normal] = textColor
        self.textColors[.highlighted] = textColor
        self.textColors[.selected] = textColor
        
        if let label {
            self.label.text = label
            self.label.textColor = textColor
        }
        if let action {
            self.eventActionStorage[.changed] = [action]
        }
        
        if let cornorRadius {
            self.cornerRadius = cornorRadius
        }

        self.stateDidChange()
    }
    
    private var labelCreated: Bool = false
    public private(set) lazy var label: Label = {
        let label = Label(text: "Toggle", font: .babel, fontSize: 14, style: .regular, textColor: self.textColors[.normal] ?? .white)
        label.centerXAnchor.constrain(to: self.centerXAnchor)
        label.centerYAnchor.constrain(to: self.centerYAnchor)
        label.widthAnchor.constrain(to: self.widthAnchor)
        label.heightAnchor.constrain(to: self.heightAnchor)
        self.addSubview(label)
        self.labelCreated = true
        return label
    }()
}


