/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath
import Shaders

public struct DrawFlags: Hashable {
    public enum Cull: Hashable {
        case disabled
        case back
        case front
    }
    public var cull: Cull

    public enum DepthTest: Hashable {
        case always
        case greater
        case greaterEqual
        case less
        case lessEqual
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

    public init(
        cull: Cull = .back,
        depthTest: DepthTest = .lessEqual,
        depthWrite: DepthWrite = .enabled,
        primitive: Primitive = .triangle,
        winding: Winding = .counterClockwise,
        blendMode: BlendMode = .normal
    ) {
        self.cull = cull
        self.depthTest = depthTest
        self.depthWrite = depthWrite
        self.primitive = primitive
        self.winding = winding
        self.blendMode = blendMode
    }
}

public struct DrawCommand {
    let geometries: [any GeometryBackend]
    let transforms: [Transform3]
    let material: Material
    let flags: DrawFlags

    @usableFromInline
    internal init(
        backends: [any GeometryBackend],
        transforms: [Transform3],
        material: Material,
        flags: DrawFlags
    ) {
        self.geometries = backends
        self.transforms = transforms
        self.material = material
        self.flags = flags

        #if GATEENGINE_DEBUG_RENDERING || DEBUG
        for backend1 in backends {
            for backend2 in backends {
                Log.assert(
                    backend1.isDrawCommandValid(sharedWith: backend2),
                    "Multiple geometries in the same DrawCommand must have similar topology."
                )
            }
        }
        #endif
    }
    
    @inlinable @inline(__always)
    @MainActor public init(
        texture: Texture,
        subRect: Rect? = nil,
        at position: Position3,
        rotation: some Angle = Radians.zero,
        scale: Size2 = .one,
        vertexShader: VertexShader = .standard,
        fragmentShader: FragmentShader = .textureSample,
        flags: DrawFlags = DrawFlags(winding: .clockwise)
    ) {
        let backends = [Renderer.rectOriginTopLeft.backend!]
        let material = Material { material in
            material.channel(0) { channel in
                channel.texture = texture
                if let subRect {
                    channel.offset = Position2(
                        (subRect.position.x + 0.001) / Float(texture.size.width),
                        (subRect.position.y + 0.001) / Float(texture.size.height)
                    )
                    channel.scale = Size2(
                        subRect.size.width / Float(texture.size.width),
                        subRect.size.height / Float(texture.size.height)
                    )
                }
            }
            material.vertexShader = vertexShader
            material.fragmentShader = fragmentShader
        }
        
        let scale = Size3(scale * (subRect?.size ?? texture.size), 1)
        let rotation = Quaternion(rotation, axis: .forward)
        let transform = Transform3(position: position, rotation: rotation, scale: scale)
        self.init(backends: backends, transforms: [transform], material: material, flags: flags)
    }

    @inlinable @inline(__always)
    @MainActor public init(
        points geometries: [Points],
        transforms: [Transform3],
        material: Material,
        flags: DrawFlags
    ) {
        let backends = geometries.map({ $0.backend! })
        self.init(backends: backends, transforms: transforms, material: material, flags: flags)
    }
    
    @inlinable @inline(__always)
    @MainActor public init(
        lines geometries: [Lines],
        transforms: [Transform3],
        material: Material,
        flags: DrawFlags
    ) {
        let backends = geometries.map({ $0.backend! })
        self.init(backends: backends, transforms: transforms, material: material, flags: flags)
    }

    @inlinable @inline(__always)
    @MainActor public init(
        geometries: [Geometry],
        transforms: [Transform3],
        material: Material,
        flags: DrawFlags
    ) {
        let backends = geometries.map({ $0.backend! })
        self.init(backends: backends, transforms: transforms, material: material, flags: flags)
    }

    @inlinable @inline(__always)
    @MainActor public init(
        geometries: [SkinnedGeometry],
        transforms: [Transform3],
        material: Material,
        flags: DrawFlags
    ) {
        let backends = geometries.map({ $0.backend! })
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
