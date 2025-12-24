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
    
    /// A distance value checked against each individual axis (x,y,z) of each node. Nodes within the distance are linked together in the graph.
    /// - note: This value is only used when inserting a new position into the graph
    public var linkDistance: Scalar
    
    /// A closure to fine tune graph node linking. Return `true` if the two nodes should be linked.
    public typealias LinkValidator = (Position3n<Scalar>, Position3n<Scalar>) -> Bool
    /// A closure to fine tune graph node linking. Return `true` if the two nodes should be linked.
    /// - note: This closure is only used when inserting a new position into the graph, and is only consulted if the new position passes the linkDistance check.
    public var linkValidator: LinkValidator? = nil
    
    /**
     Build an empty PathFinding3 graph, to be populated later.
     - parameter manhatanDistance: A distance value checked against each axis (x,y,z) of each node. Nodes within the distance are linked together in the graph
     */
    public init(linkDistance manhatanDistance: Scalar, validatingBy validator: LinkValidator? = nil) {
        self.linkDistance = manhatanDistance
        self.linkValidator = validator
        self.graph = []
    }
    
    /**
     Build a graph from provided positions linking any withing the provided distance
     - parameter positions: The unique unordered positions of the nodes
     - parameter manhatanDistance: A distance value checked against each axis (x,y,z) of each node. Nodes within the distance are linked together in the graph
     */
    public init(positions: [Position3n<Scalar>], linkedWithin manhatanDistance: Scalar, validatingBy validator: LinkValidator? = nil) {
        self.init(linkDistance: manhatanDistance, validatingBy: validator)
        self.graph.reserveCapacity(positions.count)
        for position in positions {
            self.insert(position)
        }
    }
    
    /**
     Adds a position to the node graph returning the node index.
     
     This function filters duplicate nodes, so inserting the same position multiple times will not break the graph.
     - parameter position: The position of the node to be created.
     - returns: The graph index of the inserted node.
     */
    @discardableResult
    public mutating func insert(_ position: Position3n<Scalar>) -> Index {
        var node1 = Node(position: position, children: [])
        let insertionResult = graph.append(node1)
        let node1Index = insertionResult.index
        // If the node is new, check for linking
        if insertionResult.inserted {
            var node1Children = node1.children
            for node2Index in self.graph.indices {
                guard node2Index != node1Index else {continue}
                
                let node2 = self.graph[node2Index]
                
                if Swift.abs(node1.position.x - node2.position.x) > linkDistance {continue}
                if Swift.abs(node1.position.y - node2.position.y) > linkDistance {continue}
                if Swift.abs(node1.position.z - node2.position.z) > linkDistance {continue}
                
                let shouldLink: Bool = self.linkValidator?(node1.position, node2.position) ?? true
                
                if shouldLink {
                    let distance = node1.position.distance(from: node2.position)
                                        
                    node1Children.insert(.init(index: node2Index, distance: distance))
                    
                    var node2Children = node2.children
                    node2Children.insert(.init(index: node1Index, distance: distance))
                    let updatedNode2: Node = .init(position: node2.position, children: node2Children)
                    self.graph.update(updatedNode2, at: node2Index)
                }
            }
            node1 = .init(position: node1.position, children: node1Children)
            self.graph.update(node1, at: node1Index)
        }
        return node1Index
    }
    
    /// Returns the children of the graph node at `index`
    public func children(for index: Index) -> Set<Index> {
        return Set(self.graph[index].children.map(\.index))
    }
}

extension PathFinding3n {
    /**
     Finds nodes within the provided raidus.
     - parameter position: The position to compare to each no in the node graph.
     - parameter radius: An optional minimum distance between `position` and any node position that is required for a match. This distance is direct, not manhatan.
     - returns: An array of indicies for nodes near `position` sorted by nearest to farthest.
     */
    public func nearestNodes(to position: Position3n<Scalar>, withinRadius radius: Scalar? = nil) -> [Index] {
        let sortNodes: [(index: Index, distance: Scalar)] = self.indices.map({ index in
            let node = self.graph[index]
            return (index: index, distance: node.position.distance(from: position))
        }).sorted(by: {$0.distance < $1.distance})
        return sortNodes.compactMap({
            if let radius {
                if $0.distance > radius {
                    return nil
                }
            }
            return $0.index
        })
    }
    
    /**
     Attempts to trace a path through the node graph.
     - parameter startIndex: The index of the graph node to begin the path trace. Use `nearestNodes(to: _, withinRadius:_)` to find an index for this variable.
     - parameter goalIndex: The index of the graph node to end the path trace. Use `nearestNodes(to: _, withinRadius:_)` to find an index for this variable.
     - returns: An array of node graph indicies for nodes that create a path from and including `startIndex` to and including `goalIndex`, or `nil` if no path could be found.
     */
    public func tracePath(from startIndex: Index, to goalIndex: Index) -> [Index]? {
        precondition(self.indices.contains(startIndex), "Index out of range.")
        precondition(self.indices.contains(goalIndex), "Index out of range.")
        
        // The node we want to reach
        let goalNode = self.graph[goalIndex]
        
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
            
            let currentGraphNode = self.graph[currentPathNode.index]
            
            for child in currentGraphNode.children {
                // Don't check already visited nodes
                guard visited.contains(child.index) == false else { continue }
                
                let currentGraphNodeChild = self.graph[child.index]
                
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
    @usableFromInline
    struct Node: Equatable, Hashable {
        @usableFromInline
        let position: Position3n<Scalar>
        @usableFromInline
        let children: Set<Child>
        @usableFromInline
        struct Child: Equatable, Hashable {
            @usableFromInline
            let index: Index
            @usableFromInline
            let distance: Scalar
            @usableFromInline
            init(index: Index, distance: Scalar) {
                self.index = index
                self.distance = distance
            }
            @usableFromInline
            static func == (lhs: Self, rhs: Self) -> Bool {
                return lhs.index == rhs.index
            }
            @usableFromInline
            func hash(into hasher: inout Hasher) {
                hasher.combine(index)
            }
        }
        @usableFromInline
        init(position: Position3n<Scalar>, children: Set<Child>) {
            self.position = position
            self.children = children
        }
        @usableFromInline
        static func == (lhs: Self, rhs: Self) -> Bool {
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
    public typealias Element = Position3n<Scalar>
    
    @inlinable
    public var startIndex: Index {
        nonmutating get {
            return 0
        }
    }
    
    @inlinable
    public var endIndex: Index {
        nonmutating get {
            if graph.isEmpty {
                return startIndex
            }
            return graph.count
        }
    }
    
    @inlinable
    public subscript(index: Index) -> Position3n<Scalar> {
        nonmutating get {
            return graph[index].position
        }
    }
}
