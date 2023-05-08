/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the blend state for a render target.
public struct D3DRenderTargetBlendDescription {
    public typealias RawValue = WinSDK.D3D12_RENDER_TARGET_BLEND_DESC
    internal var rawValue: RawValue

    /** Specifies whether to enable (or disable) blending. Set to TRUE to enable blending.
    - note: It's not valid for LogicOpEnable and BlendEnable to both be TRUE.
    */
    public var blendEnabled: Bool {
        get {
            return rawValue.BlendEnable.boolValue
        }
        set {
            rawValue.BlendEnable = WindowsBool(booleanLiteral: newValue)
        }
    }

    /** Specifies whether to enable (or disable) a logical operation. Set to TRUE to enable a logical operation.
    - note: It's not valid for LogicOpEnable and BlendEnable to both be TRUE.
    */
    public var logicOperationEnabled: Bool {
        get {
            return rawValue.LogicOpEnable.boolValue
        }
        set {
            rawValue.LogicOpEnable = WindowsBool(booleanLiteral: newValue)
        }
    }

    /// A D3D12_BLEND-typed value that specifies the operation to perform on the RGB value that the pixel shader outputs. The BlendOp member defines how to combine the SrcBlend and DestBlend operations.
    public var sourceBlend: D3DBlendFactor {
        get {
            return D3DBlendFactor(rawValue.SrcBlend)
        }
        set {
            rawValue.SrcBlend = newValue.rawValue
        }
    }

    /// A D3D12_BLEND-typed value that specifies the operation to perform on the current RGB value in the render target. The BlendOp member defines how to combine the SrcBlend and DestBlend operations.
    public var destinationBlend: D3DBlendFactor {
        get {
            return D3DBlendFactor(rawValue.DestBlend)
        }
        set {
            rawValue.DestBlend = newValue.rawValue
        }
    }

    /// A D3D12_BLEND_OP-typed value that defines how to combine the SrcBlend and DestBlend operations.
    public var blendOperation: D3DBlendOperation {
        get {
            return D3DBlendOperation(rawValue.BlendOp)
        }
        set {
            rawValue.BlendOp = newValue.rawValue
        }
    }

    /// A D3D12_BLEND-typed value that specifies the operation to perform on the alpha value that the pixel shader outputs. Blend options that end in _COLOR are not allowed. The BlendOpAlpha member defines how to combine the SrcBlendAlpha and DestBlendAlpha operations.
    public var sourceBlendAlpha: D3DBlendFactor {
        get {
            return D3DBlendFactor(rawValue.SrcBlendAlpha)
        }
        set {
            rawValue.SrcBlendAlpha = newValue.rawValue
        }
    }

    /// A D3D12_BLEND-typed value that specifies the operation to perform on the current alpha value in the render target. Blend options that end in _COLOR are not allowed. The BlendOpAlpha member defines how to combine the SrcBlendAlpha and DestBlendAlpha operations.
    public var destinationBlendAlpha: D3DBlendFactor {
        get {
            return D3DBlendFactor(rawValue.DestBlendAlpha)
        }
        set {
            rawValue.DestBlendAlpha = newValue.rawValue
        }
    }

    /// A D3D12_BLEND_OP-typed value that defines how to combine the SrcBlendAlpha and DestBlendAlpha operations.
    public var blendAlphaOperation: D3DBlendOperation {
        get {
            return D3DBlendOperation(rawValue.BlendOpAlpha)
        }
        set {
            rawValue.BlendOpAlpha = newValue.rawValue
        }
    }

    /// A D3D12_LOGIC_OP-typed value that specifies the logical operation to configure for the render target.
    public var logicOperation: D3DLogicOperation {
        get {
            return D3DLogicOperation(rawValue.LogicOp)
        }
        set {
            rawValue.LogicOp = newValue.rawValue
        }
    }

    /// A combination of D3D12_COLOR_WRITE_ENABLE-typed values that are combined by using a bitwise OR operation. The resulting value specifies a write mask.
    public var renderTargetWriteMask: D3DColorWriteEnable {
        get {
            return D3DColorWriteEnable(rawValue: D3DColorWriteEnable.RawValue(rawValue.RenderTargetWriteMask))
        }
        set {
            rawValue.RenderTargetWriteMask = UInt8(newValue.rawValue)
        }
    }

    /** Describes the blend state for a render target.
    - parameter blendEnabled: Specifies whether to enable (or disable) blending. Set to TRUE to enable blending. It's not valid for LogicOpEnable and BlendEnable to both be TRUE.
    - parameter logicOperationEnabled: Specifies whether to enable (or disable) a logical operation. Set to TRUE to enable a logical operation. It's not valid for LogicOpEnable and BlendEnable to both be TRUE.
    - parameter sourceBlend: A D3D12_BLEND-typed value that specifies the operation to perform on the RGB value that the pixel shader outputs. The BlendOp member defines how to combine the SrcBlend and DestBlend operations.
    - parameter destinationBlend: A D3D12_BLEND-typed value that specifies the operation to perform on the current RGB value in the render target. The BlendOp member defines how to combine the SrcBlend and DestBlend operations.
    - parameter blendOperation: A D3D12_BLEND_OP-typed value that defines how to combine the SrcBlend and DestBlend operations.
    - parameter sourceBlendAlpha: A D3D12_BLEND-typed value that specifies the operation to perform on the alpha value that the pixel shader outputs. Blend options that end in _COLOR are not allowed. The BlendOpAlpha member defines how to combine the SrcBlendAlpha and DestBlendAlpha operations.
    - parameter destinationBlendAlpha: A D3D12_BLEND-typed value that specifies the operation to perform on the current alpha value in the render target. Blend options that end in _COLOR are not allowed. The BlendOpAlpha member defines how to combine the SrcBlendAlpha and DestBlendAlpha operations.
    - parameter blendAlphaOperation: A D3D12_BLEND_OP-typed value that defines how to combine the SrcBlendAlpha and DestBlendAlpha operations.
    - parameter logicOperation: A D3D12_LOGIC_OP-typed value that specifies the logical operation to configure for the render target.
    - parameter renderTargetWriteMask: A combination of D3D12_COLOR_WRITE_ENABLE-typed values that are combined by using a bitwise OR operation. The resulting value specifies a write mask.
    */
    public init(blendEnabled: Bool = false,
                logicOperationEnabled: Bool = false,
                sourceBlend: D3DBlendFactor = .one,
                destinationBlend: D3DBlendFactor = .zero,
                blendOperation: D3DBlendOperation = .add,
                sourceBlendAlpha: D3DBlendFactor = .one,
                destinationBlendAlpha: D3DBlendFactor = .zero,
                blendAlphaOperation: D3DBlendOperation = .add,
                logicOperation: D3DLogicOperation = .none,
                renderTargetWriteMask: D3DColorWriteEnable = .all) {
        self.rawValue = RawValue()
        self.blendEnabled = blendEnabled
        self.logicOperationEnabled = logicOperationEnabled
        self.sourceBlend = sourceBlend
        self.destinationBlend = destinationBlend
        self.blendOperation = blendOperation
        self.sourceBlendAlpha = sourceBlendAlpha
        self.destinationBlendAlpha = destinationBlendAlpha
        self.blendAlphaOperation = blendAlphaOperation
        self.logicOperation = logicOperation
        self.renderTargetWriteMask = renderTargetWriteMask
    }
    
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DRenderTargetBlendDescription")
public typealias D3D12_RENDER_TARGET_BLEND_DESC = D3DRenderTargetBlendDescription

#endif
