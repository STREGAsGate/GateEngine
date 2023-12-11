/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Shaders

extension VertexShader {
    public static let positionOnly: VertexShader = {
        let vsh = VertexShader()
        vsh.output.position =
            vsh.modelViewProjectionMatrix * Vec4(vsh.input.geometry(0).position, 1)
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
    
    public static let skinned: VertexShader = {
        let vsh = VertexShader()
        let bones = vsh.uniforms.value(named: "bones", as: Mat4Array.self, arrayCapacity: 64)
        let jointIndices = vsh.input.geometry(0).jointIndices
        let jointWeights = vsh.input.geometry(0).jointWeights
        var vertex = Vec4(vsh.input.geometry(0).position, 1)
        let position = bones[jointIndices[0]] * vertex * jointWeights[0]
        + bones[jointIndices[1]] * vertex * jointWeights[1]
        + bones[jointIndices[2]] * vertex * jointWeights[2]
        + bones[jointIndices[3]] * vertex * jointWeights[3]
        vsh.output.position = vsh.modelViewProjectionMatrix * position
        vsh.output["texCoord0"] =
            vsh.input.geometry(0).textureCoordinate0 * vsh.channel(0).scale + vsh.channel(0).offset
        return vsh
    }()

    /// Used by the system to draw point primitives
    public static let pointSizeAndColor: VertexShader = {
        let vsh = VertexShader()
        vsh.output.position =
            vsh.modelViewProjectionMatrix * Vec4(vsh.input.geometry(0).position, 1)
        vsh.output.pointSize = vsh.uniforms["pointSize"]
        vsh.output["color"] = vsh.input.geometry(0).color
        return vsh
    }()
    
    /// Handles 2 geometries, intended for use with FragmentShader.morphTextureSample
    public static let morph: VertexShader = {
        let vsh = VertexShader()
        let factor: Scalar = vsh.uniforms["factor"]
        let g1 = vsh.input.geometry(0)
        let g2 = vsh.input.geometry(1)
        let position = g1.position.lerp(to: g2.position, factor: factor)
        vsh.output.position = vsh.modelViewProjectionMatrix * Vec4(position, 1)
        vsh.output["texCoord0"] = g1.textureCoordinate0
        vsh.output["texCoord1"] = g2.textureCoordinate0
        return vsh
    }()
}

extension FragmentShader {
    /// Uses material.channel(0).texture to shade objects
    public static let textureSample: FragmentShader = {
        let fsh = FragmentShader()
        fsh.output.color = fsh.channel(0).texture.sample(
            at: fsh.input["texCoord0"]
        )
        return fsh
    }()
    /// Uses material.channel(0).texture to shade objects
    public static let textureSampleDiscardZeroAlpha: FragmentShader = {
        let fsh = FragmentShader()
        let sample = fsh.channel(0).texture.sample(
            at: fsh.input["texCoord0"]
        )
        fsh.output.color = sample.discard(if: sample.a <= 0)
        return fsh
    }()
    /// Uses material.channel(0).texture to shade objects
    public static let textureSampleOpacity: FragmentShader = {
        let fsh = FragmentShader()
        let opacity: Scalar = fsh.uniforms["opacity"]
        fsh.output.color = fsh.channel(0).texture.sample(
            at: fsh.input["texCoord0"]
        ) * opacity
        return fsh
    }()
    /// Uses material.channel(0).texture to shade objects
    public static let textureSampleTintColorOpacity_DiscardZeroAlpha: FragmentShader = {
        let fsh = FragmentShader()
        let opacity: Scalar = fsh.uniforms["opacity"]
        let color = fsh.channel(0).texture.sample(
            at: fsh.input["texCoord0"]
        ) * opacity
        
        fsh.output.color = fsh.channel(0).color * color.discard(if: color.a <= 0)
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
            at: fsh.input["texCoord0"]
        )
        fsh.output.color = sample * fsh.channel(0).color
        return fsh
    }()
    
    /// The same as `textureSample` but with an additional channel for a second geometry
    /// Intended to be used with `VertexShader.morph`
    @usableFromInline
    static let morphTextureSample: FragmentShader = {
        let fsh = FragmentShader()
        let factor: Scalar = fsh.uniforms["factor"]
        let sample1 = fsh.channel(0).texture.sample(at: fsh.input["texCoord0"])
        let sample2 = fsh.channel(1).texture.sample(at: fsh.input["texCoord1"])
        fsh.output.color = sample1.lerp(to: sample2, factor: factor)
        return fsh
    }()
}


// MARK: - GateEngine Internal

internal extension VertexShader {
    @MainActor static let renderTarget: VertexShader = {
        let vsh = VertexShader(name: "renderTarget")
        vsh.output.position =
        vsh.modelViewProjectionMatrix * Vec4(vsh.input.geometry(0).position, 1)
        let texCoord = vsh.input.geometry(0).textureCoordinate0
        vsh.output["texCoord0"] = texCoord * vsh.channel(0).scale + vsh.channel(0).offset
        return vsh
    }()
}

internal extension FragmentShader {

}
