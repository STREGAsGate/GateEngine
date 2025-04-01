/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@MainActor 
public struct UICanvas: Drawable {
    @usableFromInline
    internal var _drawCommands: ContiguousArray<DrawCommand> = []
    @inlinable
    public var drawCommands: ContiguousArray<DrawCommand> {
        return _drawCommands
    }

    var renderTargets: [any RenderTargetProtocol] {
        var renderTargets: [any RenderTargetProtocol] = []
        for command in drawCommands {
            renderTargets.append(contentsOf: command.renderTargets)
        }
        return renderTargets
    }
    
    internal init(estimatedCommandCount: Int) {
        self._drawCommands.reserveCapacity(estimatedCommandCount)
    }
    
    @inlinable
    public mutating func insert(_ drawCommand: DrawCommand) {
        if drawCommand.isReady {
            assert(drawCommand.validate())
            self._drawCommands.append(drawCommand)
        }
    }

    public func matrices(withSize size: Size2) -> Matrices {
        let ortho = Matrix4x4(
            orthographicWithTop: 0,
            left: 0,
            bottom: size.height,
            right: size.width,
            near: 0,
            far: Float(Int32.max)
        )
        let view = Matrix4x4(
            position: Position3(
                x: 0,
                y: 0,
                z: 1_000_000
            )
        )
        return Matrices(projection: ortho, view: view)
    }
}
