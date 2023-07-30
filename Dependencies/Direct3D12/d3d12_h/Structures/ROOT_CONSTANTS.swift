/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes constants inline in the root signature that appear in shaders as one constant buffer.
public struct D3DRootConstants {
    public typealias RawValue = WinSDK.D3D12_ROOT_CONSTANTS
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

    /// The number of constants that occupy a single shader slot (these constants appear like a single constant buffer). All constants occupy a single root signature bind slot.
    @inlinable @inline(__always)
    public var num32BitValues: UInt32 {
        get {
            return rawValue.Num32BitValues
        }
        set {
            rawValue.Num32BitValues = newValue
        }
    }

    /** Describes constants inline in the root signature that appear in shaders as one constant buffer.
    - parameter shaderRegister: The shader register.
    - parameter registerSpace: The register space.
    - parameter num32BitValues: The number of constants that occupy a single shader slot (these constants appear like a single constant buffer). All constants occupy a single root signature bind slot.
    */
    @inlinable @inline(__always)
    public init(shaderRegister: UInt32 = 0, registerSpace: UInt32 = 0, num32BitValues: UInt32 = 0) {
        self.rawValue = RawValue(ShaderRegister: shaderRegister, RegisterSpace: registerSpace, Num32BitValues: num32BitValues)
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DRootConstants")
public typealias D3D12_ROOT_CONSTANTS = D3DRootConstants

#endif
