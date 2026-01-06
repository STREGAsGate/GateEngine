/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public extension Transform3n {
    var oldTransform: Transform3 {
        return .init(position: self.position.oldVector, rotation: self.rotation.oldVector, scale: self.scale.oldVector)
    }
    init(oldTransform transform: Transform3) {
        self.init(position: .init(oldVector: transform.position), rotation: .init(oldVector: transform.rotation), scale: .init(oldVector: transform.scale))
    }
}
