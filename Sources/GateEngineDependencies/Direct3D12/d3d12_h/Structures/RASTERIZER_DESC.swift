/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes rasterizer state.
public struct D3DRasterizerDescription {
    public typealias RawValue = WinSDK.D3D12_RASTERIZER_DESC
    internal var rawValue: RawValue

    /// A D3D12_FILL_MODE-typed value that specifies the fill mode to use when rendering.
    public var fillMode: D3DFillMode {
        get {
            return D3DFillMode(rawValue.FillMode)
        }
        set {
            rawValue.FillMode = newValue.rawValue
        }
    }

    /// A D3D12_CULL_MODE-typed value that specifies that triangles facing the specified direction are not drawn.
    public var cullMode: D3DCullMode {
        get {
            return D3DCullMode(rawValue.CullMode)
        }
        set {
            rawValue.CullMode = newValue.rawValue
        }
    }

    /// Determines if a triangle is front- or back-facing. If this member is TRUE, a triangle will be considered front-facing if its vertices are counter-clockwise on the render target and considered back-facing if they are clockwise. If this parameter is FALSE, the opposite is true.
    public var windingDirection: D3DWindingDirection {
        get {
            return rawValue.FrontCounterClockwise.boolValue ? .counterClockwise : .clockwise
        }
        set {
            rawValue.FrontCounterClockwise = WindowsBool(booleanLiteral: newValue == .counterClockwise)
        }
    }

    /// Depth value added to a given pixel. For info about depth bias, see Depth Bias.
    public var depthBias: Int32 {
        get {
            return rawValue.DepthBias
        }
        set {
            rawValue.DepthBias = newValue
        }
    }

    /// Maximum depth bias of a pixel. For info about depth bias, see Depth Bias.
    public var depthBiasClamp: Float {
        get {
            return rawValue.DepthBiasClamp
        }
        set {
            rawValue.DepthBiasClamp = newValue
        }
    }

    /// Scalar on a given pixel's slope. For info about depth bias, see Depth Bias.
    public var slopeScaledDepthBias: Float {
        get {
            return rawValue.SlopeScaledDepthBias
        }
        set {
            rawValue.SlopeScaledDepthBias = newValue
        }
    }

    /// Specifies whether to enable clipping based on distance.
    public var shouldClipDepth: Bool {
        get {
            return rawValue.DepthClipEnable.boolValue
        }
        set {
            rawValue.DepthClipEnable = WindowsBool(booleanLiteral: newValue)
        }
    }

    /// Specifies whether to use the quadrilateral or alpha line anti-aliasing algorithm on multisample antialiasing (MSAA) render targets. Set to TRUE to use the quadrilateral line anti-aliasing algorithm and to FALSE to use the alpha line anti-aliasing algorithm. For more info about this member, see Remarks.
    public var shouldMultisample: Bool {
        get {
            return rawValue.MultisampleEnable.boolValue
        }
        set {
            rawValue.MultisampleEnable = WindowsBool(booleanLiteral: newValue)
        }
    }

    /// Specifies whether to enable line antialiasing; only applies if doing line drawing and MultisampleEnable is FALSE. For more info about this member, see Remarks.
    public var shouldAntialiasedLines: Bool {
        get {
            return rawValue.AntialiasedLineEnable.boolValue
        }
        set {
            rawValue.AntialiasedLineEnable = WindowsBool(booleanLiteral: newValue)
        }
    }

    /// The sample count that is forced while UAV rendering or rasterizing. Valid values are 0, 1, 2, 4, 8, and optionally 16. 0 indicates that the sample count is not forced.
    public var forcedSampleCount: UInt32 {
        get {
            return rawValue.ForcedSampleCount
        }
        set {
            rawValue.ForcedSampleCount = newValue
        }
    }

    /// A D3D12_CONSERVATIVE_RASTERIZATION_MODE-typed value that identifies whether conservative rasterization is on or off.
    public var conservativeRaster: D3DConservativeRasterizationMode {
        get {
            return D3DConservativeRasterizationMode(rawValue.ConservativeRaster)
        }
        set {
            rawValue.ConservativeRaster = newValue.rawValue
        }
    }

    /** Describes rasterizer state.
    - parameter fillMode: A D3D12_FILL_MODE-typed value that specifies the fill mode to use when rendering.
    - parameter cullMode: A D3D12_CULL_MODE-typed value that specifies that triangles facing the specified direction are not drawn.
    - parameter windingDirection: Determines if a triangle is front- or back-facing. If this member is TRUE, a triangle will be considered front-facing if its vertices are counter-clockwise on the render target and considered back-facing if they are clockwise. If this parameter is FALSE, the opposite is true.
    - parameter depthBias: Depth value added to a given pixel. For info about depth bias, see Depth Bias.
    - parameter depthBiasClamp: Maximum depth bias of a pixel. For info about depth bias, see Depth Bias.
    - parameter slopeScaledDepthBias: Scalar on a given pixel's slope. For info about depth bias, see Depth Bias.
    - parameter shouldClipDepth: Specifies whether to enable clipping based on distance.
    - parameter shouldMultisample: Specifies whether to use the quadrilateral or alpha line anti-aliasing algorithm on multisample antialiasing (MSAA) render targets. Set to TRUE to use the quadrilateral line anti-aliasing algorithm and to FALSE to use the alpha line anti-aliasing algorithm. For more info about this member, see Remarks.
    - parameter shouldAntialiasedLines: Specifies whether to enable line antialiasing; only applies if doing line drawing and MultisampleEnable is FALSE. For more info about this member, see Remarks.
    - parameter forcedSampleCount: The sample count that is forced while UAV rendering or rasterizing. Valid values are 0, 1, 2, 4, 8, and optionally 16. 0 indicates that the sample count is not forced.
    - parameter conservativeRaster: A D3D12_CONSERVATIVE_RASTERIZATION_MODE-typed value that identifies whether conservative rasterization is on or off.
    */
    public init(fillMode: D3DFillMode = .solid,
                cullMode: D3DCullMode = .back,
                windingDirection: D3DWindingDirection = .counterClockwise,
                depthBias: Int32 = 0,
                depthBiasClamp: Float = 0,
                slopeScaledDepthBias: Float = 0,
                shouldClipDepth: Bool = true,
                shouldMultisample: Bool = false,
                shouldAntialiasedLines: Bool = false,
                forcedSampleCount: UInt32 = 0,
                conservativeRaster: D3DConservativeRasterizationMode = .off) {
        self.rawValue = RawValue()
        self.fillMode = fillMode
        self.cullMode = cullMode
        self.windingDirection = windingDirection
        self.depthBias = depthBias
        self.depthBiasClamp = depthBiasClamp
        self.slopeScaledDepthBias = slopeScaledDepthBias
        self.shouldClipDepth = shouldClipDepth
        self.shouldMultisample = shouldMultisample
        self.shouldAntialiasedLines = shouldAntialiasedLines
        self.forcedSampleCount = forcedSampleCount
        self.conservativeRaster = conservativeRaster
    }

    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DRasterizerDescription")
public typealias D3D12_RASTERIZER_DESC = D3DRasterizerDescription

#endif
