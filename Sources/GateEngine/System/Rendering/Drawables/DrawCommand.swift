/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

struct DrawFlags: Hashable {
    enum Cull: Hashable {
        case disabled
        case back
        case front
    }
    var cull: Cull
    
    enum DepthTest: Hashable {
        case always
        case greaterThan
        case lessThan
        case never
    }
    var depthTest: DepthTest
    
    enum DepthWrite: Hashable {
        case enabled
        case disabled
    }
    var depthWrite: DepthWrite
    
    enum Primitive: Hashable {
        case point
        case line
        case lineStrip
        case triangle
        case triangleStrip
    }
    var primitive: Primitive
    
    enum Winding {
        case clockwise
        case counterClockwise
    }
    var winding: Winding
    
    enum BlendMode: Hashable {
        case none
        case normal
    }
    var blendMode: BlendMode

    init(cull: Cull = .back, depthTest: DepthTest = .lessThan, depthWrite: DepthWrite = .enabled, primitive: Primitive = .triangle, winding: Winding = .clockwise, blendMode: BlendMode = .normal) {
        self.cull = cull
        self.depthTest = depthTest
        self.depthWrite = depthWrite
        self.primitive = primitive
        self.winding = winding
        self.blendMode = blendMode
    }
}

internal struct DrawCommand {
    let geometries: [GeometryBackend]
    let joints: [Skin.Joint]?
    let pose: Skeleton.Pose?
    let transforms: [Transform3]
    let material: Material
    let flags: DrawFlags
    
    init(geometries: [GeometryBackend], joints: [Skin.Joint], pose: Skeleton.Pose, transforms: [Transform3], material: Material, flags: DrawFlags) {
        self.geometries = geometries
        self.joints = joints
        self.pose = pose
        self.transforms = transforms
        self.material = material
        self.flags = flags
    }
    
    init(geometries: [GeometryBackend], transforms: [Transform3], material: Material, flags: DrawFlags) {
        self.geometries = geometries
        self.joints = nil
        self.pose = nil
        self.transforms = transforms
        self.material = material
        self.flags = flags
    }
    
    @MainActor var renderTargets: Set<RenderTarget> {
        var renderTargets: Set<RenderTarget> = []
        for channel in material.channels {
            if let texture = channel.texture, let renderTarget = texture.renderTarget {
                renderTargets.insert(renderTarget)
            }
        }
        return renderTargets
    }
}
