/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public struct Matrices {
    public let projection: Matrix4x4
    public let view: Matrix4x4

    @inlinable
    func modelView(_ model: Matrix4x4) -> Matrix4x4 {
        return view * model
    }
    @inlinable
    func viewProjection() -> Matrix4x4 {
        return projection * view
    }
    @inlinable
    func modelViewProjection(_ model: Matrix4x4) -> Matrix4x4 {
        return projection * view * model
    }

    public init(projection: Matrix4x4, view: Matrix4x4 = .identity) {
        self.projection = projection
        self.view = view
    }
}
