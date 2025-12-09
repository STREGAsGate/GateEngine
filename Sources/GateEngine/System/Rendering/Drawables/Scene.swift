/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Shaders

/// A Scene is a drawing space with 3 dimensions and a perspective camera.
@MainActor public struct Scene: Drawable {
    @usableFromInline internal var camera: Camera
    @usableFromInline internal var viewport: Rect?
    @usableFromInline internal var scissorRect: Rect?

    @usableFromInline internal var pointLights: Set<PointLight> = []
    @usableFromInline internal var spotLights: Set<SpotLight> = []
    @usableFromInline internal var directionalLight: DirectionalLight? = nil

    @usableFromInline 
    internal var _drawCommands: ContiguousArray<DrawCommand> = []
    @inlinable
    public var drawCommands: ContiguousArray<DrawCommand> {
        return _drawCommands
    }
    
    @inlinable
    public mutating func insert(_ drawCommand: DrawCommand) {
        if drawCommand.isReady {
            assert(drawCommand.validate())
            _drawCommands.append(drawCommand)
        }
    }

    /** Adds the camera to the scene
    Each scene can have a single camera. Only the most recent camera is kept.
    - parameter camera: The camera to view the scene from
     */
    @inlinable
    public mutating func setCamera(_ camera: Camera) {
        self.camera = camera
    }

    @inlinable
    public mutating func setViewport(_ viewport: Rect?) {
        self.viewport = viewport
    }
    
    @inlinable
    public mutating func setScissorRect(_ scissorRect: Rect?) {
        self.scissorRect = scissorRect
    }

    /** Adds geometry to the scene for rendering.
    - parameter geometry: The geometry to draw.
    - parameter material: The color information used to draw the geometry.
    - parameter transform: Describes how the geometry should be positioned and scaled relative to the scene.
    - parameter flags: Options to customize how drawing is handled.
    - Geometry is automatically instanced for performance. There are two types of instancing that happen automatically under the hood.
      1. Simple instancing. This happens when all instances of the same `Geometry` reference have the same `material` and `flags` and differ only by `transform`. This is the most efficient and suitible for things like particles, foliage, and tiles.
      2. Complex instancing. Complex instancing occurs if any instance of the same `Geometry` reference has a different material or flags. Complex instancing allows using the same `Geometry` with different materials while still having some.
    - The  instancing is best effort and does not guarantee the same performance across platforms or package version. You should test each platform if you use many instances.
    - You may not explicitly choose the instancing, however you could create a new `Geometry` from the same URL which would have a different id and have separate instancing. This would allow both instancing types at the expense of an additional GPU resource for each `Geometry` reference.
    */
    @inlinable
    public mutating func insert(
        _ geometry: Geometry,
        withMaterial material: Material,
        at transform: Transform3,
        blendMode: DrawCommand.Flags.BlendMode = .normal,
        flags: SceneElementFlags = .default
    ) {
        self.insert(geometry, withMaterial: material, at: [transform], blendMode: blendMode, flags: flags)
    }

    /** Adds geometry to the scene for rendering.
    - parameter geometry: The geometry to draw.
    - parameter material: The color information used to draw the geometry.
    - parameter transforms: Describes how each geometry instance should be positioned and scaled relative to the scene.
    - parameter flags: Options to customize how drawing is handled.
    - Explicitly instances the geometry as it's own batch. Use this for known instancing like particles.
    */
    @inlinable
    public mutating func insert(
        _ geometry: Geometry,
        withMaterial material: Material,
        at transforms: [Transform3],
        blendMode: DrawCommand.Flags.BlendMode = .normal,
        flags: SceneElementFlags = .default
    ) {
        let command = DrawCommand(
            resource: .geometry(geometry),
            transforms: transforms,
            material: material,
            vsh: (material.channels.first?.texture != nil) ? .standard : material.channels.first?.color == .vertexColors ? .vertexColors : .standard,
            fsh: (material.channels.first?.texture != nil) ? .textureSampleTintColor : material.channels.first?.color == .vertexColors ? .vertexColor : .materialColor,
            flags: flags.drawCommandFlags(withPrimitive: .triangle, blendMode: blendMode)
        )
        self.insert(command)
    }

    /** Adds geometry to the scene for rendering.
    - parameter geometry: The geometry to draw.
    - parameter material: The color information used to draw the geometry.
    - parameter transform: Describes how the geometry should be positioned and scaled relative to the scene.
    - parameter flags: Options to customize how drawing is handled.
    - Geometry is automatically instanced for performance. There are two types of instancing that happen automatically under the hood.
      1. Simple instancing. This happens when all instances of the same `Geometry` reference have the same `material` and `flags` and differ only by `transform`. This is the most efficient and suitible for things like particles, foliage, and tiles.
      2. Complex instancing. Complex instancing occurs if any instance of the same `Geometry` reference has a different material or flags. Complex instancing allows using the same `Geometry` with different materials while still having some.
    - The  instancing is best effort and does not guarantee the same performance across platforms or package version. You should test each platform if you use many instances.
    - You may not explicitly choose the instancing, however you could create a new `Geometry` from the same URL which would have a different id and have separate instancing. This would allow both instancing types at the expense of an additional GPU resource for each `Geometry` reference.
    */
    @inlinable
    public mutating func insert(
        _ geometry: SkinnedGeometry,
        withPose pose: Skeleton.Pose,
        material: Material,
        at transform: Transform3,
        flags: SceneElementFlags = .default
    ) {
        self.insert(geometry, withPose: pose, material: material, at: [transform], flags: flags)
    }

    /** Adds geometry to the scene for rendering.
    - parameter geometry: The geometry to draw.
    - parameter material: The color information used to draw the geometry.
    - parameter transforms: Describes how each geometry instance should be positioned and scaled relative to the scene.
    - parameter flags: Options to customize how drawing is handled.
    - Geometry is automatically instanced for performance. There are two types of instancing that happen automatically under the hood.
      1. Simple instancing. This happens when all instances of the same `Geometry` reference have the same `material` and `flags` and differ only by `transform`. This is the most efficient and suitible for things like particles, foliage, and tiles.
      2. Complex instancing. Complex instancing occurs if any instance of the same `Geometry` reference has a different material or flags. Complex instancing allows using the same `Geometry` with different materials while still having some.
    - The  instancing is best effort and does not guarantee the same performance across platforms or package version. You should test each platform if you use many instances.
    - You may not explicitly choose the instancing, however you could create a new `Geometry` from the same URL which would have a different id and have separate instancing. This would allow both instancing types at the expense of an additional GPU resource for each `Geometry` reference.
    */
    @inlinable
    public mutating func insert(
        _ skinnedGeometry: SkinnedGeometry,
        withPose pose: Skeleton.Pose,
        material: Material,
        at transforms: [Transform3],
        flags: SceneElementFlags = .default
    ) {
        guard skinnedGeometry.isReady else {return}
        var material = material
        material.setCustomUniformValue(
            pose.shaderMatrixArray(orderedFromSkinJoints: skinnedGeometry.skinJoints),
            forUniform: "bones"
        )

        let command = DrawCommand(
            resource: .skinned(skinnedGeometry),
            transforms: transforms,
            material: material,
            vsh: .skinned,
            fsh: (material.channels.first?.texture != nil) ? .textureSample : .materialColor,
            flags: flags.drawCommandFlags(withPrimitive: .triangle)
        )
        self.insert(command)
    }
    
    /** Adds lines to the scene for rendering.
    - parameter points: The points to draw.
    - parameter material: The color information used to draw the geometry.
    - parameter transform: Describes how the points instance should be positioned and scaled relative to the scene.
    - parameter flags: Options to customize how drawing is handled.
    - Explicitly instances the geometry as it's own batch. Use this for known instancing like particles.
    */
    @inlinable
    public mutating func insert(
        _ points: Points,
        color: Color,
        size: Float,
        at transform: Transform3,
        flags: SceneElementFlags = .default
    ) {
        self.insert(points, color: color, size: size, at: [transform], flags: flags)
    }
    
    /** Adds lines to the scene for rendering.
    - parameter points: The lines to draw.
    - parameter material: The color information used to draw the geometry.
    - parameter transforms: Describes how each points instance should be positioned and scaled relative to the scene.
    - parameter flags: Options to customize how drawing is handled.
    - Explicitly instances the geometry as it's own batch. Use this for known instancing like particles.
    */
    @inlinable
    public mutating func insert(
        _ points: Points,
        color: Color,
        size: Float,
        at transforms: [Transform3],
        flags: SceneElementFlags = .default
    ) {
        var material = Material(color: color)
        material.setCustomUniformValue(size, forUniform: "pointSize")
        let command = DrawCommand(
            resource: .points(points),
            transforms: transforms,
            material: material,
            vsh: .pointSizeAndColor,
            fsh: .vertexColor,
            flags: flags.drawCommandFlags(withPrimitive: .point)
        )
        self.insert(command)
    }
    
    /** Adds lines to the scene for rendering.
    - parameter lines: The lines to draw.
    - parameter color: The color information used to draw the geometry. nil will use vertex color data.
    - parameter transform: Describes how the lines instance should be positioned and scaled relative to the scene.
    - parameter flags: Options to customize how drawing is handled.
    - Explicitly instances the geometry as it's own batch. Use this for known instancing like particles.
    */
    @inlinable
    public mutating func insert(
        _ lines: Lines,
        withColor color: Color? = nil,
        at transform: Transform3,
        flags: SceneElementFlags = .default
    ) {
        self.insert(lines, withColor: color, at: [transform], flags: flags)
    }
    
    /** Adds lines to the scene for rendering.
    - parameter lines: The lines to draw.
    - parameter color: The color information used to draw the geometry. nil will use vertex color data.
    - parameter transforms: Describes how each lines instance should be positioned and scaled relative to the scene.
    - parameter flags: Options to customize how drawing is handled.
    - Explicitly instances the geometry as it's own batch. Use this for known instancing like particles.
    */
    @inlinable
    public mutating func insert(
        _ lines: Lines,
        withColor color: Color? = nil,
        at transforms: [Transform3],
        flags: SceneElementFlags = .default
    ) {
        let useVertexColors: Bool = (color == nil)
        let command = DrawCommand(
            resource: .lines(lines),
            transforms: transforms,
            material: Material(color: useVertexColors ? .black : color!),
            vsh: useVertexColors ? .vertexColors : .materialColor,
            fsh: .materialColor,
            flags: flags.drawCommandFlags(withPrimitive: .line)
        )
        self.insert(command)
    }

    @inlinable
    public mutating func insert(
        _ source: Geometry,
        morphingTo destination: Geometry,
        withMaterial material: Material,
        interpolationFactor factor: Float,
        at transforms: [Transform3],
        flags: SceneElementFlags = .default
    ) {
        var material = material
        material.setCustomUniformValue(factor, forUniform: "interpolationFactor")
        let command = DrawCommand(
            resource: .morph(source, destination),
            transforms: transforms,
            material: material,
            vsh: .morph,
            fsh: (material.channels.first?.texture != nil) ? .morphTextureSample : .materialColor,
            flags: flags.drawCommandFlags(withPrimitive: .line)
        )
        self.insert(command)
    }

    @inlinable
    public mutating func insert(
        _ source: Geometry,
        morphingTo destination: Geometry,
        withMaterial material: Material,
        interpolationFactor factor: Float,
        at transform: Transform3,
        flags: SceneElementFlags = .default
    ) {
        self.insert(
            source,
            morphingTo: destination,
            withMaterial: material,
            interpolationFactor: factor,
            at: [transform],
            flags: flags
        )
    }
    
    @inlinable
    public mutating func insert(
        _ sprite: Sprite,
        at transform: Transform3,
        opacity: Float = 1,
        blendMode: DrawCommand.Flags.BlendMode = .normal,
        flags: CanvasElementSpriteFlags = .default
    ) {
        let material = Material { material in
            material.channel(0) { channel in
                channel.color = sprite.tintColor
                channel.texture = sprite.texture
                channel.scale = sprite.uvScale
                channel.offset = sprite.uvOffset
                channel.sampleFilter = sprite.sampleFilter
            }
            material.setCustomUniformValue(opacity, forUniform: "opacity")
        }
        
        var transform = transform
        transform.scale.y *= -1

        let flags = DrawCommand.Flags(
            cull: .back,
            depthTest: .lessEqual,
            depthWrite: .enabled,
            primitive: .triangle,
            winding: .clockwise,
            blendMode: blendMode
        )
        let command = DrawCommand(
            resource: .geometry(.rectOriginCentered),
            transforms: [transform],
            material: material,
            vsh: .standard,
            fsh: .textureSampleOpacity,
            flags: flags
        )
        self.insert(command)
    }

    @available(*, unavailable, message: "Dynamic lighting is not supported yet.")
    public mutating func insert(_ light: PointLight) {
        self.pointLights.insert(light)
    }
    @available(*, unavailable, message: "Dynamic lighting is not supported yet.")
    public mutating func insert(_ light: SpotLight) {
        self.spotLights.insert(light)
    }
    @available(*, unavailable, message: "Dynamic lighting is not supported yet.")
    public mutating func insert(_ light: DirectionalLight) {
        self.directionalLight = light
    }

    @inlinable
    internal var hasLights: Bool {
        guard directionalLight != nil else { return true }
        guard pointLights.isEmpty else { return true }
        guard spotLights.isEmpty else { return true }

        return false
    }

    public init(camera: Camera, viewport: Rect? = nil, clipRect: Rect? = nil, estimatedCommandCount: Int = 10) {
        self.camera = camera
        self.viewport = viewport

        self._drawCommands.reserveCapacity(estimatedCommandCount)
    }
    
    @inlinable
    public mutating func matrices(withSize size: GameMath.Size2) -> Matrices {
        self.camera.matricies(withViewportSize: size)
    }
}

public struct SceneElementFlags: OptionSet, Hashable, Sendable {
    public typealias RawValue = UInt32
    public let rawValue: RawValue

    public static let cullBackface = SceneElementFlags(rawValue: 1 << 1)
    public static let disableDepthCull = SceneElementFlags(rawValue: 1 << 2)
    public static let disableDepthWrite = SceneElementFlags(rawValue: 1 << 3)
    //    public static let onlyDepthWrite = SceneElementFlags(rawValue: 1 << 4)

    public static let `default`: SceneElementFlags = [.cullBackface]

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    @inlinable
    public func drawCommandFlags(withPrimitive primitive: DrawCommand.Flags.Primitive, blendMode: DrawCommand.Flags.BlendMode = .normal) -> DrawCommand.Flags {
        let cull: DrawCommand.Flags.Cull = self.contains(.cullBackface) ? .back : .disabled
        let depthTest: DrawCommand.Flags.DepthTest = self.contains(.disableDepthCull) ? .always : .lessEqual
        let depthWrite: DrawCommand.Flags.DepthWrite =
            self.contains(.disableDepthWrite) ? .disabled : .enabled
        return DrawCommand.Flags(
            cull: cull,
            depthTest: depthTest,
            depthWrite: depthWrite,
            primitive: primitive, 
            winding: .counterClockwise,
            blendMode: blendMode
        )
    }
}
