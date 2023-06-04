/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public enum WindowStyle {
    ///The window will appear the way most windows do on the platfrom.
    case system
    ///The window will attempt to maximize the content size within the window by reducing window decorations.
    case bestForGames
}

@MainActor public final class Window: RenderTargetProtocol, _RenderTargetProtocol {
    public var lastDrawnFrame: UInt = .max
    public let identifier: String
    public let style: WindowStyle
    
    @usableFromInline
    internal lazy var windowBacking: WindowBacking = createWindowBacking()
    @usableFromInline
    lazy var renderTargetBackend: RenderTargetBackend = windowBacking.createWindowRenderTargetBackend()
    
    var drawables: [Any] = []
    public private(set) lazy var texture: Texture = Texture(renderTarget: self)
    
    weak var delegate: WindowDelegate? = nil
    
    // true if the last draw attempt changed the screen
    internal var didDrawSomething: Bool = false
    
    public enum State {
        ///The window exists but isn't on screen
        case hidden
        ///The window is on screen
        case shown
        ///The window isn't visible and can never be shown again.
        case destroyed
    }
    
    @inlinable @inline(__always)
    public var state: State {
        return windowBacking.state
    }
    
    @inlinable @inline(__always)
    public var title: String? {
        get {
            return windowBacking.title
        }
        set {
            windowBacking.title = newValue
        }
    }
    
    @usableFromInline
    internal lazy var newSize: Size2 = self.size
    @inlinable @inline(__always)
    public internal(set) var size: Size2 {
        get {
            return windowBacking.backingSize
        }
        set {
            newSize = newValue
        }
    }
    
    @inlinable @inline(__always)
    public var interfaceSize: Size2 {
        return self.size / self.interfaceScale
    }
    
    @inline(__always)
    internal func reshapeIfNeeded() {
        if self.newSize != renderTargetBackend.size || renderTargetBackend.wantsReshape {
            renderTargetBackend.size = self.newSize
            renderTargetBackend.reshape()
        }
    }
    
    internal init(identifier: String, style: WindowStyle) {
        self.identifier = identifier
        self.style = style
        self.clearColor = .black
    }
    
    private var previousTime: Double = 0

    var frame: UInt = 0
    internal func vSyncCalled() {
        let now: Double = Game.shared.platform.systemTime()
        let delta: Double = now - previousTime
        self.previousTime = now
        // Positive time change and miniumum of 10 fps
        guard delta > 0 && delta < 0.1 else {return}
        if let delegate: WindowDelegate = self.delegate {
            delegate.window(self, wantsUpdateForTimePassed: Float(delta))
            self.draw(frame)
        }
        frame &+= 1
    }
    
    @inlinable @inline(__always)
    public var interfaceScale: Float {
        return windowBacking.backingScaleFactor
    }
    
    @inlinable @inline(__always)
    public var safeAreaInsets: Insets {
        return windowBacking.safeAreaInsets
    }
    
    @usableFromInline @inline(__always)
    func setMouseHidden(_ hidden: Bool) {
        self.windowBacking.setMouseHidden(hidden)
    }
    @usableFromInline @inline(__always)
    func setMousePosition(_ position: Position2) {
        let windowFrame = Rect(size: self.size)
        let clampedToWindowFrame = position.clamped(within: windowFrame)
        self.windowBacking.setMousePosition(clampedToWindowFrame)
    }
    
    func show() {
        self.windowBacking.show()
    }
}

@usableFromInline
internal protocol WindowBacking: AnyObject {
    var style: WindowStyle {get}
    var title: String? {get set}
    var frame: Rect {get set}
    var safeAreaInsets: Insets {get}
    var backingSize: Size2 {get}
    var backingScaleFactor: Float {get}
    var state: Window.State {get}
    
    init(identifier: String, style: WindowStyle, window: Window)
    
    func setMouseHidden(_ hidden: Bool)
    func setMousePosition(_ position: Position2)
    
    func show()
    func close()

    @MainActor func createWindowRenderTargetBackend() -> RenderTargetBackend
}


protocol WindowDelegate: AnyObject {
    func window(_ window: Window, wantsUpdateForTimePassed deltaTime: Float)

    func mouseChange(event: MouseChangeEvent, position: Position2, delta: Position2, window: Window?)
    func mouseClick(event: MouseClickEvent, button: MouseButton, count: Int?, position: Position2?, delta: Position2?, window: Window?)

    func screenTouchChange(id: AnyHashable, kind: TouchKind, event: TouchChangeEvent, position: Position2)
    func surfaceTouchChange(id: AnyHashable, event: TouchChangeEvent, surfaceID: AnyHashable, normalizedPosition: Position2)

    func keyboardDidhandle(key: KeyboardKey,
                           character: Character?,
                           modifiers: KeyboardModifierMask,
                           isRepeat: Bool,
                           event: KeyboardEvent) -> Bool
}

internal extension Window {
    @_transparent
    func createWindowBacking() -> WindowBacking {
        #if canImport(UIKit)
        return UIKitWindow(identifier: identifier, style: style, window: self)
        #elseif canImport(AppKit)
        return AppKitWindow(identifier: identifier, style: style, window: self)
        #elseif canImport(WinSDK)
        return Win32Window(identifier: identifier, style: style, window: self)
        #elseif os(Linux)
        return X11Window(identifier: identifier, style: style, window: self)
        #elseif os(WASI)
        return WASIWindow(identifier: identifier, style: style, window: self)
        #elseif os(Android)
        #error("Not implemented")
        #else
        #error("Not implemented")
        #endif
    }
}

public enum MouseButton: Hashable {
    case button1
    case button2
    case button3
    case button4
    case button5
    case unknown(_ index: Int?)
    
    public static let primary: Self = .button1
    public static let secondary: Self = .button2
    public static let middle: Self = .button3
    public static let backward: Self = .button4
    public static let forward: Self = .button5
}

public enum MouseChangeEvent {
    case entered
    case moved
    case exited
}

public enum MouseClickEvent {
    case buttonDown
    case buttonUp
}

public enum TouchChangeEvent {
    case began
    case moved
    case ended
    case canceled
}

public enum TouchKind {
    /// The touch could be from anything.
    case unknown
    /// The touch was a finger or non-electronic stylus
    case physical
    /// The touch is an electronic device
    case stylus
    /// The touch happened through software
    case simulated
}

public struct KeyboardModifierMask: OptionSet {
    public typealias RawValue = UInt32
    public let rawValue: RawValue

    /// The Platform specific key Command for Apple, Flag for Windows, etc...
    public static let host = KeyboardModifierMask(rawValue: 1 << 1)
    /// Any shift key is down
    public static let shift = KeyboardModifierMask(rawValue: 1 << 2)
    /// Any control key is down
    public static let control = KeyboardModifierMask(rawValue: 1 << 3)
    /// Any alt key is down. This is option for Apple
    public static let alt = KeyboardModifierMask(rawValue: 1 << 4)
    /// capslock is enabled
    public static let capsLock = KeyboardModifierMask(rawValue: 1 << 5)
    /// fn is down
    public static let function = KeyboardModifierMask(rawValue: 1 << 5)
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

extension KeyboardModifierMask: CustomStringConvertible {
    public var description: String {
        var text = "["
        if self.contains(.shift) {
            text += "shift, "
        }
        if self.contains(.control) {
            text += "control, "
        }
        if self.contains(.alt) {
            text += "alt, "
        }
        if self.contains(.host) {
            text += "host, "
        }
        if text.hasSuffix(", ") {
            text = String(text[..<text.lastIndex(of: ",")!])
        }
        return text + "]"
    }
}

public enum KeyboardKey: Hashable {
    /// The Esc key
    case escape
    
    /// Clear on Apple
    case numLock
    
    case home
    case end
    case delete
    case pageUp
    case pageDown
    
    /**
     F keys on the top of a keyboard
     - parameter number: The F key's number F1, F2, F3, etc...
     */
    case function(_ number: Int)

    public enum KeyOrigin {
        case main
        case pad
    }
    case character(Character, _ origin: KeyOrigin? = nil)
    
    /// The backspace or delete key
    case backspace
    /// The spacebar
    case space
    /// An enter / return key
    case enter(_ origin: KeyOrigin? = nil)
    /// The tab key
    case tab
    /// The up arrow
    case up
    /// The down arrow
    case down
    /// The left arrow
    case left
    ///  The right arrow
    case right
    /**
     Gives an opportunity to handle keyboard events not handled by GateEngine.
     
     - parameter int: A key code represented as an Int
     - parameter string: A key represented as a String
     */
    case unhandledPlatformKeyCode(_ int: Int?, _ string: String?)
    
    public enum Alignment {
        case left
        case right
    }
    case alt(_ alignment: Alignment)
    case host(_ alignment: Alignment)
    case control(_ alignment: Alignment)
    case shift(_ alignment: Alignment)
    // The Fn key
    case functionModifier
    case capsLock
    
    var asModifierMask: KeyboardModifierMask {
        switch self {
        case .alt(_):
            return .alt
        case .host(_):
            return .host
        case .control(_):
            return .control
        case .shift(_):
            return .shift
        case .functionModifier:
            return .function
        default:
            return []
        }
    }
}

extension KeyboardKey: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self = .character(value.first!)
    }
    
    @_transparent
    public static func qwerty(_ character: Character, origin: KeyOrigin? = nil) -> Self {
        return .character(character, origin)
    }
    
    public static func qwertz(_ character: Character, origin: KeyOrigin? = nil) -> Self {
        switch character {
        case "<":
            return .character("`", origin)
            
        case "ß":
            return .character("-", origin)
        case "´":
            return .character("=", origin)
            
        case "z":
            return .character("y", origin)
            
        case "ü":
            return .character("[", origin)
        case "+":
            return .character("]", origin)
        case "#":
            return .character("\\", origin)
            
        case "ö":
            return .character(";", origin)
        case "ä":
            return .character("'", origin)
            
        case "y":
            return .character("z", origin)
            
        case "-":
            return .character("/", origin)
            
        default:
            return .character(character, origin)
        }
    }
    
    public static func azerty(_ character: Character, origin: KeyOrigin? = nil) -> Self {
        switch character {
        case "<":
            return .character("`", origin)
        case "&":
            return .character("1", origin)
        case "é":
            return .character("2", origin)
        case "\"":
            return .character("3", origin)
        case "'":
            return .character("4", origin)
        case "(":
            return .character("5", origin)
        case "§":
            return .character("6", origin)
        case "è":
            return .character("7", origin)
        case "!":
            return .character("8", origin)
        case "ç":
            return .character("9", origin)
        case "à":
            return .character("0", origin)
        case ")":
            return .character("-", origin)
        case "-":
            return .character("=", origin)
            
        case "a":
            return .character("q", origin)
        case "z":
            return .character("w", origin)
            
        case "^":
            return .character("[", origin)
        case "$":
            return .character("]", origin)
        case "`":
            return .character("\\", origin)
            
        case "q":
            return .character("a", origin)
        case "m":
            return .character(";", origin)
        case "ù":
            return .character("'", origin)
            
        case "w":
            return .character("z", origin)
            
        case ";":
            return .character(",", origin)
        case ":":
            return .character(".", origin)
        case "=":
            return .character("/", origin)
            
        default:
            return .character(character, origin)
        }
    }
}

public enum KeyboardEvent {
    case keyDown
    case keyUp
    case toggle
}
