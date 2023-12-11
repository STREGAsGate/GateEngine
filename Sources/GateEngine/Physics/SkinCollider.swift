/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class SkinCollider: Collider3D {
    var transform: Transform3 = .default {
        didSet {
            if transform != oldValue {
                forceRecompute = true
                boundingBox.center = transform.position
            }
        }
    }
    unowned let entity: Entity
    public let geometry: RawGeometry
    public let skin: Skin
    
    public private(set) var transformedTriangles: [CollisionTriangle] = []
    
    var rigComponent: Rig3DComponent? {
        return entity[Rig3DComponent.self]
    }
    
    var currentAnimation: ObjectIdentifier? = nil
    var computedAtAnimationProgress: Float = -1
    var forceRecompute: Bool = true
    @MainActor var needsRecompute: Bool {
        if forceRecompute {
            return true
        }
        if let activeAnimation = rigComponent?.activeAnimation {
            if currentAnimation != ObjectIdentifier(activeAnimation) {
                return true
            }
        }
        return rigComponent?.animationProgress != computedAtAnimationProgress 
    }
    
    @MainActor func recomputeIfNeeded() {
        guard let rigComponent = rigComponent else {return}
        guard needsRecompute else {return}
        forceRecompute = false
        if let activeAnimation = rigComponent.activeAnimation {
            currentAnimation = ObjectIdentifier(activeAnimation)
        }
        computedAtAnimationProgress = rigComponent.animationProgress
        
        let matrix = transform.matrix()
        
        let indicies = geometry.indices.map({Int($0)})
        let positions = geometry.positions
        let uvs = geometry.uvSet1
        
        let boneMatricies = rigComponent.skeleton.getPose().shaderMatrixArray(orderedFromSkinJoints: skin.joints).map({$0.transposed()})
        let boneIndicies = skin.jointIndices.map({Int($0)})
        let boneWeights = skin.jointWeights
        
        let positionCount: Int = indicies.count
        
        var transformedPositions: [Position3] = Array(repeating: .zero, count: positionCount)
        var transformedUVs: [Size2] = Array(repeating: .zero, count: positionCount)
        for vertexIndex in indicies.indices {
            let index = indicies[vertexIndex]
            
            let index3_1 = index * 3
            let index3_2 = index3_1 + 1
            let index3_3 = index3_2 + 1
            
            let index2_1 = index * 2
            let index2_2 = index2_1 + 1
            
            let vertex = Position3(positions[index3_1], positions[index3_2], positions[index3_3])
            
            let position: Position3 = {
                let index4_1: Int = index * 4
                let index4_2: Int = index4_1 + 1
                let index4_3: Int = index4_2 + 1
                let index4_4: Int = index4_3 + 1
                
                let boneIndex1: Int = boneIndicies[index4_1]
                let boneIndex2: Int = boneIndicies[index4_2]
                let boneIndex3: Int = boneIndicies[index4_3]
                let boneIndex4: Int = boneIndicies[index4_4]
                
                let boneMaterix1: Matrix4x4 = boneMatricies[boneIndex1]
                let boneMaterix2: Matrix4x4 = boneMatricies[boneIndex2]
                let boneMaterix3: Matrix4x4 = boneMatricies[boneIndex3]
                let boneMaterix4: Matrix4x4 = boneMatricies[boneIndex4]
                
                let boneWeight1: Float = boneWeights[index4_1]
                let boneWeight2: Float = boneWeights[index4_2]
                let boneWeight3: Float = boneWeights[index4_3]
                let boneWeight4: Float = boneWeights[index4_4]
                
                let w1: Position3 = boneMaterix1 * vertex * boneWeight1
                let w2: Position3 = boneMaterix2 * vertex * boneWeight2
                let w3: Position3 = boneMaterix3 * vertex * boneWeight3
                let w4: Position3 = boneMaterix4 * vertex * boneWeight4
                
                return w1 + w2 + w3 + w4
            }()
 
            transformedPositions[vertexIndex] = position * matrix
            transformedUVs[vertexIndex] = Size2(uvs[index2_1], uvs[index2_2])
        }
                
        transformedTriangles = stride(from: 0, to: transformedPositions.count, by: 3).map({
            let uv = transformedUVs[$0]
            let attributes = CollisionTriangle.attributeParser(uv.x, uv.y, 0)
            return CollisionTriangle(
                transformedPositions[$0 + 0],
                transformedPositions[$0 + 1],
                transformedPositions[$0 + 2],
                attributes: attributes
            )
        })
    }
    
    public var center: Position3 {
        get {
            return transform.position
        }
        set {
            if transform.position != newValue {
                transform.position = newValue
            }
        }
    }
    ///The translation difference from node centroid to geometry centroid
    public let offset: Position3 = .zero

    public func update(transform: Transform3) {
        self.transform = transform
    }
    
    public func update(sizeAndOffsetUsingTransform transform: Transform3) {
        self.transform = transform
    }
    
    @MainActor
    public func closestSurfacePoint(from point: Position3) -> Position3 {
        recomputeIfNeeded()
        var closest: Position3 = self.position
        var closestDistance: Float = .greatestFiniteMagnitude
        for triangle in transformedTriangles {
            let new = triangle.closestSurfacePoint(from: point)
            let distance = point.distance(from: point)
            if distance < closestDistance {
                closest = new
                closestDistance = distance
            }
        }
        return closest
    }
    
    @MainActor
    public func interpenetration(comparing collider: any Collider3D) -> Interpenetration3D? {
        recomputeIfNeeded()
        return nil
    }
    
    @MainActor
    public func surfacePoint(for ray: Ray3D) -> Position3? {
        recomputeIfNeeded()
        var closest: Position3? = nil
        var closestDistance: Float = .greatestFiniteMagnitude
        for triangle in transformedTriangles {
            guard let new = triangle.surfacePoint(for: ray) else {continue}
            let distance = new.distance(from: ray.origin)
            if distance < closestDistance {
                closest = new
                closestDistance = distance
            }
        }
        return closest
    }
    
    @MainActor
    public func surfaceNormal(facing point: Position3) -> Direction3 {
        recomputeIfNeeded()
        var closestDistance: Float = .greatestFiniteMagnitude
        var closestTriangle: CollisionTriangle? = nil
        for triangle in transformedTriangles {
            let new = triangle.closestSurfacePoint(from: point)
            let distance = new.distance(from: point)
            if distance < closestDistance {
                closestTriangle = triangle
                closestDistance = distance
            }
        }
        if let closestTriangle {
            return closestTriangle.normal
        }
        return Direction3(from: position, to: point)
    }
    
    @MainActor
    public func surfaceImpact(comparing ray: Ray3D) -> SurfaceImpact3D? {
        recomputeIfNeeded()
        var closest: Position3? = nil
        var closestDistance: Float = .greatestFiniteMagnitude
        var closestTriangle: CollisionTriangle? = nil
        for triangle in transformedTriangles {
            guard let new = triangle.surfacePoint(for: ray) else {continue}
            let distance = new.distance(from: ray.origin)
            if distance < closestDistance {
                closest = new
                closestDistance = distance
                closestTriangle = triangle
            }
        }
        if let closestTriangle, let closest {
            return SurfaceImpact3D(normal: closestTriangle.normal, position: closest) 
        }
        return nil
    }
    
    @MainActor
    public func trianglesHit(
        by ray: Ray3D, 
        filter: ((CollisionTriangle)->Bool)? = nil
    ) -> [(position: Position3, triangle: CollisionTriangle)] {
        recomputeIfNeeded()
        var hits: [(position: Position3, triangle: CollisionTriangle)] = []
        for triangle in transformedTriangles {
            guard filter?(triangle) ?? true else {continue}
            if let intersection = triangle.surfacePoint(for: ray) {
                hits.append((intersection, triangle))
            }
        }
        return hits
    }
    
    public var boundingBox: AxisAlignedBoundingBox3D = AxisAlignedBoundingBox3D()
    
    public init(entity: Entity, geometry: RawGeometry, skin: Skin, boundingBoxSize: Size3) {
        self.entity = entity
        self.geometry = geometry
        self.skin = skin
        
        self.transformedTriangles = []
        self.boundingBox.size = boundingBoxSize
        self.boundingBox.offset.y = boundingBoxSize.y * 0.5
    }
}
