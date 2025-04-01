/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Defines constants that specify logical operations to configure for a render target.
public enum D3DLogicOperation {
    public typealias RawValue = WinSDK.D3D12_LOGIC_OP

    ///	Clears the render target (0).	
    case clear
    ///	Sets the render target ( 1).	
    case set
    ///	Copies the render target (s source from Pixel Shader output).	
    case copy
    ///	Performs an inverted-copy of the render target (~s).	
    case invertedCopy
    ///	No operation is performed on the render target (d destination in the Render Target View).	
    case none
    ///	Inverts the render target (~d).	
    case invert
    ///	Performs a logical AND operation on the render target (s & d).	
    case logicalAnd
    ///	Performs a logical NAND operation on the render target (~(s & d)).	
    case logicalNand
    ///	Performs a logical OR operation on the render target (s	d).
    case logicalOr
    ///	Performs a logical NOR operation on the render target (~(s	d)).
    case logicalNor
    ///	Performs a logical XOR operation on the render target (s ^ d).	
    case logicalXor
    ///	Performs a logical equal operation on the render target (~(s ^ d)).	
    case logicalEqual
    ///	Performs a logical AND and reverse operation on the render target (s & ~d).	
    case logicalAndReverse
    ///	Performs a logical AND and invert operation on the render target (~s & d).	
    case logicalAndInverse
    ///	Performs a logical OR and reverse operation on the render target (s	~d).
    case logicalOrReverse
    ///	Performs a logical OR and invert operation on the render target (~s	d).
    case logicalOrInverse

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable
    public var rawValue: RawValue {
        switch self {
        case .clear:
            return WinSDK.D3D12_LOGIC_OP_CLEAR
        case .set:
            return WinSDK.D3D12_LOGIC_OP_SET
        case .copy:
            return WinSDK.D3D12_LOGIC_OP_COPY
        case .invertedCopy:
            return WinSDK.D3D12_LOGIC_OP_COPY_INVERTED
        case .none:
            return WinSDK.D3D12_LOGIC_OP_NOOP
        case .invert:
            return WinSDK.D3D12_LOGIC_OP_INVERT
        case .logicalAnd:
            return WinSDK.D3D12_LOGIC_OP_AND
        case .logicalNand:
            return WinSDK.D3D12_LOGIC_OP_NAND
        case .logicalOr:
            return WinSDK.D3D12_LOGIC_OP_OR
        case .logicalNor:
            return WinSDK.D3D12_LOGIC_OP_NOR
        case .logicalXor:
            return WinSDK.D3D12_LOGIC_OP_XOR
        case .logicalEqual:
            return WinSDK.D3D12_LOGIC_OP_EQUIV
        case .logicalAndReverse:
            return WinSDK.D3D12_LOGIC_OP_AND_REVERSE
        case .logicalAndInverse:
            return WinSDK.D3D12_LOGIC_OP_AND_INVERTED
        case .logicalOrReverse:
            return WinSDK.D3D12_LOGIC_OP_OR_REVERSE
        case .logicalOrInverse:
            return WinSDK.D3D12_LOGIC_OP_OR_INVERTED
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_LOGIC_OP_CLEAR:
            self = .clear
        case WinSDK.D3D12_LOGIC_OP_SET:
            self =  .set
        case WinSDK.D3D12_LOGIC_OP_COPY:
            self = .copy
        case WinSDK.D3D12_LOGIC_OP_COPY_INVERTED:
            self = .invertedCopy
        case WinSDK.D3D12_LOGIC_OP_NOOP:
            self = .none
        case WinSDK.D3D12_LOGIC_OP_INVERT:
            self = .invert
        case WinSDK.D3D12_LOGIC_OP_AND:
            self = .logicalAnd
        case WinSDK.D3D12_LOGIC_OP_NAND:
            self = .logicalNand
        case WinSDK.D3D12_LOGIC_OP_OR:
            self = .logicalOr
        case WinSDK.D3D12_LOGIC_OP_NOR:
            self = .logicalNor
        case WinSDK.D3D12_LOGIC_OP_XOR:
            self = .logicalXor
        case WinSDK.D3D12_LOGIC_OP_EQUIV:
            self = .logicalEqual
        case WinSDK.D3D12_LOGIC_OP_AND_REVERSE:
            self = .logicalAndReverse
        case WinSDK.D3D12_LOGIC_OP_AND_INVERTED:
            self = .logicalAndInverse
        case WinSDK.D3D12_LOGIC_OP_OR_REVERSE:
            self = .logicalOrReverse
        case WinSDK.D3D12_LOGIC_OP_OR_INVERTED:
            self = .logicalOrInverse
        default:
            self = ._unimplemented(rawValue)
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DLogicOperation.D3DLogicOperation")
public typealias D3D12_LOGIC_OP = D3DLogicOperation


@available(*, deprecated, renamed: "D3DLogicOperation.clear")
public let D3D12_LOGIC_OP_CLEAR = D3DLogicOperation.clear

@available(*, deprecated, renamed: "D3DLogicOperation.set")
public let D3D12_LOGIC_OP_SET = D3DLogicOperation.set

@available(*, deprecated, renamed: "D3DLogicOperation.copy")
public let D3D12_LOGIC_OP_COPY = D3DLogicOperation.copy

@available(*, deprecated, renamed: "D3DLogicOperation.invertedCopy")
public let D3D12_LOGIC_OP_COPY_INVERTED = D3DLogicOperation.invertedCopy

@available(*, deprecated, renamed: "D3DLogicOperation.none")
public let D3D12_LOGIC_OP_NOOP = D3DLogicOperation.none

@available(*, deprecated, renamed: "D3DLogicOperation.invert")
public let D3D12_LOGIC_OP_INVERT = D3DLogicOperation.invert

@available(*, deprecated, renamed: "D3DLogicOperation.logicalAnd")
public let D3D12_LOGIC_OP_AND = D3DLogicOperation.logicalAnd

@available(*, deprecated, renamed: "D3DLogicOperation.logicalNand")
public let D3D12_LOGIC_OP_NAND = D3DLogicOperation.logicalNand

@available(*, deprecated, renamed: "D3DLogicOperation.logicalNor")
public let D3D12_LOGIC_OP_NOR = D3DLogicOperation.logicalNor

@available(*, deprecated, renamed: "D3DLogicOperation.logicalXor")
public let D3D12_LOGIC_OP_XOR = D3DLogicOperation.logicalXor

@available(*, deprecated, renamed: "D3DLogicOperation.logicalEqual")
public let D3D12_LOGIC_OP_EQUIV = D3DLogicOperation.logicalEqual

@available(*, deprecated, renamed: "D3DLogicOperation.logicalAndReverse")
public let D3D12_LOGIC_OP_AND_REVERSE = D3DLogicOperation.logicalAndReverse

@available(*, deprecated, renamed: "D3DLogicOperation.logicalAndInverse")
public let D3D12_LOGIC_OP_AND_INVERTED = D3DLogicOperation.logicalAndInverse

@available(*, deprecated, renamed: "D3DLogicOperation.logicalOrReverse")
public let D3D12_LOGIC_OP_OR_REVERSE = D3DLogicOperation.logicalOrReverse

@available(*, deprecated, renamed: "D3DLogicOperation.logicalOrInverse")
public let D3D12_LOGIC_OP_OR_INVERTED = D3DLogicOperation.logicalOrInverse

#endif
