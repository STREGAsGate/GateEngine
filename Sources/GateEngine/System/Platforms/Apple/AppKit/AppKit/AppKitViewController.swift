/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(macOS)
import AppKit
import GameController

@available(macOS 10.11, *)
internal class AppKitViewController: GCEventViewController {
    weak var window: AppKitWindow?
    init(window: AppKitWindow) {
        self.window = window
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        let size = window!.frame.size.cgSize
        #if GATEENGINE_FORCE_OPNEGL_APPLE
        self.view = GLKitView(viewController: self, size: size)
        #else
        if MetalRenderer.isSupported {
            self.view = MetalView(viewController: self, size: size)
        }else{
            self.view = GLKitView(viewController: self, size: size)
        }
        #endif
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        self.window?.updateStoredMetaData()
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
