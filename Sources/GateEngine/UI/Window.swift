/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public enum WindowStyle {
    ///The window will appear the way most windows do on the platform.
    case system
    ///The window will attempt to maximize the content size within the window by reducing window decorations.
    case minimalSystemDecorations
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

@MainActor public final class Window: View, RenderTargetProtocol, _RenderTargetProtocol {
    public var lastDrawnFrame: UInt = .max
    public let identifier: String
    public let style: WindowStyle
    public let options: WindowOptions
    internal var drawables: [any Drawable] = []
    
    internal lazy var layout: Layout = Layout(window: self)
    public var rootViewController: ViewController? = nil {
        willSet {
            rootViewController?.isRootViewController = false
            rootViewController?.view.removeFromSuperview()
        }
        didSet {
            rootViewController?.isRootViewController = true
            if let view = rootViewController?.view {
                view.fill(self)
            }
        }
    }

    @inlinable @inline(__always)
    public var isMainWindow: Bool {
        return identifier == WindowManager.mainWindowIdentifier
    }

    @usableFromInline
    internal lazy var windowBacking: any WindowBacking = createWindowBacking()
    @usableFromInline
    lazy var renderTargetBackend: any RenderTargetBackend =
        windowBacking.createWindowRenderTargetBackend()

    public private(set) lazy var texture: Texture = Texture(renderTarget: self)
    
    public override var backgroundColor: Color? {
        get {
            return self.clearColor
        }
        set {
            self.clearColor = newValue ?? .clear
            super.backgroundColor = nil // Set super for didSet trigger
        }
    }
    
    override func draw(_ rect: Rect, into canvas: inout UICanvas) {
        // Don't forward to super as the clear color will fill the background
    }
    
    var offScreenRendering = OffScreenRendering()
    @MainActor struct OffScreenRendering {
        let renderTarget: RenderTarget = RenderTarget(size: Size2(width: 2048, height: 2048), backgroundColor: .clear)
        
        #if DEBUG
        static let blockSize: Int = 64
        #else
        static let blockSize: Int = 16
        #endif
        
        private var elements: [Element] = []
        private struct Element {
            weak var view: View? = nil
            var size: Size2 = .zero
            var gridOrigin: (x: Int, y: Int) = (0, 0)
            
            @MainActor
            var packedFrame: Rect {
                return Rect(
                    position: Position2(
                        x: Float(gridOrigin.x * blockSize), 
                        y: Float(gridOrigin.y * blockSize)
                    ),
                    size: size
                )
            }
            
//            @_transparent
            @MainActor
            func blocksWide() -> Int {
                let value = (size.width / Float(blockSize)).rounded(.up)
                return max(1, Int(value))
            }
//            @_transparent
            @MainActor
            func blocksTall() -> Int {
                let value = (size.height / Float(blockSize)).rounded(.up)
                return max(1, Int(value))
            }
        }
        
        mutating func addView(_ view: View) {
            if let index = viewToRemove.firstIndex(where: {$0 === view}) {
                viewToRemove.remove(at: index)
            }else{
                self.viewToAdd.append(view)
            }
        }
        
        mutating func removeView(_ view: View) {
            if let index = viewToAdd.firstIndex(where: {$0 === view}) {
                viewToAdd.remove(at: index)
            }else{
                self.viewToRemove.append(view)
            }
        }
        
        func frameForView(_ view: View) -> Rect {
            if let index = self.elements.firstIndex(where: {$0.view === view}) {
                return self.elements[index].packedFrame
            }
            fatalError()
        }
        
        var viewToAdd: [View] = []
        var viewToRemove: [View] = []
        
        mutating func update() {
            guard viewToAdd.isEmpty == false || viewToRemove.isEmpty == false else {
                return
            }
            
            for view in viewToRemove {
                if let index = self.elements.firstIndex(where: {$0.view === view}) {
                    self.elements.remove(at: index)
                }
            }
            self.viewToRemove.removeAll(keepingCapacity: true)
            
            for view in viewToAdd {
                if self.elements.firstIndex(where: {$0.view === view}) == nil {
                    let size = view.frame.size * view.interfaceScale
                    if size.width > 0 && size.height > 0 {
                        self.elements.append(Element(view: view, size: size))
                    }
                }
            }
            self.viewToAdd.removeAll(keepingCapacity: true)
            
            var cleanIndicies: [Int] = []
            for index in elements.indices {
                if let view = elements[index].view {
                    elements[index].size = view.frame.size * view.interfaceScale
                }else{
                    cleanIndicies.append(index)
                }
            }
            for index in cleanIndicies.reversed() {
                self.elements.remove(at: index)
            }
            
            self.elements.sort { element1, element2 in
                return element1.size.width > element2.size.width
            }
            
            var searchGrid = SearchGrid(width: 2048 / Self.blockSize)
            for index in elements.indices {
                let element = elements[index]
                elements[index].gridOrigin = searchGrid.firstUnoccupiedFor(
                    width: element.blocksWide(),
                    height: element.blocksTall(),
                    markOccupied: true
                )
            }
        }
        
        struct SearchGrid {
            let width: Int
            
            var height: Int {
                mutating get {
                    return rows.count
                }
            }
            
            var rows: [[Bool]] = []
            
            init(width: Int) {
                self.width = width
            }
            
            mutating func insertNewRow() {
                rows.append(Array(repeating: false, count: width))
            }
            
            mutating func markAsOccupied(x: Int, y: Int, width: Int, height: Int) {
                assert(x + width <= self.width)
                while y + height > rows.count {
                    insertNewRow()
                }
                for row in y ..< y + height {
                    for column in x ..< x + width {
                        rows[row][column] = true
                    }
                }
            }
            
            mutating func isOccupied(x: Int, y: Int, width: Int, height: Int) -> Bool {
                assert(x + width <= self.width)
                for row in y ..< y + height {
                    guard row < rows.count else {break}
                    for column in x ..< x + width {
                        if rows[row][column] {
                            return true
                        }
                    }
                }
                return false
            }

            mutating func firstUnoccupiedFor(width: Int, height: Int, markOccupied: Bool) -> (x: Int, y: Int) {
                assert(width <= self.width)
                for row in rows.indices {
                    for column in 0 ..< self.width {
                        guard column + width <= self.width else {
                            break
                        }
                        if isOccupied(x: column, y: row, width: width, height: height) == false {
                            if markOccupied {
                                markAsOccupied(x: column, y: row, width: width, height: height)
                            }
                            return (column, row)
                        }
                    }
                }
                let coord = (x: 0, y: rows.count)
                if markOccupied {
                    markAsOccupied(x: coord.x, y: coord.y, width: width, height: height)
                }
                return coord
            }
        }
    }

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

    internal lazy var newPixelSize: Size2 = self.size {
        didSet {
            self.setNeedsLayout()
        }
    }
        
    public override func contentSize() -> Size2 {
        return self.pointSize
    }

    @inlinable @inline(__always)
    public var size: Size2 {
        return windowBacking.pixelSize
    }

    @inlinable @inline(__always)
    public var pointSize: Size2 {
        return windowBacking.pointSize
    }

    @inlinable @inline(__always)
    public override var interfaceScale: Float {
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
    
//    internal func matrices() -> Matrices {
//        let ortho = Matrix4x4(
//            orthographicWithTop: 0,
//            left: 0,
//            bottom: self.size.height,
//            right: self.size.width,
//            near: 0,
//            far: Float(Int32.max)
//        )
//        
//        let view = Matrix4x4(position: .zero)
//        return Matrices(projection: ortho, view: view)
//    }
    
    func _update(deltaTime: Float) async {
        self._update(withTimePassed: deltaTime)
        await self.rootViewController?._update(withTimePassed: deltaTime)
        
        self.layout.process()
    }
    
    var accumulatedFrames: UInt = 0
    func _draw(deltaTime: Float) {
        self.accumulatedFrames &+= 1
        self._willDraw()
        self.offScreenRendering.update()
//        guard Geometry.rectOriginTopLeft.isReady else {return}
//        var canvas = UICanvas(estimatedCommandCount: 10)
        self.draw(self.accumulatedFrames)
//        self.draw(into: &canvas, at: Rect(size: self.size))
//        self.didDrawSomething = canvas.hasContent
//        self.insert(canvas)
    }
    
    // The window shouldn't ever need to render off screen
    override var renderingMode: View.RenderingMode {
        get {
            return .screen
        }
        set {
            
        }
    }
    
    public enum Orientation {
        case portrait
        case landscape
    }
    private var sentInitialOrientationCall = false
    public final internal(set) var orientation: Orientation = .landscape {
        didSet {
            if sentInitialOrientationCall == false || oldValue != orientation {
                sentInitialOrientationCall = true
                self.rootViewController?._windowOrientationDidChange(to: orientation)
            }
        }
    }
    
    public override var frame: Rect {
        didSet {
            let size = frame.size
            
            if size.width > size.height {
                self.orientation = .landscape
            }else if size.height > size.width {
                self.orientation = .portrait
            }
        }
    }

    internal init(
        identifier: String,
        rootViewController: ViewController,
        style: WindowStyle = .system,
        options: WindowOptions = .firstLaunchFullScreen
    ) {
        self.identifier = identifier
        self.rootViewController = rootViewController
        self.style = style
        self.options = options
        super.init()
        self.rootViewController?.isRootViewController = true
        self.rootViewController?.view.fill(self)
    }

    private var previousTime: Double = 0

    /// The current delta time as a Double
    /// Use this instead of the System Float variant when keeping track of timers
    public var deltaTime: Double = 0

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
    
    
    weak var currentlyHitMouseView: View? = nil
    
    internal func mouseChange(
        event: Mouse.ChangeEvent,
        position: Position2,
        delta: Position2
    ) {
        switch event {
        case .entered:
            if let hit = self.hitTest(position, clipRect: Rect(size: self.size)) {
                if hit !== currentlyHitMouseView {
                    currentlyHitMouseView?.cursorExited(Game.shared.hid.mouse)
                }
                currentlyHitMouseView = hit
                currentlyHitMouseView!.cursorEntered(Game.shared.hid.mouse)
            }else{
                currentlyHitMouseView?.cursorExited(Game.shared.hid.mouse)
                currentlyHitMouseView = nil
            }
        case .moved:
            if let hit = self.hitTest(position, clipRect: Rect(size: self.size)) {
                if hit !== currentlyHitMouseView {
                    currentlyHitMouseView?.cursorExited(Game.shared.hid.mouse)
    
                    currentlyHitMouseView = hit
                    currentlyHitMouseView!.cursorEntered(Game.shared.hid.mouse)
                }else{
                    currentlyHitMouseView = hit
                    currentlyHitMouseView!.cursorMoved(Game.shared.hid.mouse)
                }
            }else{
                currentlyHitMouseView?.cursorExited(Game.shared.hid.mouse)
                currentlyHitMouseView = nil
            }
        case .exited:
            currentlyHitMouseView?.cursorExited(Game.shared.hid.mouse)
            currentlyHitMouseView = nil
        }
    }

    internal func mouseClick(
        event: Mouse.ClickEvent,
        button: MouseButton,
        multiClickTime: Double,
        position: Position2?,
        delta: Position2?
    ) {
        if let view = currentlyHitMouseView {
            let mouse = Game.shared.hid.mouse
            if event == .buttonDown {
                view.cursorButtonDown(button: button, mouse: mouse)
            }else if event == .buttonUp {
                view.cursorButtonUp(button: button, mouse: mouse)
            }
        }
    }

    internal func mouseScrolled(
        delta: Position3,
        uiDelta: Position3,
        device: Int,
        isMomentum: Bool
    ) {
        if let view = currentlyHitMouseView {
            view.scrolled(Position2(uiDelta.x, uiDelta.y), isPlatformGeneratedMomentum: isMomentum)
        }
    }
    
    var currentlyHitTouchViews: [Touch:View] = [:]
    
    internal func touchChange(
        id: AnyHashable,
        kind: TouchKind,
        event: TouchChangeEvent,
        position: Position2,
        precisionPosition: Position2?,
        pressure: Float
    ) {
        switch event {
        case .began:
            let touch = Touch(
                id: id, 
                window: self, 
                position: position, 
                precisionPosition: precisionPosition, 
                pressure: pressure, 
                phase: .down, 
                kind: kind
            )
            if let view = self.hitTest(position, clipRect: Rect(size: self.size)) {
                currentlyHitTouchViews[touch] = view
                view.touchesBegan([touch])
            }
        case .moved:
            let touch = Touch(
                id: id, 
                window: self, 
                position: position, 
                precisionPosition: precisionPosition, 
                pressure: pressure, 
                phase: .down, 
                kind: kind
            )
            if let view = currentlyHitTouchViews[touch] {
                view.touchesMoved([touch])
            }
        case .ended:
            let touch = Touch(
                id: id, 
                window: self, 
                position: position, 
                precisionPosition: precisionPosition, 
                pressure: pressure, 
                phase: .down, 
                kind: kind
            )
            if let view = currentlyHitTouchViews[touch] {
                view.touchesEnded([touch])
                currentlyHitTouchViews[touch] = nil
            }
        case .canceled:
            let touch = Touch(
                id: id, 
                window: self, 
                position: position, 
                precisionPosition: precisionPosition, 
                pressure: pressure, 
                phase: .down, 
                kind: kind
            )
            if let view = currentlyHitTouchViews[touch] {
                view.touchesCanceled([touch])
                currentlyHitTouchViews[touch] = nil
            }
        }
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
