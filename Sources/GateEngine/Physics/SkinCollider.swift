/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
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
    
    public private(set) var transformedTriangles: [CollisionTriangle]
    private var attributesPerTriangle: [UInt32]! = nil
    
    @MainActor
    @inline(__always)
    var rigComponent: Rig3DComponent? {
        return entity.component(ofType: Rig3DComponent.self)
    }
    
    var currentAnimation: ObjectIdentifier? = nil
    var computedAtAnimationProgress: Float = -1
    var forceRecompute: Bool = true
    @MainActor 
    var needsRecompute: Bool {
        if forceRecompute {
            return true
        }
        if let rigComponent {
            if let activeAnimation = rigComponent.activeAnimation {
                if currentAnimation != ObjectIdentifier(activeAnimation) {
                    return true
                }
            }
            return rigComponent.animationProgress != computedAtAnimationProgress
        }
        return false
    }
    
    @MainActor 
    func populateAttributes() {
        let indicies = geometry.indices.map({Int($0)})
        let uvs = geometry.uvSets
        
        let positionCount: Int = indicies.count
        
        var transformedUVs: [[Size2]] = Array(repeating: Array(repeating: .zero, count: positionCount), count: geometry.uvSets.count)
        for vertexIndex in indicies.indices {
            let index = indicies[vertexIndex]
 
            let index2_1 = index * 2
            let index2_2 = index2_1 + 1
            
            for setIndex in 0 ..< geometry.uvSets.count {
                transformedUVs[setIndex][vertexIndex] = Size2(uvs[setIndex][index2_1], uvs[setIndex][index2_2])
            }
        }
        
        for triangleIndex in transformedTriangles.indices {
            var attributes: UInt32 = 0
            for uvSetIndex in 0 ..< transformedUVs.count {
                let uvSet = transformedUVs[uvSetIndex]
                let uv = uvSet[triangleIndex * 3]
                attributes |= CollisionTriangle.attributeParser(uv.x, uv.y, UInt32(uvSetIndex))
            }
            transformedTriangles[triangleIndex]._attributes = attributes
        }
    }
    
    @MainActor 
    func recomputeIfNeeded() {
        guard needsRecompute else {return}
        guard let rigComponent = rigComponent else {return}
        self.forceRecompute = false
        if let activeAnimation = rigComponent.activeAnimation {
            self.currentAnimation = ObjectIdentifier(activeAnimation)
        }
        self.computedAtAnimationProgress = rigComponent.animationProgress
        
        let matrix = self.transform.matrix()
        
        let indicies = self.geometry.indices.map({Int($0)})
        let positions = self.geometry.positions
        
        let boneMatricies = rigComponent.skeleton.getPose().shaderMatrixArray(orderedFromSkinJoints: self.skin.joints).map({$0.transposed()})
        let boneIndicies = self.skin.jointIndices.map({Int($0)})
        let boneWeights = self.skin.jointWeights
        
        var triangleIndex = 0
        var triangleVertex = 0
        for vertexIndex in indicies.indices {
            let index = indicies[vertexIndex]
            
            let index3_1 = index * 3
            let index3_2 = index3_1 + 1
            let index3_3 = index3_2 + 1
            
            let vertex = Position3(positions[index3_1], positions[index3_2], positions[index3_3])
            
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
            
            let position: Position3 = w1 + w2 + w3 + w4
            
            // Update the vertex of the triangle
            self.transformedTriangles[triangleIndex].positions[triangleVertex] = position * matrix
            
            triangleVertex += 1
            if triangleVertex == 3 {
                // Recomupte the triangle once after all 3 verts have been updated
                self.transformedTriangles[triangleIndex].recomputeAll()
                
                triangleIndex += 1
                triangleVertex = 0
            }
        }
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
            return SurfaceImpact3D(normal: closestTriangle.normal, position: closest, triangle: closestTriangle)
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
    
    @MainActor
    public init(entity: Entity, geometry: RawGeometry, skin: Skin, boundingBoxSize: Size3) {
        self.entity = entity
        self.geometry = geometry
        self.skin = skin
        
        self.boundingBox.size = boundingBoxSize
        self.boundingBox.offset.y = boundingBoxSize.y * 0.5
        
        self.forceRecompute = true
        
        self.transformedTriangles = Array(repeating: CollisionTriangle(.zero, .zero, .zero, attributes: 0), count: Int(geometry.indices.count / 3))
        self.populateAttributes()
    }
}
