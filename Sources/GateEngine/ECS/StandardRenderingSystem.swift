/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public final class StandardRenderingSystem: RenderingSystem {
    internal var verticalResolution: Float? = nil
    internal lazy var renderTarget: RenderTarget = RenderTarget()
    
    public init(verticalResolution: UInt) {
        self.verticalResolution = Float(verticalResolution)
    }
    
    required public init() {

    }

    public override func render(game: Game, window: Window, withTimePassed deltaTime: Float) {
        if let verticalResolution = verticalResolution {
            var width = verticalResolution * window.size.aspectRatio
            width -= width.truncatingRemainder(dividingBy: 2)
            renderTarget.size = Size2(width: width, height: verticalResolution)
        }
        
        do {// 3D
            if let camera = Camera(game.cameraEntity) {
                let sorted3DEntities = game.entities.filter({
                    return $0.hasComponent(Transform3Component.self) && $0.hasComponent(MaterialComponent.self)
                }).sorted { entity1, entity2 in
                    return entity1[MaterialComponent.self].shouldTransparencySort && entity2[MaterialComponent.self].shouldTransparencySort == false
                }.sorted { entity1, entity2 in
                    let p1 = entity1.transform3.position.distance(from: camera.transform.position)
                    let p2 = entity2.transform3.position.distance(from: camera.transform.position)
                    return p1 > p2
                }
                
                var scene = Scene(camera: camera)
                
                for entity in sorted3DEntities {
                    guard let material = entity.component(ofType: MaterialComponent.self)?.material else {continue}
                    guard let transform = entity.component(ofType: Transform3Component.self)?.transform else {continue}
                    
                    if let renderingGeometry = entity.component(ofType: RenderingGeometryComponent.self) {
                        if let geometry = renderingGeometry.geometry {
                            scene.insert(geometry, withMaterial: material, at: transform, flags: renderingGeometry.flags)
                        }
                    }
                    
//                    if let skinnedRenderingGeometry = entity.component(ofType: SkinnedRenderingGeometryComponent.self) {
//                        if let skinnedGeometry = skinnedRenderingGeometry.skinnedGeometry {
//                            if let rigComponent = entity.component(ofType: RigComponent.self) {
//                                scene.insert(skinnedGeometry, withPose: rigComponent.skeleton.getPose(), material: material, at: transform, flags: skinnedRenderingGeometry.flags)
//                            }
//                        }
//                    }
                }
                
                if verticalResolution != nil {
                    renderTarget.insert(scene)
                }else{
                    window.insert(scene)
                }
            }
        }

        do {// 2D
            var canvas = Canvas(interfaceScale: verticalResolution == nil ? window.interfaceScale : 1)
            
            for entity in game.entities {
                if let transform = entity.component(ofType: Transform3Component.self) {
                    if let spriteComponent = entity.component(ofType: SpriteComponent.self) {
                        if let sprite = spriteComponent.sprite() {
                            let position = Position2(transform.position.x, transform.position.y)
                            canvas.insert(sprite, at: position, depth: spriteComponent.depth)
                        }
                    }
//                    if let textComponent = entity.component(ofType: TextComponent.self) {
//                        let position = Position2(transform.position.x, transform.position.y)
//                        canvas.insert(textComponent.text, at: position)
//                    }
                }
            }
            
            if verticalResolution != nil {
                renderTarget.insert(canvas)
            }else{
                window.insert(canvas)
            }
        }
        
        if verticalResolution != nil {
            window.insert(renderTarget)
        }
    }
}
