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
    
    // Stoted Metadata
    var pixelSafeAreaInsets: Insets = .zero
    var pixelSize: Size2 = .zero
    var interfaceScaleFactor: Float = 1
    
    // Called from UIKitViewController
    func updateStoredMetaData() {
        self.interfaceScaleFactor = Float(uiWindow.traitCollection.displayScale)
        if let view = uiWindow.rootViewController?.view {
            self.pixelSize = Size2(view.bounds.size) * self.interfaceScaleFactor
            if #available(iOS 11, tvOS 11, macCatalyst 13, *) {
                self.pixelSafeAreaInsets = Insets(top: Float(view.safeAreaInsets.top) * self.interfaceScaleFactor,
                                                  leading: Float(view.safeAreaInsets.left) * self.interfaceScaleFactor,
                                                  bottom: Float(view.safeAreaInsets.bottom) * self.interfaceScaleFactor,
                                                  trailing: Float(view.safeAreaInsets.right) * self.interfaceScaleFactor)
            }
        }
    }
    
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
            return OpenGLRenderTarget(windowBacking: self)
        #else
        #if canImport(GLKit) && !targetEnvironment(macCatalyst)
        if MetalRenderer.isSupported == false {
            return OpenGLRenderTarget(windowBacking: self)
        }
        #endif
        return MetalRenderTarget(windowBacking: self)
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
    
    func setMouseHidden(_ hidden: Bool) {
        // TODO: implement
    }
    
    func setMousePosition(_ position: Position2) {
        // TODO: implement
    }
}
#endif
