/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(UIKit) && !os(watchOS)

import Foundation
import GameController
import GameMath

internal class UIKitViewController: GCEventViewController {
    unowned let window: UIKitWindow
    init(window: UIKitWindow) {
        self.window = window
        super.init(nibName: nil, bundle: nil)

        self.view = UIKitMetalView(viewController: self, size: CGSize(width: 2, height: 2))
    }
    
    #if os(iOS)
    override var prefersHomeIndicatorAutoHidden: Bool {
        switch window.style {
        case .system:
            return false
        case .bestForGames:
            return true
        }
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        switch window.style {
        case .system:
            return []
        case .bestForGames:
            return .all
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
            self.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        }
    }
    #endif
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var touchesIDs: [ObjectIdentifier:UUID] = [:]
    private func type(for touch: UITouch) -> TouchKind {
        switch touch.type {
        case .direct:
            return .physical
        case .pencil, .stylus:
            return .stylus
        case .indirect, .indirectPointer:
            return .indirect
        @unknown default:
            return .unknown
        }
    }
    func locationOfTouch(_ touch: UITouch, from event: UIEvent?) -> Position2 {
        switch type(for: touch) {
        case .physical:
            let p = touch.location(in: nil)
            return Position2(Float(p.x), Float(p.y))
        case .indirect:
            let p = touch.location(in: nil)
            return Position2(Float(p.x), Float(p.y))
        default:
            fatalError()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        for touch in touches {
            let id = UUID()
            touchesIDs[ObjectIdentifier(touch)] = id
            let type = type(for: touch)
            let position = locationOfTouch(touch, from: event)
            window.window.delegate?.touchChange(id: id, kind: type, event: .began, position: position)
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        for touch in touches {
            let id = touchesIDs[ObjectIdentifier(touch)]!
            let type = type(for: touch)
            let position = locationOfTouch(touch, from: event)
            window.window.delegate?.touchChange(id: id, kind: type, event: .moved, position: position)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        for touch in touches {
            let id = touchesIDs[ObjectIdentifier(touch)]!
            let type = type(for: touch)
            let position = locationOfTouch(touch, from: event)
            window.window.delegate?.touchChange(id: id, kind: type, event: .ended, position: position)
            touchesIDs[ObjectIdentifier(touch)] = nil
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        for touch in touches {
            let id = touchesIDs[ObjectIdentifier(touch)]!
            let type = type(for: touch)
            let position = locationOfTouch(touch, from: event)
            window.window.delegate?.touchChange(id: id, kind: type, event: .canceled, position: position)
            touchesIDs[ObjectIdentifier(touch)] = nil
        }
    }
}
#endif
