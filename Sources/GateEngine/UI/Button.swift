/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

open class Button: Control {
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
    
    public enum Kind {
        case momentaryPush
        case toggle
    }
    public let kind: Kind
    
    public var _value: Bool = false
    public var value: Bool {
        get {
            switch self.kind {
            case .momentaryPush:
                return self.state == .selected
            case .toggle:
                return _value
            }
        }
        set {
            switch self.kind {
            case .momentaryPush:
                break
            case .toggle:
                self._value = newValue
                if self.state != .highlighted {
                    if self._value {
                        self.setState(.selected, sendActions: false)
                    }else{
                        self.setState(.normal, sendActions: false)
                    }
                }
            }
        }
    }
    
    open override func canBeHit() -> Bool {
        return true
    }
    
    public struct Event: OptionSet, Hashable, Sendable {
        public typealias RawValue = UInt
        public var rawValue: RawValue
        
        public static let pressed = Self(rawValue: 1 << 0)
        public static let stateChanged = Self(rawValue: 1 << 1)
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    
    private var eventActionStorage: [Event: [(_ button: Button)->()]] = [:]
    
    public final func sendActions(forEvent event: Event) {
        if let eventActionStorage = self.eventActionStorage[event] {
            for block in eventActionStorage {
                Task(priority: .userInitiated) { @MainActor in
                    block(self)
                }
            }
        }
    }
    
    public final func addAction(forEvent event: Event, completion: @escaping (_ button: Button)->()) {
        var array = eventActionStorage[event] ?? []
        array.append(completion)
        eventActionStorage[event] = array
    }
    
    public enum State {
        case normal
        case highlighted
        case selected
    }
    private var _state: State = .normal
    public var state: State {
        get {
            return _state
        }
        set {
            self.setState(newValue, sendActions: false)
        }
    }
    
    private func setState(_ state: State, sendActions: Bool = true) {
        let previousState = self._state
        self._state = state
        if previousState != state {
            self._stateDidChange(sendActions: sendActions)
        }
    }
    
    final func _stateDidChange(sendActions: Bool) {
        if let color = backgroundColors[state] {
            self.backgroundColor = color
        }
        if labelCreated {
            if let color = textColors[state] {
                self.label.textColor = color
            }
        }
        if sendActions {
            self.sendActions(forEvent: .stateChanged)
        }
        self.stateDidChange()
    }
    
    open func stateDidChange() {
        
    }
    
    open override func cursorEntered(_ cursor: Mouse) {
        self.setState(.highlighted)
    }
    
    open override func cursorExited(_ cursor: Mouse) {
        switch self.kind {
        case .momentaryPush:
            self.setState(.normal)
        case .toggle:
            if value {
                self.setState(.selected)
            }else{
                self.setState(.normal)
            }
        }
    }
    
    open override func cursorButtonDown(button: MouseButton, mouse: Mouse) {
        self.setState(.selected)
        if let mouseLocation = mouse.locationInView(self) {
            if self.bounds.contains(mouseLocation) {
                switch self.kind {
                case .momentaryPush:
                    break
                case .toggle:
                    self._value.toggle()
                }
                self.sendActions(forEvent: .pressed)
            }
        }
    }
    
    open override func cursorButtonUp(button: MouseButton, mouse: Mouse) {
        if mouse.isInsideView(self) {
            self.setState(.highlighted)
        }else{
            switch kind {
            case .momentaryPush:
                self.setState(.normal)
            case .toggle:
                if _value {
                    self.setState(.selected)
                }else{
                    self.setState(.normal)
                }
            }
        }
    }
    
    open override func touchesBegan(_ touches: Set<Touch>) {
        self.setState(.selected)
    }
    
    open override func touchesMoved(_ touches: Set<Touch>) {
        var nextState: State = .normal
        switch self.kind {
        case .momentaryPush:
            break
        case .toggle:
            if _value {
                nextState = .selected
            }else{
                nextState = .normal
            }
        }
        
        for touch in touches {
            if touch.isInsideView(self) {
                nextState = .selected
            }
        }
        self.setState(nextState)
    }
    
    open override func touchesEnded(_ touches: Set<Touch>) {
        for touch in touches {
            if touch.isInsideView(self) {
                switch self.kind {
                case .momentaryPush:
                    break
                case .toggle:
                    self._value.toggle()
                }
                self.sendActions(forEvent: .pressed)
                break
            }
        }
        switch self.kind {
        case .momentaryPush:
            self.setState(.normal)
        case .toggle:
            if _value {
                self.setState(.selected)
            }else{
                self.setState(.normal)
            }
        }
    }
    
    open override func touchesCanceled(_ touches: Set<Touch>) {
        switch kind {
        case .momentaryPush:
            self.setState(.normal)
        case .toggle:
            if _value {
                self.setState(.selected)
            }else{
                self.setState(.normal)
            }
        }
    }
    
    public init(kind: Kind = .momentaryPush, size: Size2? = nil, label: String? = nil, textColor: Color = .white, backgroundColor: Color = .blue, cornorRadius: Float? = nil, action: ((_ button: Button)->())? = nil) {
        self.kind = kind
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
            self.addAction(forEvent: .pressed, completion: action)
        }
        
        if let cornorRadius {
            self.cornerRadius = cornorRadius
        }

        self.setState(.normal, sendActions: false)
    }
    
    private var labelCreated: Bool = false
    weak var _label: Label! = nil
    func createLabel() {
        let label = Label(text: kind == .momentaryPush ? "Button" : "Toggle", font: .default, fontSize: 18, style: .bold, textColor: self.textColors[.normal] ?? .white)
        label.centerXAnchor.constrain(to: self.centerXAnchor)
        label.centerYAnchor.constrain(to: self.centerYAnchor)
        label.widthAnchor.constrain(to: self.widthAnchor)
        label.heightAnchor.constrain(to: self.heightAnchor)
        self.addSubview(label)
        self.labelCreated = true
        _label = label
    }
    public var label: Label {
        if labelCreated == false {
            createLabel()
        }
        return _label
    }
}

extension Button: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(type(of: self))(label: \"\(label.text)\")"
    }
}
