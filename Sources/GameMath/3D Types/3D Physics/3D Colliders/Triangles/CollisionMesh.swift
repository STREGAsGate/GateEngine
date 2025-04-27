/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

/// An optimized container for CollisionTriangles
public final class CollisionMesh {
    @usableFromInline
    package struct Components {
        @usableFromInline
        package var positions: [Float]
        @usableFromInline
        package var normals: [Float]
        @usableFromInline
        package var attributes: [UInt64]
        
        package init(positions: [Float], normals: [Float], attributes: [UInt64]) {
            self.positions = positions
            self.normals = normals
            self.attributes = attributes
        }
    }
    @usableFromInline
    package struct TriangleIndices {
        @usableFromInline
        package let p1: Int
        @usableFromInline
        package let p2: Int
        @usableFromInline
        package let p3: Int
        @usableFromInline
        package let center: Int
        @usableFromInline
        package let normal: Int
        @usableFromInline
        package let faceNormal: Int
        @usableFromInline
        package let attributes: Int

        package init(p1: Int, p2: Int, p3: Int, center: Int, normal: Int, faceNormal: Int, attributes: Int) {
            self.p1 = p1
            self.p2 = p2
            self.p3 = p3
            self.center = center
            self.normal = normal
            self.faceNormal = faceNormal
            self.attributes = attributes
        }
    }
    @usableFromInline
    package var components: Components
    @usableFromInline
    package var indices: [TriangleIndices]

    @inlinable
    public var triangleCount: Int {
        return indices.count
    }
        
    public init(collisionTriangles triangles: [CollisionTriangle]) {
            assert(triangles.isEmpty == false)

        var positions: [Position3] = []
        var normals: [Direction3] = []
        var attributes: [UInt64] = []
        var indicies: [TriangleIndices] = []
        
        for triangle in triangles {
            func indexByAppendingValue<V: Equatable>(_ value: V, to array: inout [V]) -> Int {
                var arrayIndex: Int
                if let existingIndex = array.firstIndex(of: value) {
                    arrayIndex = existingIndex
                }else{
                    arrayIndex = array.count
                    array.append(value)
                }
                return arrayIndex
            }
            
            let faceNormal = Direction3((triangle.p2 - triangle.p1).cross(triangle.p3 - triangle.p1)).normalized
            let center = (triangle.p1 + triangle.p2 + triangle.p3) / 3
            indicies.append(
                TriangleIndices(
                    p1: indexByAppendingValue(triangle.p1, to: &positions) * 3,
                    p2: indexByAppendingValue(triangle.p2, to: &positions) * 3,
                    p3: indexByAppendingValue(triangle.p3, to: &positions) * 3,
                    center: indexByAppendingValue(center, to: &positions) * 3,
                    normal: indexByAppendingValue(triangle.normal, to: &normals) * 3,
                    faceNormal: indexByAppendingValue(faceNormal, to: &normals) * 3,
                    attributes: indexByAppendingValue(triangle.rawAttributes, to: &attributes)
                )
            )
        }
        
        self.components = Components(
            positions: positions.valuesArray(),
            normals: normals.valuesArray(),
            attributes: attributes
        )
        self.indices = indicies
    }
    
    package init(indices: [TriangleIndices], positions: [Float], normals: [Float], attributes: [UInt64]) {
        self.indices = indices
        self.components = Components(positions: positions, normals: normals, attributes: attributes)
    }
    
    public func generateCollisionTriangles() -> [CollisionTriangle] {
        var triangles: [CollisionTriangle] = []
        triangles.reserveCapacity(triangleCount)
        for index in 0 ..< triangleCount {
            self.withTriangle(atIndex: index) { triangle in
                triangles.append(
                    CollisionTriangle(
                        p1: triangle.p1,
                        p2: triangle.p2,
                        p3: triangle.p3,
                        normal: triangle.faceNormal,
                        rawAttributes: triangle.rawAttributes
                    )
                )
            }
        }
        return triangles
    }
}

public extension CollisionMesh {
    struct Triangle<CollisionAttributes: CollisionAttributesGroup>: ~Copyable {
        @usableFromInline
        internal var mesh: CollisionMesh
        @usableFromInline
        internal let indices: TriangleIndices
        
        @inlinable
        public var p1: Position3 {
            let baseIndex = indices.p1
            let x = mesh.components.positions[baseIndex]
            let y = mesh.components.positions[baseIndex + 1]
            let z = mesh.components.positions[baseIndex + 2]
            return Position3(x, y, z)
        }
        @inlinable
        public var p2: Position3 {
            let baseIndex = indices.p2
            let x = mesh.components.positions[baseIndex]
            let y = mesh.components.positions[baseIndex + 1]
            let z = mesh.components.positions[baseIndex + 2]
            return Position3(x, y, z)
        }
        @inlinable
        public var p3: Position3 {
            let baseIndex = indices.p3
            let x = mesh.components.positions[baseIndex]
            let y = mesh.components.positions[baseIndex + 1]
            let z = mesh.components.positions[baseIndex + 2]
            return Position3(x, y, z)
        }
        @inlinable
        public var center: Position3 {
            let baseIndex = indices.center
            let x = mesh.components.positions[baseIndex]
            let y = mesh.components.positions[baseIndex + 1]
            let z = mesh.components.positions[baseIndex + 2]
            return Position3(x, y, z)
        }
        
        @inlinable
        public var normal: Direction3 {
            let baseIndex = indices.normal
            let x = mesh.components.normals[baseIndex]
            let y = mesh.components.normals[baseIndex + 1]
            let z = mesh.components.normals[baseIndex + 2]
            return Direction3(x, y, z)
        }
        @inlinable
        public var faceNormal: Direction3 {
            let baseIndex = indices.faceNormal
            let x = mesh.components.normals[baseIndex]
            let y = mesh.components.normals[baseIndex + 1]
            let z = mesh.components.normals[baseIndex + 2]
            return Direction3(x, y, z)
        }
                
        @inlinable
        public var attributes: CollisionAttributes {
            let rawValue = mesh.components.attributes[indices.attributes]
            return CollisionAttributes(rawValue: rawValue)
        }
        
        @inlinable
        public var rawAttributes: UInt64 {
            return mesh.components.attributes[indices.attributes]
        }
        
        @inlinable
        public var plane: Plane3D {
            return Plane3D(origin: center, normal: normal)
        }
        
        @usableFromInline
        internal init(mesh: CollisionMesh, triangleIndex: Int) {
            self.mesh = mesh
            self.indices = mesh.indices[triangleIndex]
        }
    }
    
    struct MutableTriangle<CollisionAttributes: CollisionAttributesGroup>: ~Copyable {
        @usableFromInline
        internal var mesh: CollisionMesh
        @usableFromInline
        internal let indices: TriangleIndices
        
        @inlinable
        public var p1: Position3 {
            get {
                let baseIndex = Int(indices.p1)
                let x = mesh.components.positions[baseIndex]
                let y = mesh.components.positions[baseIndex + 1]
                let z = mesh.components.positions[baseIndex + 2]
                return Position3(x, y, z)
            }
            nonmutating set {
                let baseIndex = Int(indices.p1)
                mesh.components.positions[baseIndex] = newValue.x
                mesh.components.positions[baseIndex + 1] = newValue.y
                mesh.components.positions[baseIndex + 2] = newValue.z
            }
        }
        
        @inlinable
        public var p2: Position3 {
            get {
                let baseIndex = Int(indices.p2)
                let x = mesh.components.positions[baseIndex]
                let y = mesh.components.positions[baseIndex + 1]
                let z = mesh.components.positions[baseIndex + 2]
                return Position3(x, y, z)
            }
            nonmutating set {
                let baseIndex = Int(indices.p2)
                mesh.components.positions[baseIndex] = newValue.x
                mesh.components.positions[baseIndex + 1] = newValue.y
                mesh.components.positions[baseIndex + 2] = newValue.z
            }
        }

        @inlinable
        public var p3: Position3 {
            get {
                let baseIndex = Int(indices.p3)
                let x = mesh.components.positions[baseIndex]
                let y = mesh.components.positions[baseIndex + 1]
                let z = mesh.components.positions[baseIndex + 2]
                return Position3(x, y, z)
            }
            nonmutating set {
                let baseIndex = Int(indices.p3)
                mesh.components.positions[baseIndex] = newValue.x
                mesh.components.positions[baseIndex + 1] = newValue.y
                mesh.components.positions[baseIndex + 2] = newValue.z
            }
        }
        
        @inlinable
        public var normal: Direction3 {
            get {
                let baseIndex = Int(indices.normal)
                let x = mesh.components.normals[baseIndex]
                let y = mesh.components.normals[baseIndex + 1]
                let z = mesh.components.normals[baseIndex + 2]
                return Direction3(x, y, z)
            }
            nonmutating set {
                let baseIndex = Int(indices.normal)
                mesh.components.normals[baseIndex] = newValue.x
                mesh.components.normals[baseIndex + 1] = newValue.y
                mesh.components.normals[baseIndex + 2] = newValue.z
            }
        }

        @inlinable
        public var attributes: CollisionAttributes {
            get {
                let rawValue = mesh.components.attributes[Int(indices.attributes)]
                return CollisionAttributes(rawValue: rawValue)
            }
            nonmutating set {
                mesh.components.attributes[Int(indices.attributes)] = newValue.rawValue
            }
        }
        
        @usableFromInline
        internal init(mesh: CollisionMesh, triangleIndex: Int) {
            self.mesh = mesh
            self.indices = mesh.indices[triangleIndex]
        }
    }
}

extension CollisionMesh {
    @inlinable
    public func withTriangle<A: CollisionAttributesGroup, ResultType>(
        atIndex index: Int,
        with attributesType: A.Type = BasicCollisionAttributes.self,
        _ provideTriangle: (_ triangle: borrowing Triangle<A>) -> ResultType
    ) -> ResultType {
        let triangle = Triangle<A>(mesh: self, triangleIndex: index)
        let result = provideTriangle(triangle)
        return result
    }
    
    @inlinable
    public func editTriangle<A: CollisionAttributesGroup, ResultType>(
        atIndex index: Int,
        with attributesType: A.Type = BasicCollisionAttributes.self,
        _ editTriangle: (_ triangle: borrowing MutableTriangle<A>) -> ResultType
    ) -> ResultType {
        let triangle = MutableTriangle<A>(mesh: self, triangleIndex: index)
        let result = editTriangle(triangle)
        return result
    }
}
