/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation
import GameMath

/**
 A Scene is a drawing space with 3 dimentions and a persepctive camera.
 */
@MainActor public struct Scene {
    internal var camera: Camera
    internal var viewport: Rect?
    
    internal var pointLights: Set<ScenePointLight> = []
    internal var spotLights: Set<SceneSpotLight> = []
    internal var directionalLight: SceneDirectionalLight? = nil

    internal var drawCommands: [DrawCommand] = []
    
    /** Adds the camera to the scene
    Each scene can have a single camera. Only the most recent camera is kept.
    - parameter camera: The camera to view the scene from
     */
    @inline(__always)
    public mutating func setCamera(_ camera: Camera) {
        self.camera = camera
    }
    
    @inline(__always)
    public mutating func setViewport(_ viewport: Rect?) {
        self.viewport = viewport
    }
    
    /** Adds geometry to the scene for rendering.
    - parameter geometry: The geometry to draw.
    - parameter material: The color information used to draw the geometry.
    - parameter transform: Describes how the geometry should be positioned and scaled releative to the scene.
    - parameter flags: Options to customize how drawing is handled.
    - Geometry is automatically instanced for performance. There are two types of instancing that happen automatically under the hood.
      1. Simple instancing. This happens when all instances of the same `Geometry` reference have the same `material` and `flags` and differ only by `transform`. This is the most efficient and suitible for things like particles, foliage, and tiles.
      2. Complex instancing. Complex instancing occures if any instance of the same `Geometry` reference has a different material or flags. Complex instancing allows using the same `Geometry` with different materials while still having some.
    - The  instancing is best effort and does not guarantee the same perfromance across platforms or package version. You should test each platform if you use many instances.
    - You may not explicilty choose the instancing, however you could create a new `Geometry` from the same URL wich would have a different id and have seperate instancing. This would allow both instancing types at the expence of an additional GPU resource for each `Geometry` reference.
    */
    @_transparent
    public mutating func insert(_ geometry: Geometry, withMaterial material: Material, at transform: Transform3, flags: SceneElementFlags = .default) {
        self.insert(geometry, withMaterial: material, at: [transform], flags: flags)
    }
    
    /** Adds geometry to the scene for rendering.
    - parameter geometry: The geometry to draw.
    - parameter material: The color information used to draw the geometry.
    - parameter transforms: Describes how each geometry instance should be positioned and scaled releative to the scene.
    - parameter flags: Options to customize how drawing is handled.
    - Explicitly instances the geometry as it's own batch. Use this for known instancing like particles.
    */
    @inline(__always)
    public mutating func insert(_ geometry: Geometry, withMaterial material: Material, at transforms: [Transform3], flags: SceneElementFlags = .default) {
        guard geometry.state == .ready else {return}
        guard material.isReady else {return}
        guard let geometryBackend = geometry.backend else {return}

        let command = DrawCommand(geometries: [geometryBackend], transforms: transforms, material: material, flags: flags.drawFlags)
        self.drawCommands.append(command)
    }
    
    /** Adds geometry to the scene for rendering.
    - parameter geometry: The geometry to draw.
    - parameter material: The color information used to draw the geometry.
    - parameter transform: Describes how the geometry should be positioned and scaled releative to the scene.
    - parameter flags: Options to customize how drawing is handled.
    - Geometry is automatically instanced for performance. There are two types of instancing that happen automatically under the hood.
      1. Simple instancing. This happens when all instances of the same `Geometry` reference have the same `material` and `flags` and differ only by `transform`. This is the most efficient and suitible for things like particles, foliage, and tiles.
      2. Complex instancing. Complex instancing occures if any instance of the same `Geometry` reference has a different material or flags. Complex instancing allows using the same `Geometry` with different materials while still having some.
    - The  instancing is best effort and does not guarantee the same perfromance across platforms or package version. You should test each platform if you use many instances.
    - You may not explicilty choose the instancing, however you could create a new `Geometry` from the same URL wich would have a different id and have seperate instancing. This would allow both instancing types at the expence of an additional GPU resource for each `Geometry` reference.
    */
    @_transparent
    public mutating func insert(_ geometry: SkinnedGeometry, withPose pose: Skeleton.Pose, material: Material, at transform: Transform3, flags: SceneElementFlags = .default) {
        self.insert(geometry, withPose: pose, material: material, at: [transform], flags: flags)
    }
    
    /** Adds geometry to the scene for rendering.
    - parameter geometry: The geometry to draw.
    - parameter material: The color information used to draw the geometry.
    - parameter transforms: Describes how each geometry instance should be positioned and scaled releative to the scene.
    - parameter flags: Options to customize how drawing is handled.
    - Geometry is automatically instanced for performance. There are two types of instancing that happen automatically under the hood.
      1. Simple instancing. This happens when all instances of the same `Geometry` reference have the same `material` and `flags` and differ only by `transform`. This is the most efficient and suitible for things like particles, foliage, and tiles.
      2. Complex instancing. Complex instancing occures if any instance of the same `Geometry` reference has a different material or flags. Complex instancing allows using the same `Geometry` with different materials while still having some.
    - The  instancing is best effort and does not guarantee the same perfromance across platforms or package version. You should test each platform if you use many instances.
    - You may not explicilty choose the instancing, however you could create a new `Geometry` from the same URL wich would have a different id and have seperate instancing. This would allow both instancing types at the expence of an additional GPU resource for each `Geometry` reference.
    */
    @inline(__always)
    public mutating func insert(_ geometry: SkinnedGeometry, withPose pose: Skeleton.Pose, material: Material, at transforms: [Transform3], flags: SceneElementFlags = .default) {
        guard geometry.state == .ready else {return}
        guard material.isReady else {return}
        var material = material
        material.vertexShader = SystemShaders.standardSkinnedVertexShader
        material.setCustomUniformValue(pose.shaderMatrixArray(orderedFromSkinJoints: geometry.skinJoints!), forUniform: "bones")
        guard let geometryBackend = geometry.backend else {return}

        let command = DrawCommand(geometries: [geometryBackend], transforms: transforms, material: material, flags: flags.drawFlags)
        self.drawCommands.append(command)
    }
    
    @inline(__always)
    public mutating func insert(_ source: Geometry, withSourceMaterial sourceMaterial: Material,
                                morphingTo destination: Geometry, withDestinationMaterial destinationMaterial: Material,
                                interpolationFactors factor: Float,
                                at transforms: [Transform3],
                                flags: SceneElementFlags = .default) {
        guard source.state == .ready && destination.state == .ready else {return}
        guard sourceMaterial.isReady && destinationMaterial.isReady else {return}
        guard let sourceGeometryBackend = Game.shared.resourceManager.geometryCache(for: source.cacheKey)?.geometryBackend else {return}
        guard let destinationGeometryBackend = Game.shared.resourceManager.geometryCache(for: destination.cacheKey)?.geometryBackend else {return}

        let command = DrawCommand(geometries: [sourceGeometryBackend, destinationGeometryBackend], transforms: transforms, material: sourceMaterial, flags: flags.drawFlags)
        self.drawCommands.append(command)
    }
    
    @_transparent
    public mutating func insert(_ src: Geometry, withSourceMaterial srcMaterial: Material,
                                morphingTo dst: Geometry, withDestinationMaterial dstMaterial: Material,
                                interpolationFactor factor: Float,
                                at transform: Transform3,
                                flags: SceneElementFlags = .default) {
        self.insert(src, withSourceMaterial: srcMaterial, morphingTo: dst, withDestinationMaterial: dstMaterial, interpolationFactors: factor, at: [transform], flags: flags)
    }

    @_transparent
    public mutating func insert(_ source: Geometry, morphingTo destination: Geometry, withMaterial material: Material,
                                interpolationFactors factor: Float,
                                at transforms: [Transform3],
                                withFlags flags: SceneElementFlags = .default) {
        self.insert(source, withSourceMaterial: material, morphingTo: destination, withDestinationMaterial: material, interpolationFactors: factor, at: transforms, flags: flags)
    }
    
    @_transparent
    public mutating func insert(_ source: Geometry, morphingTo destination: Geometry, withMaterial material: Material,
                                interpolationFactor factor: Float,
                                at transform: Transform3,
                                withFlags flags: SceneElementFlags = .default) {
        self.insert(source, withSourceMaterial: material, morphingTo: destination, withDestinationMaterial: material, interpolationFactors: factor, at: [transform], flags: flags)
    }
    
    @available(*, unavailable, message: "Dynamic lighting is not supported yet.")
    @inline(__always)
    public mutating func insert(_ light: PointLight) {
        guard light.state == .ready else {return}
        self.pointLights.insert(ScenePointLight(light))
    }
    @available(*, unavailable, message: "Dynamic lighting is not supported yet.")
    @inline(__always)
    public mutating func insert(_ light: SpotLight) {
        guard light.state == .ready else {return}
        self.spotLights.insert(SceneSpotLight(light))
    }
    @available(*, unavailable, message: "Dynamic lighting is not supported yet.")
    @inline(__always)
    public mutating func insert(_ light: DirectionalLight) {
        guard light.state == .ready else {return}
        self.directionalLight = SceneDirectionalLight(light)
    }
    
    @_transparent
    internal var hasContent: Bool {
        return drawCommands.isEmpty == false
    }
    
    @_transparent
    internal var hasLights: Bool {
        guard directionalLight != nil else {return true}
        guard pointLights.isEmpty else {return true}
        guard spotLights.isEmpty else {return true}

        return false
    }
    
    @_transparent
    internal var renderTargets: Set<RenderTarget> {
        var renderTargets: Set<RenderTarget> = []
        for command in drawCommands {
            renderTargets.formUnion(command.renderTargets)
        }
        return renderTargets
    }
    
    public init(camera: Camera, viewport: Rect? = nil) {
        self.camera = camera
        self.viewport = viewport
    }
}

internal struct ScenePointLight: Hashable {
    let pointer: PointLight
    let brightness: Float
    let color: SIMD3<Float>
    let radius: Float
    let softness: Float
    let drawShadows: Light.DrawShadows
    let position: SIMD3<Float>

    init(_ pointer: PointLight) {
        self.pointer = pointer
        self.brightness = pointer.brightness
        self.color = SIMD3(pointer.color.red, pointer.color.green, pointer.color.blue)
        self.radius = pointer.radius
        self.softness = pointer.softness
        self.drawShadows = pointer.drawShadows
        self.position = pointer.position.simd
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(pointer.id)
    }
}

internal struct SceneSpotLight: Hashable {
    let pointer: SpotLight
    let brightness: Float
    let color: SIMD3<Float>
    let radius: Float
    let coneAngle: Degrees
    let sharpness: Float
    let drawShadows: Light.DrawShadows
    let position: SIMD3<Float>
    let direction: SIMD3<Float>
    
    init(_ pointer: SpotLight) {
        self.pointer = pointer
        self.brightness = pointer.brightness
        self.color = SIMD3(pointer.color.red, pointer.color.green, pointer.color.blue)
        self.radius = pointer.radius
        self.coneAngle = pointer.coneAngle
        self.sharpness = pointer.sharpness
        self.drawShadows = pointer.drawShadows
        self.position = pointer.position.simd
        self.direction = pointer.direction.simd
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(pointer.id)
    }
}

internal struct SceneDirectionalLight: Hashable {
    let pointer: DirectionalLight
    let brightness: Float
    let color: SIMD3<Float>
    let drawShadows: Light.DrawShadows
    let direction: SIMD3<Float>
    
    init(_ pointer: DirectionalLight) {
        self.pointer = pointer
        self.brightness = pointer.brightness
        self.color = SIMD3(pointer.color.red, pointer.color.green, pointer.color.blue)
        self.drawShadows = pointer.drawShadows
        self.direction = pointer.direction.simd
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(pointer.id)
    }
}


public struct SceneElementFlags: OptionSet, Hashable {
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
    
    @_transparent
    internal var drawFlags: DrawFlags {
        let cull: DrawFlags.Cull = self.contains(.cullBackface) ? .back : .disabled
        let depthTest: DrawFlags.DepthTest = self.contains(.disableDepthCull) ? .always : .lessThan
        let depthWrite: DrawFlags.DepthWrite = self.contains(.disableDepthWrite) ? .disabled : .enabled
        return DrawFlags(cull: cull, depthTest: depthTest, depthWrite: depthWrite, winding: .counterClockwise, blendMode: .normal)
    }
}
