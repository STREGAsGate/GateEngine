/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import func Foundation.floor
import GameMath

public extension OctreeComponent {
    func load(_ path: String, options: GeometryImporterOptions = .none, center: Position3) async throws {
        self.load(withCenter: center, triangles: try await RawGeometry(path: path).generateCollisionTrianges())
    }
}

extension OctreeComponent {
    @inline(__always)
    func trianglesHit(by ray: Ray3D, filter: ((CollisionTriangle)->Bool)? = nil) -> [(position: Position3, triangle: CollisionTriangle)] {
        return rootNode.trianglesHit(by: ray, filter: filter)
    }
    
    @inline(__always)
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
    @inline(__always)
    var center: Position3 {return rootNode.boundingBox.center}
    @inline(__always)
    var size: Size3 {return rootNode.boundingBox.size}

    var rootNode: Node! = nil
    lazy var leafNodes: [Node] = {
        return self.nodesNear(self.rootNode.boundingBox).filter({$0.isLeaf})
    }()
    
    @inline(__always)
    var boundingBox: AxisAlignedBoundingBox3D {
        return rootNode.boundingBox
    }
    
    struct Location: Hashable {
        var depth: Int
        var position: Position3
    }
    
    public required init() {}
    public static var componentID: ComponentID = ComponentID()
}

// MARK: - Helpers
private extension OctreeComponent {
    @_transparent
    func boxesVisibleTo(_ frustum: ViewFrustum3D, leafOnly: Bool) -> [AxisAlignedBoundingBox3D] {
        var nodes = nodesNear(self.rootNode.boundingBox, visibleTo: frustum)
        if leafOnly {
            nodes = nodes.filter({$0.isLeaf})
        }
        
        return nodes.map{$0.boundingBox}
    }
    
    @_transparent
    func nodesNear(_ box: AxisAlignedBoundingBox3D, visibleTo frustum: ViewFrustum3D? = nil) -> [Node] {
        guard rootNode.boundingBox.isColiding(with: box) else {print("No collision"); return []}
        var nodes: [Node] = []
        if let children = rootNode.childrenNear(box) {
            nodes.append(contentsOf: children)
        }
        return nodes
    }
    
    @_transparent
    func nodesHit(by ray: Ray3D) -> [Node] {
        guard rootNode.boundingBox.isColiding(with: ray) else {print("No collision"); return []}
        var nodes: [Node] = []
        if let children = rootNode.childrenHit(by: ray) {
            nodes.append(contentsOf: children)
        }
        return nodes
    }
    
    @_transparent
    func node(at position: Position3, depth: Int) -> Node? {
        guard depth > 0 else {return rootNode.boundingBox.contains(position) ? rootNode : nil}
        
        var node: Node? = self.rootNode
        while node?.depth != depth && node != nil {
            node = node?.children?.first(where: {$0.boundingBox.contains(position)})
        }
        return node
    }
}

// MARK: - Setup
internal extension OctreeComponent {
    @inline(__always)
    func insertTriangles(_ triangles: [CollisionTriangle], boxes: [AxisAlignedBoundingBox3D]) {
        self.rootNode.insertTriangles(triangles, boxes)
    }
    
    @inline(__always)
    func load(withCenter center: Position3, triangles: [CollisionTriangle]) {
        struct Primer {
            let center: Position3
            private(set) var triangles: [CollisionTriangle] = []
            private(set) var triangleBoxes: [AxisAlignedBoundingBox3D] = []
            lazy private(set) var boundingBox: AxisAlignedBoundingBox3D = AxisAlignedBoundingBox3D(center: center, offset: .zero, radius: .one)
            
            init(center: Position3) {
                self.center = center
            }
            
            mutating func insertTriangles(_ triangles: [CollisionTriangle]) {
                guard triangles.isEmpty == false else {return}
                
                var convertedTriangles: [CollisionTriangle] = []
                convertedTriangles.reserveCapacity(triangles.count)
                var boundingBoxes: [AxisAlignedBoundingBox3D] = []
                boundingBoxes.reserveCapacity(triangles.count)

                for triangle in triangles {
                    let convertedTriangle = triangle + center
                    let triangleBox = AxisAlignedBoundingBox3D(convertedTriangle.positions)
                    boundingBoxes.append(triangleBox)
                    self.boundingBox = self.boundingBox.expandedToEnclose(triangleBox)
                    convertedTriangles.append(convertedTriangle)
                }
                self.triangles.append(contentsOf: convertedTriangles)
                self.triangleBoxes.append(contentsOf: boundingBoxes)
            }
        }
        var primer = Primer(center: center)
        
        primer.insertTriangles(triangles)
        
        self.setup(size: primer.boundingBox.size + Size3(0.1), offset: primer.boundingBox.offset, position: primer.boundingBox.center)
        
        self.rootNode.insertTriangles(primer.triangles, primer.triangleBoxes)

        self.cleanEmptyNodes()
    }
    
    @inline(__always)
    private func setup(size: Size3, offset: Position3, position: Position3) {
        let maxDepth: Int = {
            return max(1, min(4, Int(floor(size.max / 150))))
        }()

        func buildChildren(forBox boundingBox: AxisAlignedBoundingBox3D, depth: Int) -> [Node]? {
            guard depth < maxDepth else {return nil}
            var children: [Node] = []
            let center = boundingBox.center + boundingBox.offset
            
            for p in boundingBox.points() {
                let center = (p + center) / 2
                let box = AxisAlignedBoundingBox3D(center: center, radius: boundingBox.radius / 2)
                children.append(Node(depth: depth + 1, maxDepth: maxDepth, boundingBox: box, children: buildChildren(forBox: box, depth: depth + 1)))
            }
            assert(children.count == 8)
            return children
        }
        let box = AxisAlignedBoundingBox3D(center: position, offset: offset, radius: size / 2)
        self.rootNode = Node(depth: 0, maxDepth: maxDepth, boundingBox: box, children: buildChildren(forBox: box, depth: 0))
    }
    
    @inline(__always)
    private func cleanEmptyNodes() {
        var checkes = 0
        func removeAnyNode() -> Bool {
            func removeChildIfNeeded(of node: Node) -> Bool {
                checkes += 1
                guard node.children != nil else {return false}
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
        while removeAnyNode() {removed += 1}
        print("Octree nodes cleaned: \(removed), checkes: \(checkes)")
    }
}

extension OctreeComponent {
    @usableFromInline
    final class Node: Codable {
        let depth: Int
        let maxDepth: Int
        fileprivate(set) var boundingBox: AxisAlignedBoundingBox3D
        var children: [Node]?
        
        var collisionTriangles: [CollisionTriangle]
        func appendTriangle(_ triangle: CollisionTriangle) {
            if self.collisionTriangles.contains(triangle) == false {
                self.collisionTriangles.append(triangle)
            }
        }
        
        @inline(__always)
        var isLeaf: Bool {
            return hasChildren == false
        }
        
        @inline(__always)
        var hasContent: Bool {
            return collisionTriangles.isEmpty == false
        }
        
        @inline(__always)
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
        
        @inline(__always)
        func childrenHit(by ray: Ray3D) -> [Node]? {
            guard let children = self.children else {return nil}
            
            var nodes: [Node] = []
            for child in children {
                guard child.boundingBox.isColiding(with: ray) else {continue}
                if child.isLeaf {
                    nodes.append(child)
                }else if let children = child.childrenHit(by: ray) {
                    nodes.append(contentsOf: children)
                }
            }
            return nodes
        }
        
        @inline(__always)
        func childrenNear(_ box: AxisAlignedBoundingBox3D, visibleTo frustum: ViewFrustum3D? = nil) -> [Node]? {
            guard let children = self.children else {return nil}
            
            var nodes: [Node] = []
            for child in children {
                guard child.boundingBox.isColiding(with: box) else {continue}
                guard frustum?.canSeeBox(child.boundingBox) ?? true else {continue}
                if child.isLeaf {
                    nodes.append(child)
                    if child.boundingBox.contains(box) {
                        break
                    }
                }else if let children = child.childrenNear(box, visibleTo: frustum) {
                    nodes.append(contentsOf: children)
                }
            }
            return nodes
        }
        
        @inline(__always)
        func trianglesHit(by ray: Ray3D, filter: ((CollisionTriangle)->Bool)?) -> [(position: Position3, triangle: CollisionTriangle)] {
            var hits: [(position: Position3, triangle: CollisionTriangle)] = []
            guard self.boundingBox.isColiding(with: ray) else {return  hits}
            
            if self.isLeaf {
                for triangle in self.collisionTriangles {
                    guard filter?(triangle) ?? true else {continue}
                    if let intersection = triangle.surfacePoint(for: ray) {
                        hits.append((intersection, triangle))
                    }
                }
            }
            
            guard let children = self.children else {return hits}
            
            for node in children {
                let triangles = node.trianglesHit(by: ray, filter: filter)
                if triangles.isEmpty == false {
                    hits.append(contentsOf: triangles)
                }
            }
            return hits
        }
        
        @inline(__always)
        func insertTriangles(_ triangles: [CollisionTriangle], _ boxes: [AxisAlignedBoundingBox3D]) {
            if self.isLeaf {
                for index in triangles.indices {
                    if boundingBox.isColiding(with: boxes[index]) {
                        self.appendTriangle(triangles[index])
                    }
                }
            }else{
                if let children = children {
                    for child in children {
                        child.insertTriangles(triangles, boxes)
                    }
                }
            }
        }
    }
}
