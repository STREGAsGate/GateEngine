/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

@MainActor
public struct Layout {
    unowned let window: Window
    
    init(window: Window) {
        self.window = window
    }
    
    typealias Value = Constraints.LayoutResolutionRect.Value
    
    private func resolveX(for view: View) -> Value<Layout.Horizontal, Layout.Location>.Computed? {
        if let resolved = view.layoutConstraints.resolvedFrame.x.computed {
            return resolved
        }
        if view.layoutConstraints.resolvedFrame.x.currentlyBeingResolved {
            return nil
        }
        
        // Determine the local x offset between the view and the target coordinate spaces
        func relativeResolvedX(forTarget targetView: View) -> Float? {
            if view.superView === targetView {
                return 0
            }else if view.superView === targetView.superView {
                return resolveX(for: targetView)?.value
            }else{
                //TODO: The view is in another coordinate space
                fatalError("Layout cannot yet constrain views between coordinate spaces.")
            }
        }
        
        var computed: Value<Layout.Horizontal, Layout.Location>.Computed? = nil
        
        for hPosition in view.layoutConstraints.horizontalPositions {
            if let target = hPosition.target {
                if hPosition.source == view.leadingAnchor {
                    guard let targetX = relativeResolvedX(forTarget: target.view) else {continue}
                    if target == target.view.leadingAnchor {
                        computed = Value.Computed(
                            value: targetX + hPosition.constant
                        )
                        break
                    }
                    guard let targetWidth = resolveWidth(for: target.view) else {continue}
                    if target == target.view.centerXAnchor {
                        computed = Value.Computed(
                            value: targetX + (targetWidth.value / 2) + hPosition.constant
                        )
                        break
                    }
                    if target == target.view.trailingAnchor {
                        computed = Value.Computed(
                            value: targetX + targetWidth.value + hPosition.constant
                        )
                        break
                    }
                    fatalError("Layout is not able to handle an unknown horizontal position anchor. This is a bug.")
                }
                if hPosition.source == view.centerXAnchor {
                    guard let sourceWidth = resolveWidth(for: view) else {continue}
                    guard let targetX = relativeResolvedX(forTarget: target.view) else {continue}
                    if target == target.view.leadingAnchor {
                        computed = Value.Computed(
                            value: targetX + hPosition.constant
                        )
                        break
                    }
                    guard let targetWidth = resolveWidth(for: target.view) else {continue}
                    if target == target.view.centerXAnchor {
                        computed = Value.Computed(
                            value: targetX + (targetWidth.value / 2) - (sourceWidth.value / 2) + hPosition.constant
                        )
                        break
                    }
                    if target == target.view.trailingAnchor {
                        computed = Value.Computed(
                            value: (sourceWidth.value / 2) + targetX + targetWidth.value + hPosition.constant
                        )
                        break
                    }
                    fatalError("Layout is not able to handle an unknown horizontal position anchor. This is a bug.")
                }
                if hPosition.source == view.trailingAnchor {
                    guard let sourceWidth = resolveWidth(for: view) else {continue}
                    guard let targetX = relativeResolvedX(forTarget: target.view) else {continue}
                    if target == target.view.leadingAnchor {
                        computed = Value.Computed(
                            value: targetX + hPosition.constant
                        )
                        break
                    }
                    guard let targetWidth = resolveWidth(for: target.view) else {continue}
                    if target == target.view.centerXAnchor {
                        computed = Value.Computed(
                            value: targetX + (targetWidth.value / 2) - sourceWidth.value + hPosition.constant
                        )
                        break
                    }
                    if target == target.view.trailingAnchor {
                        computed = Value.Computed(
                            value: targetWidth.value + targetX - sourceWidth.value - hPosition.constant
                        )
                        break
                    }
                    fatalError("Layout is not able to handle an unknown horizontal position anchor. This is a bug.")
                }
            }else{
                computed = Value.Computed(value: hPosition.constant)
                break
            }
        }
        
        if let computed {
            view.layoutConstraints.resolvedFrame.x.computed = computed
        }
        return computed
    }
        
    private func resolveY(for view: View) -> Value<Layout.Vertical, Layout.Location>.Computed? {
        if let resolved = view.layoutConstraints.resolvedFrame.y.computed {
            return resolved
        }
        if view.layoutConstraints.resolvedFrame.y.currentlyBeingResolved {
            return nil
        }
        view.layoutConstraints.resolvedFrame.y.currentlyBeingResolved = true
        
        // Determine the local y offset between the view and the target coordinate spaces
        func relativeResolvedY(forTarget targetView: View) -> Float? {
            if view.superView === targetView {
                return 0
            }else if view.superView === targetView.superView {
                return resolveY(for: targetView)?.value
            }else{
                //TODO: The view is in another coordinate space
                fatalError("Layout cannot yet constrain views between coordinate spaces.")
            }
        }
        
        var computed: Value<Layout.Vertical, Layout.Location>.Computed? = nil
        
        for vPosition in view.layoutConstraints.verticalPositions {
            if let target = vPosition.target {
                if vPosition.source == view.topAnchor {
                    guard let targetY = relativeResolvedY(forTarget: target.view) else {continue}
                    if target == target.view.topAnchor {
                        computed = Value.Computed(
                            value: targetY + vPosition.constant
                        )
                        break
                    }
                    guard let targetHeight = resolveHeight(for: target.view) else {continue}
                    if target == target.view.centerYAnchor {
                        computed = Value.Computed(
                            value: targetY + (targetHeight.value / 2) + vPosition.constant
                        )
                        break
                    }
                    if target == target.view.bottomAnchor {
                        computed = Value.Computed(
                            value: targetY + targetHeight.value + vPosition.constant
                        )
                        break
                    }
                    fatalError("Layout is not able to handle an unknown horizontal position anchor. This is a bug.")
                }
                if vPosition.source == view.centerYAnchor {
                    guard let targetY = relativeResolvedY(forTarget: target.view) else {continue}
                    if target == target.view.topAnchor {
                        computed = Value.Computed(
                            value: targetY + vPosition.constant
                        )
                        break
                    }
                    guard let targetHeight = resolveHeight(for: target.view) else {continue}
                    guard let sourceHeight = resolveHeight(for: view) else {continue}
                    if target == target.view.centerYAnchor {
                        computed = Value.Computed(
                            value: targetY + (targetHeight.value / 2) - (sourceHeight.value / 2) + vPosition.constant
                        )
                        break
                    }
                    if target == target.view.bottomAnchor {
                        computed = Value.Computed(
                            value: (sourceHeight.value / 2) + targetY + targetHeight.value + vPosition.constant
                        )
                        break
                    }
                    fatalError("Layout is not able to handle an unknown horizontal position anchor. This is a bug.")
                }
                if vPosition.source == view.bottomAnchor {
                    guard let height = resolveHeight(for: view) else {continue}
                    guard let targetY = relativeResolvedY(forTarget: target.view) else {continue}
                    if target == target.view.topAnchor {
                        computed = Value.Computed(
                            value: targetY + vPosition.constant
                        )
                        break
                    }
                    guard let targetHeight = resolveHeight(for: target.view) else {continue}
                    if target == target.view.centerYAnchor {
                        computed = Value.Computed(
                            value: targetY + (targetHeight.value / 2) - height.value + vPosition.constant
                        )
                        break
                    }
                    if target == target.view.bottomAnchor {
                        computed = Value.Computed(
                            value: targetY + targetHeight.value - height.value - vPosition.constant
                        )
                        break
                    }
                    fatalError("Layout is not able to handle an unknown horizontal position anchor. This is a bug.")
                }
            }else{
                computed = Value.Computed(value: vPosition.constant)
                break
            }
        }
        
        view.layoutConstraints.resolvedFrame.y.currentlyBeingResolved = false
        if let computed {
            view.layoutConstraints.resolvedFrame.y.computed = computed
        }
        
        return computed
    }
    
    private func resolveWidth(for view: View) -> Value<Layout.Horizontal, Layout.Size>.Computed? {
        if let resolved = view.layoutConstraints.resolvedFrame.width.computed {
            return resolved
        }
        if view.layoutConstraints.resolvedFrame.width.currentlyBeingResolved {
            return nil
        }
        view.layoutConstraints.resolvedFrame.width.currentlyBeingResolved = true
        
        // Determine the local trailing offset between the view and the target coordinate spaces
        func relativeResolvedTrailing(forTarget targetView: View) -> Float? {
            if view.superView === targetView {// Target is the supreview
                if let targetWidth = resolveWidth(for: targetView) {
                    return targetWidth.value
                }
            }else if targetView.superView === view {// Target is a subview
                if let targetX = resolveX(for: targetView) {
                    if let targetWidth = resolveWidth(for: targetView) {
                        return targetX.value + targetWidth.value
                    }
                }
            }else if view.superView === targetView.superView {// Target is a sibling
                if let targetX = resolveX(for: targetView) {
                    if let targetWidth = resolveWidth(for: targetView) {
                        return targetX.value + targetWidth.value
                    }
                }
            }else{
                //TODO: The view is in another coordinate space
                fatalError("Layout cannot yet constrain views between coordinate spaces.")
            }
            return nil
        }
        
        // Determine the local trailing offset between the view and the target coordinate spaces
        func relativeResolvedLeading(forTarget targetView: View) -> Float? {
            if view.superView === targetView {// Target is the supreview
                if let targetWidth = resolveWidth(for: targetView) {
                    return targetWidth.value
                }
            }else if targetView.superView === view {// Target is a subview
                if let targetX = resolveX(for: targetView) {
                    return targetX.value
                }
            }else if view.superView === targetView.superView {// Target is a sibling
                if let targetX = resolveX(for: targetView) {
                    return targetX.value
                }
            }else{
                //TODO: The view is in another coordinate space
                fatalError("Layout cannot yet constrain views between coordinate spaces.")
            }
            return nil
        }
        
        var computed: Value<Layout.Horizontal, Layout.Size>.Computed? = nil
        
        for hSize in view.layoutConstraints.horizontalSizes {
            if let target = hSize.target {
                if hSize.source == view.widthAnchor {
                    guard let targetWidth = resolveWidth(for: target.view) else {continue}
                    if target == target.view.widthAnchor {
                        computed = Value.Computed(
                            value: targetWidth.value * hSize.multiplier + hSize.constant
                        )
                        break
                    }
                    fatalError("Layout is not able to handle an unknown horizontal position anchor. This is a bug.")
                }
            }else{
                computed = Value.Computed(value: hSize.constant)
                break
            }
        }
        
        if computed == nil {
            if let sourceX = resolveX(for: view) {
                if let trailing = view.layoutConstraints.horizontalPositions.first(where: {$0.source == view.trailingAnchor}) {
                    if let targetView = trailing.target?.view {
                        if trailing.target === targetView.trailingAnchor {
                            if let targetTrailing = relativeResolvedTrailing(forTarget: targetView) {
                                computed = Value.Computed(value: targetTrailing - sourceX.value + trailing.constant)
                            }
                        }else if trailing.target === targetView.leadingAnchor {
                            if let targetLeading = relativeResolvedLeading(forTarget: targetView) {
                                computed = Value.Computed(value: targetLeading - sourceX.value + trailing.constant)
                            }
                        }
                    }
                }
            }
        }
        if computed == nil {
            // Subview must determine width
            var farthestSubviewTrailing: Float? = nil
            for subview in view.subviews {
                if let subviewMaxX = relativeResolvedTrailing(forTarget: subview) {
                    if let _farthestSubviewTrailing = farthestSubviewTrailing {
                        if subviewMaxX > _farthestSubviewTrailing {
                            farthestSubviewTrailing = subviewMaxX
                        }
                    }else{
                        farthestSubviewTrailing = subviewMaxX
                    }
                }
            }
            
            if let farthestSubviewTrailing {
                computed = Value.Computed(value: farthestSubviewTrailing)
            }
        }
        
        view.layoutConstraints.resolvedFrame.width.currentlyBeingResolved = false
        if let computed {
            view.layoutConstraints.resolvedFrame.width.computed = computed
        }
        
        return computed
    }
    
    private func resolveHeight(for view: View) -> Value<Layout.Vertical, Layout.Size>.Computed? {
        if let resolved = view.layoutConstraints.resolvedFrame.height.computed {
            return resolved
        }
        if view.layoutConstraints.resolvedFrame.height.currentlyBeingResolved {
            return nil
        }
        view.layoutConstraints.resolvedFrame.height.currentlyBeingResolved = true
        
        // Determine the local bottom offset between the view and the target coordinate spaces
        func relativeResolvedBottom(forTarget targetView: View) -> Float? {
            if view.superView === targetView {// Target is the supreview
                if let targetHeight = resolveHeight(for: targetView) {
                    return targetHeight.value
                }
            }else if targetView.superView === view {// Target is a subview
                if let targetY = resolveY(for: targetView) {
                    if let targetHeight = resolveHeight(for: targetView) {
                        return targetY.value + targetHeight.value
                    }
                }
            }else if view.superView === targetView.superView {// Target is a sibling
                if let targetY = resolveY(for: targetView) {
                    if let targetHeight = resolveHeight(for: targetView) {
                        return targetY.value + targetHeight.value
                    }
                }
            }else{
                //TODO: The view is in another coordinate space
                fatalError("Layout cannot yet constrain views between coordinate spaces.")
            }
            return nil
        }
        
        var computed: Value<Layout.Vertical, Layout.Size>.Computed? = nil
        
        for vSize in view.layoutConstraints.verticalSizes {
            if let target = vSize.target {
                if vSize.source == view.heightAnchor {
                    guard let targetHeight = resolveHeight(for: target.view) else {continue}
                    if target == target.view.heightAnchor {
                        computed = Value.Computed(
                            value: targetHeight.value * vSize.multiplier + vSize.constant
                        )
                        break
                    }
                    fatalError("Layout is not able to handle an unknown horizontal position anchor. This is a bug.")
                }
            }else{
                computed = Value.Computed(value: vSize.constant)
                break
            }
        }
        
        if computed == nil {
            if let sourceY = resolveY(for: view) {
                if let bottom = view.layoutConstraints.verticalPositions.first(where: {$0.source == view.bottomAnchor}) {
                    if let targetView = bottom.target?.view {
                        if bottom.target === targetView.bottomAnchor {
                            if let targetBottom = relativeResolvedBottom(forTarget: targetView) {
                                computed = Value.Computed(value: targetBottom - sourceY.value + bottom.constant)
                            }
                        }
                    }
                }
            }
        }
        if computed == nil {
            // Subview must determine height
            var lowestSubviewBottom: Float? = nil
            for subview in view.subviews {
                if let subviewMaxY = relativeResolvedBottom(forTarget: subview) {
                    if let _lowestSubviewBottom = lowestSubviewBottom {
                        if subviewMaxY > _lowestSubviewBottom {
                            lowestSubviewBottom = subviewMaxY
                        }
                    }else{
                        lowestSubviewBottom = subviewMaxY
                    }
                }
            }
            
            if let lowestSubviewBottom {
                computed = Value.Computed(value: lowestSubviewBottom)
            }
        }
        
        view.layoutConstraints.resolvedFrame.height.currentlyBeingResolved = false
        if let computed {
            view.layoutConstraints.resolvedFrame.height.computed = computed
        }
        
        return computed
    }
    
    internal func process() {
        let windowPointSize = window.windowBacking.pointSize
        if window.frame.size != windowPointSize {
            window.frame.size = windowPointSize
            window.setNeedsLayout()
        }
        guard window.needsLayout || window.needsUpdateConstraints else {return}
        
        let layoutStart = Game.shared.platform.systemTime()
        
        // Reset all view layout resolutions
        func prepareToLayout(_ view: View) {
            guard view.needsLayout else {return}
            view.willLayout()
            view.layoutConstraints.sortIfNeeded()
            view.layoutConstraints.resolvedFrame = Layout.Constraints.LayoutResolutionRect()
            if view.needsUpdateConstraints {
                view._updateLayoutConstraints()
            }
            for subview in view.subviews {
                prepareToLayout(subview)
            }
        }
        prepareToLayout(window)
        
        // Update the window so it's anchors are resolved with the correct values
        self.window.layoutConstraints.resolvedFrame.x.computed = Value.Computed(
            value: window.bounds.x
        )
        self.window.layoutConstraints.resolvedFrame.y.computed = Value.Computed(
            value: window.bounds.y
        )
        self.window.layoutConstraints.resolvedFrame.width.computed = Value.Computed(
            value: window.bounds.width
        )
        self.window.layoutConstraints.resolvedFrame.height.computed = Value.Computed(
            value: window.bounds.height
        )
                    
        enum FailedResolutions {
            case horizontalPosition
            case verticalPosition
            case horizontalSize
            case verticalSize
        }
        @inline(__always)
        func resolve(_ view: View) -> (failure: FailedResolutions, view: View)? {
            for subview in view.subviews {
                if let failed = resolve(subview) {
                    return failed
                }
            }
            
            guard let _ = resolveX(for: view) else { return (.horizontalPosition, view) }
            guard let _ = resolveY(for: view) else { return (.verticalPosition, view) }
            guard let _ = resolveWidth(for: view) else { return (.horizontalSize, view) }
            guard let _ = resolveHeight(for: view) else { return (.verticalSize, view) }
            
            return nil
        }
        
        var iteration = 1
        var lastLayoutError: (failure: FailedResolutions, view: View)? = nil
        while let failed = resolve(window) {
            if iteration == 1000 {
                lastLayoutError = failed
                break
            }
            iteration += 1
        }
        if let lastLayoutError {
            func genericError() {
                Log.errorOnce("Layout failed after \(iteration) iterations.\n\t\(type(of: lastLayoutError.view))(\(Unmanaged.passUnretained(lastLayoutError.view).toOpaque())) failed to resolve \(lastLayoutError.failure).")
            }
            #if GATEENGINE_DEBUG_LAYOUT
            switch lastLayoutError.failure {
            case .horizontalPosition:
                if lastLayoutError.view.layoutConstraints.horizontalPositions.isEmpty {
                    Log.errorOnce("Layout failed after \(iteration) iterations.\n\t\(type(of: lastLayoutError.view))(\(Unmanaged.passUnretained(lastLayoutError.view).toOpaque())) has 0 horizontal position constraints.")
                }else{
                    genericError()
                }
            case .verticalPosition:
                if lastLayoutError.view.layoutConstraints.verticalPositions.isEmpty {
                    Log.errorOnce("Layout failed after \(iteration) iterations.\n\t\(type(of: lastLayoutError.view))(\(Unmanaged.passUnretained(lastLayoutError.view).toOpaque())) has 0 vertical position constraints.")
                }else{
                    genericError()
                }
            case .horizontalSize:
                if lastLayoutError.view.layoutConstraints.horizontalSizes.isEmpty {
                    Log.errorOnce("Layout failed after \(iteration) iterations.\n\t\(type(of: lastLayoutError.view))(\(Unmanaged.passUnretained(lastLayoutError.view).toOpaque())) has 0 horizontal size constraints.")
                }else{
                    genericError()
                }
            case .verticalSize:
                if lastLayoutError.view.layoutConstraints.verticalSizes.isEmpty {
                    Log.errorOnce("Layout failed after \(iteration) iterations.\n\t\(type(of: lastLayoutError.view))(\(Unmanaged.passUnretained(lastLayoutError.view).toOpaque())) has 0 vertical size constraints.")
                }else{
                    genericError()
                }
            }
            #else
            genericError()
            #endif
        }
        
        #if GATEENGINE_DEBUG_LAYOUT
        var viewsLayedOut: Int = 0
        var hadError: Bool = false
        #endif
        @inline(__always)
        func finishLayout(for view: View) {
            guard view.needsLayout else {return}
            
            do {
                view.frame = try view.layoutConstraints.resolvedFrame.getResolvedFrame(for: view)
            }catch{
                #if GATEENGINE_DEBUG_LAYOUT
                hadError = true
                #endif
                Log.errorOnce("\(error)")
            }
            
            for subview in view.subviews {
                finishLayout(for: subview)
            }
            
            view.needsLayout = false
            view.didLayout()
            
            #if GATEENGINE_DEBUG_LAYOUT
            viewsLayedOut += 1
            #endif
        }
        finishLayout(for: window)
        
        #if GATEENGINE_DEBUG_LAYOUT
        if hadError == false {
            let layoutEnd = Game.shared.platform.systemTime()
            let duration = String(format: "%.3fms", (layoutEnd - layoutStart) * 1000)
            Log.debug("Layout updated \(viewsLayedOut) views in \(duration) using \(iteration) iterations.")
        }
        #endif
    }
}

public protocol LayoutDimension {}
public protocol LayoutAttribute {}
extension Layout {
    public struct Vertical: LayoutDimension {}
    public struct Horizontal: LayoutDimension {}
    
    public struct Location: LayoutAttribute {}
    public struct Size: LayoutAttribute {}
}

extension Layout {
    public struct Guide {
        public let topAnchor: Layout.Anchor<Layout.Vertical, Layout.Location>
        public let leadingAnchor: Layout.Anchor<Layout.Horizontal, Layout.Location>
        public let bottomAnchor: Layout.Anchor<Layout.Vertical, Layout.Location>
        public let trailingAnchor: Layout.Anchor<Layout.Horizontal, Layout.Location>
        
        internal init(view: View) {
            self.topAnchor = Layout.Anchor<Layout.Vertical, Layout.Location>(view: view)
            self.leadingAnchor = Layout.Anchor<Layout.Horizontal, Layout.Location>(view: view)
            self.bottomAnchor = Layout.Anchor<Layout.Vertical, Layout.Location>(view: view)
            self.trailingAnchor = Layout.Anchor<Layout.Horizontal, Layout.Location>(view: view)
        }
    }
    
    public enum Priority: Comparable {
        case required
        case high
        case `default`
        case low
        case trivial
    }
    
    public final class Anchor<D: LayoutDimension, A: LayoutAttribute>: Equatable {
        @usableFromInline
        internal unowned var view: View
        internal init(view: View) {
            self.view = view
        }
        
        public static func == (lhs: Layout.Anchor<D, A>, rhs: Layout.Anchor<D, A>) -> Bool {
            return lhs === rhs
        }
    }
    public struct Constraint<D: LayoutDimension, A: LayoutAttribute>: Equatable {
        public internal(set) var source: Layout.Anchor<D,A>
        public internal(set) var target: Layout.Anchor<D,A>?
        
        public var multiplier: Float
        public var constant: Float
        public var priority: Priority
        
        @usableFromInline
        internal init(source: Layout.Anchor<D,A>, target: Layout.Anchor<D,A>?, constant: Float, multiplier: Float, priority: Priority) {
            self.source = source
            self.target = target
            self.multiplier = multiplier
            self.constant = constant
            self.priority = priority
        }
        
        public static func ==(lhs: Layout.Constraint<D,A>, rhs: Layout.Constraint<D,A>) -> Bool {
            return lhs.source === rhs.source && lhs.target === rhs.target && lhs.constant == rhs.constant && lhs.multiplier == rhs.multiplier
        }
    }
    
    public struct Constraints {
        @usableFromInline
        internal var horizontalPositions: [Constraint<Layout.Horizontal, Layout.Location>] = [] {
            didSet {
                needsSorting = true
                _allTargets = nil
            }
        }
        @usableFromInline
        internal var verticalPositions: [Constraint<Layout.Vertical, Layout.Location>] = [] {
            didSet {
                needsSorting = true
                _allTargets = nil
            }
        }
        @usableFromInline
        internal var horizontalSizes: [Constraint<Layout.Horizontal, Layout.Size>] = [] {
            didSet {
                needsSorting = true
                _allTargets = nil
            }
        }
        @usableFromInline
        internal var verticalSizes: [Constraint<Layout.Vertical, Layout.Size>] = [] {
            didSet {
                needsSorting = true
                _allTargets = nil
            }
        }
        
        private var _allTargets: [View]? = nil
        var allTargets: [View] {
            mutating get {
                if let _allTargets {
                    return _allTargets
                }
                
                var views: [View] = []
                for constraint in horizontalPositions {
                    if let target = constraint.target?.view {
                        views.append(target)
                    }
                }
                for constraint in verticalPositions {
                    if let target = constraint.target?.view {
                        views.append(target)
                    }
                }
                for constraint in horizontalSizes {
                    if let target = constraint.target?.view {
                        views.append(target)
                    }
                }
                for constraint in verticalSizes {
                    if let target = constraint.target?.view {
                        views.append(target)
                    }
                }
                _allTargets = views
                return views
            }
        }
        
        public mutating func removeAllConstraints() {
            horizontalPositions.removeAll(keepingCapacity: true)
            verticalPositions.removeAll(keepingCapacity: true)
            horizontalSizes.removeAll(keepingCapacity: true)
            verticalSizes.removeAll(keepingCapacity: true)
        }
        
        public mutating func removeAllHorizontalPositionConstraints() {
            horizontalPositions.removeAll(keepingCapacity: true)
        }
        
        public mutating func removeAllVerticalPositionConstraints() {
            verticalPositions.removeAll(keepingCapacity: true)
        }
        
        public mutating func removeAllHorizontalSizeConstraints() {
            horizontalSizes.removeAll(keepingCapacity: true)
        }
        
        public mutating func removeAllVerticalSizeConstraints() {
            verticalSizes.removeAll(keepingCapacity: true)
        }
        
        private var needsSorting: Bool = false
        internal mutating func sortIfNeeded() {
            guard self.needsSorting else {return}
            
            self.horizontalPositions.sort { constraint1, constraint2 in
                return constraint1.priority > constraint2.priority
            }
            self.verticalPositions.sort { constraint1, constraint2 in
                return constraint1.priority > constraint2.priority
            }
            self.horizontalSizes.sort { constraint1, constraint2 in
                return constraint1.priority > constraint2.priority
            }
            self.verticalSizes.sort { constraint1, constraint2 in
                return constraint1.priority > constraint2.priority
            }
            
            self.needsSorting = false
        }
        
        // This frame is used to determine which parts of the frame have final resolved 
        // values during the layout process. -1 represents unresolved.
        internal var resolvedFrame: LayoutResolutionRect = LayoutResolutionRect()

        internal struct LayoutResolutionRect {
            struct Value<D: LayoutDimension, A: LayoutAttribute> {
                struct Computed {
                    var value: Float
                }
                var computed: Computed? = nil
                
                // A value to prevent recursion explosions
                var currentlyBeingResolved: Bool = false
            }
            var x: Value<Layout.Horizontal, Layout.Location> = Value()
            var y: Value<Layout.Vertical, Layout.Location> = Value()
            var width: Value<Layout.Horizontal, Layout.Size> = Value()
            var height: Value<Layout.Vertical, Layout.Size> = Value()
            
            @MainActor
            func getResolvedFrame(for view: View) throws -> Rect {
                guard let x = self.x.computed?.value else {
                    throw GateEngineError.layoutFailed("\(type(of: view))(\(Unmanaged.passUnretained(view).toOpaque())) failed to find horizontal position.") 
                }
                guard let y = self.y.computed?.value else {
                    throw GateEngineError.layoutFailed("\(type(of: view))(\(Unmanaged.passUnretained(view).toOpaque())) failed to find vertical position.")
                }
                guard let width = self.width.computed?.value else {
                    throw GateEngineError.layoutFailed("\(type(of: view))(\(Unmanaged.passUnretained(view).toOpaque())) failed to find horizontal size.")
                }
                guard let height = self.height.computed?.value else {
                    throw GateEngineError.layoutFailed("\(type(of: view))(\(Unmanaged.passUnretained(view).toOpaque())) failed to find vertical size.")
                }
                
                // Allow fractions but make sure we always land on a pixel
                let minimumRepresentable: Float = 1 / view.interfaceScale

                return Rect(
                    x: x - x.truncatingRemainder(dividingBy: minimumRepresentable),
                    y: y - y.truncatingRemainder(dividingBy: minimumRepresentable), 
                    width: width - width.truncatingRemainder(dividingBy: minimumRepresentable),
                    height: height - height.truncatingRemainder(dividingBy: minimumRepresentable)
                )
            }
        }
        
        internal init() {
            
        }
    }
}

@MainActor
extension Layout.Anchor where D == Layout.Horizontal, A == Layout.Location {
    @_transparent
    public func constrain(to target: Layout.Anchor<Layout.Horizontal, Layout.Location>, priority: Layout.Priority = .default) {
        self.constrain(0, from: target, priority: priority)
    }
    @_transparent
    public func constrain(_ constant: Float, from target: Layout.Anchor<Layout.Horizontal, Layout.Location>, priority: Layout.Priority = .default) {
        self.view.layoutConstraints.horizontalPositions.append(
            Layout.Constraint(source: self, target: target, constant: constant, multiplier: 1, priority: priority)
        )
    }
}

@MainActor
extension Layout.Anchor where D == Layout.Vertical, A == Layout.Location {
    @_transparent
    public func constrain(to target: Layout.Anchor<Layout.Vertical, Layout.Location>, priority: Layout.Priority = .default) {
        self.constrain(0, from: target, priority: priority)
    }
    @_transparent
    public func constrain(_ constant: Float, from target: Layout.Anchor<Layout.Vertical, Layout.Location>, priority: Layout.Priority = .default) {
        self.view.layoutConstraints.verticalPositions.append(
            Layout.Constraint(source: self, target: target, constant: constant, multiplier: 1, priority: priority)
        )
    }
}

@MainActor
extension Layout.Anchor where D == Layout.Horizontal, A == Layout.Size {
    @_transparent
    public func constrain(to target: Layout.Anchor<Layout.Horizontal, Layout.Size>, multiplier: Float = 1, adding constant: Float = 0, priority: Layout.Priority = .default) {
        self.view.layoutConstraints.horizontalSizes.append(
            Layout.Constraint(source: self, target: target, constant: constant, multiplier: multiplier, priority: priority)
        )
    }
    @_transparent
    public func constrain(to constant: Float, priority: Layout.Priority = .default) {
        self.view.layoutConstraints.horizontalSizes.append(
            Layout.Constraint(source: self, target: nil, constant: constant, multiplier: 1, priority: priority)
        )
    }
}

@MainActor
extension Layout.Anchor where D == Layout.Vertical, A == Layout.Size {
    @_transparent
    public func constrain(to target: Layout.Anchor<Layout.Vertical, Layout.Size>, multiplier: Float = 1, adding constant: Float = 0, priority: Layout.Priority = .default) {
        self.view.layoutConstraints.verticalSizes.append(
            Layout.Constraint(source: self, target: target, constant: constant, multiplier: multiplier, priority: priority)
        )
    }
    @_transparent
    public func constrain(to constant: Float, priority: Layout.Priority = .default) {
        self.view.layoutConstraints.verticalSizes.append(
            Layout.Constraint(source: self, target: nil, constant: constant, multiplier: 1, priority: priority)
        )
    }
}
