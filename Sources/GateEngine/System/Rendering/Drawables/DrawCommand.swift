/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath
import Shaders

public struct DrawCommand {
    public enum Resource {
        case points(_ points: Points)
        case lines(_ lines: Lines)
        case geometry(_ geometry: Geometry)
        case morph(_ source: Geometry, _ destination: Geometry)
        case skinned(_ skinnedGeometry: SkinnedGeometry)
    }
    public var resource: Resource
    public var transforms: [Transform3]
    public var material: Material
    public var vsh: VertexShader
    public var fsh: FragmentShader
    public var flags: Flags
    
    public init(
        resource: Resource,
        transforms: [Transform3],
        material: Material,
        vsh: VertexShader,
        fsh: FragmentShader,
        flags: Flags
    ) {
        self.resource = resource
        self.transforms = transforms
        self.material = material
        self.vsh = vsh
        self.fsh = fsh
        self.flags = flags
    }
    
    @MainActor
    public var isReady: Bool {
        guard material.isReady else {return false}
        
        switch resource {
        case .points(let points):
            return points.state == .ready
        case .lines(let lines):
            return lines.state == .ready
        case .geometry(let geometry):
            return geometry.state == .ready
        case .morph(let source, let destination):
            let isReady = source.state == .ready && destination.state == .ready
            #if GATEENGINE_DEBUG_RENDERING || DEBUG
            if isReady {
                Log.assert(
                    source.backend!.isDrawCommandValid(sharedWith: destination.backend!),
                    "morph must have similar topology for source and destination."
                )
            }
            #endif
            return isReady
        case .skinned(let skinnedGeometry):
            return skinnedGeometry.state == .ready
        }
    }

    @MainActor 
    internal var renderTargets: [any _RenderTargetProtocol] {
        var renderTargets: [any _RenderTargetProtocol] = []
        for channel in material.channels {
            if let texture = channel.texture, let renderTarget = texture.renderTarget {
                renderTargets.append(renderTarget)
            }
        }
        return renderTargets
    }
    
    @MainActor 
    internal var geometries: [any GeometryBackend] {
        switch resource {
        case .points(let points):
            return [points.backend!]
        case .lines(let lines):
            return [lines.backend!]
        case .geometry(let geometry):
            return [geometry.backend!]
        case .morph(let source, let destination):
            return [source.backend!, destination.backend!]
        case .skinned(let skinnedGeometry):
            return [skinnedGeometry.backend!]
        }
    }
}

public extension DrawCommand.Flags {
    @_transparent
    static var `default`: Self {Self()}
}

public extension DrawCommand {
    struct Flags: Hashable {
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
            /**
             Adds the source to the target
             
             - note: For best results use a black background with no alpha channel.
             */
            case add
            /**
             Subtracts the source from the target. White becomes black.
             
             - note: For best results use a black background with no alpha channel.
             */
            case subtract
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
}
