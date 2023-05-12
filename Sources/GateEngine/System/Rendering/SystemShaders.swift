/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Shaders

public enum SystemShaders {
    public static let renderTargetVertexShader: VertexShader = {
        let vsh = VertexShader()
        vsh.output.position = vsh.modelViewProjectionMatrix * Vec4(vsh.input.geometry(0).position, 1)
        #if os(WASI)
        let texCood = vsh.input.geometry(0).textureCoordinate0
        let y = 1.0 - texCood.y
        vsh.output["texCoord0"] = Vec2(x: texCood.x, y: y) * vsh.channel(0).scale + vsh.channel(0).offset
        #else
        vsh.output["texCoord0"] = vsh.input.geometry(0).textureCoordinate0 * vsh.channel(0).scale + vsh.channel(0).offset
        #endif
        return vsh
    }()
    public static let standardVertexShader: VertexShader = {
        let vsh = VertexShader()
        vsh.output.position = vsh.modelViewProjectionMatrix * Vec4(vsh.input.geometry(0).position, 1)
        vsh.output["texCoord0"] = vsh.input.geometry(0).textureCoordinate0 * vsh.channel(0).scale + vsh.channel(0).offset
        return vsh
    }()
    public static let standardSkinnedVertexShader: VertexShader = {
        let vsh = VertexShader()
        let bones = vsh.uniform(named: "bones", as: Mat4Array.self, arrayCapacity: 24)
        let jointIndicies = vsh.input.geometry(0).jointIndicies
        let jointWeights = vsh.input.geometry(0).jointWeights
        var position = Vec4(vsh.input.geometry(0).position, 1)
        position += bones[jointIndicies[0]] * position * jointWeights[0]
        position += bones[jointIndicies[1]] * position * jointWeights[1]
        position += bones[jointIndicies[2]] * position * jointWeights[2]
        position += bones[jointIndicies[3]] * position * jointWeights[3]
        vsh.output.position = vsh.modelViewProjectionMatrix * position
        vsh.output["texCoord0"] = vsh.input.geometry(0).textureCoordinate0 * vsh.channel(0).scale + vsh.channel(0).offset
        return vsh
    }()
    public static let pointSizeAndColorVertexShader: VertexShader = {
        let vsh = VertexShader()
        vsh.output.position = vsh.modelViewProjectionMatrix * Vec4(vsh.input.geometry(0).position, 1)
        vsh.output.pointSize = vsh.uniform(named: "pointSize", as: Scalar.self)
        vsh.output["color"] = vsh.input.geometry(0).color
        return vsh
    }()
    public static let colorsVertexShader: VertexShader = {
        let vsh = VertexShader()
        vsh.output.position = vsh.modelViewProjectionMatrix * Vec4(vsh.input.geometry(0).position, 1)
        vsh.output["color"] = vsh.input.geometry(0).color
        return vsh
    }()
    public static let morphVertexShader: VertexShader = {
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
    public static let morphFragmentShader: FragmentShader = {
        let fsh = FragmentShader()
        let factor = fsh.uniform(named: "factor", as: Scalar.self)
        let sample1 = fsh.channel(0).texture.sample(at: fsh.input["texCoord0"])
        let sample2 = fsh.channel(1).texture.sample(at: fsh.input["texCoord1"], filter: .nearest)
        fsh.output.color = sample1.lerp(to: sample2, factor: factor)
        return fsh
    }()
    public static let textureSampleFragmentShader: FragmentShader = {
        let fsh = FragmentShader()
        fsh.output.color = fsh.channel(0).texture.sample(at: fsh.input["texCoord0"], filter: .nearest)
        return fsh
    }()
    public static let materialColorFragmentShader: FragmentShader = {
        let fsh = FragmentShader()
        fsh.output.color = fsh.channel(0).color
        return fsh
    }()
    public static let vertexColorFragmentShader: FragmentShader = {
        let fsh = FragmentShader()
        fsh.output.color = fsh.input["color"]
        return fsh
    }()
}
