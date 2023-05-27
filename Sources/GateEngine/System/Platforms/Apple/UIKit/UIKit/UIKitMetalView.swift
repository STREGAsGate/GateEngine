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

@available(iOS 9, tvOS 9, *)
internal class MetalView: MTKView, MTKViewDelegate {
    unowned let viewController: UIKitViewController
    
    init(viewController: UIKitViewController, size: CGSize) {
        self.viewController = viewController
        super.init(frame: CGRect(origin: .zero, size: size), device: Game.shared.renderer.device)
        self.delegate = self
        
        #if os(iOS)
        self.isMultipleTouchEnabled = true
        self.isExclusiveTouch = true
        #endif

        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }

    func draw(in view: MTKView) {
        viewController.window.window.vSyncCalled()
    }

    override func updateConstraints() {
        super.updateConstraints()

        self.topAnchor.constraint(equalTo: self.window!.topAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: self.window!.leadingAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.window!.bottomAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.window!.trailingAnchor).isActive = true
    }
}
#endif
