/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public struct DrawFlags: Hashable {
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

public struct DrawCommand {
    let geometries: ContiguousArray<GeometryBackend>
    let transforms: ContiguousArray<Transform3>
    let material: Material
    let flags: DrawFlags

    internal init(backends: ContiguousArray<GeometryBackend>, transforms: ContiguousArray<Transform3>, material: Material, flags: DrawFlags) {
        self.geometries = backends
        self.transforms = transforms
        self.material = material
        self.flags = flags
        
#if GATEENGINE_DEBUG_RENDERING || DEBUG
        for backend1 in backends {
            for backend2 in backends {
                assert(backend1.isDrawCommandValid(sharedWith: backend2), "[GateEngine] Error: Multiple geometries in the same DrawCommand must have similar topology.")
            }
        }
#endif
    }
    
    @inline(__always)
    @MainActor public init(lines geometries: [Lines], transforms: [Transform3], material: Material, flags: DrawFlags) {
        let backends = ContiguousArray(geometries.map({$0.backend!}))
        let transforms = ContiguousArray(transforms)
        self.init(backends: backends, transforms: transforms, material: material, flags: flags)
    }
    
    @inline(__always)
    @MainActor public init(points geometries: [Points], transforms: [Transform3], material: Material, flags: DrawFlags) {
        let backends = ContiguousArray(geometries.map({$0.backend!}))
        let transforms = ContiguousArray(transforms)
        self.init(backends: backends, transforms: transforms, material: material, flags: flags)
    }
    
    @inline(__always)
    @MainActor public init(geometries: [Geometry], transforms: [Transform3], material: Material, flags: DrawFlags) {
        let backends = ContiguousArray(geometries.map({$0.backend!}))
        let transforms = ContiguousArray(transforms)
        self.init(backends: backends, transforms: transforms, material: material, flags: flags)
    }
    
    @inline(__always)
    @MainActor public init(geometries: [SkinnedGeometry], transforms: [Transform3], material: Material, flags: DrawFlags) {
        let backends = ContiguousArray(geometries.map({$0.backend!}))
        let transforms = ContiguousArray(transforms)
        self.init(backends: backends, transforms: transforms, material: material, flags: flags)
    }
    
    @inline(__always)
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
