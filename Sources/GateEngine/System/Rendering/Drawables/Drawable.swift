//
//  File.swift
//  
//
//  Created by Dustin Collins on 1/4/24.
//

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
