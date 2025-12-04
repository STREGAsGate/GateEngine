/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

/// An element array object formatted as triangle primitives
public struct RawGeometry: Codable, Sendable, Equatable, Hashable {
    public var vertices: VertexView
 
    private func triangle(at index: Index) -> Element {
        assert(self.indices.contains(index), "Index \(index) out of range \(self.indices)")
        let index = index * 3
        return Triangle(
            v1: self.vertices[index + 0],
            v2: self.vertices[index + 1],
            v3: self.vertices[index + 2],
            repairIfNeeded: false
        )
    }
    
    private mutating func setTriangle(_ triangle: Triangle, at index: Index) {
        assert(self.indices.contains(index), "Index \(index) out of range \(self.indices)")
        let index = index * 3
        self.vertices.setVertex(triangle.v1, at: index + 0)
        self.vertices.setVertex(triangle.v2, at: index + 1)
        self.vertices.setVertex(triangle.v3, at: index + 2)
    }

    public func flipped() -> RawGeometry {
        var copy = self
        for index in self.indices {
            copy[index] = copy[index].flipped()
        }
        return copy
    }
    
    public mutating func optimize() {
        var newVertices: VertexView = VertexView()
        for vertex in self.vertices {
            newVertices.insert(vertex, at: newVertices.endIndex, sacrificingPerformanceToOptimize: true)
        }
        self.vertices = newVertices
    }
    
    public func optimized() -> RawGeometry {
        var copy = self
        copy.optimize()
        return copy
    }

    /// Creates a new `Geometry` from element array values.
    public init(
        positions: [Float],
        uvSets: [[Float]],
        normals: [Float]?,
        tangents: [Float]?,
        colors: [Float]?,
        indexes: [UInt16]
    ) {
        self.vertices = .init(
            positions: positions,
            uvSets: uvSets,
            normals: normals,
            tangents: tangents,
            colors: colors,
            indexes: indexes
        )
    }
    
    public enum Optimization {
        /// Keeps every vertex as is, including duplicates.
        /// This option is required for skins as the indices are pre computed
        case dontOptimize
        /// Compares each vertex using equality. If equal,  they are considered the same and will be folded into a single vertex.
        case byEquality
        /// Compares the vertex components. If the difference between components is within `threshold` they are considered the same and will be folded into a single vertex.
        case byThreshold(_ threshold: Float)
        /// Checks the result of the provided comparator. If true, the vertices will be folded into a single vertex. The vertex kept is always lhs.
        case usingComparator(_ comparator: (_ lhs: Vertex, _ rhs: Vertex) -> Bool)
    }

    /// Create `Geometry` from counter-clockwise wound `Triangles` and optionanly attempts to optimize the arrays by distance.
    /// Optimization is extremely slow and may result in loss of data. It should be used to pre-optimize assets and should not be used at runtime.
    public init(triangles: [Triangle], optimization: Optimization = .dontOptimize) {
        self.init()
        self.reserveCapacity(triangles.count)
        
        if case .dontOptimize = optimization {
            for triangle in triangles {
                self.append(triangle)
            }
            return
        }
        
        var inVertices = triangles.vertices

        var optimizedIndicies: [UInt16]
        switch optimization {
        case .dontOptimize:
            assert(inVertices.count < UInt16.max, "Exceeded the maximum number of indices (\(inVertices.count)\\\(UInt16.max)) for a single geometry. This geometry needs to be spilt up.")
            optimizedIndicies = Array(0 ..< UInt16(inVertices.count))
        case .byEquality:
            optimizedIndicies = Array(repeating: 0, count: inVertices.count)
            for index in 0 ..< inVertices.count {
                assert(index <= UInt16.max, "Exceeded the maximum number of indices (\(index)\\\(UInt16.max)) for a single geometry. This geometry needs to be spilt up.")
                let vertex = inVertices[index]
                if let similarIndex = inVertices.firstIndex(where: {$0 == vertex}) {
                    optimizedIndicies[index] = UInt16(similarIndex)
                }else{
                    optimizedIndicies[index] = UInt16(index)
                }
            }
        case .byThreshold(let threshold):
            optimizedIndicies = Array(repeating: 0, count: inVertices.count)
            for index in 0 ..< inVertices.count {
                assert(index <= UInt16.max, "Exceeded the maximum number of indices (\(index)\\\(UInt16.max)) for a single geometry. This geometry needs to be spilt up.")
                let vertex = inVertices[index]
                if let similarIndex = inVertices.firstIndex(where: {$0.isSimilar(to: vertex, threshold: threshold)}) {
                    optimizedIndicies[index] = UInt16(similarIndex)
                }else{
                    if let similarIndex = inVertices.firstIndex(where: {$0.isPositionSimilar(to: vertex, threshold: threshold)}) {
                        // If a vertex has a similar position, move this vertex to that position
                        inVertices[index].position = inVertices[similarIndex].position
                    }
                    optimizedIndicies[index] = UInt16(index)
                }
            }
        case .usingComparator(let comparator):
            optimizedIndicies = Array(repeating: 0, count: inVertices.count)
            for index in 0 ..< inVertices.count {
                assert(index <= UInt16.max, "Exceeded the maximum number of indices (\(index)\\\(UInt16.max)) for a single geometry. This geometry needs to be spilt up.")
                let vertex = inVertices[index]
                if let similarIndex = inVertices.firstIndex(where: { comparator($0, vertex)}) {
                    optimizedIndicies[index] = UInt16(similarIndex)
                }else{
                    optimizedIndicies[index] = UInt16(index)
                }
            }
        }
        
        // The next real indices index
        var nextIndex = 0
        if case .dontOptimize = optimization {
            for vertex in inVertices {
                self.positions.append(contentsOf: vertex.position.valuesArray())
                self.normals.append(contentsOf: vertex.normal.valuesArray())
                uvSet1.append(contentsOf: vertex.uv1.valuesArray())
                uvSet2.append(contentsOf: vertex.uv2.valuesArray())
                self.tangents.append(contentsOf: vertex.tangent.valuesArray())
                self.colors.append(contentsOf: vertex.color.valuesArray())

                self.vertexIndicies.append(UInt16(nextIndex))
                // Increment the next real indicies index
                nextIndex += 1
            }
        }else{
            // Store the optimized vertex index using the actual indicies index
            // so we can look up the real index for repeated verticies
            var indicesMap: [UInt16:UInt16] = [:]
            indicesMap.reserveCapacity(inVertices.count)
            for vertexIndexInt in inVertices.indices {
                // Obtain the optimized vertexIndex for this vertex
                let vertexIndex: UInt16 = optimizedIndicies[vertexIndexInt]
                
                // Check our map to see if this vertex was already added
                if let index = indicesMap[vertexIndex] {
                    // Add the repeated index to the indices and continue to the next
                    self.vertexIndicies.append(index)
                    continue
                }
                
                let vertex = inVertices[vertexIndexInt]
                self.positions.append(contentsOf: vertex.position.valuesArray())
                self.normals.append(contentsOf: vertex.normal.valuesArray())
                uvSet1.append(contentsOf: vertex.uv1.valuesArray())
                uvSet2.append(contentsOf: vertex.uv2.valuesArray())
                self.tangents.append(contentsOf: vertex.tangent.valuesArray())
                self.colors.append(contentsOf: vertex.color.valuesArray())
                
                let index = UInt16(nextIndex)
                self.vertexIndicies.append(index)
                // Update the map
                indicesMap[vertexIndex] = index
                // Increment the next real indicies index
                nextIndex += 1
            }
        }
        self.uvSets = [uvSet1, uvSet2]
    }

    /// Creates a new `Geometry` by merging multiple geometry. This is usful for loading files that store geometry speretly base don material if you intend to only use a single material for them all.
    public init(byCombining geometries: [RawGeometry], withOptimization optimization: Optimization = .dontOptimize) {
        self.init(triangles: geometries.reduce(into: []) {$0.append(contentsOf: $1)}, optimization: optimization)
    }
    
    public init(verticies: VertexView) {
        self.vertices = verticies
    }
    
    public init() {
        self.vertices = VertexView()
    }
}

extension RawGeometry {
    var positions: [Float] {
        get {vertices.positions}
        set {vertices.positions = newValue}
    }
    var uvSets: [[Float]] {
        get {vertices.uvSets}
        set {vertices.uvSets = newValue}
    }
    var uvSet1: [Float] {
        get {vertices.uvSet1}
        set {vertices.uvSet1 = newValue}
    }
    var uvSet2: [Float] {
        get {vertices.uvSet2}
        set {vertices.uvSet2 = newValue}
    }
    var normals: [Float] {
        get {vertices.normals}
        set {vertices.normals = newValue}
    }
    var tangents: [Float] {
        get {vertices.tangents}
        set {vertices.tangents = newValue}
    }
    var colors: [Float] {
        get {vertices.colors}
        set {vertices.colors = newValue}
    }
    var vertexIndicies: [UInt16] {
        get {vertices.vertexIndicies}
        set {vertices.vertexIndicies = newValue}
    }
}

extension RawGeometry {
    public struct VertexView: Codable, Sendable, Equatable, Hashable {
        internal var positions: [Float]
        internal var uvSets: [[Float]]
        internal var uvSet1: [Float] {
            get {
                assert(self.uvSets.indices.contains(0), "Index \(0) out of range \(self.uvSets.indices)")
                return uvSets[0]
            }
            set {
                assert(self.uvSets.indices.contains(0), "Index \(0) out of range \(self.uvSets.indices)")
                uvSets[0] = newValue
            }
        }
        internal var uvSet2: [Float] {
            get {
                assert(self.uvSets.indices.contains(1), "Index \(1) out of range \(self.uvSets.indices)")
                return uvSets[1]
            }
            set {
                assert(self.uvSets.indices.contains(1), "Index \(1) out of range \(self.uvSets.indices)")
                uvSets[1] = newValue
            }
        }
        internal var normals: [Float]
        internal var tangents: [Float]
        internal var colors: [Float]
        internal var vertexIndicies: [UInt16]

        func uvSet(_ index: Int) -> [Float]? {
            guard index < uvSets.count else { return nil }
            return uvSets[index]
        }
        
        public func vertex(at i: Int) -> Vertex {
            assert(self.indices.contains(i), "Index \(i) out of range \(self.indices)")
            let index = Int(self.vertexIndicies[i])
            let start3 = index * 3
            let start2 = index * 2
            let start4 = index * 4
            
            return Vertex(
                px: positions[start3], py: positions[start3 + 1], pz: positions[start3 + 2],
                nx: normals[start3], ny: normals[start3 + 1], nz: normals[start3 + 2],
                tanX: tangents[start3], tanY: tangents[start3 + 1], tanZ: tangents[start3 + 2],
                tu1: uvSet1[start2], tv1: uvSet1[start2 + 1],
                tu2: uvSet2[start2], tv2: uvSet2[start2 + 1],
                cr: colors[start4], cg: colors[start4 + 1], cb: colors[start4 + 2], ca: colors[start4 + 3]
            )
        }
        
        public mutating func setVertex(_ vertex: Vertex, at i: Int) {
            if self.vertexIndicies.count(where: {$0 == self.vertexIndicies[i]}) == 1 {
                assert(self.indices.contains(i), "Index \(i) out of range \(self.indices)")
                let index = Int(self.vertexIndicies[i])
                let start3 = index * 3
                let start2 = index * 2
                let start4 = index * 4
                
                self.positions[start3 + 0] = vertex.position.x
                self.positions[start3 + 1] = vertex.position.y
                self.positions[start3 + 2] = vertex.position.z
                
                self.normals[start3 + 0] = vertex.normal.x
                self.normals[start3 + 1] = vertex.normal.y
                self.normals[start3 + 2] = vertex.normal.z
                
                self.tangents[start3 + 0] = vertex.tangent.x
                self.tangents[start3 + 1] = vertex.tangent.y
                self.tangents[start3 + 2] = vertex.tangent.z
                
                self.uvSet1[start2 + 0] = vertex.uv1.x
                self.uvSet1[start2 + 1] = vertex.uv1.y
                
                self.uvSet2[start2 + 0] = vertex.uv2.x
                self.uvSet2[start2 + 1] = vertex.uv2.y
                
                self.colors[start4 + 0] = vertex.color.red
                self.colors[start4 + 1] = vertex.color.green
                self.colors[start4 + 2] = vertex.color.blue
                self.colors[start4 + 3] = vertex.color.alpha
            }else if let existingIndex = self.firstIndex(of: vertex) {
                self.vertexIndicies[i] = self.vertexIndicies[existingIndex]
            }else{
                let newIndex = UInt16(self.positions.count / 3)
                if i == self.endIndex {
                    self.vertexIndicies.append(newIndex)
                }else{
                    assert(self.indices.contains(i), "Index \(i) out of range \(self.indices)")
                    self.vertexIndicies[i] = newIndex
                }
                
                self.positions.append(vertex.position.x)
                self.positions.append(vertex.position.y)
                self.positions.append(vertex.position.z)
                
                self.normals.append(vertex.normal.x)
                self.normals.append(vertex.normal.y)
                self.normals.append(vertex.normal.z)
                
                self.tangents.append(vertex.tangent.x)
                self.tangents.append(vertex.tangent.y)
                self.tangents.append(vertex.tangent.z)
                
                self.uvSets[0].append(vertex.uv1.x)
                self.uvSets[0].append(vertex.uv1.y)
                
                self.uvSets[1].append(vertex.uv2.x)
                self.uvSets[1].append(vertex.uv2.y)
                
                self.colors.append(vertex.color.red)
                self.colors.append(vertex.color.green)
                self.colors.append(vertex.color.blue)
                self.colors.append(vertex.color.alpha)
            }
        }
        
        public init(
            positions: [Float],
            uvSets: [[Float]],
            normals: [Float]?,
            tangents: [Float]?,
            colors: [Float]?,
            indexes: [UInt16]
        ) {
            self.positions = positions
            self.uvSets = uvSets
            if self.uvSets.count < 2 {
                let filler = [Float](repeating: 0, count: indexes.count * 2)
                for _ in uvSets.count ..< 2 {
                    self.uvSets.append(filler)
                }
            }
            self.normals = normals ?? Array(repeating: 0, count: indexes.count * 3)
            self.tangents = tangents ?? Array(repeating: 0, count: indexes.count * 3)
            
            var colors: [Float]! = colors
            if colors == nil {
                colors = Array(repeating: 0.5, count: indexes.count * 4)
                for index in stride(from: 3, to: colors.count, by: 4) {
                    colors[index] = 1
                }
            }
            self.colors = colors
            self.vertexIndicies = indexes
        }
        
        public init() {
            self.positions = []
            self.normals = []
            self.tangents = []
            self.uvSets = [[],[]]
            self.colors = []
            self.vertexIndicies = []
        }
    }
}

extension RawGeometry {
    public static func * (lhs: Self, rhs: Matrix4x4) -> Self {
        var copy = lhs
        for index in copy.indices {
            copy[index] = copy[index] * rhs
        }
        return copy
    }
    
    public static func *= (lhs: inout Self, rhs: Matrix4x4) {
        lhs = lhs * rhs
    }
}

extension RawGeometry.VertexView: RandomAccessCollection, MutableCollection, RangeReplaceableCollection {
    public typealias Element = Vertex
    public typealias Index = Int
    
    public var startIndex: Index {
        return self.vertexIndicies.startIndex
    }
    
    public var endIndex: Index {
        return self.vertexIndicies.endIndex
    }

    public func index(before i: Index) -> Index {
        return self.vertexIndicies.index(before: i)
    }
    
    public func index(after i: Index) -> Index {
        return self.vertexIndicies.index(after: i)
    }
    
    @discardableResult
    public mutating func remove(at i: Int) -> Vertex {
        assert(self.indices.contains(i), "Index \(i) out of range \(self.indices)")
        let vertex = self.vertex(at: i)
        if self.vertexIndicies.count(where: {$0 == self.vertexIndicies[i]}) > 1 {
            // If more then one exists, just remove the duplicate index
            self.vertexIndicies.remove(at: i)
        }else{
            let index = self.vertexIndicies[i]
            let start3 = Int(index) * 3
            let start2 = Int(index) * 2
            let start4 = Int(index) * 4
            
            self.positions.removeSubrange(start3 ..< start3 + 3)
            self.normals.removeSubrange(start3 ..< start3 + 3)
            self.tangents.removeSubrange(start3 ..< start3 + 3)
            self.uvSet1.removeSubrange(start2 ..< start2 + 2)
            self.uvSet2.removeSubrange(start2 ..< start2 + 2)
            self.colors.removeSubrange(start4 ..< start4 + 4)
            self.vertexIndicies.remove(at: i)
            
            // Decrement every index above the removed index
            self.vertexIndicies = self.vertexIndicies.map({$0 > index ? $0 - 1 : $0})
        }
        return vertex
    }
    
    public mutating func insert(_ vertex: Vertex, at i: Int, sacrificingPerformanceToOptimize optimize: Bool = false) {
        if optimize, let existing = self.firstIndex(of: vertex) {
            if i == self.endIndex {
                self.vertexIndicies.append(self.vertexIndicies[existing])
            }else{
                assert(self.indices.contains(i), "Index \(i) out of range \(self.indices)")
                self.vertexIndicies.insert(self.vertexIndicies[existing], at: i)
            }
        }else{
            let newIndex = UInt16(self.positions.count / 3)
            if i == self.endIndex {
                self.vertexIndicies.append(newIndex)
            }else{
                assert(self.indices.contains(i), "Index \(i) out of range \(self.indices)")
                self.vertexIndicies.insert(newIndex, at: i)
            }
            
            self.positions.append(vertex.position.x)
            self.positions.append(vertex.position.y)
            self.positions.append(vertex.position.z)
            
            self.normals.append(vertex.normal.x)
            self.normals.append(vertex.normal.y)
            self.normals.append(vertex.normal.z)
            
            self.tangents.append(vertex.tangent.x)
            self.tangents.append(vertex.tangent.y)
            self.tangents.append(vertex.tangent.z)
            
            self.uvSets[0].append(vertex.uv1.x)
            self.uvSets[0].append(vertex.uv1.y)
            
            self.uvSets[1].append(vertex.uv2.x)
            self.uvSets[1].append(vertex.uv2.y)
            
            self.colors.append(vertex.color.red)
            self.colors.append(vertex.color.green)
            self.colors.append(vertex.color.blue)
            self.colors.append(vertex.color.alpha)
        }
    }
    
    public subscript (index: Index) -> Element {
        get {
            assert(self.indices.contains(index), "Index \(index) out of range \(self.indices)")
            return self.vertex(at: index)
        }
        mutating set {
            assert(self.indices.contains(index), "Index \(index) out of range \(self.indices)")
            self.setVertex(newValue, at: index)
        }
    }
    
    public mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C) where C : Collection, Element == C.Element {
        for indices in zip(subrange, newElements.indices) {
            assert(self.indices.contains(indices.0), "Index \(indices.0) out of range \(self.indices)")
            self[indices.0] = newElements[indices.1]
        }
    }
    
    public mutating func reserveCapacity(_ n: Int) {
        self.positions.reserveCapacity(n * 3)
        self.normals.reserveCapacity(n * 3)
        self.tangents.reserveCapacity(n * 3)
        for index in self.uvSets.indices {
            self.uvSets[index].reserveCapacity(n * 2)
        }
        self.colors.reserveCapacity(n * 4)
    }
}

extension RawGeometry.VertexView: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Element
    
    public init(arrayLiteral elements: Element...) {
        self.init()
        self.reserveCapacity(elements.count)
        for element in elements {
            self.positions.append(element.position.x)
            self.positions.append(element.position.y)
            self.positions.append(element.position.z)
            
            self.normals.append(element.normal.x)
            self.normals.append(element.normal.y)
            self.normals.append(element.normal.z)
            
            self.tangents.append(element.tangent.x)
            self.tangents.append(element.tangent.y)
            self.tangents.append(element.tangent.z)
            
            self.uvSet1.append(element.uv1.x)
            self.uvSet1.append(element.uv1.y)
            
            self.uvSet2.append(element.uv2.x)
            self.uvSet2.append(element.uv2.y)
            
            self.colors.append(element.color.red)
            self.colors.append(element.color.green)
            self.colors.append(element.color.blue)
            self.colors.append(element.color.alpha)
        }
    }
}

extension RawGeometry: RandomAccessCollection, MutableCollection, RangeReplaceableCollection {
    public typealias Element = Triangle
    public typealias Index = Int
    
    public var startIndex: Index {
        return 0
    }
    
    public var endIndex: Index {
        return self.vertices.count / 3
    }

    public func index(before i: Index) -> Index {
        return i - 1
    }
    
    public func index(after i: Index) -> Index {
        return i + 1
    }
    
    public mutating func insert(_ triangle: Element, at i: Int) {
        let index = i * 3
        self.vertices.insert(triangle.v3, at: index)
        self.vertices.insert(triangle.v2, at: index)
        self.vertices.insert(triangle.v1, at: index)
    }
    
    @discardableResult
    public mutating func remove(at i: Int) -> Element {
        let index = i * 3
        let v1 = self.vertices.remove(at: index)
        let v2 = self.vertices.remove(at: index)
        let v3 = self.vertices.remove(at: index)
        return Triangle(v1: v1, v2: v2, v3: v3, repairIfNeeded: false)
    }
    
    public subscript (index: Index) -> Element {
        get {
            assert(self.indices.contains(index), "Index \(index) out of range \(self.indices)")
            return self.triangle(at: index)
        }
        mutating set {
            assert(self.indices.contains(index), "Index \(index) out of range \(self.indices)")
            self.setTriangle(newValue, at: index)
        }
    }
    
    public mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C) where C : Collection, Element == C.Element {
        for indices in zip(subrange, newElements.indices) {
            assert(self.indices.contains(indices.0), "Index \(indices.0) out of range \(self.indices)")
            self[indices.0] = newElements[indices.1]
        }
    }
    
    public mutating func reserveCapacity(_ n: Int) {
        self.vertices.reserveCapacity(n * 3)
    }
}

extension RawGeometry: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Element
    
    public init(arrayLiteral elements: Element...) {
        self.init(triangles: elements)
    }
}

extension RawGeometry: BinaryCodable {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try vertices.encode(into: &data, version: version)
    }
    
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        self.vertices = try .init(decoding: data, at: &offset, version: version)
    }
}

extension RawGeometry.VertexView: BinaryCodable {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try positions.encode(into: &data, version: version)
        try uvSets.encode(into: &data, version: version)
        try normals.encode(into: &data, version: version)
        try tangents.encode(into: &data, version: version)
        try colors.encode(into: &data, version: version)
        try vertexIndicies.encode(into: &data, version: version)
    }
    
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        self.positions = try .init(decoding: data, at: &offset, version: version)
        self.uvSets = try .init(decoding: data, at: &offset, version: version)
        self.normals = try .init(decoding: data, at: &offset, version: version)
        self.tangents = try .init(decoding: data, at: &offset, version: version)
        self.colors = try .init(decoding: data, at: &offset, version: version)
        self.vertexIndicies = try .init(decoding: data, at: &offset, version: version)
    }
}
