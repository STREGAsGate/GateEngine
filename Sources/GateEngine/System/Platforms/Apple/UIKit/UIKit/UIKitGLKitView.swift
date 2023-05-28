/**
 * Copyright (c) 2022 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 * Licensed under Apache License v2.0
 * 
 * http://stregasgate.com
 */
#if canImport(UIKit) && canImport(GLKit) && !targetEnvironment(macCatalyst)

import Foundation
import GLKit

internal class GLKitView: GLKView {
    unowned let viewController: UIKitViewController
    static let shareGroup = EAGLSharegroup()

    init(viewController: UIKitViewController, size: CGSize) {
        self.viewController = viewController
        let context = EAGLContext(api: .openGLES3, sharegroup: Self.shareGroup)!
        super.init(frame: CGRect(origin: .zero, size: size), context: context)
            
        self.setup()
        
        #if os(iOS)
        self.isMultipleTouchEnabled = true
        self.isExclusiveTouch = true
        #endif
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        EAGLContext.setCurrent(context)
        self.bindDrawable()
        glFlush()
    }
    
    override func draw(_ rect: CGRect) {
        drawOpenUG()
    }
    
    func drawOpenUG() {        
        EAGLContext.setCurrent(context)
        self.bindDrawable()
        glFlush()
    }
}

#endif
