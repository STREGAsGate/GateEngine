/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public import Collections

public typealias PathFinding3f = PathFinding3n<Float32>
public typealias PathFinding3d = PathFinding3n<Float64>

/// A type that can trace a path through a graph of known positions. Based on the A-Star algorithm.
public struct PathFinding3n<Scalar: Vector3n.ScalarType & FloatingPoint & Comparable> {
    @usableFromInline
    internal var graph: OrderedSet<Node>
    
    public var linkDistance: Scalar
    
    /**
     Build an empty PathFinding3 graph, to be populated later.
     - parameter manhatanDistance: A distance value checked against each axis (x,y,z) of each node. Nodes within the distance are linked together in the graph
     */
    public init(linkDistance manhatanDistance: Scalar) {
        self.linkDistance = manhatanDistance
        self.graph = []
    }
    
    /**
     Build a graph from provided positions linking any withing the provided distance
     - parameter positions: The unique unordered positions of the nodes
     - parameter manhatanDistance: A distance value checked against each axis (x,y,z) of each node. Nodes within the distance are linked together in the graph
     */
    public init(positions: [Position3n<Scalar>], linkedWithin manhatanDistance: Scalar) {
        self.init(linkDistance: manhatanDistance)
        
        for position in positions {
            self.insert(position)
        }
    }
    
    @discardableResult
    public mutating func insert(_ position: Position3n<Scalar>) -> Index {
        var node1 = Node(position: position)
        let result = graph.append(node1)
        let node1Index = result.index
        if result.inserted {
            for node2Index in self.indices {
                guard node2Index != node1Index else {continue}
                
                var node2 = self[node2Index]
                guard Swift.abs(node1.position.x - node2.position.x) <= linkDistance else {continue}
                guard Swift.abs(node1.position.y - node2.position.y) <= linkDistance else {continue}
                guard Swift.abs(node1.position.z - node2.position.z) <= linkDistance else {continue}
                
                let distance = node1.position.distance(from: node2.position)
                node1.children.insert(.init(index: node2Index, distance: distance))
                node2.children.insert(.init(index: node1Index, distance: distance))
                self.graph.update(node2, at: node2Index)
            }
            self.graph.update(node1, at: node1Index)
        }
        return node1Index
    }
}

extension PathFinding3n {
    public func nearestNodes(to position: Position3n<Scalar>, withinRadius: Scalar? = nil) -> [Index] {
        let sortNodes: [(index: Index, distance: Scalar)] = self.indices.map({ index in
            let node = self[index]
            return (index: index, distance: node.position.distance(from: position))
        }).sorted(by: {$0.distance < $1.distance})
        return sortNodes.compactMap({
            if let radius = withinRadius {
                if $0.distance > radius {
                    return nil
                }
            }
            return $0.index
        })
    }
    
    public func path(from startIndex: Index, to goalIndex: Index) -> [Index]? {
        precondition(self.indices.contains(startIndex), "Index out of range.")
        precondition(self.indices.contains(goalIndex), "Index out of range.")
        
        // The node we want to reach
        let goalNode = self[goalIndex]
        
        // A collection of pairs where the key is the desired node,
        // and the value is the previous node traveled (its parent in the path)
        var parents: Dictionary<Index, Index> = [:]
        
        // A list of nodes that could be valid for the path
        var openList: Deque<PathNode> = [
            PathNode(index: startIndex, hCost: 0) // Start Node
        ]
        // A list of nodes that have already been checked
        var visited: Set<Index> = []
        
        // A list of gScores for checked nodes
        var gScores: Dictionary<Index, Scalar> = [
            startIndex: 0 // Give the start node a zero gScore
        ]
        
        while openList.isEmpty == false {
            let currentPathNode = openList.removeFirst()
            
            // Build the path if we reached the end
            if currentPathNode.index == goalIndex {
                var path: [Index] = []
                var currentIndex: Array<Node>.Index? = currentPathNode.index
                while let _currentIndex = currentIndex {
                    path.append(_currentIndex)
                    currentIndex = parents[_currentIndex]
                }
                assert(path.last == startIndex && path.first == goalIndex)
                return path.reversed()
            }
            
            // mark current node as visited
            visited.insert(currentPathNode.index)
            
            let currentGraphNode = self[currentPathNode.index]
            
            for child in currentGraphNode.children {
                // Don't check already visited nodes
                guard visited.contains(child.index) == false else { continue }
                
                let currentGraphNodeChild = self[child.index]
                
                let gCost = gScores[currentPathNode.index, default: .infinity] + child.distance
                let gCostChild = gScores[child.index, default: .infinity]
                
                if gCost < gCostChild {
                    gScores[child.index] = gCost
                    
                    let gCost: Scalar = gCost
                    let fCost: Scalar = // Manhattan distance
                    Swift.abs(currentGraphNodeChild.position.x - goalNode.position.x) +
                    Swift.abs(currentGraphNodeChild.position.y - goalNode.position.y) +
                    Swift.abs(currentGraphNodeChild.position.z - goalNode.position.z)
                    let hCost = gCost + fCost
                    
                    let pathNode = PathNode(
                        index: child.index,
                        hCost: hCost
                    )
                    
                    // Keep openList sorted by hCost
                    if let index = openList.firstIndex(where: {hCost < $0.hCost}) {
                        openList.insert(pathNode, at: index)
                    }else{
                        openList.append(pathNode)
                    }
                    
                    parents[child.index] = currentPathNode.index
                }
            }
        }
        
        // No path found
        return nil
    }
}

extension PathFinding3n {
    public struct Node: Equatable, Hashable {
        public let position: Position3n<Scalar>
        public var children: Set<Child>
        public struct Child: Equatable, Hashable {
            public let index: Index
            public let distance: Scalar
            
            public init(index: Index, distance: Scalar) {
                self.index = index
                self.distance = distance
            }
            
            public static func == (lhs: Self, rhs: Self) -> Bool {
                return lhs.index == rhs.index
            }
            public func hash(into hasher: inout Hasher) {
                hasher.combine(index)
            }
        }
        
        public init(position: Position3n<Scalar>, children: Set<Child> = []) {
            self.position = position
            self.children = children
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.position == rhs.position
        }
    }
    
    struct PathNode {
        let index: Index
        var hCost: Scalar
        
        init(index: Index, hCost: Scalar) {
            self.index = index
            self.hCost = hCost
        }
    }
}

extension PathFinding3n: RandomAccessCollection {
    public typealias Index = Int
    public typealias Element = Node
    
    @inlinable
    public var startIndex: Index {
        return 0
    }
    
    @inlinable
    public var endIndex: Index {
        if graph.isEmpty {
            return startIndex
        }
        return graph.count
    }
    
    @inlinable
    public subscript(index: Index) -> Node {
        nonmutating get {
            return graph[index]
        }
    }
}
