/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(macOS)

import Foundation
import GameController
import GameMath
import AppKit

@available(macOS 10.11, *)
internal class AppKitViewController: GCEventViewController {
    unowned let window: AppKitWindow
    init(window: AppKitWindow, size: Size2) {
        self.window = window
        super.init(nibName: nil, bundle: nil)
        #if GATEENGINE_FORCE_OPNEGL_APPLE
        self.view = GLKitView(viewController: self, size: CGSize(size))
        #else
        if MetalRenderer.isSupported {
            self.view = MetalView(viewController: self, size: CGSize(size))
        }else{
            self.view = GLKitView(viewController: self, size: CGSize(size))
        }
        #endif
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()

        //1:1 aspect max
        self.view.heightAnchor.constraint(lessThanOrEqualTo: self.view.widthAnchor, multiplier: 1/1).isActive = true
        //21:9 aspect min
        self.view.heightAnchor.constraint(greaterThanOrEqualTo: self.view.widthAnchor, multiplier: 9/21).isActive = true
        
        self.view.widthAnchor.constraint(greaterThanOrEqualToConstant: 256).isActive = true
        self.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 144).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
