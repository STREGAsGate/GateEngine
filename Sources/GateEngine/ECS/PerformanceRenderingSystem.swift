/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class PerformanceRenderingSystem: RenderingSystem {
    let improveLegibility: Bool
    
    public override func setup(context: ECSContext) {
        context.setRecordPerformance(true)
    }
    
    public override func teardown(context: ECSContext) {
        context.setRecordPerformance(false)
    }

    lazy var text: Text = Text(
        string: "Accumulating Statistics...",
        pointSize: improveLegibility ? 14 : 10,
        style: .bold,
        color: .gray
    )
    func rebuildText() -> Bool {
        let performance = context.performance!
        let systemsFrameTime = performance.systemsFrameTime
        let renderingSystemsFrameTime = performance.renderingSystemsFrameTime
        let totalSystemTime = systemsFrameTime + renderingSystemsFrameTime
        let frameTime = performance.frameTime * 1000
        
        // Prevent division by zero
        guard totalSystemTime != 0 else {return false}
        
        var string: String = "\(performance.fps) FPS"
        if performance.totalDroppedFrames > 0 {
            string += ", \(performance.totalDroppedFrames) All Time Dropped"
        }
        string += "\n"
        string += String(format: "%.1fms Frame Time", frameTime)
        string += "\n\n"
        
        string += String(format: "%.1fms Total Systems Time", totalSystemTime * 1000)
        string += "\n\(String(format: "%02d%%", Int((renderingSystemsFrameTime / totalSystemTime) * 100))) Rendering Systems"
        string += "\n\(String(format: "%02d%%", Int((systemsFrameTime / totalSystemTime) * 100))) Systems\n"
        string += "\nLoading: \(game.resourceManager.currentlyLoading.count)"
        if game.resourceManager.currentlyLoading.isEmpty == false {
            string += "\n\t"
            string += game.resourceManager.currentlyLoading.joined(separator: ",\n\t")
        }
        string += "\nLoaded:\n\t"
        var loadedThingsCount = 0
        func loadedThingsLine() {
            if loadedThingsCount >= 3 {
                loadedThingsCount = 0
                string += ",\n\t"
            }else{
                string += ", "
            }
        }
        
        string += "\(context.entities.count) Entities"
        loadedThingsCount += 1
        
        if game.resourceManager.cache.geometries.isEmpty == false || game.resourceManager.cache.skinnedGeometries.isEmpty == false {
            loadedThingsLine()
            string += "\(game.resourceManager.cache.geometries.count + game.resourceManager.cache.skinnedGeometries.count) Geometry"
            loadedThingsCount += 1
        }
        
        if game.resourceManager.cache.collisionMeshes.isEmpty == false {
            loadedThingsLine()
            string += "\(game.resourceManager.cache.collisionMeshes.count) Collision"
            loadedThingsCount += 1
        }
        
        if game.resourceManager.cache.textures.isEmpty == false {
            loadedThingsLine()
            string += "\(game.resourceManager.cache.textures.count) Texture"
            loadedThingsCount += 1
        }
        
        if game.resourceManager.cache.skeletons.isEmpty == false {
            loadedThingsLine()
            string += "\(game.resourceManager.cache.skeletons.count) Skeleton"
            loadedThingsCount += 1
        }
        
        if game.resourceManager.cache.skeletalAnimations.isEmpty == false {
            loadedThingsLine()
            string += "\(game.resourceManager.cache.skeletalAnimations.count) SkelAnim"
            loadedThingsCount += 1
        }
        
        if game.resourceManager.cache.objectAnimation3Ds.isEmpty == false {
            loadedThingsLine()
            string += "\(game.resourceManager.cache.objectAnimation3Ds.count) ObjAnim3D"
            loadedThingsCount += 1
        }
        
        if game.resourceManager.cache.tileSets.isEmpty == false {
            loadedThingsLine()
            string += "\(game.resourceManager.cache.tileSets.count) TileSet"
            loadedThingsCount += 1
        }
        
        if game.resourceManager.cache.tileMaps.isEmpty == false {
            loadedThingsLine()
            string += "\(game.resourceManager.cache.tileMaps.count) TileMap"
            loadedThingsCount += 1
        }
        

        string += "\n"
        
        for statistic in performance.averageSortedStatistics() {
            string += "\n"
            let duration = statistic.value
            string += String(format: "%02d%% ", Int((duration / totalSystemTime) * 100)) + statistic.key
        }
        text.string = string
        
        return true
    }

    let tickDuration: Float = 3
    var cumulativeTime: Float = 0
    
    public override func shouldRender(context: ECSContext, into view: GameView, withTimePassed deltaTime: Float) -> Bool {
        return context.performance != nil && text.isReady
    }
    
    public override func render(context: ECSContext, into view: GameView, withTimePassed deltaTime: Float) {
        self.cumulativeTime += deltaTime
        if self.cumulativeTime > self.tickDuration {
            let didRebuild = self.rebuildText()
            if didRebuild {
                self.cumulativeTime = 0
            }
        }

        let x: Float = .maximum(10, view.marginInsets.leading)
        let y: Float = .maximum(10, view.marginInsets.top)
        let position = Position2(x, y)

        var canvas: Canvas = Canvas(view: view)
        
        if improveLegibility {// Rectangle
            let color = Color(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.5)
            let rect = Rect(size: text.size).inset(by: Insets(-4))
            let position = Position3(
                position.x + rect.position.x,
                position.y + rect.position.y,
                0
            )
            let scale = Size3(rect.size.width, rect.size.height, 1)
            let rotation = Quaternion(.zero, axis: .forward)
            let transform = Transform3(position: position, rotation: rotation, scale: scale)
            
            let material = Material(color: color)
            let flags = DrawCommand.Flags(
                cull: .disabled,
                depthTest: .always,
                depthWrite: .disabled,
                primitive: .triangle,
                winding: .clockwise,
                blendMode: .subtract
            )
            let command = DrawCommand(
                resource: .geometry(.rectOriginTopLeft),
                transforms: [transform],
                material: material,
                vsh: .standard,
                fsh: .materialColor,
                flags: flags
            )
            canvas.insert(command)
        }
        
        do {// Text
            if text.string.isEmpty == false {
                text.interfaceScale = canvas.interfaceScale
                
                let position = Position3(position.x, position.y, 0)
                let rotation = Quaternion(.zero, axis: .forward)
                let transform = Transform3(position: position, rotation: rotation, scale: .one)
                
                let material = Material(texture: text.texture, sampleFilter: text.sampleFilter, tintColor: text.color.withAlpha(improveLegibility ? 1 : 0.6))
                
                let flags = DrawCommand.Flags(
                    cull: .disabled,
                    depthTest: .always,
                    depthWrite: .disabled,
                    primitive: .triangle,
                    winding: .clockwise,
                    blendMode: .add
                )
                let command = DrawCommand(
                    resource: .geometry(text.geometry),
                    transforms: [transform],
                    material: material,
                    vsh: .standard,
                    fsh: .textureSampleTintColor,
                    flags: flags
                )
                canvas.insert(command)
            }
        }
        
        view.insert(canvas)
    }
    
    public init(improveLegibility: Bool) {
        self.improveLegibility = improveLegibility
    }
    
    public required init() {
        self.improveLegibility = false
    }
    
    public override class func sortOrder() -> RenderingSystemSortOrder? { .performance }
}
