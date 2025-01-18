/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Octree: Codable {
    var center: Position3 { return rootNode.boundingBox.center }
    var size: Size3 { return rootNode.boundingBox.size }

    fileprivate var rootNode: Node
    internal lazy var leafNodes: [Octree.Node] = {
        return self.nodesNear(self.rootNode.boundingBox, visibleTo: nil).filter({ $0.isLeaf })
    }()

    public struct Location: Hashable {
        var depth: Int
        var position: Position3
    }

    public func trianglesHit(by ray: Ray3D) -> [(point: Position3, triangle: CollisionTriangle)] {
        return rootNode.trianglesHit(by: ray)
    }

    public func trianglesNear(
        _ box: AxisAlignedBoundingBox3D,
        visibleTo frustum: ViewFrustum3D? = nil
    ) -> [CollisionTriangle] {
        var triangles: [CollisionTriangle] = []
        for node in self.nodesNear(box, visibleTo: frustum) {
            triangles.append(contentsOf: node.collisionTriangles)
        }
        return triangles
    }

    public func triangles(at position: Position3, depth: Int) -> [CollisionTriangle]? {
        return node(at: position, depth: depth)?.collisionTriangles
    }

    internal func boxesVisibleTo(_ frustum: ViewFrustum3D, leafOnly: Bool)
        -> [AxisAlignedBoundingBox3D]
    {
        var nodes = nodesNear(self.rootNode.boundingBox, visibleTo: frustum)
        if leafOnly {
            nodes = nodes.filter({ $0.isLeaf })
        }

        return nodes.map { $0.boundingBox }
    }

    fileprivate func nodesNear(_ box: AxisAlignedBoundingBox3D, visibleTo frustum: ViewFrustum3D?)
        -> [Node]
    {
        guard rootNode.boundingBox.isColiding(with: box) else {
            Log.debug("No collision")
            return []
        }
        var nodes: [Node] = []
        if let children = rootNode.childrenNear(box, visibleTo: frustum) {
            nodes.append(contentsOf: children)
        }
        return nodes
    }

    private func node(at position: Position3, depth: Int) -> Node? {
        guard depth > 0 else { return rootNode.boundingBox.contains(position) ? rootNode : nil }

        var node: Node? = self.rootNode
        while node?.depth != depth && node != nil {
            node = node?.children?.first(where: { $0.boundingBox.contains(position) })
        }
        return node
    }

    public init(size: Size3, offset: Position3, position: Position3) {
        let maxDepth: Int = {
            #if DEBUG
            return 1
            #else
            return max(1, Int(ceil(size.max / 25)))
            #endif
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
            boundingBox: box,
            children: buildChildren(forBox: box, depth: 0)
        )
    }

    func insertTriangles(_ triangles: [CollisionTriangle]) {
        self.rootNode.insertTriangles(triangles)
    }
}

extension Octree {
    struct Node: Codable {
        let depth: Int
        let boundingBox: AxisAlignedBoundingBox3D
        var children: [Node]?

        var collisionTriangles: [CollisionTriangle]
        @_transparent
        mutating func appendTriangle(_ triangle: CollisionTriangle) {
            self.collisionTriangles.append(triangle)
        }

        @_transparent
        var isLeaf: Bool {
            return children == nil
        }

        init(depth: Int, boundingBox: AxisAlignedBoundingBox3D, children: [Node]?) {
            self.depth = depth
            self.boundingBox = boundingBox
            self.children = children
            self.collisionTriangles = []
        }

        @inline(__always)
        func childrenNear(_ box: AxisAlignedBoundingBox3D, visibleTo frustum: ViewFrustum3D?)
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

        @inline(__always)
        func trianglesHit(by ray: Ray3D) -> [(point: Position3, triangle: CollisionTriangle)] {
            var hits: [(point: Position3, triangle: CollisionTriangle)] = []
            if self.isLeaf {
                for triangle in self.collisionTriangles {
                    if let intersection = triangle.surfacePoint(for: ray) {
                        hits.append((intersection, triangle))
                    }
                }
            }

            guard
                let sortedChildren = self.children?.sorted(by: { (lhs, rhs) -> Bool in
                    let d1 = lhs.boundingBox.center.distance(from: ray.origin)
                    let d2 = rhs.boundingBox.center.distance(from: ray.origin)
                    return d1 < d2
                })
            else { return hits }

            for node in sortedChildren {
                let triangles = node.trianglesHit(by: ray)
                if triangles.isEmpty == false {
                    hits.append(contentsOf: triangles)
                    break
                }
            }
            return hits
        }

        @inline(__always)
        mutating func insertTriangles(_ triangles: [CollisionTriangle]) {
            if self.isLeaf {
                for triangle in triangles {
                    //                    if boundingBox.isColiding(with: AxisAlignedBoundingBox3D(triangle.positions)) {
                    self.appendTriangle(triangle)
                    //                    }
                }
            } else {
                if let children = children {
                    for index in children.indices {
                        self.children![index].insertTriangles(triangles)
                    }
                }
            }
        }
    }
}
