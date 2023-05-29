/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(UIKit) && !os(watchOS)

import Foundation
import UIKit
import MetalKit
import GameMath

class UIKitWindow: WindowBacking {
    unowned let window: Window
    let uiWindow: UIWindow
    let identifier: String
    let style: WindowStyle
    var state: Window.State = .hidden
    
    required init(identifier: String, style: WindowStyle, window: Window) {
        self.window = window
        self.uiWindow = UIWindow()
        self.identifier = identifier
        self.style = style
        
        self.uiWindow.rootViewController = UIKitViewController(window: self)
    }
    
    lazy private(set) var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(getFrame(_ :)))
        displayLink.add(to: .main, forMode: .default)
        return displayLink
    }()
    
    @objc func getFrame(_ displayLink: CADisplayLink) {
        self.uiWindow.rootViewController!.view.setNeedsDisplay()
    }
    
    func show() {
        _ = displayLink
        uiWindow.makeKeyAndVisible()
        self.state = .shown
    }
    
    func close() {
        assertionFailure("UIKit windows can't be closed.")
    }
    
    deinit {
        displayLink.invalidate()
    }
}

extension UIKitWindow {
    var title: String? {
        get {
            if let title = uiWindow.rootViewController?.title, title.isEmpty == false {
                return title
            }
            return nil
        }
        set {
            uiWindow.rootViewController?.title = newValue
        }
    }
    var frame: Rect {
        get {
            return Rect(uiWindow.frame)
        }
        set {
            // Can't set a UIKit window frame
        }
    }
    var safeAreaInsets: Insets {
        get {
            if #available(iOS 11, tvOS 11, *) {
                let insets = uiWindow.safeAreaInsets
                return Insets(top: Float(insets.top), leading: Float(insets.left), bottom: Float(insets.bottom), trailing: Float(insets.right))
            }
            return .zero
        }
    }
    
    @inline(__always)
    var backingSize: Size2 {
        return frame.size * Float(uiWindow.traitCollection.displayScale)
    }
    
    @inline(__always)
    var backingScaleFactor: Float {
        return Float(uiWindow.traitCollection.displayScale)
    }
    
    func setMouseHidden(_ hidden: Bool) {
        // TODO: implement
    }
    
    func setMousePosition(_ position: Position2) {
        // TODO: implement
    }
}
#endif
