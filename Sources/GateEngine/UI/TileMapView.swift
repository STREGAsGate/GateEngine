/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@MainActor
public protocol TileMapViewDelegate: AnyObject {
    func tileMapViewDidLoadLayers(_ tileMapView: TileMapView)
}

open class TileMapView: View {
    public typealias SampleFilter = Material.Channel.SampleFilter
    
    public weak var delegate: (any TileMapViewDelegate)? = nil
    
    internal var material = Material()
    public var sampleFilter: SampleFilter {
        get {
            return material.channel(0) { channel in
                return channel.sampleFilter
            }
        }
        set {
            material.channel(0) { channel in
                channel.sampleFilter = newValue
            }
        }
    }
    
    internal var needsSetup: Bool = true
    
    public var isReady: Bool {
        return self.needsSetup == false && self.tileSet.isReady && self.tileMap.isReady
    }
    
    public var tileSet: TileSet! = nil {
        didSet {
            needsSetup = true
        }
    }
    public var tileMap: TileMap! = nil {
        didSet {
            needsSetup = true
        }
    }
    
    private var inProgressEdits: Set<Array<Layer>.Index> = []
    public private(set) var layers: [Layer] = []
    
    public func layer<ResultType>(named name: String, _ block: (_ layer: Layer)->ResultType) -> ResultType {
        let index = self.layers.firstIndex(where: {$0.name == name})!
        let layer = self.layers[index]
        let result = block(layer)
        return result
    }
    
    public func editLayer<ResultType>(named name: String, _ block: (_ layer: inout Layer)->ResultType) -> ResultType {
        let index = self.layers.firstIndex(where: {$0.name == name})!
        assert(self.inProgressEdits.contains(index) == false, "Cannot modify the same layer multiple times simultaneously.")
        self.inProgressEdits.insert(index)
        var layer = self.layers[index]
        let result = block(&layer)
        self.layers[index] = layer
        self.inProgressEdits.remove(index)
        return result
    }
    
    public convenience init(tileSetPath: String, tileMapPath: String, sampleFilter: SampleFilter = .nearest, delegate: (any TileMapViewDelegate)? = nil) {
        self.init(tileSet: TileSet(path: tileSetPath), tileMap: TileMap(path: tileMapPath), sampleFilter: sampleFilter, delegate: delegate)
    }
    
    public init(tileSet: TileSet, tileMap: TileMap, sampleFilter: SampleFilter = .nearest, delegate: (any TileMapViewDelegate)? = nil) {
        self.tileSet = tileSet
        self.tileMap = tileMap
        super.init()
        self.sampleFilter = sampleFilter
        self.delegate = delegate
    }
    
    open override func update(withTimePassed deltaTime: Float) {
        super.update(withTimePassed: deltaTime)
        
        if needsSetup, self.tileSet.isReady, self.tileMap.isReady {
            self.layers = tileMap.layers.map({Layer(layer: $0)})
            
            self.material.channel(0) { channel in
                channel.texture = self.tileSet.texture
            }
            self.needsSetup = false
            
            self._didLoadLayers()
            
            self.setNeedsLayout()
            self.setNeedsUpdateConstraints()
        }else{
            self.updateAnimations(deltaTime: deltaTime)
            self.rebuild()
        }
    }
    
    private final func _didLoadLayers() {
        self.didLoadLayers()
        self.delegate?.tileMapViewDidLoadLayers(self)
    }
    open func didLoadLayers() {
        self.delegate?.tileMapViewDidLoadLayers(self)
    }
    
    public override func contentSize() -> Size2 {
        if let layer0 = self.layers.first {
            return layer0.size * layer0.tileSize
        }
        return super.contentSize()
    }
    
    override func draw(_ rect: Rect, into canvas: inout UICanvas) {
        super.draw(rect, into: &canvas)
        
        for layer in layers {
            // Calculate scale to fill rect
            let layerPointSize = layer.size * layer.tileSize
            let layerScale = rect.size / layerPointSize
            let layerScaledSize = layerPointSize * layerScale
            
            if layerScaledSize == rect.size {
                canvas.insert(
                    DrawCommand(
                        resource: .geometry(layer.geometry),
                        transforms: [
                            Transform3(
                                position: Position3(rect.x, rect.y, 0),
                                scale: Size3(
                                    layerScale.width,
                                    layerScale.height,
                                    1
                                )
                            )
                        ],
                        material: material,
                        vsh: .standard,
                        fsh: .textureSample,
                        flags: .userInterface
                    )
                )
            }else{
                // If the layer is unrenderable, draw the placeholder texture
                canvas.insert(
                    DrawCommand(
                        resource: .geometry(.rectOriginTopLeft),
                        transforms: [
                            Transform3(
                                position: Position3(rect.x, rect.y, 0),
                                scale: .one
                            )
                        ],
                        material: .init(texture: Texture(as: .checkerPattern), tintColor: .magenta),
                        vsh: .standard,
                        fsh: .textureSampleTemplateTintColor,
                        flags: .userInterface
                    )
                )
            }
        }
    }
}

extension TileMapView {
    @MainActor public struct Layer {
        public let name: String?
        public let size: Size2
        public let tileSize: Size2
        public private(set) var tiles: [[TileMap.Tile]]
        public var animations: [TileAnimation] = []
        public private(set) var geometry: MutableGeometry = MutableGeometry()
        internal var needsRebuild: Bool = true
        
        public var rows: Int {
            return tiles.count
        }
        public var columns: Int {
            return tiles.first?.count ?? 0
        }
        
        public mutating func setTile(_ tile: TileMap.Tile, at coordinate: TileMap.Layer.Coordinate) {
            assert(containsCoordinate(coordinate), "Coordinate out of range")
            if self.tiles[coordinate.row][coordinate.column] != tile {
                self.tiles[coordinate.row][coordinate.column] = tile
                self.needsRebuild = true
            }
        }
        
        public func containsCoordinate(_ coordinate: TileMap.Layer.Coordinate) -> Bool {
            return tiles.indices.contains(coordinate.row)
            && tiles[coordinate.row].indices.contains(coordinate.column)
        }
        
        public func coordinate(at position: Position2) -> TileMap.Layer.Coordinate? {
            let row = Int(position.y / tileSize.height)
            let column = Int(position.x / tileSize.width)
            if tiles.indices.contains(row) && tiles[row].indices.contains(column) {
                return TileMap.Layer.Coordinate(column: column, row: row)
            }
            return nil
        }
        
        public func tileAtCoordinate(_ coordinate: TileMap.Layer.Coordinate) -> TileMap.Tile {
            assert(containsCoordinate(coordinate), "Coordinate out of range")
            return tiles[coordinate.row][coordinate.column]
        }
        
        public func tileAtPosition(_ position: Position2) -> TileMap.Tile? {
            guard let coordinate = coordinate(at: position) else {return nil}
            return tileAtCoordinate(coordinate)
        }
        
        public func rectForTileAt(_ coordinate: TileMap.Layer.Coordinate) -> Rect {
            assert(containsCoordinate(coordinate), "Coordinate out of range")
            let x = Float(coordinate.column)
            let y = Float(coordinate.row)
            let position = Position2(x, y) * tileSize
            return Rect(position: position, size: tileSize)
        }
        
        //        public func tileIndexAtCoordinate(column: Int, row: Int) -> Int {
        //            return tiles[row][column].id
        //        }
        //
        //        public func tileIndexAtPosition(_ position: Position2) -> Int {
        //            let column = position.x / tileSize.width
        //            let row = position.y / tileSize.height
        //            return tileIndexAtCoordinate(column: Int(column), row: Int(row))
        //        }
        //
        //        public func pixelCenterForTileAt(column: Int, row: Int) -> Position2 {
        //            return (Position2(Float(column), Float(row)) * tileSize)
        //        }
        
        internal init(layer: TileMap.Layer) {
            self.name = layer.name
            self.size = layer.size
            self.tileSize = layer.tileSize
            self.tiles = layer.tiles
        }
        
        public struct TileAnimation {
            let coordinate: TileMap.Layer.Coordinate
            let frames: [TileMap.Tile]
            let duration: Float
            var accumulatedTime: Float = 0
            let timePerFrame: Float
            var repeats: Bool
            
            var previousTileIndex: Int = -1
            
            private mutating func append(deltaTime: Float) {
                accumulatedTime += deltaTime
                if repeats {
                    while accumulatedTime > duration {
                        accumulatedTime -= duration
                    }
                }else if accumulatedTime > duration {
                    accumulatedTime = duration
                }
            }
            internal mutating func getNewTile(advancingBy deltaTime: Float) -> TileMap.Tile? {
                self.append(deltaTime: deltaTime)
                
                let index = Int(accumulatedTime / timePerFrame)
                if previousTileIndex != index {
                    self.previousTileIndex = index
                    return frames[index]
                }
                return nil
            }
            
            public init(coordinate: TileMap.Layer.Coordinate, frames: [TileMap.Tile], duration: Float, repeats: Bool = true) {
                self.coordinate = coordinate
                self.frames = frames
                if duration == 0 {
                    self.duration = .ulpOfOne
                }else{
                    self.duration = duration
                }
                self.timePerFrame = duration / Float(frames.count)
                self.repeats = repeats
            }
        }
    }
    
    func updateAnimations(deltaTime: Float) {
        for layerIndex in layers.indices {
            for animationIndex in layers[layerIndex].animations.indices {
                if let tile = layers[layerIndex].animations[animationIndex].getNewTile(advancingBy: deltaTime) {
                    let coordinate = layers[layerIndex].animations[animationIndex].coordinate
                    layers[layerIndex].setTile(tile, at: coordinate)
                }
            }
        }
    }
    
    func rebuild() {
        guard let tileSet else { return }
        guard let tileMap else { return }
        
        for layerIndex in layers.indices {
            let layer = layers[layerIndex]
            guard layer.needsRebuild else { continue }
            
            layers[layerIndex].needsRebuild = false
            
            var triangles: [Triangle] = []
            triangles.reserveCapacity(Int(layer.size.width * layer.size.height) * 2)
            
            let tileSize = tileSet.tileSize.vector2
            
            let wM: Float = 1 / Float(tileSet.texture.size.width)
            let hM: Float = 1 / Float(tileSet.texture.size.height)
            for hIndex in 0 ..< Int(tileMap.size.height) {
                for wIndex in 0 ..< Int(tileMap.size.width) {
                    let tile = layer.tileAtCoordinate(TileMap.Layer.Coordinate(column: wIndex, row: hIndex))
                    guard tile.id > -1 else {continue}
                    let tileRect = tileSet.rectForTile(tile)
                    let position = Position2(
                        x: Float(wIndex) * tileSize.width,
                        y: Float(hIndex) * tileSize.height
                    )
                    let rect = Rect(position: position, size: tileSize)
                    var v1 = Vertex(
                        px: rect.x,
                        py: rect.y,
                        pz: 0,
                        tu1: tileRect.x * wM,
                        tv1: tileRect.y * hM
                    )
                    var v2 = Vertex(
                        px: rect.maxX,
                        py: rect.y,
                        pz: 0,
                        tu1: tileRect.maxX * wM,
                        tv1: tileRect.y * hM
                    )
                    var v3 = Vertex(
                        px: rect.maxX,
                        py: rect.maxY,
                        pz: 0,
                        tu1: tileRect.maxX * wM,
                        tv1: tileRect.maxY * hM
                    )
                    var v4 = Vertex(
                        px: rect.x,
                        py: rect.maxY,
                        pz: 0,
                        tu1: tileRect.x * wM,
                        tv1: tileRect.maxY * hM
                    )
                    
                    if tile.options.contains(.flippedHorizontal) {
                        swap(&v1.uv1.u, &v2.uv1.u)
                        swap(&v3.uv1.u, &v4.uv1.u)
                    }
                    if tile.options.contains(.flippedVertical) {
                        swap(&v1.uv1.v, &v3.uv1.v)
                        swap(&v2.uv1.v, &v4.uv1.v)
                    }
                    if tile.options.contains(.flippedDiagonal) {
                        swap(&v1.uv1.u, &v3.uv1.u)
                        swap(&v1.uv1.v, &v3.uv1.v)
                    }
                    
                    triangles.append(Triangle(v1: v1, v2: v3, v3: v2, repairIfNeeded: false))
                    triangles.append(Triangle(v1: v3, v2: v1, v3: v4, repairIfNeeded: false))
                }
            }
            if triangles.isEmpty {
                layer.geometry.rawGeometry = nil
            }else{
                layer.geometry.rawGeometry = RawGeometry(triangles: triangles)
            }
        }
    }
}

extension TileMapView: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(type(of: self))(tileSet: \"\(self.tileSet.cacheKey.requestedPath)\", tileMap: \"\(self.tileMap.cacheKey.requestedPath)\")"
    }
}
