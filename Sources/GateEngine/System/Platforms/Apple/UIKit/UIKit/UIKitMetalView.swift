/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(UIKit) && !os(watchOS)
import UIKit
import MetalKit

@available(iOS 9, tvOS 9, *)
internal class MetalView: MTKView, MTKViewDelegate {
    unowned let viewController: UIKitViewController

    init(viewController: UIKitViewController, size: CGSize) {
        self.viewController = viewController
        super.init(
            frame: viewController.window.uiWindow.bounds,
            device: Game.shared.renderer.device
        )
        self.setup()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        self.delegate = self
        self.preferredFramesPerSecond = self.window?.screen.maximumFramesPerSecond ?? 60
        self.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        #if os(iOS)
        self.isMultipleTouchEnabled = true
        self.isExclusiveTouch = true
        #endif
        self.colorPixelFormat = .bgra8Unorm
        self.translatesAutoresizingMaskIntoConstraints = true
        self.autoResizeDrawable = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.drawableSize = CGSize(
            width: bounds.size.width * layer.contentsScale,
            height: bounds.size.height * layer.contentsScale
        )
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        var size = Size2(size)
        if size.isFinite == false {
            size = Size2(view.bounds.size) * Float(view.layer.rasterizationScale)
        }
        self.viewController.window.window?.newPixelSize = Size2(size)
    }

    func draw(in view: MTKView) {
        if let preferredDevice = view.preferredDevice,
            preferredDevice !== Game.shared.renderer.device
        {
            Game.shared.renderer.device = preferredDevice
        }
        viewController.window.window?.vSyncCalled()
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
