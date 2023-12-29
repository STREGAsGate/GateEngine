/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

/// A Canvas is a drawing space with no depth and an orthographic camera.
@MainActor public struct Canvas {
    let interfaceScale: Float
    internal var viewOrigin: Position2? = nil
    internal var viewport: Rect? = nil
    private var _scissorRect: Rect? = nil
    internal var scissorRect: Rect? {
        if let _scissorRect {
            return _scissorRect * interfaceScale
        }
        return nil
    }

    internal var size: Size2? = nil
    internal var camera: Camera? = nil

    @usableFromInline 
    internal var _drawCommands: ContiguousArray<DrawCommand> = []
    
    @_transparent 
    public mutating func insert(_ drawCommand: DrawCommand) {
        guard drawCommand.isReady else {return}
        _drawCommands.append(drawCommand)
    }
    
    public mutating func setCamera(_ camera: Camera, size: Size2) {
        self.camera = camera
        self.size = size
    }
    
    /**
     Changes the location of the 2D camera for this Canvas.
     
     - parameter viewOrigin: The top left corner location for the camera
     */
    public mutating func setViewOrigin(_ viewOrigin: Position2) {
        self.viewOrigin = viewOrigin
    }
    
    public mutating func setViewport(_ viewport: Rect?) {
        self.viewport = viewport
    }
    
    /**
     Applys a clip rectangle to all content in this Canvas.
     
     - parameter scissorRect: The area within this Rect will be drawn.
     */
    public mutating func setScissorRect(_ scissorRect: Rect?) {
        self._scissorRect = scissorRect
    }

    public mutating func insert(
        _ points: Points,
        pointSize: Float = 1,
        at position: Position2,
        rotation: some Angle = Radians.zero,
        scale: Size2 = .one,
        depth: Float = 0,
        opacity: Float = 1,
        flags: CanvasElementPrimitiveFlags = .default
    ) {
        let position = Position3(position.x, position.y, depth * -1)
        let scale = Size3(scale.x, scale.y, 1)
        let rotation = Quaternion(rotation, axis: .forward)
        let transform = Transform3(position: position, rotation: rotation, scale: scale)

        let material = Material { material in
            material.setCustomUniformValue(pointSize, forUniform: "pointSize")
        }
        let flags = DrawCommand.Flags(
            cull: .back,
            depthTest: .lessEqual,
            depthWrite: .enabled,
            primitive: .point,
            winding: .clockwise,
            blendMode: .normal
        )
        let command = DrawCommand(
            resource: .points(points),
            transforms: [transform],
            material: material,
            vsh: .pointSizeAndColor,
            fsh: .vertexColor,
            flags: flags
        )
        self.insert(command)
    }

    public mutating func insert(
        _ lines: Lines,
        at position: Position2,
        rotation: some Angle = Radians.zero,
        scale: Size2 = .one,
        depth: Float = 0,
        opacity: Float = 1,
        flags: CanvasElementPrimitiveFlags = .default
    ) {
        let position = Position3(position.x, position.y, depth * -1)
        let scale = Size3(scale.x, scale.y, 1)
        let rotation = Quaternion(rotation, axis: .forward)
        let transform = Transform3(position: position, rotation: rotation, scale: scale)

        let flags = DrawCommand.Flags(
            cull: .back,
            depthTest: .lessEqual,
            depthWrite: .enabled,
            primitive: .line,
            winding: .clockwise,
            blendMode: .normal
        )
        let command = DrawCommand(
            resource: .lines(lines),
            transforms: [transform],
            material: Material(),
            vsh: .vertexColors,
            fsh: .vertexColor,
            flags: flags
        )
        self.insert(command)
    }

    public mutating func insert(
        _ rect: Rect,
        color: Color,
        at position: Position2,
        rotation: some Angle = Radians.zero,
        scale: Size2 = .one,
        depth: Float = 0,
        opacity: Float = 1,
        flags: CanvasElementPrimitiveFlags = .default
    ) {
        let position = Position3(
            position.x + rect.position.x,
            position.y + rect.position.y,
            depth * -1
        )
        let scale = Size3(scale.x, scale.y, 1) * Size3(rect.size.width, rect.size.height, 1)
        let rotation = Quaternion(rotation, axis: .forward)
        let transform = Transform3(position: position, rotation: rotation, scale: scale)

        let material = Material(color: color.withAlpha(opacity))
        let flags = DrawCommand.Flags(
            cull: .disabled,
            depthTest: .always,
            depthWrite: .disabled,
            primitive: .triangle,
            winding: .clockwise,
            blendMode: .normal
        )
        let command = DrawCommand(
            resource: .geometry(.rectOriginTopLeft),
            transforms: [transform],
            material: material,
            vsh: .standard,
            fsh: .materialColor,
            flags: flags
        )
        self.insert(command)
    }
    
    public mutating func insert(
        _ texture: Texture,
        subRect: Rect? = nil,
        at position: Position2,
        rotation: some Angle = Radians.zero,
        scale: Size2 = .one,
        depth: Float = 0,
        opacity: Float = 1,
        sampleFilter: Material.Channel.SampleFilter = .linear,
        flags: CanvasElementSpriteFlags = .default
    ) {
        let position = Position3(position.x, position.y, depth * -1)
        let scale = Size3(scale.x, scale.y, 1)
        let rotation = Quaternion(rotation, axis: .forward)
        let transform = Transform3(position: position, rotation: rotation, scale: scale)

        let material = Material { material in
            material.channel(0) { channel in
                channel.texture = texture
                channel.sampleFilter = sampleFilter
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
            material.setCustomUniformValue(opacity, forUniform: "opacity")
        }

        let flags = DrawCommand.Flags(
            cull: .disabled,
            depthTest: .always,
            depthWrite: .disabled,
            primitive: .triangle,
            winding: .clockwise,
            blendMode: .normal
        )
        let command = DrawCommand(
            resource: .geometry(.rectOriginTopLeft),
            transforms: [transform],
            material: material,
            vsh: .standard,
            fsh: .textureSampleOpacity,
            flags: flags
        )
        self.insert(command)
    }

    public mutating func insert(
        _ sprite: Sprite,
        at position: Position2,
        rotation: some Angle = Radians.zero,
        scale: Size2 = .one,
        depth: Float = 0,
        opacity: Float = 1,
        blendingMode: DrawCommand.Flags.BlendMode = .normal,
        flags: CanvasElementSpriteFlags = .default
    ) {
        let position = Position3(position.x, position.y, depth * -1)
        let scale = Size3(scale.x, scale.y, 1) * sprite.geometryScale
        let rotation = Quaternion(rotation, axis: .forward)
        let transform = Transform3(position: position, rotation: rotation, scale: scale)

        let material = Material { material in
            material.channel(0) { channel in
                channel.texture = sprite.texture
                channel.scale = sprite.uvScale
                channel.offset = sprite.uvOffset
                channel.sampleFilter = sprite.sampleFilter
            }
            material.setCustomUniformValue(opacity, forUniform: "opacity")
        }

        let flags = DrawCommand.Flags(
            cull: .disabled,
            depthTest: .always,
            depthWrite: .disabled,
            primitive: .triangle,
            winding: .clockwise,
            blendMode: blendingMode
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
    
    public mutating func insert(
        _ sprite: Sprite,
        at transform: Transform3,
        opacity: Float = 1,
        flags: CanvasElementSpriteFlags = .default
    ) {
        let material = Material { material in
            material.channel(0) { channel in
                channel.texture = sprite.texture
                channel.scale = sprite.uvScale
                channel.offset = sprite.uvOffset
            }
            material.setCustomUniformValue(opacity, forUniform: "opacity")
        }

        let flags = DrawCommand.Flags(
            cull: .disabled,
            depthTest: .always,
            depthWrite: .disabled,
            primitive: .triangle,
            winding: .clockwise,
            blendMode: .normal
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

    public mutating func insert(
        _ text: Text,
        at position: Position2,
        rotation: any Angle = Radians.zero,
        scale: Size2 = .one,
        depth: Float = 0,
        opacity: Float = 1,
        flags: CanvasElementTextFlags = .default
    ) {
        guard text.string.isEmpty == false else { return }
        text.interfaceScale = self.interfaceScale
        guard text.isReady else { return }

        let position = Position3(position.x, position.y, depth * -1)
        let scale = Size3(scale.x, scale.y, 1)
        let rotation = Quaternion(rotation, axis: .forward)
        let transform = Transform3(position: position, rotation: rotation, scale: scale)

        let material = Material(texture: text.texture, sampleFilter: text.sampleFilter, tintColor: text.color.withAlpha(opacity))
        
        let flags = DrawCommand.Flags(
            cull: .disabled,
            depthTest: .always,
            depthWrite: .disabled,
            primitive: .triangle,
            winding: .clockwise,
            blendMode: .normal
        )
        let command = DrawCommand(
            resource: .geometry(text.geometry),
            transforms: [transform],
            material: material,
            vsh: .standard,
            fsh: .textureSampleTintColor,
            flags: flags
        )
        self.insert(command)
    }

    public mutating func insert(
        _ geometry: Geometry,
        withMaterial material: Material,
        at position: Position2,
        rotation: some Angle = Radians.zero,
        scale: Size2 = .one,
        depth: Float = 0,
        flags: SceneElementFlags = .default
    ) {
        let position = Position3(position.x, position.y, depth * -1)
        let scale = Size3(scale.x, scale.y, 1)
        let rotation = Quaternion(rotation, axis: .forward)
        let transform = Transform3(position: position, rotation: rotation, scale: scale)
        var drawFlags = flags.drawCommandFlags(withPrimitive: .triangle)
        drawFlags.depthTest = .lessEqual
        let command = DrawCommand(
            resource: .geometry(geometry),
            transforms: [transform],
            material: material,
            vsh: .standard,
            fsh: (material.channels.first?.texture != nil) ? .textureSampleTintColor : .materialColor,
            flags: drawFlags
        )
        self.insert(command)
    }
    
    /** Adds geometry to the canvas for rendering.
    - parameter geometry: The geometry to draw.
    - parameter material: The color information used to draw the geometry.
    - parameter transforms: Describes how each geometry instance should be positioned and scaled relative to the canvas.
    - parameter flags: Options to customize how drawing is handled.
    - Geometry is automatically instanced for performance. There are two types of instancing that happen automatically under the hood.
      1. Simple instancing. This happens when all instances of the same `Geometry` reference have the same `material` and `flags` and differ only by `transform`. This is the most efficient and suitible for things like particles, foliage, and tiles.
      2. Complex instancing. Complex instancing occurs if any instance of the same `Geometry` reference has a different material or flags. Complex instancing allows using the same `Geometry` with different materials while still having some.
    - The  instancing is best effort and does not guarantee the same performance across platforms or package version. You should test each platform if you use many instances.
    - You may not explicitly choose the instancing, however you could create a new `Geometry` from the same URL which would have a different id and have separate instancing. This would allow both instancing types at the expense of an additional GPU resource for each `Geometry` reference.
    */
    @inlinable @inline(__always)
    public mutating func insert(
        _ skinnedGeometry: SkinnedGeometry,
        withPose pose: Skeleton.Pose,
        material: Material,
        at transforms: [Transform3],
        opacity: Float = 1,
        flags: SceneElementFlags = .default
    ) {
        guard skinnedGeometry.isReady else {return}
        var material = material
        material.setCustomUniformValue(
            pose.shaderMatrixArray(orderedFromSkinJoints: skinnedGeometry.skinJoints),
            forUniform: "bones"
        )
        material.setCustomUniformValue(
            opacity, 
            forUniform: "opacity"
        )

        let command = DrawCommand(
            resource: .skinned(skinnedGeometry),
            transforms: transforms,
            material: material,
            vsh: .skinned,
            fsh: (material.channels.first?.texture != nil) ? .textureSampleOpacity : .materialColor,
            flags: flags.drawCommandFlags(withPrimitive: .triangle)
        )
        self.insert(command)
    }

    /**
     Get a canvas position for a scene position.

     This function requires you to first call `setCamera(_:size:)`.
     - returns: A 2D position representing the location of a 3D object.
     */
    public func convertFrom3DSpace(_ position: Position3) -> Position2 {
        guard let camera = camera else {
            preconditionFailure("Must set camera during `Canvas.init` to use \(#function).")
        }
        guard let size = size else {
            preconditionFailure("Must set size during `Canvas.init` to use \(#function).")
        }

        let matricies = camera.matricies(withAspectRatio: size.aspectRatio)
        var position = position * matricies.viewProjection()
        position.x /= position.z
        position.y /= position.z

        position.x = size.width * (position.x + 1) / 2
        position.y = size.height * (1.0 - ((position.y + 1) / 2))

        position.x /= self.interfaceScale
        position.y /= self.interfaceScale

        return Position2(position.x, position.y)
    }

    public func convertTo3DSpace(_ position: Position2) -> Ray3D {
        guard let camera = camera else {
            preconditionFailure("Must set camera during `Canvas.init` to use \(#function).")
        }
        guard let size = size else {
            preconditionFailure("Must set size during `Canvas.init` to use \(#function).")
        }

        let halfSize = size / 2
        let aspectRatio = size.aspectRatio

        let inverseView = camera.matricies(withAspectRatio: aspectRatio).view.inverse
        let halfFOV = tan(camera.fieldOfViewAsRadians.rawValue * 0.5)
        let near = camera.clippingPlane.near
        let far = camera.clippingPlane.far

        let dx = halfFOV * (position.x / halfSize.width - 1.0) * aspectRatio
        let dy = halfFOV * (1.0 - position.y / halfSize.height)

        let p1 = Position3(dx * near, dy * near, near) * inverseView
        let p2 = Position3(dx * far, dy * far, far) * inverseView

        return Ray3D(from: p1, toward: p2)
    }

    /**
     Create a canvas.

     - parameter camera: An optional Scene camera, which is required for 3D space conversions.
     - parameter size: The exact size of the canvas, this should be the saizxe of your renderTarget.
     - parameter interfaceScale: The userInterface scale. Sometimes called HiDPI. This setting changes how some drawable items are laid out. Use `1` for traditional gaming style drawing.
     - parameter estimatedCommandCount: A performance hint of how many commands will be added.
     */
    public init(
        camera: Camera? = nil,
        size: Size2? = nil,
        interfaceScale: Float = 1,
        estimatedCommandCount: Int = 10
    ) {
        self.interfaceScale = interfaceScale
        self.size = size
        self.camera = camera

        self._drawCommands.reserveCapacity(estimatedCommandCount)
    }

    /**
     Create a canvas.

     - parameter camera: An optional Scene camera, which is required for 3D space conversions.
     - parameter window: The Window this canvas will be added to.
     - parameter estimatedCommandCount: A performance hint of how many commands will be added.
     */
    @_transparent
    public init(window: Window, camera: Camera? = nil, estimatedCommandCount: Int = 10) {
        self.init(
            camera: camera,
            size: window.size,
            interfaceScale: window.interfaceScale,
            estimatedCommandCount: estimatedCommandCount
        )
    }

    @_transparent
    internal var hasContent: Bool {
        return _drawCommands.isEmpty == false
    }

    internal func matrices(withSize size: Size2) -> Matrices {
        let ortho = Matrix4x4(
            orthographicWithTop: 0,
            left: 0,
            bottom: size.height,
            right: size.width,
            near: 0,
            far: Float(Int32.max)
        )
        let view =
            Matrix4x4(
                position: Position3(
                    x: -(viewOrigin?.x ?? 0),
                    y: -(viewOrigin?.y ?? 0),
                    z: 1_000_000
                )
            ) * Matrix4x4(scale: Size3(interfaceScale, interfaceScale, 1))
        return Matrices(projection: ortho, view: view)
    }
}

public struct CanvasElementSpriteFlags: OptionSet {
    public typealias RawValue = UInt32
    public let rawValue: RawValue

    public static let flipHorizontal = CanvasElementSpriteFlags(rawValue: 1 << 1)
    public static let flipVertical = CanvasElementSpriteFlags(rawValue: 1 << 2)
    public static let flipDiagonal = CanvasElementSpriteFlags(rawValue: 1 << 3)

    public static let `default`: CanvasElementSpriteFlags = []

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

public struct CanvasElementTextFlags: OptionSet {
    public typealias RawValue = UInt32
    public let rawValue: RawValue

    public static let flipHorizontal = CanvasElementTextFlags(rawValue: 1 << 1)
    public static let flipVertical = CanvasElementTextFlags(rawValue: 1 << 2)
    public static let flipDiagonal = CanvasElementTextFlags(rawValue: 1 << 3)

    public static let `default`: CanvasElementTextFlags = []

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

public struct CanvasElementPrimitiveFlags: OptionSet {
    public typealias RawValue = UInt32
    public let rawValue: RawValue

    public static let `default`: CanvasElementPrimitiveFlags = []

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}
