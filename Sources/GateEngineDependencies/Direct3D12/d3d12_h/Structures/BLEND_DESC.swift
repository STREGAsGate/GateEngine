/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the blend state.
public struct D3DBlendDescription {
    public typealias RawValue = WinSDK.D3D12_BLEND_DESC
    internal var rawValue: RawValue

    /// Specifies whether to use alpha-to-coverage as a multisampling technique when setting a pixel to a render target. For more info about using alpha-to-coverage, see Alpha-To-Coverage.
    public var alphaToCoverageEnabled: Bool {
        get {
            return rawValue.AlphaToCoverageEnable.boolValue
        }
        set {
            rawValue.AlphaToCoverageEnable = WindowsBool(booleanLiteral: newValue)
        }
    }

    /// Specifies whether to enable independent blending in simultaneous render targets. Set to TRUE to enable independent blending. If set to FALSE, only the RenderTarget[0] members are used; RenderTarget[1..7] are ignored.
    public var independentBlendEnabled: Bool {
        get {
            return rawValue.IndependentBlendEnable.boolValue
        }
        set {
            rawValue.IndependentBlendEnable = WindowsBool(booleanLiteral: newValue)
        }
    }

    /// An array of D3D12_RENDER_TARGET_BLEND_DESC structures that describe the blend states for render targets; these correspond to the eight render targets that can be bound to the output-merger stage at one time.
    public var renderTarget: [D3DRenderTargetBlendDescription] {
        get {
            return withUnsafePointer(to: rawValue.RenderTarget.0) {p in
                let buffer = UnsafeBufferPointer(start: p, count: MemoryLayout.size(ofValue: rawValue.RenderTarget))
                return buffer.map({D3DRenderTargetBlendDescription($0)})
            }
        }
        set {
            typealias Tuple = (D3DRenderTargetBlendDescription.RawValue, D3DRenderTargetBlendDescription.RawValue,
                               D3DRenderTargetBlendDescription.RawValue, D3DRenderTargetBlendDescription.RawValue,
                               D3DRenderTargetBlendDescription.RawValue, D3DRenderTargetBlendDescription.RawValue,
                               D3DRenderTargetBlendDescription.RawValue, D3DRenderTargetBlendDescription.RawValue)
            _renderTarget = newValue.map({$0.rawValue})
            _renderTarget.withUnsafeBytes {buf in
                rawValue.RenderTarget = buf.bindMemory(to: Tuple.self)[0]  
            }
        }
    }
    private var _renderTarget: [D3DRenderTargetBlendDescription.RawValue]! = nil

    /// Describes the blend state.
    public init() {
        self.rawValue = RawValue()
    }

    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

public extension D3DBlendDescription {
    static var `default`: D3DBlendDescription {
        return D3DBlendDescription(WinSDK.D3D12_BLEND_DESC(
            AlphaToCoverageEnable: false,
            IndependentBlendEnable: false,
            RenderTarget: (
                WinSDK.D3D12_RENDER_TARGET_BLEND_DESC(
                    BlendEnable: false,
                    LogicOpEnable: false,
                    SrcBlend: WinSDK.D3D12_BLEND_ONE,
                    DestBlend: WinSDK.D3D12_BLEND_ZERO,
                    BlendOp: WinSDK.D3D12_BLEND_OP_ADD,
                    SrcBlendAlpha: WinSDK.D3D12_BLEND_ONE,
                    DestBlendAlpha: WinSDK.D3D12_BLEND_ZERO,
                    BlendOpAlpha: WinSDK.D3D12_BLEND_OP_ADD,
                    LogicOp: WinSDK.D3D12_LOGIC_OP_NOOP,
                    RenderTargetWriteMask: WinSDK.UINT8(WinSDK.D3D12_COLOR_WRITE_ENABLE_ALL.rawValue)),
                WinSDK.D3D12_RENDER_TARGET_BLEND_DESC(
                    BlendEnable: false,
                    LogicOpEnable: false,
                    SrcBlend: WinSDK.D3D12_BLEND_ONE,
                    DestBlend: WinSDK.D3D12_BLEND_ZERO,
                    BlendOp: WinSDK.D3D12_BLEND_OP_ADD,
                    SrcBlendAlpha: WinSDK.D3D12_BLEND_ONE,
                    DestBlendAlpha: WinSDK.D3D12_BLEND_ZERO,
                    BlendOpAlpha: WinSDK.D3D12_BLEND_OP_ADD,
                    LogicOp: WinSDK.D3D12_LOGIC_OP_NOOP,
                    RenderTargetWriteMask: WinSDK.UINT8(WinSDK.D3D12_COLOR_WRITE_ENABLE_ALL.rawValue)),
                WinSDK.D3D12_RENDER_TARGET_BLEND_DESC(
                    BlendEnable: false,
                    LogicOpEnable: false,
                    SrcBlend: WinSDK.D3D12_BLEND_ONE,
                    DestBlend: WinSDK.D3D12_BLEND_ZERO,
                    BlendOp: WinSDK.D3D12_BLEND_OP_ADD,
                    SrcBlendAlpha: WinSDK.D3D12_BLEND_ONE,
                    DestBlendAlpha: WinSDK.D3D12_BLEND_ZERO,
                    BlendOpAlpha: WinSDK.D3D12_BLEND_OP_ADD,
                    LogicOp: WinSDK.D3D12_LOGIC_OP_NOOP,
                    RenderTargetWriteMask: WinSDK.UINT8(WinSDK.D3D12_COLOR_WRITE_ENABLE_ALL.rawValue)),
                WinSDK.D3D12_RENDER_TARGET_BLEND_DESC(
                    BlendEnable: false,
                    LogicOpEnable: false,
                    SrcBlend: WinSDK.D3D12_BLEND_ONE,
                    DestBlend: WinSDK.D3D12_BLEND_ZERO,
                    BlendOp: WinSDK.D3D12_BLEND_OP_ADD,
                    SrcBlendAlpha: WinSDK.D3D12_BLEND_ONE,
                    DestBlendAlpha: WinSDK.D3D12_BLEND_ZERO,
                    BlendOpAlpha: WinSDK.D3D12_BLEND_OP_ADD,
                    LogicOp: WinSDK.D3D12_LOGIC_OP_NOOP,
                    RenderTargetWriteMask: WinSDK.UINT8(WinSDK.D3D12_COLOR_WRITE_ENABLE_ALL.rawValue)),
                WinSDK.D3D12_RENDER_TARGET_BLEND_DESC(
                    BlendEnable: false,
                    LogicOpEnable: false,
                    SrcBlend: WinSDK.D3D12_BLEND_ONE,
                    DestBlend: WinSDK.D3D12_BLEND_ZERO,
                    BlendOp: WinSDK.D3D12_BLEND_OP_ADD,
                    SrcBlendAlpha: WinSDK.D3D12_BLEND_ONE,
                    DestBlendAlpha: WinSDK.D3D12_BLEND_ZERO,
                    BlendOpAlpha: WinSDK.D3D12_BLEND_OP_ADD,
                    LogicOp: WinSDK.D3D12_LOGIC_OP_NOOP,
                    RenderTargetWriteMask: WinSDK.UINT8(WinSDK.D3D12_COLOR_WRITE_ENABLE_ALL.rawValue)),
                WinSDK.D3D12_RENDER_TARGET_BLEND_DESC(
                    BlendEnable: false,
                    LogicOpEnable: false,
                    SrcBlend: WinSDK.D3D12_BLEND_ONE,
                    DestBlend: WinSDK.D3D12_BLEND_ZERO,
                    BlendOp: WinSDK.D3D12_BLEND_OP_ADD,
                    SrcBlendAlpha: WinSDK.D3D12_BLEND_ONE,
                    DestBlendAlpha: WinSDK.D3D12_BLEND_ZERO,
                    BlendOpAlpha: WinSDK.D3D12_BLEND_OP_ADD,
                    LogicOp: WinSDK.D3D12_LOGIC_OP_NOOP,
                    RenderTargetWriteMask: WinSDK.UINT8(WinSDK.D3D12_COLOR_WRITE_ENABLE_ALL.rawValue)),
                WinSDK.D3D12_RENDER_TARGET_BLEND_DESC(
                    BlendEnable: false,
                    LogicOpEnable: false,
                    SrcBlend: WinSDK.D3D12_BLEND_ONE,
                    DestBlend: WinSDK.D3D12_BLEND_ZERO,
                    BlendOp: WinSDK.D3D12_BLEND_OP_ADD,
                    SrcBlendAlpha: WinSDK.D3D12_BLEND_ONE,
                    DestBlendAlpha: WinSDK.D3D12_BLEND_ZERO,
                    BlendOpAlpha: WinSDK.D3D12_BLEND_OP_ADD,
                    LogicOp: WinSDK.D3D12_LOGIC_OP_NOOP,
                    RenderTargetWriteMask: WinSDK.UINT8(WinSDK.D3D12_COLOR_WRITE_ENABLE_ALL.rawValue)),
                WinSDK.D3D12_RENDER_TARGET_BLEND_DESC(
                    BlendEnable: false,
                    LogicOpEnable: false,
                    SrcBlend: WinSDK.D3D12_BLEND_ONE,
                    DestBlend: WinSDK.D3D12_BLEND_ZERO,
                    BlendOp: WinSDK.D3D12_BLEND_OP_ADD,
                    SrcBlendAlpha: WinSDK.D3D12_BLEND_ONE,
                    DestBlendAlpha: WinSDK.D3D12_BLEND_ZERO,
                    BlendOpAlpha: WinSDK.D3D12_BLEND_OP_ADD,
                    LogicOp: WinSDK.D3D12_LOGIC_OP_NOOP,
                    RenderTargetWriteMask: WinSDK.UINT8(WinSDK.D3D12_COLOR_WRITE_ENABLE_ALL.rawValue))
                )
            )
        )
    }

    static var `additive`: D3DBlendDescription {
        return D3DBlendDescription(WinSDK.D3D12_BLEND_DESC(
            AlphaToCoverageEnable: false,
            IndependentBlendEnable: false,
            RenderTarget: (
                WinSDK.D3D12_RENDER_TARGET_BLEND_DESC(
                    BlendEnable: true,
                    LogicOpEnable: false,
                    SrcBlend: WinSDK.D3D12_BLEND_SRC_ALPHA,
                    DestBlend: WinSDK.D3D12_BLEND_INV_SRC_ALPHA,
                    BlendOp: WinSDK.D3D12_BLEND_OP_ADD,
                    SrcBlendAlpha: WinSDK.D3D12_BLEND_ONE,
                    DestBlendAlpha: WinSDK.D3D12_BLEND_INV_SRC_ALPHA,
                    BlendOpAlpha: WinSDK.D3D12_BLEND_OP_ADD,
                    LogicOp: WinSDK.D3D12_LOGIC_OP_NOOP,
                    RenderTargetWriteMask: WinSDK.UINT8(WinSDK.D3D12_COLOR_WRITE_ENABLE_ALL.rawValue)),
                WinSDK.D3D12_RENDER_TARGET_BLEND_DESC(
                    BlendEnable: true,
                    LogicOpEnable: false,
                    SrcBlend: WinSDK.D3D12_BLEND_SRC_ALPHA,
                    DestBlend: WinSDK.D3D12_BLEND_INV_SRC_ALPHA,
                    BlendOp: WinSDK.D3D12_BLEND_OP_ADD,
                    SrcBlendAlpha: WinSDK.D3D12_BLEND_ONE,
                    DestBlendAlpha: WinSDK.D3D12_BLEND_INV_SRC_ALPHA,
                    BlendOpAlpha: WinSDK.D3D12_BLEND_OP_ADD,
                    LogicOp: WinSDK.D3D12_LOGIC_OP_NOOP,
                    RenderTargetWriteMask: WinSDK.UINT8(WinSDK.D3D12_COLOR_WRITE_ENABLE_ALL.rawValue)),
                WinSDK.D3D12_RENDER_TARGET_BLEND_DESC(
                    BlendEnable: true,
                    LogicOpEnable: false,
                    SrcBlend: WinSDK.D3D12_BLEND_SRC_ALPHA,
                    DestBlend: WinSDK.D3D12_BLEND_INV_SRC_ALPHA,
                    BlendOp: WinSDK.D3D12_BLEND_OP_ADD,
                    SrcBlendAlpha: WinSDK.D3D12_BLEND_ONE,
                    DestBlendAlpha: WinSDK.D3D12_BLEND_INV_SRC_ALPHA,
                    BlendOpAlpha: WinSDK.D3D12_BLEND_OP_ADD,
                    LogicOp: WinSDK.D3D12_LOGIC_OP_NOOP,
                    RenderTargetWriteMask: WinSDK.UINT8(WinSDK.D3D12_COLOR_WRITE_ENABLE_ALL.rawValue)),
                WinSDK.D3D12_RENDER_TARGET_BLEND_DESC(
                    BlendEnable: true,
                    LogicOpEnable: false,
                    SrcBlend: WinSDK.D3D12_BLEND_SRC_ALPHA,
                    DestBlend: WinSDK.D3D12_BLEND_INV_SRC_ALPHA,
                    BlendOp: WinSDK.D3D12_BLEND_OP_ADD,
                    SrcBlendAlpha: WinSDK.D3D12_BLEND_ONE,
                    DestBlendAlpha: WinSDK.D3D12_BLEND_INV_SRC_ALPHA,
                    BlendOpAlpha: WinSDK.D3D12_BLEND_OP_ADD,
                    LogicOp: WinSDK.D3D12_LOGIC_OP_NOOP,
                    RenderTargetWriteMask: WinSDK.UINT8(WinSDK.D3D12_COLOR_WRITE_ENABLE_ALL.rawValue)),
                WinSDK.D3D12_RENDER_TARGET_BLEND_DESC(
                    BlendEnable: true,
                    LogicOpEnable: false,
                    SrcBlend: WinSDK.D3D12_BLEND_SRC_ALPHA,
                    DestBlend: WinSDK.D3D12_BLEND_INV_SRC_ALPHA,
                    BlendOp: WinSDK.D3D12_BLEND_OP_ADD,
                    SrcBlendAlpha: WinSDK.D3D12_BLEND_ONE,
                    DestBlendAlpha: WinSDK.D3D12_BLEND_INV_SRC_ALPHA,
                    BlendOpAlpha: WinSDK.D3D12_BLEND_OP_ADD,
                    LogicOp: WinSDK.D3D12_LOGIC_OP_NOOP,
                    RenderTargetWriteMask: WinSDK.UINT8(WinSDK.D3D12_COLOR_WRITE_ENABLE_ALL.rawValue)),
                WinSDK.D3D12_RENDER_TARGET_BLEND_DESC(
                    BlendEnable: true,
                    LogicOpEnable: false,
                    SrcBlend: WinSDK.D3D12_BLEND_SRC_ALPHA,
                    DestBlend: WinSDK.D3D12_BLEND_INV_SRC_ALPHA,
                    BlendOp: WinSDK.D3D12_BLEND_OP_ADD,
                    SrcBlendAlpha: WinSDK.D3D12_BLEND_ONE,
                    DestBlendAlpha: WinSDK.D3D12_BLEND_INV_SRC_ALPHA,
                    BlendOpAlpha: WinSDK.D3D12_BLEND_OP_ADD,
                    LogicOp: WinSDK.D3D12_LOGIC_OP_NOOP,
                    RenderTargetWriteMask: WinSDK.UINT8(WinSDK.D3D12_COLOR_WRITE_ENABLE_ALL.rawValue)),
                WinSDK.D3D12_RENDER_TARGET_BLEND_DESC(
                    BlendEnable: true,
                    LogicOpEnable: false,
                    SrcBlend: WinSDK.D3D12_BLEND_SRC_ALPHA,
                    DestBlend: WinSDK.D3D12_BLEND_INV_SRC_ALPHA,
                    BlendOp: WinSDK.D3D12_BLEND_OP_ADD,
                    SrcBlendAlpha: WinSDK.D3D12_BLEND_ONE,
                    DestBlendAlpha: WinSDK.D3D12_BLEND_INV_SRC_ALPHA,
                    BlendOpAlpha: WinSDK.D3D12_BLEND_OP_ADD,
                    LogicOp: WinSDK.D3D12_LOGIC_OP_NOOP,
                    RenderTargetWriteMask: WinSDK.UINT8(WinSDK.D3D12_COLOR_WRITE_ENABLE_ALL.rawValue)),
                WinSDK.D3D12_RENDER_TARGET_BLEND_DESC(
                    BlendEnable: true,
                    LogicOpEnable: false,
                    SrcBlend: WinSDK.D3D12_BLEND_SRC_ALPHA,
                    DestBlend: WinSDK.D3D12_BLEND_INV_SRC_ALPHA,
                    BlendOp: WinSDK.D3D12_BLEND_OP_ADD,
                    SrcBlendAlpha: WinSDK.D3D12_BLEND_ONE,
                    DestBlendAlpha: WinSDK.D3D12_BLEND_INV_SRC_ALPHA,
                    BlendOpAlpha: WinSDK.D3D12_BLEND_OP_ADD,
                    LogicOp: WinSDK.D3D12_LOGIC_OP_NOOP,
                    RenderTargetWriteMask: WinSDK.UINT8(WinSDK.D3D12_COLOR_WRITE_ENABLE_ALL.rawValue))
                )
            )
        )
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DBlendDescription")
public typealias D3D12_BLEND_DESC = D3DBlendDescription 

#endif
