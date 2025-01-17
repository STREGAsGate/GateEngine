/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class TileMapSystem: System {
    public override func update(context: ECSContext, input: HID, withTimePassed deltaTime: Float) async {
        for entity in context.entities {
            if let component = entity.component(ofType: TileMapComponent.self) {
                if component.needsSetup {
                    self.setup(component)
                }else{
                    self.updateAnimations(component, deltaTime: deltaTime)
                    self.rebuild(component)
                }
            }
        }
    }
    
    func setup(_ component: TileMapComponent) {
        guard component.tileSet?.state == .ready else {return}
        guard component.tileMap?.state == .ready else {return}
        component.needsSetup = false
        component.layers = component.tileMap.layers.map({TileMapComponent.Layer(layer: $0)})
    }
    
    func updateAnimations(_ component: TileMapComponent, deltaTime: Float) {
        for layerIndex in component.layers.indices {
            for animationIndex in component.layers[layerIndex].animations.indices {
                if let tile = component.layers[layerIndex].animations[animationIndex].getNewTile(advancingBy: deltaTime) {
                    let coordinate = component.layers[layerIndex].animations[animationIndex].coordinate
                    component.layers[layerIndex].setTile(tile, at: coordinate)
                }
            }
        }
    }

    func rebuild(_ component: TileMapComponent) {
        guard let tileSet = component.tileSet else { return }
        guard let tileMap = component.tileMap else { return }
        
        for layerIndex in component.layers.indices {
            let layer = component.layers[layerIndex]
            guard layer.needsRebuild else { continue }
           
            component.layers[layerIndex].needsRebuild = false
            
            var triangles: [Triangle] = []
            triangles.reserveCapacity(Int(layer.size.width * layer.size.height) * 2)
            
            let tileSize = tileSet.tileSize
            
            let wM: Float = 1 / tileSet.texture.size.width
            let hM: Float = 1 / tileSet.texture.size.height
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
                    
                    if tile.options.contains(.flippedHorizontal) || tile.options.contains(.flippedDiagonal) {
                        swap(&v1.u1, &v2.u1)
                        swap(&v3.u1, &v4.u1)
                    }
                    if tile.options.contains(.flippedVertical) || tile.options.contains(.flippedDiagonal) {
                        swap(&v1.v1, &v3.v1)
                        swap(&v2.v1, &v4.v1)
                    }
                    
                    triangles.append(Triangle(v1: v1, v2: v3, v3: v2, repairIfNeeded: false))
                    triangles.append(Triangle(v1: v3, v2: v1, v3: v4, repairIfNeeded: false))
                }
            }
            if triangles.isEmpty == false {
                layer.geometry.rawGeometry = RawGeometry(triangles: triangles)
            }
        }
    }

    public override class var phase: System.Phase { .updating }
    public override class func sortOrder() -> SystemSortOrder? {
        return .tileMapSystem
    }
}
