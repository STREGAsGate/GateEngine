/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@MainActor
open class View {
    public final var opacity: Float = 1 {
        didSet {
            self.renderingModeNeedsUpdate = true
            self.offScreenRepresentationMaterialNeedsUpdate = true
        }
    }
    
    open var backgroundColor: Color? = nil {
        didSet {
            self._onScreenMaterial.channel(0) { channel in
                channel.color = backgroundColor ?? .clear
            }
        }
    }
    
    public final var cornerRadius: Float = 0 {
        didSet {
            self.renderingModeNeedsUpdate = true
            self.offScreenRepresentationMaterialNeedsUpdate = true
            
        }
    }
    public final var cornerMask: CornerMask = .all {
        didSet {
            self.renderingModeNeedsUpdate = true
            self.offScreenRepresentationMaterialNeedsUpdate = true
        }
    }
    
    public var clipToBounds: Bool = false {
        didSet {
            self.renderingModeNeedsUpdate = true
        }
    }
    
    public init() {

    }
    
    public var interfaceScale: Float {
        if let scale = window?.interfaceScale {
            return scale
        }
        return 1.0
    }
    
    public var userInteractionEnabled: Bool = true
    
    internal var _needsLayout: Bool = true
    var needsLayout: Bool {
        get {
            if _needsLayout { return true }
            for subview in subviews {
                if subview.needsLayout {
                    return true
                }
            }
            return false
        }
        set {
            if newValue {
                self.setNeedsLayout()
            }
        }
    }
    internal var needsUpdateConstraints: Bool = true
    public private(set) weak var superView: View? = nil {
        didSet {
            self._window = nil
            self.setNeedsLayout()
            self.didChangeSuperview()
            self.setNeedsUpdateConstraints()
        }
    }
    public private(set) var subviews: [View] = [] {
        didSet {
            self.setNeedsUpdateConstraints()
            self.setNeedsLayout()
        }
    }
    
    @usableFromInline
    internal final weak var _viewController: ViewController? = nil
    
    public private(set) weak var _window: Window? = nil
    public var window: Window? {
        if let _window {
            return _window
        }
        
        var view: View? = self
        while view is Window == false && view != nil {
            view = view?.superView
        }
        if let window = view as? Window {
            _window = window
        }
        
        if _window == nil {
            // If the view is removed from the view heirarchy
            // Check the ViewController chain
            var parent: ViewController? = self._viewController?.parent
            while parent != nil {
                let next = parent?.parent
                if next == nil {break}
                parent = next
            }
            if let window = parent?.view.window {
                _window = window
            }
        }
        
        return _window
    }
    
    
    //MARK: Layout
    
    open func contentSize() -> Size2 {
        if let viewController = _viewController {
            return viewController.preferredContentSize()
        }
        var size: Size2 = .zero
        for subview in self.subviews {
            let frame = subview.representationFrame()
            size.width = .maximum(size.width, frame.maxX)
            size.height = .maximum(size.height, frame.maxY)
        }
        return size
    }
    
    var _computedWindowSpaceFrame: Rect? = nil
    var _representationFrame: Rect? = nil
    var _offScreenFrame: Rect? = nil
    func invalidateFrameCache() {
        self._computedWindowSpaceFrame = nil
        self._representationFrame = nil
        self._offScreenFrame = nil
    }
    
    internal var computedWindowSpaceFrame: Rect {
        if let _computedWindowSpaceFrame {
            return _computedWindowSpaceFrame
        }
        var frame = self.frame
        var _superview: View? = self.superView
        while let superview = _superview {
            frame.position += superview.frame.position
            _superview = superview.superView
        }
        _computedWindowSpaceFrame = frame
        return frame
    }
    
    /// The frame when placing this content inside its superview
    func representationFrame() -> Rect {
        if let _representationFrame {
            return _representationFrame
        }
        var frame = self.frame
        var _superview: View? = self.superView
        while let superview = _superview {
            if superview.renderingMode == .offScreen {
                if let offsecreenPosition = window?.offScreenRendering.frameForView(superview)?.position {
                    frame.position += offsecreenPosition / interfaceScale
                    break
                }
            }
            frame.position += superview.bounds.position
            frame.position += superview.frame.position
            _superview = superview.superView
        }
        _representationFrame = frame * interfaceScale
        return _representationFrame!
    }
    
    /// The frame when placing this content in the offscreen buffer
    func offScreenFrame() -> Rect {
        if self.renderingMode == .offScreen {
            if let frame = window?.offScreenRendering.frameForView(self) {
                return frame
            }
        }
        
        if let _offScreenFrame {
            return _offScreenFrame
        }
        
        var frame = self.frame
        var _superview: View? = self.superView
        while let superview = _superview {
            if superview.renderingMode == .offScreen {
                break
            }
            frame.position += superview.bounds.position
            frame.position += superview.frame.position
            _superview = superview.superView
        }
        _offScreenFrame = frame * interfaceScale
        return _offScreenFrame!
    }
    
    public internal(set) var frame: Rect = .zero {
        didSet {
            if frame != oldValue {
                self.bounds = Rect(position: .zero, size: frame.size)
                self.invalidateFrameCache()
                self.offScreenRepresentationMaterialNeedsUpdate = true
            }
        }
    }
    public internal(set) var bounds: Rect = .zero
    
    open func didChangeSuperview() {
        
    }
    
    public var layoutConstraints = Layout.Constraints() {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public var marginInsets: Insets = .zero
    @available(*, deprecated, message: "margin guide not implemented. Will crash if used.")
    public private(set) lazy var margin: Layout.Guide = Layout.Guide(view: self)
    
    public var additionalSafeAreaInsets: Insets = .zero
    @available(*, deprecated, message: "safeArea guide not implemented. Will crash if used.")
    public private(set) lazy var safeArea: Layout.Guide = Layout.Guide(view: self)
    
    internal lazy var layoutGuide: Layout.Guide = Layout.Guide(view: self)
    
    public var topAnchor: Layout.Anchor<Layout.Vertical, Layout.Location> {self.layoutGuide.topAnchor}
    public var leadingAnchor: Layout.Anchor<Layout.Horizontal, Layout.Location> {self.layoutGuide.leadingAnchor}
    public var bottomAnchor: Layout.Anchor<Layout.Vertical, Layout.Location> {self.layoutGuide.bottomAnchor}
    public var trailingAnchor: Layout.Anchor<Layout.Horizontal, Layout.Location> {self.layoutGuide.trailingAnchor}
    
    public private(set) lazy var centerXAnchor: Layout.Anchor<Layout.Horizontal, Layout.Location> = Layout.Anchor(view: self)
    public private(set) lazy var centerYAnchor: Layout.Anchor<Layout.Vertical, Layout.Location> = Layout.Anchor(view: self)
    
    public private(set) lazy var widthAnchor: Layout.Anchor<Layout.Horizontal, Layout.Size> = Layout.Anchor(view: self)
    public private(set) lazy var heightAnchor: Layout.Anchor<Layout.Vertical, Layout.Size> = Layout.Anchor(view: self)
    
    
    internal func _update(withTimePassed deltaTime: Float) {
        self.update(withTimePassed: deltaTime)
        for subview in subviews {
            subview._update(withTimePassed: deltaTime)
        }
    }
    
    open func update(withTimePassed deltaTime: Float) {
        
    }
    
    internal func _updateLayoutConstraints() {
        self.needsUpdateConstraints = false
        self._viewController?.viewWillUpdateLayoutConstraints()
        self.updateLayoutConstraints()
        self._viewController?.viewDidUpdateLayoutConstraints()
    }
    
    public final func layoutIfNeeded() {
        Layout.layoutViewIfNeeded(self)
    }
    
    internal func _willLayout() {
        self.willLayout()
    }
    
    internal func _didLayout() {
        self.didLayout()
    }
    
    open func updateLayoutConstraints() {
        
    }
    
    open func willLayout() {
        
    }
    
    open func didLayout() {
        
    }
    
    //MARK: User Interaction
    
    public private(set) var gestureRecognizers: [GestureRecognizer] = []
    public func addGestureRecognizer(_ gestureRecognizer: GestureRecognizer) {
        gestureRecognizer.view = self
        gestureRecognizers.append(gestureRecognizer)
    }
    public func removeGestureRecognizer(_ gestureRecognizer: GestureRecognizer) {
        gestureRecognizers.removeAll { $0 === gestureRecognizer }
        if gestureRecognizer.view === self {
            gestureRecognizer.view = nil
        }
    }
    private func updateGestureRecognizers() {
        var active: [GestureRecognizer] = []
        for gestureRecognizer in gestureRecognizers {
            if gestureRecognizer.phase != .unrecognized {
                active.append(gestureRecognizer)
            }
        }
        guard active.count > 1 else {return}
        guard let recognized = active.first(where: {$0.phase == .recognized}) else {return}
        for recognizer in active {
            if recognized !== recognizer {
                if recognized.recognizesSimultaneously(with: recognizer) == false {
                    recognizer.invalidate()
                }
            }
        }
    }
    
    open func touchesBegan(_ touches: Set<Touch>) {
        for gestureRecognizer in gestureRecognizers {
            gestureRecognizer.touchesBegan(touches)
        }
        self.updateGestureRecognizers()
        self.controllingViewController?.touchesBegan(touches)
    }
    open func touchesMoved(_ touches: Set<Touch>) {
        for gestureRecognizer in gestureRecognizers {
            gestureRecognizer.touchesMoved(touches)
        }
        self.updateGestureRecognizers()
        self.controllingViewController?.touchesMoved(touches)
    }
    open func touchesEnded(_ touches: Set<Touch>) {
        for gestureRecognizer in gestureRecognizers {
            gestureRecognizer.touchesEnded(touches)
        }
        self.updateGestureRecognizers()
        self.controllingViewController?.touchesEnded(touches)
    }
    open func touchesCanceled(_ touches: Set<Touch>) {
        for gestureRecognizer in gestureRecognizers {
            gestureRecognizer.touchesCanceled(touches)
        }
        self.updateGestureRecognizers()
        self.controllingViewController?.touchesCanceled(touches)
    }
    
    open func surfaceTouchesBegan(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        for gestureRecognizer in gestureRecognizers {
            gestureRecognizer.surfaceTouchesBegan(touches, mouse: mouse)
        }
        self.updateGestureRecognizers()
        self.controllingViewController?.surfaceTouchesBegan(touches, mouse: mouse)
    }
    open func surfaceTouchesMoved(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        for gestureRecognizer in gestureRecognizers {
            gestureRecognizer.surfaceTouchesMoved(touches, mouse: mouse)
        }
        self.updateGestureRecognizers()
        self.controllingViewController?.surfaceTouchesMoved(touches, mouse: mouse)
    }
    open func surfaceTouchesEnded(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        for gestureRecognizer in gestureRecognizers {
            gestureRecognizer.surfaceTouchesEnded(touches, mouse: mouse)
        }
        self.updateGestureRecognizers()
        self.controllingViewController?.surfaceTouchesEnded(touches, mouse: mouse)
    }
    open func surfaceTouchesCanceled(_ touches: Set<SurfaceTouch>, mouse: Mouse) {
        for gestureRecognizer in gestureRecognizers {
            gestureRecognizer.surfaceTouchesCanceled(touches, mouse: mouse)
        }
        self.updateGestureRecognizers()
        self.controllingViewController?.surfaceTouchesCanceled(touches, mouse: mouse)
    }
    
    open func cursorEntered(_ cursor: Mouse) {
        for gestureRecognizer in gestureRecognizers {
            gestureRecognizer.cursorEntered(cursor)
        }
        self.updateGestureRecognizers()
        self.controllingViewController?.cursorEntered(cursor)
    }
    open func cursorMoved(_ cursor: Mouse) {
        for gestureRecognizer in gestureRecognizers {
            gestureRecognizer.cursorMoved(cursor)
        }
        self.updateGestureRecognizers()
        self.controllingViewController?.cursorMoved(cursor)
    }
    open func cursorExited(_ cursor: Mouse) {
        for gestureRecognizer in gestureRecognizers {
            gestureRecognizer.cursorExited(cursor)
        }
        self.updateGestureRecognizers()
        self.controllingViewController?.cursorExited(cursor)
    }
    
    open func cursorButtonDown(button: MouseButton, mouse: Mouse) {
        for gestureRecognizer in gestureRecognizers {
            gestureRecognizer.cursorButtonDown(button: button, mouse: mouse)
        }
        self.updateGestureRecognizers()
        self.controllingViewController?.cursorButtonDown(button: button, mouse: mouse)
    }
    open func cursorButtonUp(button: MouseButton, mouse: Mouse) {
        for gestureRecognizer in gestureRecognizers {
            gestureRecognizer.cursorButtonUp(button: button, mouse: mouse)
        }
        self.updateGestureRecognizers()
        self.controllingViewController?.cursorButtonUp(button: button, mouse: mouse)
    }
    
    open func scrolled(_ delta: Position2, isPlatformGeneratedMomentum isMomentum: Bool) {
        for gestureRecognizer in gestureRecognizers {
            gestureRecognizer.scrolled(delta, isPlatformGeneratedMomentum: isMomentum)
        }
        self.updateGestureRecognizers()
        self.controllingViewController?.scrolled(delta, isPlatformGeneratedMomentum: isMomentum)
    }
    
    open func canBeHit() -> Bool {
        return false
    }
    
    private final var _onScreenMaterial = Material(color: .clear)
    
    private final var _offScreenRepresentationMaterial = Material(color: .clear)
    private final var offScreenRepresentationMaterial: Material {
        if offScreenRepresentationMaterialNeedsUpdate {
            offScreenRepresentationMaterialNeedsUpdate = false
            updateoffScreenRepresentationMaterial()
        }
        return _offScreenRepresentationMaterial
    }
    internal final var offScreenRepresentationMaterialNeedsUpdate: Bool = true
    private func updateoffScreenRepresentationMaterial() {
        self._offScreenRepresentationMaterial.channel(0) { [weak self] channel in
            channel.color = self?.backgroundColor ?? .clear
        }

        self._offScreenRepresentationMaterial.setCustomUniformValue(opacity, forUniform: "opacity")
        self._offScreenRepresentationMaterial.setCustomUniformValue(cornerRadius * interfaceScale, forUniform: "Radius")
        
        self._offScreenRepresentationMaterial.setCustomUniformValue(cornerMask.contains(.topLeft), forUniform: "TopLeft")
        self._offScreenRepresentationMaterial.setCustomUniformValue(cornerMask.contains(.topRight), forUniform: "TopRight")
        self._offScreenRepresentationMaterial.setCustomUniformValue(cornerMask.contains(.bottomRight), forUniform: "BottomRight")
        self._offScreenRepresentationMaterial.setCustomUniformValue(cornerMask.contains(.bottomLeft), forUniform: "BottomLeft")
        
        var frame = self.representationFrame()
        if Game.shared.renderingAPI.origin == .bottomLeft {
            frame.position.y = self.window!.representationFrame().height - frame.maxY
        }
        _offScreenRepresentationMaterial.setCustomUniformValue(frame.position, forUniform: "ViewOrigin")
        _offScreenRepresentationMaterial.setCustomUniformValue(frame.size, forUniform: "ViewSize")
    }
    
    internal enum RenderingMode {
        case screen
        case offScreen
    }
    private final var renderingModeNeedsUpdate: Bool = true
    internal private(set) var renderingMode: RenderingMode = .screen
    
    func updateRenderingModeIfNeeded() {
        if renderingModeNeedsUpdate {
            if let window { // Make sure we can access the window for offscreen pointers
                renderingModeNeedsUpdate = false
                var newMode: RenderingMode = .screen
                if self.clipToBounds {
                    newMode = .offScreen
                }
                if self.cornerRadius > 0 && self.cornerMask.isEmpty == false {
                    newMode = .offScreen
                }
                if self.opacity < 1 {
                    newMode = .offScreen
                }
                if newMode != self.renderingMode {
                    if renderingMode == .offScreen {
                        window.offScreenRendering.removeView(self)
                    }
                    if newMode == .offScreen {
                        window.offScreenRendering.addView(self)
                    }
                    self.renderingMode = newMode
                }
            }
        }
    }
    
    internal func _willDraw() {
        self.updateRenderingModeIfNeeded()
        // TODO: Make updateRenderingModeIfNeeded() happen before layout
        // RenderingMode is changing after layout which causes the cached
        // frames to be incorrect
        self.invalidateFrameCache()
        
        self.willDraw()
        for view in subviews {
            view._willDraw()
        }
    }
    
    open func willDraw() {
        
    }
    
    internal func shouldDraw() -> Bool {
        if self.opacity <= 0 {
            return false
        }
        if self.frame.size <= .zero {
            return false
        }
        return true
    }
    
    /// In Debug builds, will tint Views yellow if they were composited outside the window
    public static var colorOffscreenRendered: Bool = false
    
    internal func drawOffScreenRepresentation(into canvas: inout UICanvas, at frame: Rect) {
        guard let offScreenRendering = self.window?.offScreenRendering else {return}
        guard let offscreenFrame = offScreenRendering.frameForView(self) else {return}
        
        var material = self.offScreenRepresentationMaterial
        material.channel(0) { channel in
            channel.texture = offScreenRendering.renderTarget.texture
            channel.setSubRect(.init(position: .init(offscreenFrame.position), size: .init(offscreenFrame.size)))
        }
        #if DEBUG
        material.channel(1) { channel in
            if Self.colorOffscreenRendered {
                channel.color = .yellow.withAlpha(0.8)        
            }else{
                channel.color = .white
            }
        }
        #endif
        canvas.insert(
            DrawCommand(
                resource: .geometry(.rectOriginTopLeft),
                transforms: [
                    Transform3(
                        position: Position3(
                            x: frame.x,
                            y: frame.y,
                            z: 1_000_000 // high distance so the depth gets set to far away
                        ),
                        scale: Size3(
                            frame.width,
                            frame.height,
                            1
                        )
                    )
                ],
                material: material,
                vsh: .standard,
                fsh: Self.fragmentShaderTextureSample,
                flags: .userInterfaceMask
            )
        )
    }
        
    internal func draw(_ rect: Rect, into canvas: inout UICanvas) {
        guard let backgroundColor, backgroundColor.alpha > 0 else {return}
        canvas.insert(
            DrawCommand(
                resource: .geometry(.rectOriginTopLeft),
                transforms: [
                    Transform3(
                        position: Position3(
                            x: rect.x,
                            y: rect.y,
                            z: 0
                        ),
                        scale: Size3(
                            rect.width,
                            rect.height,
                            1
                        )
                    )
                ],
                material: _onScreenMaterial,
                vsh: .standard,
                fsh: .materialColor,
                flags: .userInterface
            )
        )
    }
}

extension View {
    /**
     The ViewController that loaded this view, if any.
     
     - returns: The `ViewController` that  created this view in it's ``ViewController/loadView()`` function, or `nil`.
     - SeeAlso: ``viewController``, ``firstParentViewController(ofType:)``
     */
    public var controllingViewController: ViewController? {
        return _viewController
    }
    
    /// The first ViewController found traviling up the view heirarchy
    public var viewController: ViewController? {
        var view: View? = self
        while view != nil && view?._viewController == nil {
            view = view?.superView
        }
        return view?._viewController
    }
    
    /**
     Finds the first ViewController that is of type `type`.
     
     This is equivalent to `self.viewController?.firstParent(ofType: type)`
     - Parameter type: Any ViewController type
     - Returns: The first ViewController instance matching type `type`, or nil.
     */
    public func firstParentViewController<ViewControllerResult: ViewController>(ofType type: ViewControllerResult.Type) -> ViewControllerResult? {
        return self.viewController?.firstParent(ofType: type)
    }
}

extension View {
    public final func addSubview(_ view: View) {
        view.removeFromSuperview()
        subviews.append(view)
        view.superView = self
    }
    public final func sendSubviewToBack(_ view: View) {
        if let index = subviews.firstIndex(where: {$0 === self}) {
            subviews.remove(at: index)
            subviews.insert(view, at: 0)
        }
    }
    public final func bringSubviewToFront(_ view: View) {
        if let index = subviews.firstIndex(where: {$0 === self}) {
            subviews.remove(at: index)
            subviews.append(view)
        }
    }
    public final func removeFromSuperview() {
        if let superView {
            if let index = superView.subviews.firstIndex(where: {$0 === self}) {
                superView.subviews.remove(at: index)
                self.superView = nil
            }
        }
    }
    
    public final func setNeedsUpdateConstraints() {
        self.window?.setNeedsLayout()
        self.needsUpdateConstraints = true
    }
    
    public func setNeedsLayout() {
        // Prevent recursion explosion
        guard _needsLayout == false else {return}
        
        // Mark this view for layout
        self._needsLayout = true
        
        // forward setNeedsLayout to all views this view is constrained by
        for view in self.layoutConstraints.allTargets {
            view.setNeedsLayout()
        }
        
        // forward setNeedsLayout to all subviews this view is constrained by
        for subview in self.subviews {
            for view in subview.layoutConstraints.allTargets {
                if view === self {
                    subview.setNeedsLayout()
                }
            }
        }
    }
}

public extension View {
    enum ConstrainStyleHorizontal {
        case fill
        case pinLeading
        case pinTrailing
        case center
    }
    enum ConstrainStyleVertical {
        case fill
        case pinTop
        case pinBottom
        case center
    }
    
    @inlinable
    func addSubview(
        _ view: View, 
        constrainHorizontal: ConstrainStyleHorizontal, 
        constrainVertical: ConstrainStyleVertical, 
        insets: Insets = .zero
    ) {
        self.addSubview(view)
        
        switch constrainHorizontal {
        case .fill:
            view.leadingAnchor.constrain(insets.leading, from: self.leadingAnchor)
            view.trailingAnchor.constrain(-insets.trailing, from: self.trailingAnchor)
        case .pinLeading:
            view.leadingAnchor.constrain(insets.leading, from: self.leadingAnchor)
        case .pinTrailing:
            view.trailingAnchor.constrain(-insets.trailing, from: self.trailingAnchor)
        case .center:
            view.centerXAnchor.constrain(to: self.centerXAnchor)
        }
        
        switch constrainVertical {
        case .fill:
            view.topAnchor.constrain(insets.top, from: self.topAnchor)
            view.bottomAnchor.constrain(-insets.bottom, from: self.bottomAnchor)
        case .pinTop:
            view.topAnchor.constrain(insets.top, from: self.topAnchor)
        case .pinBottom:
            view.bottomAnchor.constrain(-insets.bottom, from: self.bottomAnchor)
        case .center:
            view.centerYAnchor.constrain(to: self.centerYAnchor)
        }
    }
}

extension View {
    public struct CornerMask: OptionSet, Sendable {
        public var rawValue: UInt
        
        public static let topLeft: CornerMask = CornerMask(rawValue: 1 << 0)
        public static let topRight: CornerMask = CornerMask(rawValue: 1 << 1)
        public static let bottomRight: CornerMask = CornerMask(rawValue: 1 << 2)
        public static let bottomLeft: CornerMask = CornerMask(rawValue: 1 << 3)
        public static let top: CornerMask = [.topLeft, .topRight]
        public static let bottom: CornerMask = [.bottomLeft, .bottomRight]
        public static let all: CornerMask = [.topLeft, .topRight, .bottomLeft, .bottomRight]
        
        public typealias RawValue = UInt
        public init(rawValue: CornerMask.RawValue) {
            self.rawValue = rawValue
        }
    }
}

extension View {
    public func fill(_ superView: View, andInset insets: Insets = .zero) {
        superView.addSubview(self)
        self.topAnchor.constrain(insets.top, from: superView.topAnchor)
        self.leadingAnchor.constrain(insets.leading, from: superView.leadingAnchor)
        self.widthAnchor.constrain(to: superView.widthAnchor, adding: -(insets.leading + insets.trailing))
        self.heightAnchor.constrain(to: superView.heightAnchor, adding: -(insets.bottom + insets.top))
    }
}

extension View {
    internal func convert(_ position: Position2, to window: Window) -> Position2 {
        return position + computedWindowSpaceFrame.position
    }
    
    internal func convert(_ position: Position2, from window: Window) -> Position2 {
        return position - computedWindowSpaceFrame.position
    }
    
    internal func convert(_ position: Position2, to destinationView: View) -> Position2 {
        assert(self.window != nil && self.window == destinationView.window)
        
        let position = self.convert(position, to: destinationView.window!)
        return destinationView.convert(position, from: self.window!)
    }
    
    internal func convert(frame: Rect, to destination: View) -> Rect {
        var frame = frame
        frame.position = self.convert(frame.position, to: destination)
        return frame
    }
}

extension View {
    internal func hitTest(_ position: Position2, clipRect: Rect) -> View? {
        guard userInteractionEnabled else {return nil}
        let frame = self.computedWindowSpaceFrame.clamped(within: clipRect)
        if frame.contains(position) {
            for subview in subviews.reversed() {
                if let hit = subview.hitTest(position, clipRect: frame) {
                    return hit
                }
            }
            if canBeHit() {
                return self
            }
        }
        return nil
    }
}

protocol OffScreenRendered {
//    var target: Renderer.Target {get}
}

import Shaders

extension View {
    static let fragmentShader: FragmentShader = {
        var fsh = FragmentShader()
        
        let viewOrigin: Vec2 = fsh.uniforms["ViewOrigin"]
        let viewSize: Vec2 = fsh.uniforms["ViewSize"]
        let radius: Scalar = fsh.uniforms.value(named: "Radius", scalarType: .float)
        let backgroundColor = fsh.channel(0).color
        
        let pos = fsh.input.position.xy - viewOrigin
        
        let topLeft: Scalar = fsh.uniforms.value(named: "TopLeft", scalarType: .bool)
        && (pos.x < radius && pos.y < radius)
        && (radius - pos.distance(from: Vec2(radius, radius)) < 0)
        
        let topRight: Scalar = fsh.uniforms.value(named: "TopRight", scalarType: .bool)
        && (pos.x > viewSize.width - radius && pos.y < radius)
        && (radius - pos.distance(from: Vec2(viewSize.width - radius, radius)) < 0)
        
        let bottomRight: Scalar = fsh.uniforms.value(named: "BottomRight", scalarType: .bool)
        && (pos.x > viewSize.width - radius && pos.y > viewSize.height - radius)
        && (radius - pos.distance(from: Vec2(viewSize.width - radius, viewSize.height - radius)) < 0)
        
        let bottomLeft: Scalar = fsh.uniforms.value(named: "BottomLeft", scalarType: .bool)
        && (pos.x < radius && pos.y > viewSize.height - radius)
        && (radius - pos.distance(from: Vec2(radius, viewSize.height - radius)) < 0)
        
        fsh.output.color = backgroundColor.discard(if: (radius > 0) && (topLeft || topRight || bottomRight || bottomLeft))
        
        return fsh
    }()
    static let fragmentShaderTextureSample: FragmentShader = {
        var fsh = FragmentShader()
        
        let viewOrigin: Vec2 = fsh.uniforms["ViewOrigin"]
        let viewSize: Vec2 = fsh.uniforms["ViewSize"]
        let radius: Scalar = fsh.uniforms.value(named: "Radius", scalarType: .float)
        let sample = fsh.channel(0).texture.sample(at: fsh.input["texCoord0"])
        #if DEBUG
        let backgroundColor = sample * fsh.channel(1).color
        #else
        let backgroundColor = sample
        #endif
        
        let pos = fsh.input.position.xy - viewOrigin
        
        let topLeft: Scalar = fsh.uniforms.value(named: "TopLeft", scalarType: .bool)
        && (pos.x < radius && pos.y < radius)
        && (radius - pos.distance(from: Vec2(radius, radius)) < 0)
        
        let topRight: Scalar = fsh.uniforms.value(named: "TopRight", scalarType: .bool)
        && (pos.x > viewSize.width - radius && pos.y < radius)
        && (radius - pos.distance(from: Vec2(viewSize.width - radius, radius)) < 0)
        
        let bottomRight: Scalar = fsh.uniforms.value(named: "BottomRight", scalarType: .bool)
        && (pos.x > viewSize.width - radius && pos.y > viewSize.height - radius)
        && (radius - pos.distance(from: Vec2(viewSize.width - radius, viewSize.height - radius)) < 0)
        
        let bottomLeft: Scalar = fsh.uniforms.value(named: "BottomLeft", scalarType: .bool)
        && (pos.x < radius && pos.y > viewSize.height - radius)
        && (radius - pos.distance(from: Vec2(radius, viewSize.height - radius)) < 0)
        
        fsh.output.color = Vec4(backgroundColor.rgb, backgroundColor.a * fsh.uniforms["opacity"]).discard(if: (radius > 0) && (topLeft || topRight || bottomRight || bottomLeft))
  
        return fsh
    }()
}
