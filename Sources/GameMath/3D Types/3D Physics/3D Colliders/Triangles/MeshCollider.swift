/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class MeshCollider: Collider3D {
    public var center: Position3 {
        return transform.position
    }
    public var offset: Position3 {
        didSet {
            if offset != oldValue {
                needsUpdate = true
            }
        }
    }
    
    private let originalTriangles: [CollisionTriangle]
    /// Triangles as they were provided to the collider
    /// These triangles are not moved, rotated, or scaled to match its entity
    public func untransformedTriangles() -> [CollisionTriangle] {
        return originalTriangles
    }
    private var transformedTriangles: [CollisionTriangle]
    /// Triangles as they were provided to the collider
    /// These triangles are moved, rotated, and scaled by the `transform` property
    /// - note: The transform property is automatically manipulated by `Collision3DSystem` to match the `Collision3DComponents` entity
    public func triangles() -> [CollisionTriangle] {
        if needsUpdate {
            update()
        }
        return transformedTriangles
    }
    
    private func update() {
        needsUpdate = false
        let matrix = transform.matrix()
        transformedTriangles = originalTriangles.map({$0 * matrix})
        var positions: [Position3] = []
        positions.reserveCapacity(transformedTriangles.count * 3)
        for triangle in transformedTriangles {
            positions.append(contentsOf: triangle.positions)
        }
        
        _boundingBox = AxisAlignedBoundingBox3D(positions)
    }
    
    private var transform: Transform3 = .default {
        didSet {
            if transform != oldValue {
                needsUpdate = true
            }
        }
    }
        
    private var needsUpdate: Bool = true
    
    private var _boundingBox: AxisAlignedBoundingBox3D = AxisAlignedBoundingBox3D()
    public var boundingBox: AxisAlignedBoundingBox3D {
        if needsUpdate {
            update()
        }
        return _boundingBox
    }
    
    public func update(transform: Transform3) {
        self.transform = transform
    }
    
    public func update(sizeAndOffsetUsingTransform transform: Transform3) {
        self.offset = transform.position
        self.transform.scale = transform.scale
    }
    
    public func closestSurfacePoint(from point: Position3) -> Position3 {
        return closestTriangle(to: point).closestSurfacePoint(from: point)
    }
    
    public func interpenetration(comparing collider: any Collider3D) -> Interpenetration3D? {
        return triangles().compactMap({$0.interpenetration(comparing: collider)}).sorted(by: {$0.isColiding && $1.isColiding && $0.depth < $1.depth}).first
    }
    
    public func surfacePoint(for ray: Ray3D) -> Position3? {
        return triangles().compactMap({$0.surfacePoint(for: ray)}).sorted(by: {$0.distance(from: ray.origin) < $1.distance(from: ray.origin)}).first
    }
    
    public func surfaceNormal(facing point: Position3) -> Direction3 {
        return closestTriangle(to: point).normal
    }
    
    private func closestTriangle(to point: Position3) -> CollisionTriangle {
        var triangles = triangles().sorted(by: {$0.center.distance(from: point) < $1.center.distance(from: point)})
        if triangles.count > 10 {
            triangles.removeSubrange(10...)
        }
        let closestPoints = triangles.map({$0.closestSurfacePoint(from: point)})
        var distances: [Float] = Array(repeating: .greatestFiniteMagnitude, count: triangles.count)
        for index in triangles.indices {
            distances[index] = closestPoints[index].distance(from: point)
        }
        var lowestIndex: Int = -1
        var lowest: Float = .infinity
        for index in distances.indices {
            if distances[index] < lowest {
                lowestIndex = index
                lowest = distances[index]
            }
        }
        return triangles[lowestIndex]
    }
    
    public func trianglesHit(by ray: Ray3D, filter: ((CollisionTriangle)->Bool)? = nil) -> [(position: Position3, triangle: CollisionTriangle)] {
        var hits: [(position: Position3, triangle: CollisionTriangle)] = []
        for triangle in triangles() {
            guard filter?(triangle) ?? true else {continue}
            if let intersection = triangle.surfacePoint(for: ray) {
                hits.append((intersection, triangle))
            }
        }
        return hits
    }
    
    public init(transform: Transform3, offset: Position3, triangles: [CollisionTriangle]) {
        self.originalTriangles = triangles
        self.transformedTriangles = triangles
        self.offset = offset
        self.transform = transform
    }
}
