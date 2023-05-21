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
    public let identifier: String
    public let style: WindowStyle
    @usableFromInline
    internal lazy var backing: WindowBacking = createWindowBacking()
    
    lazy var renderTargetBackend: RenderTargetBackend = getRenderTargetBackend(windowBacking: self.backing)
    var drawables: [Any] = []
    public private(set) lazy var texture: Texture = Texture(renderTarget: self)
    var previousSize: Size2? = nil
    
    weak var delegate: WindowDelegate? = nil
    
    internal var didDrawSomething: Bool = false
    
    public enum State {
        ///The window exists but isn't on screen
        case hidden
        ///The window is on screen
        case shown
        ///The window isn't visible and can never be shown again.
        case destroyed
    }
    public var state: State {
        return backing.state
    }
    
    public var title: String? {
        get {
            return backing.title
        }
        set {
            backing.title = newValue
        }
    }

    internal init(identifier: String, style: WindowStyle) {
        self.identifier = identifier
        self.style = style
        self.clearColor = .black
    }
    
    private var previousTime: Double = 0

    internal func vSyncCalled() {
        let now: Double = Game.shared.internalPlatform.systemTime()
        let delta: Double = now - previousTime
        self.previousTime = now
        // Positive time change and miniumum of 10 fps
        guard delta > 0 && delta < 0.1 else {return}
        if let delegate: WindowDelegate = self.delegate {
            self.size = self.backing.backingSize
            delegate.window(self, wantsUpdateForTimePassed: Float(delta))
            self.draw()
        }
    }
    
    @inlinable @inline(__always)
    public var interfaceScale: Float {
        return backing.backingSize.width / backing.frame.size.width
    }
    
    @inlinable @inline(__always)
    public var safeAreaInsets: Insets {
        return backing.safeAreaInsets
    }
    
    func show() {
        self.backing.show()
    }
}

@usableFromInline
internal protocol WindowBacking: AnyObject {
    var style: WindowStyle {get}
    var title: String? {get set}
    var frame: Rect {get set}
    var safeAreaInsets: Insets {get}
    var backingSize: Size2 {get}
    var state: Window.State {get}
    
    init(identifier: String, style: WindowStyle, window: Window)
    
    func show()
    func close()
}


protocol WindowDelegate: AnyObject {
    func window(_ window: Window, wantsUpdateForTimePassed deltaTime: Float)

    func mouseChange(event: MouseChangeEvent, position: Position2, window: Window?)
    func mouseClick(event: MouseClickEvent, button: MouseButton, count: Int?, position: Position2, window: Window?)

    func touchChange(id: AnyHashable, kind: TouchKind, event: TouchChangeEvent, position: Position2)

    func keyboardRequestedHandling(key: KeyboardKey,
                                   modifiers: KeyboardModifierMask,
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
        #error("Not implemented")
        #elseif os(WASI)
        return WASIWindow(identifier: identifier, style: style, window: self)
        #elseif os(Android)
       #error("Not implemented")
        #else
        #error("Not implemented")
        #endif
    }
}

public enum MouseButton {
    case button1
    case button2
    case button3
    case button4
    case button5
    case unknown
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
    /// The touch happened on a device not necesarrily the same shape or resolution as the screen
    case indirect
}

public struct KeyboardModifierMask: OptionSet {
    public typealias RawValue = UInt32
    public let rawValue: RawValue

    public static let host = KeyboardModifierMask(rawValue: 1 << 1)
    public static let shift = KeyboardModifierMask(rawValue: 1 << 2)
    public static let control = KeyboardModifierMask(rawValue: 1 << 3)
    public static let alt = KeyboardModifierMask(rawValue: 1 << 4)

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
    case nothing
    case escape
    case function(Int)
    case character(Character)
    case backspace
    case space
    case `return`
    case tab
    case up
    case down
    case left
    case right
}

extension KeyboardKey: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        if (value.hasPrefix("f") || value.hasPrefix("F")), let value = Int(value[value.index(after: value.startIndex)...]) {
            self = .function(value)
        }
        self = .character(value.first!)
    }
}

public enum KeyboardEvent {
    case keyDown
    case keyUp
}
