/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct ViewFrustum3D: Sendable {
    public let planes: Array<Plane3D>
    
    @inlinable @inline(__always)
    public var center: Position3 {
        let points = self.planes.map({$0.origin})
        var center: Position3 = .zero
        for point in points {
            center += point
        }
        return center / Float(points.count)
    }
    
    public init(matrix: Matrix4x4) {
        // Add first column of the matrix to the fourth column
        let left = Plane3D(matrix[12] + matrix[0],
                           matrix[13] + matrix[1],
                           matrix[14] + matrix[2],
                           matrix[15] + matrix[3]).normalized
        
        // Subtract first column of matrix from the fourth column
        let right = Plane3D(matrix[12] - matrix[0],
                            matrix[13] - matrix[1],
                            matrix[14] - matrix[2],
                            matrix[15] - matrix[3]).normalized
        
        // Add second column of the matrix to the fourth column
        let bottom = Plane3D(matrix[12] + matrix[4],
                             matrix[13] + matrix[5],
                             matrix[14] + matrix[6],
                             matrix[15] + matrix[7]).normalized
        
        // Subtract second column of matrix from the fourth column
        let top = Plane3D(matrix[12] - matrix[4],
                          matrix[13] - matrix[5],
                          matrix[14] - matrix[6],
                          matrix[15] - matrix[7]).normalized
        
        // We could add the third column to the fourth column to get the near plane,
        // but we don't have to do this because the third column IS the near plane
        let near = Plane3D(matrix[12] + matrix[8],
                           matrix[13] + matrix[9],
                           matrix[14] + matrix[10],
                           matrix[15] + matrix[11]).normalized
        
        // Subtract third column of matrix from the fourth column
        let far = Plane3D(matrix[12] - matrix[8],
                          matrix[13] - matrix[9],
                          matrix[14] - matrix[10],
                          matrix[15] - matrix[11]).normalized
        
        self.planes = [left, right, near, far, top, bottom]
    }
    
    @inlinable @inline(__always)
    public func pointInside(_ point: Position3) -> Bool {
        if planes[0].classifyPoint(point) != .front && planes[1].classifyPoint(point) != .front {
            // if it's not within near and far it's not in the frustum
            return false
        }
        if planes[1].classifyPoint(point) != .front && planes[2].classifyPoint(point) != .front {
            // if it's not within left and right it's not in the frustum
            return false
        }
        if planes[3].classifyPoint(point) != .front && planes[4].classifyPoint(point) != .front {
            // if it's not within top and bottom it's not in the frustum
            return false
        }
        // Must be within the frustum
        return true
    }
    
    @inlinable @inline(__always)
    public func isCollidingWith(_ box: AxisAlignedBoundingBox3D) -> Bool {
        var count = 0
        for plane in planes {
            if plane.isCollidingWith(box) {
                count += 1
                if count == 2 {
                    // If 2 planes intersect it must be colliding
                    return true
                }
            }
        }
        return false
    }
}

public extension ViewFrustum3D {
    @inlinable @inline(__always)
    func canSeeBox(_ box: AxisAlignedBoundingBox3D) -> Bool {
        return pointInside(box.position) || isCollidingWith(box)
    }
}
