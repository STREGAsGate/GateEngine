/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

import func Foundation.floor

extension OctreeComponent {
    @inlinable
    @_disfavoredOverload
    public func load(
        path: GeoemetryPath,
        options: GeometryImporterOptions = .none,
        center: Position3
    ) async throws {
        try await self.load(path: path.value, options: options, center: center)
    }
    public func load(path: String, options: GeometryImporterOptions = .none, center: Position3)
        async throws
    {
        self.load(
            withCenter: center,
            triangles: try await RawGeometry(path: path).generateCollisionTriangles()
        )
    }
}

public extension OctreeComponent {
    func trianglesHit(by ray: Ray3D, filter: ((CollisionTriangle) -> Bool)? = nil) -> [(
        position: Position3, triangle: CollisionTriangle
    )] {
        return rootNode.trianglesHit(by: ray, filter: filter)
    }

    func trianglesNear(_ box: AxisAlignedBoundingBox3D) -> [CollisionTriangle] {
        var triangles: [CollisionTriangle] = []
        for node in self.nodesNear(box) {
            triangles.append(contentsOf: node.collisionTriangles)
        }
        return triangles
    }

    //    func triangles(at position: Position3, depth: Int, inReality reality: String) -> [CollisionTriangle]? {
    //        return node(at: position, depth: depth)?.reality(named: reality).collisionTriangles
    //    }
}

public final class OctreeComponent: Component {
    public private(set) var didLoad: Bool = false
    @usableFromInline
    var center: Position3 { return rootNode.boundingBox.center }
    @usableFromInline
    var size: Size3 { return rootNode.boundingBox.size }

    @usableFromInline
    var rootNode: Node! = nil
    lazy var leafNodes: [Node] = {
        return self.nodesNear(self.rootNode.boundingBox).filter({ $0.isLeaf })
    }()

    @inlinable
    public var boundingBox: AxisAlignedBoundingBox3D {
        return rootNode.boundingBox
    }

    struct Location: Hashable {
        var depth: Int
        var position: Position3
    }

    public required init() {}
    public static let componentID = ComponentID()
}

// MARK: - Helpers
extension OctreeComponent {
    fileprivate func boxesVisibleTo(_ frustum: ViewFrustum3D, leafOnly: Bool)
        -> [AxisAlignedBoundingBox3D]
    {
        var nodes = nodesNear(self.rootNode.boundingBox, visibleTo: frustum)
        if leafOnly {
            nodes = nodes.filter({ $0.isLeaf })
        }

        return nodes.map { $0.boundingBox }
    }

    fileprivate func nodesNear(
        _ box: AxisAlignedBoundingBox3D,
        visibleTo frustum: ViewFrustum3D? = nil
    ) -> [Node] {
        guard rootNode.boundingBox.isColiding(with: box) else {
            Log.debug("No collision")
            return []
        }
        var nodes: [Node] = []
        if let children = rootNode.childrenNear(box) {
            nodes.append(contentsOf: children)
        }
        return nodes
    }

    fileprivate func nodesHit(by ray: Ray3D) -> [Node] {
        guard rootNode.boundingBox.isColiding(with: ray) else {
            Log.debug("No collision")
            return []
        }
        var nodes: [Node] = []
        if let children = rootNode.childrenHit(by: ray) {
            nodes.append(contentsOf: children)
        }
        return nodes
    }

    fileprivate func node(at position: Position3, depth: Int) -> Node? {
        guard depth > 0 else { return rootNode.boundingBox.contains(position) ? rootNode : nil }

        var node: Node? = self.rootNode
        while node?.depth != depth && node != nil {
            node = node?.children?.first(where: { $0.boundingBox.contains(position) })
        }
        return node
    }
}

// MARK: - Setup
extension OctreeComponent {
    func insertTriangles(_ triangles: [CollisionTriangle], boxes: [AxisAlignedBoundingBox3D]) {
        self.rootNode.insertTriangles(triangles, boxes)
    }

    public func load(withCenter center: Position3, triangles: [CollisionTriangle]) {
        struct Primer {
            let center: Position3
            private(set) var triangles: [CollisionTriangle] = []
            private(set) var triangleBoxes: [AxisAlignedBoundingBox3D] = []
            var boundingBox: AxisAlignedBoundingBox3D! = nil

            init(center: Position3) {
                self.center = center
            }

            mutating func insertTriangles(_ triangles: [CollisionTriangle]) {
                guard triangles.isEmpty == false else { return }

                var convertedTriangles: [CollisionTriangle] = []
                convertedTriangles.reserveCapacity(triangles.count)
                var boundingBoxes: [AxisAlignedBoundingBox3D] = []
                boundingBoxes.reserveCapacity(triangles.count)

                for triangle in triangles {
                    let convertedTriangle = triangle + center
                    let triangleBox = AxisAlignedBoundingBox3D(convertedTriangle.positions)
                    boundingBoxes.append(triangleBox)
                    self.boundingBox = self.boundingBox?.expandedToEnclose(triangleBox) ?? triangleBox
                    convertedTriangles.append(convertedTriangle)
                }
                self.triangles.append(contentsOf: convertedTriangles)
                self.triangleBoxes.append(contentsOf: boundingBoxes)
            }
        }
        var primer = Primer(center: center)

        primer.insertTriangles(triangles)

        self.setup(
            size: primer.boundingBox.size + Size3(0.01),
            offset: primer.boundingBox.offset,
            position: primer.boundingBox.center
        )

        self.rootNode.insertTriangles(primer.triangles, primer.triangleBoxes)

        self.cleanEmptyNodes()
        
        self.didLoad = true
    }

    private func setup(size: Size3, offset: Position3, position: Position3) {
        let maxDepth: Int = {
            return max(1, min(4, Int(floor(size.max / 150))))
        }()

        func buildChildren(forBox boundingBox: AxisAlignedBoundingBox3D, depth: Int) -> [Node]? {
            guard depth < maxDepth else { return nil }
            var children: [Node] = []
            let center = boundingBox.center + boundingBox.offset

            for p in boundingBox.points() {
                let center = (p + center) / 2
                let box = AxisAlignedBoundingBox3D(center: center, radius: boundingBox.radius / 2)
                children.append(
                    Node(
                        depth: depth + 1,
                        maxDepth: maxDepth,
                        boundingBox: box,
                        children: buildChildren(forBox: box, depth: depth + 1)
                    )
                )
            }
            assert(children.count == 8)
            return children
        }
        let box = AxisAlignedBoundingBox3D(center: position, offset: offset, radius: size / 2)
        self.rootNode = Node(
            depth: 0,
            maxDepth: maxDepth,
            boundingBox: box,
            children: buildChildren(forBox: box, depth: 0)
        )
    }

    private func cleanEmptyNodes() {
        var checks = 0
        func removeAnyNode() -> Bool {
            func removeChildIfNeeded(of node: Node) -> Bool {
                checks += 1
                guard node.children != nil else { return false }
                for index in node.children!.indices {
                    let child = node.children![index]

                    if child.isLeaf && child.hasContent == false {
                        node.children!.remove(at: index)
                        if node.children!.isEmpty {
                            node.children = nil
                        }
                        return true
                    }

                    if removeChildIfNeeded(of: child) {
                        return true
                    }
                }
                return false
            }
            return removeChildIfNeeded(of: rootNode)
        }
        var removed = 0
        while removeAnyNode() { removed += 1 }
        Log.debug("Octree nodes cleaned: \(removed), checks: \(checks)")
    }
}

extension OctreeComponent {
    @usableFromInline
    final class Node: Codable {
        let depth: Int
        let maxDepth: Int
        @usableFromInline
        fileprivate(set) var boundingBox: AxisAlignedBoundingBox3D
        @usableFromInline
        var children: [Node]?

        @usableFromInline
        var collisionTriangles: [CollisionTriangle]
        func appendTriangle(_ triangle: CollisionTriangle) {
            if self.collisionTriangles.contains(triangle) == false {
                self.collisionTriangles.append(triangle)
            }
        }

        @inlinable
        var isLeaf: Bool {
            return hasChildren == false
        }

        @inlinable
        var hasContent: Bool {
            return collisionTriangles.isEmpty == false
        }

        @inlinable
        var hasChildren: Bool {
            return children?.isEmpty == false
        }

        init(depth: Int, maxDepth: Int, boundingBox: AxisAlignedBoundingBox3D, children: [Node]?) {
            self.depth = depth
            self.maxDepth = maxDepth
            self.boundingBox = boundingBox
            self.children = children
            self.collisionTriangles = []
        }

        func childrenHit(by ray: Ray3D) -> [Node]? {
            guard let children = self.children else { return nil }

            var nodes: [Node] = []
            for child in children {
                guard child.boundingBox.isColiding(with: ray) else { continue }
                if child.isLeaf {
                    nodes.append(child)
                } else if let children = child.childrenHit(by: ray) {
                    nodes.append(contentsOf: children)
                }
            }
            return nodes
        }

        func childrenNear(_ box: AxisAlignedBoundingBox3D, visibleTo frustum: ViewFrustum3D? = nil)
            -> [Node]?
        {
            guard let children = self.children else { return nil }

            var nodes: [Node] = []
            for child in children {
                guard child.boundingBox.isColiding(with: box) else { continue }
                guard frustum?.canSeeBox(child.boundingBox) ?? true else { continue }
                if child.isLeaf {
                    nodes.append(child)
                    if child.boundingBox.contains(box) {
                        break
                    }
                } else if let children = child.childrenNear(box, visibleTo: frustum) {
                    nodes.append(contentsOf: children)
                }
            }
            return nodes
        }

        func trianglesHit(by ray: Ray3D, filter: ((CollisionTriangle) -> Bool)?) -> [(
            position: Position3, triangle: CollisionTriangle
        )] {
            var hits: [(position: Position3, triangle: CollisionTriangle)] = []
            guard self.boundingBox.isColiding(with: ray) else { return hits }

            if self.isLeaf {
                for triangle in self.collisionTriangles {
                    guard filter?(triangle) ?? true else { continue }
                    if let intersection = triangle.surfacePoint(for: ray) {
                        hits.append((intersection, triangle))
                    }
                }
            }

            guard let children = self.children else { return hits }

            for node in children {
                let triangles = node.trianglesHit(by: ray, filter: filter)
                if triangles.isEmpty == false {
                    hits.append(contentsOf: triangles)
                }
            }
            return hits
        }

        func insertTriangles(_ triangles: [CollisionTriangle], _ boxes: [AxisAlignedBoundingBox3D])
        {
            if self.isLeaf {
                for index in triangles.indices {
                    if boundingBox.isColiding(with: boxes[index]) {
                        self.appendTriangle(triangles[index])
                    }
                }
            } else {
                if let children = children {
                    for child in children {
                        child.insertTriangles(triangles, boxes)
                    }
                }
            }
        }
    }
}
