/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Shaders

@MainActor extension VertexShader {
    @usableFromInline
    internal static let renderTarget: VertexShader = {
        let vsh = VertexShader()
        vsh.output.position =
            vsh.modelViewProjectionMatrix * Vec4(vsh.input.geometry(0).position, 1)
        switch Game.shared.renderer.api {
        case .metal, .d3d12:
            vsh.output["texCoord0"] =
                vsh.input.geometry(0).textureCoordinate0 * vsh.channel(0).scale
                + vsh.channel(0).offset
        case .openGL, .openGLES, .webGL2:
            let texCood = vsh.input.geometry(0).textureCoordinate0
            let y = 1.0 - texCood.y
            vsh.output["texCoord0"] =
                Vec2(x: texCood.x, y: y) * vsh.channel(0).scale + vsh.channel(0).offset
        case .headless:
            break
        }
        return vsh
    }()
    public static let standard: VertexShader = {
        let vsh = VertexShader()
        vsh.output.position =
            vsh.modelViewProjectionMatrix * Vec4(vsh.input.geometry(0).position, 1)
        vsh.output["texCoord0"] =
            vsh.input.geometry(0).textureCoordinate0 * vsh.channel(0).scale + vsh.channel(0).offset
        return vsh
    }()

    @usableFromInline
    internal static let skinned: VertexShader = {
        let vsh = VertexShader()
        let bones = vsh.uniform(named: "bones", as: Mat4Array.self, arrayCapacity: 64)
        let jointIndices = vsh.input.geometry(0).jointIndices
        let jointWeights = vsh.input.geometry(0).jointWeights
        var position = Vec4(vsh.input.geometry(0).position, 1)
        position += bones[jointIndices[0]] * position * jointWeights[0]
        position += bones[jointIndices[1]] * position * jointWeights[1]
        position += bones[jointIndices[2]] * position * jointWeights[2]
        position += bones[jointIndices[3]] * position * jointWeights[3]
        vsh.output.position = vsh.modelViewProjectionMatrix * position
        vsh.output["texCoord0"] =
            vsh.input.geometry(0).textureCoordinate0 * vsh.channel(0).scale + vsh.channel(0).offset
        return vsh
    }()

    /// Used by the system to draw point primitives
    @usableFromInline
    internal static let pointSizeAndColor: VertexShader = {
        let vsh = VertexShader()
        vsh.output.position =
            vsh.modelViewProjectionMatrix * Vec4(vsh.input.geometry(0).position, 1)
        vsh.output.pointSize = vsh.uniform(named: "pointSize", as: Scalar.self)
        vsh.output["color"] = vsh.input.geometry(0).color
        return vsh
    }()

    /// Uses the colors in the vertices to shade objects
    /// Intended to be paired with `FragmentShader.vertexColors`
    public static let vertexColors: VertexShader = {
        let vsh = VertexShader()
        let mvp = vsh.modelViewProjectionMatrix
        let vertexPosition = vsh.input.geometry(0).position
        vsh.output.position = mvp * Vec4(vertexPosition, 1)
        vsh.output["color"] = vsh.input.geometry(0).color
        return vsh
    }()

    /// Handles 2 geometries, intended for use with FragmentShader.morphTextureSample
    @usableFromInline
    internal static let morph: VertexShader = {
        let vsh = VertexShader()
        let factor = vsh.uniform(named: "factor", as: Scalar.self)
        let g1 = vsh.input.geometry(0)
        let g2 = vsh.input.geometry(1)
        let position = g1.position.lerp(to: g2.position, factor: factor)
        vsh.output.position = vsh.modelViewProjectionMatrix * Vec4(position, 1)
        vsh.output["texCoord0"] = g1.textureCoordinate0
        vsh.output["texCoord1"] = g2.textureCoordinate0
        return vsh
    }()
}

@MainActor extension FragmentShader {
    /// The same as `textureSample` but with an additional channel for a second geometry
    /// Intended to be used with `VertexShader.morph`
    @usableFromInline
    internal static let morphTextureSample: FragmentShader = {
        let fsh = FragmentShader()
        let factor = fsh.uniform(named: "factor", as: Scalar.self)
        let sample1 = fsh.channel(0).texture.sample(at: fsh.input["texCoord0"])
        let sample2 = fsh.channel(1).texture.sample(at: fsh.input["texCoord1"], filter: .nearest)
        fsh.output.color = sample1.lerp(to: sample2, factor: factor)
        return fsh
    }()
    /// Uses material.channel(0).texture to shade objects
    public static let textureSample: FragmentShader = {
        let fsh = FragmentShader()
        fsh.output.color = fsh.channel(0).texture.sample(
            at: fsh.input["texCoord0"],
            filter: .nearest
        )
        return fsh
    }()
    /// Uses material.channel(0).texture to shade objects
    public static let textureSampleOpacity: FragmentShader = {
        let fsh = FragmentShader()
        fsh.output.color = fsh.channel(0).texture.sample(
            at: fsh.input["texCoord0"],
            filter: .nearest
        ) * fsh.uniform(named: "opacity", as: Scalar.self)
        return fsh
    }()
    /// Uses material.channel(0).color to shade objects
    public static let materialColor: FragmentShader = {
        let fsh = FragmentShader()
        fsh.output.color = fsh.channel(0).color
        return fsh
    }()
    /// Uses the colors in the vertices to shade objects
    /// Intended to be paired with `VertexShader.vertexColors`
    public static let vertexColor: FragmentShader = {
        let fsh = FragmentShader()
        fsh.output.color = fsh.input["color"]
        return fsh
    }()
    /// Uses material.channel(0).texture to shade objects
    public static let textureSampleTintColor: FragmentShader = {
        let fsh = FragmentShader()
        let sample = fsh.channel(0).texture.sample(
            at: fsh.input["texCoord0"],
            filter: .nearest
        )
        fsh.output.color = sample * fsh.channel(0).color
        return fsh
    }()
}
