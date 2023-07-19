/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(macOS)
import QuartzCore
import MetalKit

@available(macOS 10.11, *)
internal class MetalView: MTKView, MTKViewDelegate {
    unowned let viewController: AppKitViewController

    init(viewController: AppKitViewController, size: CGSize) {
        self.viewController = viewController
        super.init(frame: CGRect(origin: .zero, size: size), device: Game.shared.renderer.device)
        self.delegate = self
        self.setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.colorPixelFormat = .bgra8Unorm
        if #available(macOS 10.12.2, *) {
            self.allowedTouchTypes = [.direct, .indirect]
        }else{
            self.acceptsTouchEvents = true
        }
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.viewController.window?.window?.newPixelSize = Size2(size)
    }

    func draw(in view: MTKView) {
        viewController.window?.window?.vSyncCalled()
    }

    override var isFlipped: Bool {
        true
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        for trackingArea in trackingAreas {
            self.removeTrackingArea(trackingArea)
        }

        let trackingArea = NSTrackingArea(rect: self.bounds,
                                          options: [.activeAlways,
                                                    .mouseEnteredAndExited,
                                                    .mouseMoved,
                                                    .cursorUpdate],
                                          owner: self,
                                          userInfo: nil)
        self.addTrackingArea(trackingArea)
    }
}
#endif
