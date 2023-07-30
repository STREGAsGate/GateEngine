/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public struct DrawFlags: Hashable {
    public enum Cull: Hashable {
        case disabled
        case back
        case front
    }
    public var cull: Cull
    
    public enum DepthTest: Hashable {
        case always
        case greaterThan
        case lessThan
        case never
    }
    public var depthTest: DepthTest
    
    public enum DepthWrite: Hashable {
        case enabled
        case disabled
    }
    public var depthWrite: DepthWrite
    
    public enum Primitive: Hashable {
        case point
        case line
        case lineStrip
        case triangle
        case triangleStrip
    }
    public var primitive: Primitive
    
    public enum Winding {
        case clockwise
        case counterClockwise
    }
    public var winding: Winding
    
    public enum BlendMode: Hashable {
        case none
        case normal
    }
    public var blendMode: BlendMode

    public init(cull: Cull = .back, depthTest: DepthTest = .lessThan, depthWrite: DepthWrite = .enabled, primitive: Primitive = .triangle, winding: Winding = .clockwise, blendMode: BlendMode = .normal) {
        self.cull = cull
        self.depthTest = depthTest
        self.depthWrite = depthWrite
        self.primitive = primitive
        self.winding = winding
        self.blendMode = blendMode
    }
}

public struct DrawCommand {
    let geometries: ContiguousArray<any GeometryBackend>
    let transforms: ContiguousArray<Transform3>
    let material: Material
    let flags: DrawFlags

    @usableFromInline
    internal init(backends: ContiguousArray<any GeometryBackend>, transforms: ContiguousArray<Transform3>, material: Material, flags: DrawFlags) {
        self.geometries = backends
        self.transforms = transforms
        self.material = material
        self.flags = flags
        
#if GATEENGINE_DEBUG_RENDERING || DEBUG
        for backend1 in backends {
            for backend2 in backends {
                Log.assert(backend1.isDrawCommandValid(sharedWith: backend2), "Multiple geometries in the same DrawCommand must have similar topology.")
            }
        }
#endif
    }
    
    @inlinable @inline(__always)
    @MainActor public init(lines geometries: [Lines], transforms: [Transform3], material: Material, flags: DrawFlags) {
        let backends = ContiguousArray(geometries.map({$0.backend!}))
        let transforms = ContiguousArray(transforms)
        self.init(backends: backends, transforms: transforms, material: material, flags: flags)
    }
    
    @inlinable @inline(__always)
    @MainActor public init(points geometries: [Points], transforms: [Transform3], material: Material, flags: DrawFlags) {
        let backends = ContiguousArray(geometries.map({$0.backend!}))
        let transforms = ContiguousArray(transforms)
        self.init(backends: backends, transforms: transforms, material: material, flags: flags)
    }
    
    @inlinable @inline(__always)
    @MainActor public init(geometries: [Geometry], transforms: [Transform3], material: Material, flags: DrawFlags) {
        let backends = ContiguousArray(geometries.map({$0.backend!}))
        let transforms = ContiguousArray(transforms)
        self.init(backends: backends, transforms: transforms, material: material, flags: flags)
    }
    
    @inlinable @inline(__always)
    @MainActor public init(geometries: [SkinnedGeometry], transforms: [Transform3], material: Material, flags: DrawFlags) {
        let backends = ContiguousArray(geometries.map({$0.backend!}))
        let transforms = ContiguousArray(transforms)
        self.init(backends: backends, transforms: transforms, material: material, flags: flags)
    }
    
    @inline(__always)
    @MainActor var renderTargets: [any _RenderTargetProtocol] {
        var renderTargets: [any _RenderTargetProtocol] = []
        for channel in material.channels {
            if let texture = channel.texture, let renderTarget = texture.renderTarget {
                renderTargets.append(renderTarget)
            }
        }
        return renderTargets
    }
}
