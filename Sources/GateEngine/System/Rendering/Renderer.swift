/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public enum RenderingAPI {
    case headless
    case metal
    case openGL
    case openGLES
    case webGL2
    case d3d12
}

@MainActor public final class Renderer {
    let _backend: any RendererBackend = getDefaultBackend()
    @inline(__always)
    nonisolated public var api: RenderingAPI { _backend.renderingAPI }

    func draw(
        _ renderTarget: any _RenderTargetProtocol,
        into destinationRenderTarget: any _RenderTargetProtocol,
        options: RenderTargetFillOptions,
        sampler: RenderTargetFillSampleFilter
    ) {
        @_transparent
        func matrices(withSize size: Size2) -> Matrices {
            let ortho = Matrix4x4(
                orthographicWithTop: 0,
                left: 0,
                bottom: size.height,
                right: size.width,
                near: 0,
                far: Float(Int32.max)
            )
            let view = Matrix4x4(position: Position3(x: 0, y: 0, z: 1_000_000))
            return Matrices(projection: ortho, view: view)
        }

        let material: Material = Material { material in
            material.channel(0) { channel in
                channel.texture = renderTarget.texture
                if options.contains(.flipHorizontal) {
                    channel.scale.x = -1
                }
                if options.contains(.flipVertical) {
                    channel.scale.y = -1
                }
               
                switch Game.shared.renderer.api {
                case .openGL, .openGLES, .webGL2:
                    channel.scale.y *= -1
                default:
                    break
                }

                switch sampler {
                case .linear:
                    channel.sampleFilter = .linear
                case .nearest:
                    channel.sampleFilter = .nearest
                }
            }
        }
        let size = destinationRenderTarget.size

        let scale = Size3(width: size.width, height: size.height, depth: 1)
        let transform = Transform3(
            position: Position3(size.width / 2, size.height / 2, 0),
            scale: scale
        )
        let matrices = matrices(withSize: size)
        let flags = DrawCommand.Flags(depthTest: .always, depthWrite: .disabled, winding: .clockwise)

        let command = DrawCommand(
            resource: .geometry(.rectOriginCentered),
            transforms: [transform],
            material: material,
            vsh: .renderTarget,
            fsh: .textureSample,
            flags: flags
        )
        if command.isReady {
            _backend.draw(
                command,
                camera: nil,
                matrices: matrices,
                renderTarget: destinationRenderTarget
            )
        }
    }

    func draw(
        _ drawCommand: DrawCommand,
        camera: Camera?,
        matrices: Matrices,
        renderTarget: some _RenderTargetProtocol
    ) {
        self._backend.draw(
            drawCommand,
            camera: camera,
            matrices: matrices,
            renderTarget: renderTarget
        )
    }
}

@MainActor internal protocol RendererBackend {
    nonisolated var renderingAPI: RenderingAPI { get }
    func draw(
        _ drawCommand: DrawCommand,
        camera: Camera?,
        matrices: Matrices,
        renderTarget: some _RenderTargetProtocol
    )
}

@_transparent
@MainActor private func getDefaultBackend() -> any RendererBackend {
    #if GATEENGINE_FORCE_OPNEGL_APPLE
    return OpenGLRenderer()
    #elseif canImport(MetalKit)
    #if canImport(GLKit) && !targetEnvironment(macCatalyst)
    if MetalRenderer.isSupported == false {
        return OpenGLRenderer()
    }
    #endif
    return MetalRenderer()
    #elseif canImport(WebGL2)
    return WebGL2Renderer()
    #elseif canImport(WinSDK)
    return DX12Renderer()
    #elseif canImport(OpenGL_GateEngine)
    return OpenGLRenderer()
    #else
    #error("Not implemented.")
    #endif
}
