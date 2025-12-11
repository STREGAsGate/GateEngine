/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public extension Vector2n where Scalar: BinaryInteger {
    init(oldVector vector2: some Vector2) {
        self.init(x: Scalar(vector2.x), y: Scalar(vector2.y))
    }
}

public extension Vector2n where Scalar: BinaryFloatingPoint {
    init(oldVector vector2: some Vector2) {
        self.init(x: Scalar(vector2.x), y: Scalar(vector2.y))
    }
}
