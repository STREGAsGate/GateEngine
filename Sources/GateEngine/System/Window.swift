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
