/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

@MainActor
public protocol Drawable {
    var drawCommands: ContiguousArray<DrawCommand> { get }
    func matrices(withSize size: Size2) -> Matrices
}

internal extension Drawable {
    @inlinable
    var hasContent: Bool {
        return drawCommands.isEmpty == false
    }
}
