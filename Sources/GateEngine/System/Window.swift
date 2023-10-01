/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public enum WindowStyle {
    ///The window will appear the way most windows do on the platform.
    case system
    ///The window will attempt to maximize the content size within the window by reducing window decorations.
    case bestForGames
}

public struct WindowOptions: OptionSet {
    public typealias RawValue = UInt
    public var rawValue: RawValue
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    /// Allows the user to manually close the window. The main window is always closable and this option is ignored.
    public static let userClosable = WindowOptions(rawValue: 1 << 1)

    /// When the window is open it will enter full screen \, regardless of the users previous poreference
    public static let forceFullScreen = WindowOptions(rawValue: 1 << 2)

    /// The window will be full screen when first opened, but the users preference will be respected on subsequent launches
    public static let firstLaunchFullScreen = WindowOptions(rawValue: 1 << 3)

    /// The recommended window options for the main window
    internal static let defaultForMainWindow: WindowOptions = [.firstLaunchFullScreen]
    /// The recommended window options for windows
    public static let `default`: WindowOptions = []
}

@MainActor public final class Window: RenderTargetProtocol, _RenderTargetProtocol {
    public var lastDrawnFrame: UInt = .max
    public let identifier: String
    public let style: WindowStyle
    public let options: WindowOptions

    @inlinable @inline(__always)
    public var isMainWindow: Bool {
        return identifier == WindowManager.mainWindowIdentifier
    }

    @usableFromInline
    internal lazy var windowBacking: any WindowBacking = createWindowBacking()
    @usableFromInline
    lazy var renderTargetBackend: any RenderTargetBackend =
        windowBacking.createWindowRenderTargetBackend()

    var drawables: [Any] = []
    public private(set) lazy var texture: Texture = Texture(renderTarget: self)

    // true if the last draw attempt changed the screen
    internal var didDrawSomething: Bool = false

    public enum State {
        ///The window exists but isn't on screen
        case hidden
        ///The window is on screen
        case shown
        ///The window is about to move to destroyed state
        case closing
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

    internal lazy var newPixelSize: Size2 = self.size

    @inlinable @inline(__always)
    public var size: Size2 {
        return windowBacking.pixelSize
    }

    @inlinable @inline(__always)
    public var pointSize: Size2 {
        return windowBacking.pointSize
    }

    @inlinable @inline(__always)
    public var interfaceScale: Float {
        return windowBacking.interfaceScaleFactor
    }

    @inlinable @inline(__always)
    public var safeAreaInsets: Insets {
        return windowBacking.pixelSafeAreaInsets
    }

    @inlinable @inline(__always)
    public var pointSafeAreaInsets: Insets {
        return windowBacking.pointSafeAreaInsets
    }

    @inline(__always)
    internal func reshapeIfNeeded() {
        if self.newPixelSize != renderTargetBackend.size || renderTargetBackend.wantsReshape {
            renderTargetBackend.size = self.newPixelSize
            renderTargetBackend.reshape()
        }
    }

    internal init(identifier: String, style: WindowStyle, options: WindowOptions) {
        self.identifier = identifier
        self.style = style
        self.options = options
        self.clearColor = .black
    }

    private var previousTime: Double = 0

    /// The current delta time as a Double
    /// Use this instead of the System Float variant when keeping track of timers
    public var deltaTime: Double = 0

    var frame: UInt = 0
    internal func vSyncCalled() {
        let now: Double = Game.shared.platform.systemTime()
        self.deltaTime = now - previousTime
        self.previousTime = now
        // Positive time change and minimum of 10 fps
        guard deltaTime > 0 && deltaTime < 0.1 else { return }

        Game.shared.windowManager.window(
            self,
            wantsUpdateForTimePassed: Float(deltaTime)
        )
        self.draw(frame)

        frame &+= 1
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
@MainActor internal protocol WindowBacking: AnyObject {
    var state: Window.State { get }

    var title: String? { get set }

    var pointSafeAreaInsets: Insets { get }
    var pixelSafeAreaInsets: Insets { get }
    var pointSize: Size2 { get }
    var pixelSize: Size2 { get }
    var interfaceScaleFactor: Float { get }

    init(window: Window)

    func setMouseHidden(_ hidden: Bool)
    func setMousePosition(_ position: Position2)

    func show()
    func close()

    func createWindowRenderTargetBackend() -> any RenderTargetBackend
}

extension Window {
    @_transparent
    func createWindowBacking() -> any WindowBacking {
        #if canImport(UIKit)
        return UIKitWindow(window: self)
        #elseif canImport(AppKit)
        return AppKitWindow(window: self)
        #elseif canImport(WinSDK)
        return Win32Window(window: self)
        #elseif os(Linux)
        return X11Window(window: self)
        #elseif os(WASI)
        return WASIWindow(window: self)
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
