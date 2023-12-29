/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes depth-stencil state.
public struct D3DDepthStencilDescription {
    public typealias RawValue = WinSDK.D3D12_DEPTH_STENCIL_DESC
    @usableFromInline
    internal var rawValue: RawValue
    
    /// Specifies whether to enable depth testing. Set this member to TRUE to enable depth testing.
    @inlinable @inline(__always)
    public var depthTestingEnabled: Bool {
        get {
            return rawValue.DepthEnable.boolValue
        }
        set {
            rawValue.DepthEnable = WindowsBool(booleanLiteral: newValue)
        }
    }

    /// A D3D12_DEPTH_WRITE_MASK-typed value that identifies a portion of the depth-stencil buffer that can be modified by depth data.
    @inlinable @inline(__always)
    public var depthWriteMask: D3DDepthWriteMask {
        get {
            return D3DDepthWriteMask(rawValue.DepthWriteMask)
        }
        set {
            rawValue.DepthWriteMask = newValue.rawValue
        }
    }

    /// A D3D12_COMPARISON_FUNC-typed value that identifies a function that compares depth data against existing depth data.
    @inlinable @inline(__always)
    public var depthFunction: D3DComparisonFunction {
        get {
            return D3DComparisonFunction(rawValue.DepthFunc)
        }
        set {
            rawValue.DepthFunc = newValue.rawValue
        }
    }

    /// Specifies whether to enable stencil testing. Set this member to TRUE to enable stencil testing.
    @inlinable @inline(__always)
    public var stencilTestingEnabled: Bool {
        get {
            return rawValue.StencilEnable.boolValue
        }
        set {
            rawValue.StencilEnable = WindowsBool(booleanLiteral: newValue)
        }
    }

    /// Identify a portion of the depth-stencil buffer for reading stencil data.
    @inlinable @inline(__always)
    public var stencilReadMask: UInt8 {
        get {
            return rawValue.StencilReadMask
        }
        set {
            rawValue.StencilReadMask = newValue
        }
    }

    /// Identify a portion of the depth-stencil buffer for writing stencil data.
    @inlinable @inline(__always)
    public var stencilWriteMask: UInt8 {
        get {
            return rawValue.StencilWriteMask
        }
        set {
            rawValue.StencilWriteMask = newValue
        }
    }

    /// A D3D12_DEPTH_STENCILOP_DESC structure that describes how to use the results of the depth test and the stencil test for pixels whose surface normal is facing towards the camera.
    @inlinable @inline(__always)
    public var frontFace: D3DDepthStencilOperationDescription {
        get {
            return D3DDepthStencilOperationDescription(rawValue.FrontFace)
        }
        set {
            rawValue.FrontFace = newValue.rawValue
        }
    }

    /// A D3D12_DEPTH_STENCILOP_DESC structure that describes how to use the results of the depth test and the stencil test for pixels whose surface normal is facing away from the camera.
    @inlinable @inline(__always)
    public var backFace: D3DDepthStencilOperationDescription {
        get {
            return D3DDepthStencilOperationDescription(rawValue.BackFace)
        }
        set {
            rawValue.BackFace = newValue.rawValue
        }
    }

    /** Describes depth-stencil state.
    - parameter depthTestingEnabled: Specifies whether to enable depth testing. Set this member to TRUE to enable depth testing.
    - parameter depthWriteMask: A D3D12_DEPTH_WRITE_MASK-typed value that identifies a portion of the depth-stencil buffer that can be modified by depth data.
    - parameter depthFunction: A D3D12_COMPARISON_FUNC-typed value that identifies a function that compares depth data against existing depth data.
    - parameter stencilTestingEnabled: Specifies whether to enable stencil testing. Set this member to TRUE to enable stencil testing.
    - parameter stencilReadMask: Identify a portion of the depth-stencil buffer for reading stencil data.
    - parameter stencilWriteMask: Identify a portion of the depth-stencil buffer for writing stencil data.
    - parameter frontFace: A D3D12_DEPTH_STENCILOP_DESC structure that describes how to use the results of the depth test and the stencil test for pixels whose surface normal is facing towards the camera.
    - parameter backFace: A D3D12_DEPTH_STENCILOP_DESC structure that describes how to use the results of the depth test and the stencil test for pixels whose surface normal is facing away from the camera.
    */
    @inlinable @inline(__always)
    public init(depthTestingEnabled: Bool,
                depthWriteMask: D3DDepthWriteMask,
                depthFunction: D3DComparisonFunction,
                stencilTestingEnabled: Bool,
                stencilReadMask: UInt8,
                stencilWriteMask: UInt8,
                frontFace: D3DDepthStencilOperationDescription,
                backFace: D3DDepthStencilOperationDescription) {
        self.rawValue = RawValue()
        self.depthTestingEnabled = depthTestingEnabled
        self.depthWriteMask = depthWriteMask
        self.depthFunction = depthFunction
        self.stencilTestingEnabled = stencilTestingEnabled
        self.stencilReadMask = stencilReadMask
        self.stencilWriteMask = stencilWriteMask
        self.frontFace = frontFace
        self.backFace = backFace
    }

    /// Describes depth-stencil state.
    @inlinable @inline(__always)
    public init() {
        self.rawValue = RawValue()
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DDepthStencilDescription")
public typealias D3D12_DEPTH_STENCIL_DESC = D3DDepthStencilDescription 

#endif
