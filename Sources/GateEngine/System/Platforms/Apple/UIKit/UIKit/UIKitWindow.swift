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

final class UIKitWindow: WindowBacking {
    weak var window: Window!
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
        self.uiWindow.translatesAutoresizingMaskIntoConstraints = true
    }
    
    lazy private(set) var displayLink: CADisplayLink = {
        if let displayLink = self.uiWindow.screen.displayLink(withTarget: self, selector: #selector(self.getFrame(_ :))) {
            displayLink.add(to: .main, forMode: .default)
            return displayLink
        }
        // Fallback
        let displayLink = CADisplayLink(target: self, selector: #selector(self.getFrame(_ :)))
        displayLink.add(to: .main, forMode: .default)
        if #available(iOS 15.0, tvOS 15.0, *) {
            displayLink.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: Float(self.uiWindow.screen.maximumFramesPerSecond))
        }else{
            displayLink.preferredFramesPerSecond = self.uiWindow.screen.maximumFramesPerSecond
        }
        return displayLink
    }()

    @objc func getFrame(_ displayLink: CADisplayLink) {
        self.uiWindow.rootViewController?.view.setNeedsDisplay()
    }
    
    func show() {
        if Game.shared.renderingAPI == .openGL {
            _ = displayLink
        }
        uiWindow.makeKeyAndVisible()
        self.state = .shown
    }
    
    func close() {
        assertionFailure("UIKit windows can't be closed.")
    }

    @MainActor func createWindowRenderTargetBackend() -> RenderTargetBackend {
        #if GATEENGINE_FORCE_OPNEGL_APPLE
            return OpenGLRenderTarget(windowBacking: windowBacking)
        #else
        #if canImport(GLKit) && !targetEnvironment(macCatalyst)
        if MetalRenderer.isSupported == false {
            return OpenGLRenderTarget(windowBacking: windowBacking)
        }
        #endif
        return MetalRenderTarget(windowBacking: windowBacking)
        #endif
    }
    
    deinit {
        if Game.shared.renderingAPI == .openGL {
            displayLink.invalidate()
        }
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
            uiWindow.frame = newValue.cgRect
        }
    }
    var safeAreaInsets: Insets {
        if #available(iOS 11, tvOS 11, macCatalyst 13, *) {
            let insets = uiWindow.safeAreaInsets
            return Insets(top: Float(insets.top), leading: Float(insets.left), bottom: Float(insets.bottom), trailing: Float(insets.right))
        }
        return .zero
    }
    
    @inline(__always)
    var backingSize: Size2 {
        return frame.size * backingScaleFactor
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
