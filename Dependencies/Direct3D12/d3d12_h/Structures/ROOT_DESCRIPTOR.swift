/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes descriptors inline in the root signature version 1.0 that appear in shaders.
public struct D3DRootDescriptor {
    public typealias RawValue = WinSDK.D3D12_ROOT_DESCRIPTOR
    @usableFromInline
    internal var rawValue: RawValue

    /// The shader register.
    @inlinable @inline(__always)
    public var shaderRegister: UInt32 {
        get {
            return rawValue.ShaderRegister
        }
        set {
            rawValue.ShaderRegister = newValue
        }
    }

    /// The register space.
    @inlinable @inline(__always)
    public var registerSpace: UInt32 {
        get {
            return rawValue.RegisterSpace
        }
        set {
            rawValue.RegisterSpace = newValue
        }
    }

    /** Describes descriptors inline in the root signature version 1.0 that appear in shaders.
    - parameter shaderRegister: The shader register.
    - parameter registerSpace: The register space.
    */
    @inlinable @inline(__always)
    public init(shaderRegister: UInt32 = 1, registerSpace: UInt32 = 0) {
        self.rawValue = RawValue(ShaderRegister: shaderRegister, RegisterSpace: registerSpace)
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DRootDescriptor")
public typealias D3D12_ROOT_DESCRIPTOR = D3DRootDescriptor

#endif
