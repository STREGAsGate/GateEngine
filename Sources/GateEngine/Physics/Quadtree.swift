/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation
import GameMath

public final class Quadtree {
    public var center: Position2 {return rootNode.boundingBox.center}
    public var offset: Position2 {return rootNode.boundingBox.offset}
    public var size: Size2 {return rootNode.boundingBox.size}
    
    fileprivate let rootNode: Node
    internal lazy var leafNodes: [Quadtree.Node] = {
        return self.nodesNear(self.rootNode.boundingBox).filter({$0.isLeaf})
    }()
    
    public struct Location: Hashable {
        var depth: Int
        var position: Position2
    }
    
    public func colliders(inLayer layer: String) -> [Collider2D] {
        return colliders(near: rootNode.boundingBox, inLayer: layer)
    }
    
    public func colliders(hitBy ray: Ray2D, inLayer layer: String) -> [(point: Position2, collider: Collider2D)] {
        return rootNode.collidersHit(by: ray, inLayer: layer)
    }
    
    public func colliders(near box: AxisAlignedBoundingBox2D, inLayer layer: String) -> [Collider2D] {
        var colliders: [Collider2D] = []
        for node in self.nodesNear(box) {
            colliders.append(contentsOf: node.layer(named: layer).colliders)
        }
        return colliders
    }
    
    public func colliders(at position: Position2, depth: Int, inLayer layer: String) -> [Collider2D]? {
        return node(at: position, depth: depth)?.layer(named: layer).colliders
    }
    
    internal func boxesVisibleTo(leafOnly: Bool) -> [AxisAlignedBoundingBox2D] {
        var nodes = nodesNear(self.rootNode.boundingBox)
        if leafOnly {
            nodes = nodes.filter({$0.isLeaf})
        }
        
        return nodes.map{$0.boundingBox}
    }
    
    fileprivate func nodesNear(_ box: AxisAlignedBoundingBox2D) -> [Node] {
        guard rootNode.boundingBox.isColiding(with: box) else {
            print("No collision");
            return []
        }
        var nodes: [Node] = []
        if let children = rootNode.childrenNear(box) {
            nodes.append(contentsOf: children)
        }
        return nodes
    }
    
    private func node(at position: Position2, depth: Int) -> Node? {
        guard depth > 0 else {return rootNode.boundingBox.contains(position) ? rootNode : nil}
        
        var node: Node? = self.rootNode
        while node?.depth != depth && node != nil {
            node = node?.children?.first(where: {$0.boundingBox.contains(position)})
        }
        return node
    }
    
    public init(size: Size2, offset: Position2, position: Position2) {
        let maxDepth: Int = {
#if DEBUG && true
            return 1
#else
            return max(1, Int(ceil(size.max / 75.0)))
#endif
        }()
        
        func buildChildren(forBox boundingBox: AxisAlignedBoundingBox2D, depth: Int) -> [Node]? {
            guard depth < maxDepth else {return nil}
            var children: [Node] = []
            let center = boundingBox.center + boundingBox.offset
            
            for p in boundingBox.points() {
                let center = (p + center) / 2
                let box = AxisAlignedBoundingBox2D(center: center, radius: boundingBox.radius / 2)
                children.append(Node(depth: depth + 1, boundingBox: box, children: buildChildren(forBox: box, depth: depth + 1)))
            }
            assert(children.count == 4)
            return children
        }
        let box = AxisAlignedBoundingBox2D(center: position, offset: offset, radius: size / 2)
        self.rootNode = Node(depth: 0, boundingBox: box, children: buildChildren(forBox: box, depth: 0))
    }
    
    public func insertColliders(_ colliders: [Collider2D], intoLayer layer: String) {
        self.rootNode.insertColliders(colliders, intoLayer: layer)
    }
}

extension Quadtree {
    final class Node {
        let depth: Int
        let boundingBox: AxisAlignedBoundingBox2D
        let children: [Node]?
        var layers: [Quadtree.Node.Layer]
        func layer(named name: String) -> Quadtree.Node.Layer {
            if let reality = layers.first(where: {$0.name == name}) {
                return reality
            }
            let layer = Quadtree.Node.Layer(name: name)
            layers.append(layer)
            return layer
        }
        
        var isLeaf: Bool {
            return children == nil
        }
        
        init(depth: Int, boundingBox: AxisAlignedBoundingBox2D, children: [Node]?) {
            self.depth = depth
            self.boundingBox = boundingBox
            self.children = children
            self.layers = []
        }
        
        func childrenNear(_ box: AxisAlignedBoundingBox2D) -> [Node]? {
            guard let children = self.children else {return nil}
            
            var nodes: [Node] = []
            for child in children {
                guard child.boundingBox.isColiding(with: box) else {continue}
                if child.isLeaf {
                    nodes.append(child)
                    if child.boundingBox.contains(box) {
                        break
                    }
                }else if let children = child.childrenNear(box) {
                    nodes.append(contentsOf: children)
                }
            }
            return nodes
        }
        
        func collidersHit(by ray: Ray2D, inLayer layer: String) -> [(point: Position2, collider: Collider2D)] {
            var hits: [(point: Position2, collider: Collider2D)] = []
            if self.isLeaf {
                for collider in self.layer(named: layer).colliders {
                    if let intersection = collider.surfacePoint(for: ray) {
                        hits.append((intersection, collider))
                    }
                }
            }
            
            guard let sortedChildren = self.children?.sorted(by: { (lhs, rhs) -> Bool in
                let d1 = lhs.boundingBox.center.distance(from: ray.origin)
                let d2 = rhs.boundingBox.center.distance(from: ray.origin)
                return d1 < d2
            }) else {return hits}
            
            for node in sortedChildren {
                let colliders = node.collidersHit(by: ray, inLayer: layer)
                if colliders.isEmpty == false {
                    hits.append(contentsOf: colliders)
                    break
                }
            }
            return hits
        }
        
        func insertColliders(_ colliders: [Collider2D], intoLayer layer: String) {
            if self.isLeaf {
                let layer = self.layer(named: layer)
                for collider in colliders {
//                    guard self.boundingBox.interpenetration(comparing: collider)?.isColiding == true else {continue}
                    layer.appendCollider(collider)
                }
            }else{
                if let children = children {
                    for child in children {
                        child.insertColliders(colliders, intoLayer: layer)
                    }
                }
            }
        }
    }
}

extension Quadtree.Node {
    final class Layer {
        let name: String
        var colliders: [Collider2D] = []
        
        func appendCollider(_ collider: Collider2D) {
            self.colliders.append(collider)
        }
        
        internal init(name: String) {
            self.name = name
        }
    }
}
