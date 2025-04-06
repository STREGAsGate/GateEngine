/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
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
    internal var geometries: [any GeometryBackend]? {
        switch resource {
        case .points(let points):
            if let backend = points.backend {
                return [backend]
            }
        case .lines(let lines):
            if let backend = lines.backend {
                return [backend]
            }
        case .geometry(let geometry):
            if let backend = geometry.backend {
                return [backend]
            }
        case .morph(let source, let destination):
            if let srcBackend = source.backend, let dstBackend = destination.backend {
                return [srcBackend, dstBackend]
            }
        case .skinned(let skinnedGeometry):
            if let backend = skinnedGeometry.backend {
                return [backend]
            }
        }
        return nil
    }
    
    @usableFromInline
    func validate() -> Bool {
        var shaderUniforms: [String: any ShaderValue] = self.vsh.uniforms.customUniforms
        for pair in self.fsh.uniforms.customUniforms {
            if let value = shaderUniforms[pair.key] {
                if pair.value.valueType != value.valueType {
                    Log.error("Shader custom uniform type missmatch. vsh(\(self.vsh)) \(pair.key):\(value.valueType) != fsh(\(self.fsh)) \(pair.key):\(pair.value.valueType)")
                    return false
                }
            }else{
                shaderUniforms[pair.key] = pair.value
            }
        }
        let shaderUniformNames = shaderUniforms.sorted(by: {$0.key.compare($1.key) == .orderedAscending }).map({$0.key})
        let materialUniformNames = material.sortedCustomUniforms().map({$0.key})
        if shaderUniformNames != materialUniformNames {
            Log.error("Shader and Material custom uniform names do not match:\n    Shaders:  \(shaderUniformNames)\n    Material: \(materialUniformNames)")
            return false
        }
        return true
    }
}

extension DrawCommand.Flags {
    @inlinable
    public static var `default`: Self { Self() }
    
    @inlinable
    internal static var userInterface: Self {
        return DrawCommand.Flags(
            cull: .disabled,
            depthTest: .always, 
            depthWrite: .disabled,
            stencilTest: .equal,
            stencilWrite: .disabled,
            primitive: .triangle,
            winding: .clockwise,
            blendMode: .normal
        )
    }
    
    @inlinable
    internal static var userInterfaceMask: Self {
        return DrawCommand.Flags(
            cull: .disabled,
            depthTest: .always, 
            depthWrite: .enabled,
            stencilTest: .always,
            stencilWrite: .enabled,
            primitive: .triangle,
            winding: .clockwise,
            blendMode: .normal
        )
    }
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
            case equal
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
        
        public enum StencilTest: Hashable {
            case always
            case equal
            case greater
            case greaterEqual
            case less
            case lessEqual
            case never
        }
        public var stencilTest: StencilTest
        
        public enum StencilWrite: Hashable {
            case enabled
            case disabled
        }
        public var stencilWrite: StencilWrite
        
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
            stencilTest: StencilTest = .equal,
            stencilWrite: StencilWrite = .disabled,
            primitive: Primitive = .triangle,
            winding: Winding = .counterClockwise,
            blendMode: BlendMode = .normal
        ) {
            self.cull = cull
            self.depthTest = depthTest
            self.depthWrite = depthWrite
            self.stencilTest = stencilTest
            self.stencilWrite = stencilWrite
            self.primitive = primitive
            self.winding = winding
            self.blendMode = blendMode
        }
    }
}
