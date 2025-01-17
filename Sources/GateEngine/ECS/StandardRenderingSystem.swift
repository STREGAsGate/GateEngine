/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public final class StandardRenderingSystem: RenderingSystem {
    internal var verticalResolution: Float? = nil
    internal lazy var renderTarget: RenderTarget = RenderTarget()

    public convenience init(verticalResolution: UInt, context: ECSContext) {
        self.init(context: context)
        self.verticalResolution = Float(verticalResolution)
    }
    
    public override func render(context: ECSContext, into view: GameView, withTimePassed deltaTime: Float) {
        if let verticalResolution = verticalResolution {
            var width = verticalResolution * view.frame.size.aspectRatio
            width -= width.truncatingRemainder(dividingBy: 2)
            renderTarget.size = Size2(width: width, height: verticalResolution)
        }

        do {  // 3D
            if let camera = Camera(context.cameraEntity) {
                let sorted3DEntities = context.entities.filter({
                    return $0.hasComponent(Transform3Component.self)
                        && $0.hasComponent(MaterialComponent.self)
                }).sorted { entity1, entity2 in
                    return entity1[MaterialComponent.self].shouldTransparencySort
                        && entity2[MaterialComponent.self].shouldTransparencySort == false
                }.sorted { entity1, entity2 in
                    let p1 = entity1.transform3.position.distance(from: camera.transform.position)
                    let p2 = entity2.transform3.position.distance(from: camera.transform.position)
                    return p1 > p2
                }

                var scene = Scene(camera: camera)

                for entity in sorted3DEntities {
                    guard let material = entity.component(ofType: MaterialComponent.self)?.material
                    else {
                        continue
                    }
                    guard
                        let transform = entity.component(ofType: Transform3Component.self)?
                            .transform
                    else {
                        continue
                    }

                    if let renderingGeometry = entity.component(
                        ofType: RenderingGeometryComponent.self
                    ) {
                        for geometry in renderingGeometry.geometries {
                            scene.insert(
                                geometry,
                                withMaterial: material,
                                at: transform,
                                flags: renderingGeometry.flags
                            )
                        }

                        if let rigComponent = entity.component(ofType: Rig3DComponent.self) {
                            for skinnedGeometry in renderingGeometry.skinnedGeometries {
                                scene.insert(
                                    skinnedGeometry,
                                    withPose: rigComponent.skeleton.getPose(),
                                    material: material,
                                    at: transform,
                                    flags: renderingGeometry.flags
                                )
                            }
                        }
                    }
                }

                if verticalResolution != nil {
                    renderTarget.insert(scene)
                } else {
                    view.insert(scene)
                }
            }
        }

        do {  // 2D
            var canvas = Canvas(
                interfaceScale: verticalResolution == nil ? view.interfaceScale : 1
            )

            for entity in context.entities {
                if let transform = entity.component(ofType: Transform3Component.self) {
                    if let spriteComponent = entity.component(ofType: SpriteComponent.self) {
                        if let sprite = spriteComponent.sprite() {
                            let position = Position2(transform.position.x, transform.position.y)
                            canvas.insert(sprite, at: position, depth: spriteComponent.depth)
                        }
                    }
                }
                if let tileMapComponent = entity.component(ofType: TileMapComponent.self) {
                    if tileMapComponent.tileSet.state == .ready {
                        let material = Material(texture: tileMapComponent.tileSet.texture)
                        for layer in tileMapComponent.layers {
                            canvas.insert(layer.geometry, withMaterial: material, at: .zero)
                        }
                    }
                }
            }

            if verticalResolution != nil {
                renderTarget.insert(canvas)
            } else {
                view.insert(canvas)
            }
        }

        if verticalResolution != nil {
//            view.insert(renderTarget)
        }
    }

    public override class func sortOrder() -> RenderingSystemSortOrder? {
        return .standard
    }
}
