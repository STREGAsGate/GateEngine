/**
 * Copyright (c) 2022 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 * Licensed under Apache License v2.0
 *
 * http://stregasgate.com
 */
#if canImport(UIKit) && canImport(GLKit) && !targetEnvironment(macCatalyst)
import GLKit

class VK: GLKViewController {

}

internal class GLKitView: GLKView {
    unowned let viewController: UIKitViewController
    static let shareGroup = EAGLSharegroup()

    init(viewController: UIKitViewController, size: CGSize) {
        self.viewController = viewController
        let context = EAGLContext(api: .openGLES3, sharegroup: Self.shareGroup)!
        super.init(frame: CGRect(origin: .zero, size: size), context: context)
        self.setup()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        #if os(iOS)
        self.isMultipleTouchEnabled = true
        self.isExclusiveTouch = true
        #endif
        EAGLContext.setCurrent(context)
        self.bindDrawable()
        glFlush()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.viewController.window.window.newPixelSize = Size2(
            Float(self.drawableWidth),
            Float(self.drawableHeight)
        )
    }

    override func draw(_ rect: CGRect) {
        self.bindDrawable()
        viewController.window.window?.vSyncCalled()
        glFlush()
    }
}

#endif
