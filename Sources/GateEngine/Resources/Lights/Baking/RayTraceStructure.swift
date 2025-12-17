/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

/// A geometry container tuned for light map tracing
nonisolated public struct RayTraceStructure: Sendable {
    @usableFromInline
    nonisolated internal struct Components: Sendable {
        @usableFromInline
        var positionBytes: ContiguousArray<UInt8>
        @usableFromInline
        var normalBytes: ContiguousArray<UInt8>
        @usableFromInline
        var attributes: Array<UInt64>
        
        init(positionBytes: ContiguousArray<UInt8>, normalBytes: ContiguousArray<UInt8>, attributes: [UInt64]) {
            self.positionBytes = positionBytes
            self.normalBytes = normalBytes
            self.attributes = attributes
        }
    }
    @usableFromInline
    nonisolated internal struct TriangleIndices: Sendable {
        @usableFromInline
        package let p1: Int
        @usableFromInline
        package let p2: Int
        @usableFromInline
        package let p3: Int
        @usableFromInline
        package let center: Int
        @usableFromInline
        package let n1: Int
        @usableFromInline
        package let n2: Int
        @usableFromInline
        package let n3: Int
        @usableFromInline
        package let faceNormal: Int
        @usableFromInline
        package let attributes: Int
        @usableFromInline
        package let source: Int
        
        package init(p1: Int, p2: Int, p3: Int, center: Int, n1: Int, n2: Int, n3: Int, faceNormal: Int, attributes: Int, source: Int) {
            self.p1 = p1
            self.p2 = p2
            self.p3 = p3
            self.center = center
            self.n1 = n1
            self.n2 = n1
            self.n3 = n1
            self.faceNormal = faceNormal
            self.attributes = attributes
            self.source = source
        }
    }
    @usableFromInline
    nonisolated internal struct Node: Sendable {
        let depth: Int
        let rect: Rect
        let kind: Kind
        enum Kind: Sendable {
            case branch(_ children: [Node])
            case leaf(_ triangles: [Array<TriangleIndices>.Index])
        }
        
        init(depth: Int, origin: Position3f, size: Size3f, kind: Kind) {
            self.depth = depth
            self.rect = Rect(center: origin, size: size)
            self.kind = kind
        }
        
        struct Rect: Rect3nSurfaceMath {
            let center: Position3f
            let size: Size3f
            let radius: Size3f
            let minPosition: Position3f
            let maxPosition: Position3f
            init(center: Position3f, size: Size3f) {
                self.center = center
                self.size = size
                self.radius = (size * 0.5)
                self.minPosition = center - radius
                self.maxPosition = center + radius
            }
        }
    }
    
    @usableFromInline
    internal let components: Components
    @usableFromInline
    internal let triangleIndices: [TriangleIndices]
    @usableFromInline
    internal let sourceIndicies: [SourceIndex]
    @usableFromInline
    internal var rootNode: Node
    
    @usableFromInline
    nonisolated struct SourceIndex: Hashable, Sendable {
        let offset: Int
        let count: Int
        
        var range: Range<Int> {
            return offset ..< (offset + count)
        }
        
        nonisolated func contains(_ index: Int) -> Bool {
            return range.contains(index)
        }
    }
    
    public init(rawGeometries: [RawGeometry]) async {
        var positions: [Position3f] = []
        var normals: [Direction3f] = []
        var attributes: [UInt64] = []
        var indicies: [TriangleIndices] = []
        
        var _positionsCapacity: Int = 0
        var _normalsCapacity: Int = 0
        var _attributesCapacity: Int = 0
        var _indiciesCapacity: Int = 0
        
        for rawGeometry in rawGeometries {
            // p1, p2, p3, center
            _positionsCapacity += rawGeometry.count * 4
            // n1, n2, n3, faceNormal
            _normalsCapacity += rawGeometry.count * 4
            
            _attributesCapacity += rawGeometry.count
            
            _indiciesCapacity += rawGeometry.count
        }
        positions.reserveCapacity(_positionsCapacity)
        normals.reserveCapacity(_normalsCapacity)
        attributes.reserveCapacity(_attributesCapacity)
        indicies.reserveCapacity(_indiciesCapacity)
        
        var min: Position3f = .nan
        var max: Position3f = .nan
        
        for sourceIndex in rawGeometries.indices {
            let rawGeometry = rawGeometries[sourceIndex]
            
            for triangle in rawGeometry {
                func indexByAppendingValue<V: Equatable>(_ value: V, to array: inout [V]) -> Int {
                    if let existingIndex = array.firstIndex(of: value) {
                        return existingIndex
                    }
                    let newIndex = array.endIndex
                    array.append(value)
                    return newIndex
                }
                
                indicies.append(
                    TriangleIndices(
                        p1: indexByAppendingValue(.init(oldVector: triangle.v1.position), to: &positions) * MemoryLayout<Position3f>.size,
                        p2: indexByAppendingValue(.init(oldVector: triangle.v2.position), to: &positions) * MemoryLayout<Position3f>.size,
                        p3: indexByAppendingValue(.init(oldVector: triangle.v3.position), to: &positions) * MemoryLayout<Position3f>.size,
                        center: indexByAppendingValue(.init(oldVector: triangle.center), to: &positions) * MemoryLayout<Position3f>.size,
                        n1: indexByAppendingValue(.init(oldVector: triangle.v1.normal).normalized, to: &normals) * MemoryLayout<Direction3f>.size,
                        n2: indexByAppendingValue(.init(oldVector: triangle.v2.normal).normalized, to: &normals) * MemoryLayout<Direction3f>.size,
                        n3: indexByAppendingValue(.init(oldVector: triangle.v3.normal).normalized, to: &normals) * MemoryLayout<Direction3f>.size,
                        faceNormal: indexByAppendingValue(.init(oldVector: triangle.faceNormal), to: &normals) * MemoryLayout<Direction3f>.size,
                        attributes: indexByAppendingValue(triangle.collisionAttributes().rawValue, to: &attributes),
                        source: sourceIndex
                    )
                )
            }
        }
        
        var positionBytes: ContiguousArray<UInt8> = []
        positionBytes.reserveCapacity(positions.count * MemoryLayout<Position3f>.size)
        for position in positions {
            min.x = .minimum(min.x, position.x)
            min.y = .minimum(min.y, position.y)
            min.z = .minimum(min.z, position.z)
            max.x = .maximum(max.x, position.x)
            max.y = .maximum(max.y, position.y)
            max.z = .maximum(max.z, position.z)
            withUnsafeBytes(of: position) { bytes in
                positionBytes.append(contentsOf: bytes)
            }
        }
        
        var normalBytes: ContiguousArray<UInt8> = []
        normalBytes.reserveCapacity(normals.count * MemoryLayout<Direction3f>.size)
        for normal in normals {
            withUnsafeBytes(of: normal) { bytes in
                normalBytes.append(contentsOf: bytes)
            }
        }
        
        self.components = Components(
            positionBytes: positionBytes,
            normalBytes: normalBytes,
            attributes: attributes
        )
        self.triangleIndices = indicies
        
        var offsets: [SourceIndex] = []
        offsets.reserveCapacity(rawGeometries.count)
        var offset = 0
        for sourceIndex in rawGeometries.indices {
            let count = rawGeometries[sourceIndex].count
            offsets.append(SourceIndex(offset: offset, count: count))
            offset += count
        }
        self.sourceIndicies = offsets
        
        var rootNodeBounds = Size3f(max - min)
        rootNodeBounds += 2
        rootNodeBounds += rootNodeBounds.truncatingRemainder(dividingBy: 2)
        let rootNodeCenter: Position3f = (max + min) * 0.5
        
        // Dummy rootNode so we can iterate self
        self.rootNode = Node(depth: 0, origin: rootNodeCenter, size: rootNodeBounds, kind: .leaf([]))
        
        let minimumTrianglesPerLeaf: Int = 2
        let maximumTrianglesPerLeaf: Int = 4
        let maximumDepth: Int = 3
        
        @_optimize(speed)
        func makeChildren(of parentDepth: Int, parentCenter: Position3f) -> [Node] {
            let childDepth = parentDepth + 1
            let childSize = rootNodeBounds / Float(childDepth * 2)
            let halfChildSize = childSize * 0.5
            
            var childCenters: [Position3f] = []
            for x: Float in [-1, 1] {
                for y: Float in [-1, 1] {
                    for z: Float in [-1, 1] {
                        let signScale = Size3f(x: x, y: y, z: z)
                        childCenters.append(parentCenter + (halfChildSize * signScale))
                    }
                }
            }
            
            var nodes: [Node] = []
            
            var trianglesForParent: Set<Int> = []
            
            for childCenter in childCenters {
                let rect: Rect3f = .init(size: childSize, center: childCenter)
                var triangles: [Self.Index] = []
                for (index, triangle) in self.enumerated() {
                    if rect.contains(triangle.nearestSurfacePosition(to: rect.center)) {
                        triangles.append(index)
                        trianglesForParent.insert(index)
                    }
                }
                
                var branch = triangles.count > maximumTrianglesPerLeaf
                if childDepth >= maximumDepth {
                    branch = false
                }
                
                if branch {
                    // Branch
                    let childNodes: [Node] = makeChildren(of: childDepth, parentCenter: childCenter)
                    if childNodes.count > 1 {
                        nodes.append(
                            Node(depth: childDepth, origin: childCenter, size: childSize, kind: .branch(childNodes))
                        )
                        continue
                    }
                }
                
                // If the branch fails create a leaf
                if triangles.isEmpty == false {
                    nodes.append(
                        Node(depth: childDepth, origin: childCenter, size: childSize, kind: .leaf(triangles))
                    )
                }
            }
            
            // If the total triangles for all children is less than the minimum, return no
            // children so the parent become a leaf
            if trianglesForParent.count < minimumTrianglesPerLeaf {
                return []
            }
            
            return nodes
        }
        
        let rootNodeChildren = makeChildren(of: 0, parentCenter: rootNodeCenter)
        self.rootNode = Node(depth: 0, origin: rootNodeCenter, size: rootNodeBounds, kind: .branch(rootNodeChildren))
    }
}

public extension RayTraceStructure {
    nonisolated struct Triangle: Triangle3nSurfaceMath, Ray3nIntersectable, Sendable {
        public typealias Scalar = Float32
        
        @usableFromInline
        internal let components: RayTraceStructure.Components
        @usableFromInline
        internal let indices: TriangleIndices
        
        @inlinable
        public var p1: Position3n<Scalar> {
            return components.positionBytes.withUnsafeBytes({ bytes in
                return bytes.load(fromByteOffset: indices.p1, as: Position3n<Scalar>.self)
            })
        }
        @inlinable
        public var p2: Position3n<Scalar> {
            return components.positionBytes.withUnsafeBytes({ bytes in
                return bytes.load(fromByteOffset: indices.p2, as: Position3n<Scalar>.self)
            })
        }
        @inlinable
        public var p3: Position3n<Scalar> {
            return components.positionBytes.withUnsafeBytes({ bytes in
                return bytes.load(fromByteOffset: indices.p3, as: Position3n<Scalar>.self)
            })
        }
        @inlinable
        public var center: Position3n<Scalar> {
            return components.positionBytes.withUnsafeBytes({ bytes in
                return bytes.load(fromByteOffset: indices.center, as: Position3n<Scalar>.self)
            })
        }
        
        @inlinable
        public var normal1: Direction3n<Scalar> {
            return components.normalBytes.withUnsafeBytes({ bytes in
                return bytes.load(fromByteOffset: indices.n1, as: Direction3n<Scalar>.self)
            })
        }
        @inlinable
        public var normal2: Direction3n<Scalar> {
            return components.normalBytes.withUnsafeBytes({ bytes in
                return bytes.load(fromByteOffset: indices.n2, as: Direction3n<Scalar>.self)
            })
        }
        @inlinable
        public var normal3: Direction3n<Scalar> {
            return components.normalBytes.withUnsafeBytes({ bytes in
                return bytes.load(fromByteOffset: indices.n3, as: Direction3n<Scalar>.self)
            })
        }
        
        @inlinable
        public var faceNormal: Direction3n<Scalar> {
            return components.normalBytes.withUnsafeBytes({ bytes in
                return bytes.load(fromByteOffset: indices.faceNormal, as: Direction3n<Scalar>.self)
            })
        }
        
        @inlinable
        public nonmutating func attributes<CollisionAttributes: CollisionAttributesGroup>(using attributesType: CollisionAttributes.Type) -> CollisionAttributes {
            let rawValue = components.attributes[indices.attributes]
            return CollisionAttributes(rawValue: rawValue)
        }
        
        @inlinable
        public var rawAttributes: UInt64 {
            return components.attributes[indices.attributes]
        }
        
        @inlinable
        public var plane: Plane3n<Scalar> {
            return Plane3n<Scalar>(origin: center, normal: faceNormal)
        }
        
        @usableFromInline
        internal init(components: RayTraceStructure.Components, triangleIndices: TriangleIndices) {
            self.components = components
            self.indices = triangleIndices
        }
    }
}

nonisolated public extension RayTraceStructure {
    @inlinable
    nonmutating func withTriangle<ResultType>(atIndex index: Int, _ block: (_ triangle: borrowing Triangle)->ResultType) -> ResultType {
        // TODO: Using borrowing should prevent self.components from being copied, and be more performant. Needs testing.
        // Since components is always immutable it, might never be copied and, might not make a difference
        let triangle = Triangle(components: self.components, triangleIndices: self.triangleIndices[index])
        return block(triangle)
    }
    
    @inlinable
    nonmutating func triangle(at index: Int) -> Triangle {
        return Triangle(components: self.components, triangleIndices: self.triangleIndices[index])
    }
}

nonisolated extension RayTraceStructure: RandomAccessCollection {
    public typealias Element = Triangle
    public typealias Index = Int

    @inlinable
    @_transparent
    public var startIndex: Index {
        return 0
    }
    
    @inlinable
    public var endIndex: Index {
        if self.triangleIndices.isEmpty {
            return self.startIndex
        }
        return self.triangleIndices.count
    }
    
    @inlinable
    public subscript(index: Int) -> Triangle {
        return self.triangle(at: index)
    }
}

extension RayTraceStructure {
    @_optimize(speed)
    func isObscured(from source: Position3f, to destination: Position3f, ignoringSources: Set<Int>, ignoringTriangles: Set<Int>) -> Bool {
        let ray = Ray3f(from: source, toward: destination)
        let distanceToDst = source.distance(from: destination)
        
        @_optimize(speed)
        func castThrough(_ node: Node) -> Bool {
            let rect = node.rect
            let refPoint = rect.nearestSurfacePosition(to: ray.origin)
            if ray.origin.distance(from: refPoint) < distanceToDst {
                if rect.intersects(with: ray) {
                    switch node.kind {
                    case .branch(let children):
                        for childIndex in children.indices.sorted(by: {children[$0].rect.center.distance(from: ray.origin) < children[$1].rect.center.distance(from: ray.origin)}) {
                            if castThrough(children[childIndex]) {
                                return true
                            }
                        }
                    case .leaf(let triangleIndicies):
                        for triangleIndex in triangleIndicies {
                            let sourceIndex = self.triangleIndices[triangleIndex].source
                            guard ignoringSources.contains(sourceIndex) == false else {continue}
                            guard ignoringTriangles.contains(triangleIndex) == false else {continue}
                            let triangle = self[triangleIndex]
                            if let hit = triangle.intersection(of: ray) {
                                if source.distance(from: hit) < distanceToDst {
                                    return true
                                }
                            }
                        }
                    }
                }
            }
            return false
        }
        
        return castThrough(rootNode)
    }
    
    @_optimize(speed)
    func indexesObscuring(from source: Position3f, to destination: Position3f, ignoringSources: Set<Int>, ignoringTriangles: Set<Int>) -> Set<Int> {
        let ray = Ray3f(from: source, toward: destination)
        let distanceToDst = source.distance(from: destination)
        
        var hits: Set<Int> = []
        
        @_optimize(speed)
        func castThrough(_ node: Node) {
            let rect = node.rect
            if rect.intersects(with: ray) {
                let refPoint = rect.nearestSurfacePosition(to: ray.origin)
                if ray.origin.distance(from: refPoint) > distanceToDst {
                    return
                }
                switch node.kind {
                case .branch(let children):
                    for child in children {
                        castThrough(child)
                    }
                case .leaf(let triangleIndicies):
                    for triangleIndex in triangleIndicies {
                        guard hits.contains(triangleIndex) == false else { continue }
                        guard ignoringSources.contains(self.triangleIndices[triangleIndex].source) == false else {continue}
                        guard ignoringTriangles.contains(triangleIndex) == false else {continue}
                        let triangle = self[triangleIndex]
//                        guard triangle.faceNormal.isFrontFacing(toward: ray.direction) else {continue}
                        if let hit = triangle.intersection(of: ray) {
                            if source.distance(from: hit) < distanceToDst {
                                hits.insert(triangleIndex)
                            }
                        }
                    }
                }
            }
        }
        
        castThrough(rootNode)
        
        return hits
    }
}
