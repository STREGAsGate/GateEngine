/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(WinSDK)
import Foundation
import WinSDK
import GameMath

final class Win32Window: WindowBacking {
    unowned let window: Window
    let style: WindowStyle
    let identifier: String?

    required init(identifier: String?, style: WindowStyle, window: Window) {
        self.window = window
        self.style = style
        self.identifier = identifier
    }

    var title: String? {
        get {
            fatalError()
        }
        set {
            fatalError()
        }
    }

    var frame: Rect {
        get {
            fatalError()
        }
        set {
            // can't
        }
    }

    var backingSize: Size2 {
        fatalError()
    }

    var safeAreaInsets: Insets = .zero

    @MainActor func show() {
        fatalError()
    }
    
    func close() {
        
    }
}

#endif
