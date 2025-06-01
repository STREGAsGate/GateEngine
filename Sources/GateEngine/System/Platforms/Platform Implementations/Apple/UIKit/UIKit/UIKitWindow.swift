/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(UIKit) && !os(watchOS)
import UIKit
import MetalKit

final class UIKitWindow: WindowBacking {
    weak var window: Window!
    let uiWindow: UIWindow
    var state: Window.State = .hidden
    var userActivity: NSUserActivity? {
        return uiWindow.windowScene?.userActivity
    }

    // Stoted Metadata
    var pointSafeAreaInsets: Insets = .zero
    var pixelSafeAreaInsets: Insets = .zero
    var pointSize: Size2 = Size2(640, 480)
    var pixelSize: Size2 = Size2(640, 480)
    var interfaceScaleFactor: Float = 1

    // Called from UIKitViewController
    func updateStoredMetaData() {
        self.interfaceScaleFactor = Float(uiWindow.traitCollection.displayScale)
        if let view = uiWindow.rootViewController!.view {
            self.pointSize = Size2(view.bounds.size)
            self.pixelSize = self.pointSize * self.interfaceScaleFactor
            if #available(iOS 11, tvOS 11, macCatalyst 13, *) {
                self.pointSafeAreaInsets = Insets(
                    top: Float(view.safeAreaInsets.top),
                    leading: Float(view.safeAreaInsets.left),
                    bottom: Float(view.safeAreaInsets.bottom),
                    trailing: Float(view.safeAreaInsets.right)
                )
                self.pixelSafeAreaInsets = self.pointSafeAreaInsets * self.interfaceScaleFactor
            }
        }
    }

    @MainActor required init(window: Window) {
        self.window = window
        self.uiWindow = UIWindow()
        self.uiWindow.rootViewController = UIKitViewController(window: self)
        self.uiWindow.translatesAutoresizingMaskIntoConstraints = true

        if Platform.current.applicationRequestedWindow == false && window.isMainWindow == false {
            Game.unsafeShared.unsafePlatform.windowPreparingForSceneConnection = self

            func existingSession(forWindow window: Window) -> UISceneSession? {
                for session in UIApplication.shared.openSessions {
                    let sceneID = session.persistentIdentifier
                    guard let windowID = UserDefaults.standard.string(forKey: sceneID) else {
                        continue
                    }
                    if windowID == window.identifier {
                        return session
                    }
                }
                return nil
            }

            let userActivity = NSUserActivity(activityType: "GateEngineWindow")
            userActivity.userInfo = ["WindowIdentifier": window.identifier]
            UserDefaults.standard.set("Untitled", forKey: "Windows/\(window.identifier)/title")
            UIApplication.shared.requestSceneSessionActivation(
                existingSession(forWindow: window),
                userActivity: userActivity,
                options: nil
            )
        }
        Game.unsafeShared.unsafePlatform.applicationRequestedWindow = false
    }

    @MainActor func show() {
        uiWindow.makeKeyAndVisible()
        self.state = .shown
    }

    func close() {

    }

    @MainActor func createWindowRenderTargetBackend() -> any RenderTargetBackend {
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

    var title: String? {
        get {
            if let title = uiWindow.rootViewController?.title, title.isEmpty == false {
                return title
            }
            return nil
        }
        set {
            self.uiWindow.rootViewController?.title = newValue
            self.uiWindow.windowScene?.title = newValue
            UserDefaults.standard.set(newValue, forKey: "Windows/\(window.identifier)/title")
            UserDefaults.standard.synchronize()
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
