/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct Circle: Sendable {
    public var center: Position2
    public var radius: Float

    @inlinable
    public init(center: Position2, radius: Float) {
        self.center = center
        self.radius = radius
    }
}

extension Circle: Equatable {}
extension Circle: Hashable {}
extension Circle: Codable {}
