/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

@MainActor
open class ViewController {
    public let title: String?
    private var _view: View! = nil {
        willSet {
            _view?._viewController = nil
        }
        didSet {
            _view._viewController = self
        }
    }
    
    public internal(set) final var isRootViewController: Bool = false
    
    public var game: Game {
        return Game.shared
    }
    
    public init(title: String? = nil) {
        self.title = title
    }
    
    open func loadView() {
        self.view = View()
    }
    
    open func viewDidLoad() {
        
    }
    
    //MARK: Layout
    open func preferredContentSize() -> Size2 {
        return .zero
    }
    
    open func viewWillUpdateLayoutConstraints() {
        
    }
    
    open func viewDidUpdateLayoutConstraints() {
        
    }
    
    internal final func _windowOrientationDidChange(to orientation: Window.Orientation) {
        self.windowOrientationDidChange(to: orientation)
        for child in children {
            child._windowOrientationDidChange(to: orientation)
        }
    }
    
    open func windowOrientationDidChange(to orientation: Window.Orientation) {
        
    }
    
    
    //MARK: ViewController Heirarchy
    public private(set) weak var parent: ViewController? = nil
    public private(set) var children: [ViewController] = []
    public func addChildViewController(_ viewController: ViewController) {
        assert(children.contains(where: {$0 === viewController}) == false, "\(viewController) is already a child.")
        self.children.append(viewController)
        viewController.parent = self
    }
    
    public func removeChildViewController(_ viewController: ViewController) {
        self.children.removeAll(where: {$0 === viewController})
        viewController.parent = nil
    }
    
    //MARK: Game Loop
    internal func _update(withTimePassed deltaTime: Float) async {
        self.update(withTimePassed: deltaTime)
        for child in children {
            await child._update(withTimePassed: deltaTime)
        }
    }
    
    open func update(withTimePassed deltaTime: Float) {
        
    }
}

//MARK: View Loading
extension ViewController {
    public final var view: View {
        get {
            self.loadViewIfNeeded()
            return _view
        }
        set {
            _view = newValue
            _view._viewController = self
        }
    }
    
    public final func loadViewIfNeeded() {
        if _view == nil {
            self.loadView()
            self.viewDidLoad()
        }
    }
}
