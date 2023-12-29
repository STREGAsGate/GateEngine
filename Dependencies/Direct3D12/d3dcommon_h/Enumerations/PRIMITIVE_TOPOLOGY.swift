/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

// The explicit D3D10 and D3D12 variants in d3dcommon.h are just aliases

/// Values that indicate how the pipeline interprets vertex data that is bound to the input-assembler stage. These primitive topology values determine how the vertex data is rendered on screen.
public enum D3DPrimitiveTopology {
    public typealias RawValue = WinSDK.D3D_PRIMITIVE_TOPOLOGY

    /// The IA stage has not been initialized with a primitive topology. The IA stage will not function properly unless a primitive topology is defined.
    case undefined
    /// Interpret the vertex data as a list of points.
    case pointList
    /// Interpret the vertex data as a list of lines.
    case lineList
    /// Interpret the vertex data as a line strip.
    case lineStrip
    /// Interpret the vertex data as a list of triangles.
    case triangleList
    /// Interpret the vertex data as a triangle strip.
    case triangleStrip
    /// Interpret the vertex data as a list of lines with adjacency data.
    case lineListAdjacent
    /// Interpret the vertex data as a line strip with adjacency data.
    case lineStripAdjacent
    /// Interpret the vertex data as a list of triangles with adjacency data.
    case triangleListAdjacent
    /// Interpret the vertex data as a triangle strip with adjacency data.
    case triangleStripAdjacent
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList1
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList2
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList3
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList4
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList5
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList6
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList7
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList8
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList9
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList10
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList11
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList12
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList13
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList14
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList15
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList16
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList17
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList18
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList19
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList20
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList21
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList22
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList23
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList24
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList25
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList26
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList27
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList28
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList29
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList30
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList31
    /// Interpret the vertex data as a patch list.
    case controlPointPatchList32

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)
    
    @inlinable @inline(__always)
    public var rawValue: RawValue {
        switch self {
        case .undefined:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_UNDEFINED
        case .pointList:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_POINTLIST
        case .lineList:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_LINELIST
        case .lineStrip:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_LINESTRIP
        case .triangleList:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST
        case .triangleStrip:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP
        case .lineListAdjacent:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_LINELIST_ADJ
        case .lineStripAdjacent:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_LINESTRIP_ADJ
        case .triangleListAdjacent:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST_ADJ
        case .triangleStripAdjacent:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP_ADJ
        case .controlPointPatchList1:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_1_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList2:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_2_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList3:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_3_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList4:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_4_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList5:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_5_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList6:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_6_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList7:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_7_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList8:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_8_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList9:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_9_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList10:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_10_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList11:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_11_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList12:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_12_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList13:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_13_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList14:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_14_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList15:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_15_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList16:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_16_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList17:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_17_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList18:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_18_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList19:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_19_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList20:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_20_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList21:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_21_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList22:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_22_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList23:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_23_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList24:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_24_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList25:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_25_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList26:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_26_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList27:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_27_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList28:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_28_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList29:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_29_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList30:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_30_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList31:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_31_CONTROL_POINT_PATCHLIST
        case .controlPointPatchList32:
            return WinSDK.D3D_PRIMITIVE_TOPOLOGY_32_CONTROL_POINT_PATCHLIST
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable @inline(__always)
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_UNDEFINED:
            self = .undefined
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_POINTLIST:
            self = .pointList
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_LINELIST:
            self = .lineList
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_LINESTRIP:
            self = .lineStrip
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST:
            self = .triangleList
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP:
            self = .triangleStrip
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_LINELIST_ADJ:
            self = .lineListAdjacent
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_LINESTRIP_ADJ:
            self = .lineStripAdjacent
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST_ADJ:
            self = .triangleListAdjacent
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP_ADJ:
            self = .triangleStripAdjacent
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_1_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList1
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_2_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList2
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_3_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList3
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_4_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList4
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_5_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList5
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_6_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList6
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_7_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList7
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_8_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList8
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_9_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList9
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_10_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList10
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_11_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList11
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_12_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList12
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_13_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList13
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_14_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList14
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_15_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList15
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_16_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList16
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_17_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList17
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_18_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList18
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_19_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList19
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_20_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList20
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_21_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList21
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_22_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList22
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_23_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList23
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_24_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList24
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_25_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList25
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_26_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList26
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_27_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList27
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_28_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList28
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_29_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList29
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_30_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList30
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_31_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList31
        case WinSDK.D3D_PRIMITIVE_TOPOLOGY_32_CONTROL_POINT_PATCHLIST:
            self = .controlPointPatchList32
        default:
            self = ._unimplemented(rawValue)
        }
    }
}
  

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DPrimitiveTopology")
public typealias D3D_PRIMITIVE_TOPOLOGY = D3DPrimitiveTopology


@available(*, deprecated, renamed: "D3DPrimitiveTopology.undefined")
public let D3D_PRIMITIVE_TOPOLOGY_UNDEFINED = D3DPrimitiveTopology.undefined

@available(*, deprecated, renamed: "D3DPrimitiveTopology.pointList")
public let D3D_PRIMITIVE_TOPOLOGY_POINTLIST = D3DPrimitiveTopology.pointList

@available(*, deprecated, renamed: "D3DPrimitiveTopology.lineList")
public let D3D_PRIMITIVE_TOPOLOGY_LINELIST = D3DPrimitiveTopology.lineList

@available(*, deprecated, renamed: "D3DPrimitiveTopology.lineStrip")
public let D3D_PRIMITIVE_TOPOLOGY_LINESTRIP = D3DPrimitiveTopology.lineStrip

@available(*, deprecated, renamed: "D3DPrimitiveTopology.triangleList")
public let D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST = D3DPrimitiveTopology.triangleList

@available(*, deprecated, renamed: "D3DPrimitiveTopology.triangleStrip")
public let D3D_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP = D3DPrimitiveTopology.triangleStrip

@available(*, deprecated, renamed: "D3DPrimitiveTopology.lineListAdjacent")
public let D3D_PRIMITIVE_TOPOLOGY_LINELIST_ADJ = D3DPrimitiveTopology.lineListAdjacent

@available(*, deprecated, renamed: "D3DPrimitiveTopology.lineStripAdjacent")
public let D3D_PRIMITIVE_TOPOLOGY_LINESTRIP_ADJ = D3DPrimitiveTopology.lineStripAdjacent

@available(*, deprecated, renamed: "D3DPrimitiveTopology.triangleListAdjacent")
public let D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST_ADJ = D3DPrimitiveTopology.triangleListAdjacent

@available(*, deprecated, renamed: "D3DPrimitiveTopology.triangleStripAdjacent")
public let D3D_PRIMITIVE_TOPOLOGY_TRIANGLESTRIP_ADJ = D3DPrimitiveTopology.triangleStripAdjacent

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList1")
public let D3D_PRIMITIVE_TOPOLOGY_1_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList1

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList2")
public let D3D_PRIMITIVE_TOPOLOGY_2_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList2

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList3")
public let D3D_PRIMITIVE_TOPOLOGY_3_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList3

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList4")
public let D3D_PRIMITIVE_TOPOLOGY_4_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList4

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList5")
public let D3D_PRIMITIVE_TOPOLOGY_5_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList5

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList6")
public let D3D_PRIMITIVE_TOPOLOGY_6_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList6

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList7")
public let D3D_PRIMITIVE_TOPOLOGY_7_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList7

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList8")
public let D3D_PRIMITIVE_TOPOLOGY_8_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList8

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList9")
public let D3D_PRIMITIVE_TOPOLOGY_9_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList9

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList10")
public let D3D_PRIMITIVE_TOPOLOGY_10_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList10

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList11")
public let D3D_PRIMITIVE_TOPOLOGY_11_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList11

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList12")
public let D3D_PRIMITIVE_TOPOLOGY_12_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList12

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList13")
public let D3D_PRIMITIVE_TOPOLOGY_13_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList13

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList14")
public let D3D_PRIMITIVE_TOPOLOGY_14_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList14

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList15")
public let D3D_PRIMITIVE_TOPOLOGY_15_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList15

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList16")
public let D3D_PRIMITIVE_TOPOLOGY_16_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList16

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList17")
public let D3D_PRIMITIVE_TOPOLOGY_17_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList17

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList18")
public let D3D_PRIMITIVE_TOPOLOGY_18_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList18

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList19")
public let D3D_PRIMITIVE_TOPOLOGY_19_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList19

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList20")
public let D3D_PRIMITIVE_TOPOLOGY_20_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList20

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList21")
public let D3D_PRIMITIVE_TOPOLOGY_21_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList21

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList22")
public let D3D_PRIMITIVE_TOPOLOGY_22_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList22

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList23")
public let D3D_PRIMITIVE_TOPOLOGY_23_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList23

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList24")
public let D3D_PRIMITIVE_TOPOLOGY_24_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList24

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList25")
public let D3D_PRIMITIVE_TOPOLOGY_25_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList25

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList26")
public let D3D_PRIMITIVE_TOPOLOGY_26_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList26

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList27")
public let D3D_PRIMITIVE_TOPOLOGY_27_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList27

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList28")
public let D3D_PRIMITIVE_TOPOLOGY_28_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList28

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList29")
public let D3D_PRIMITIVE_TOPOLOGY_29_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList29

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList30")
public let D3D_PRIMITIVE_TOPOLOGY_30_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList30

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList31")
public let D3D_PRIMITIVE_TOPOLOGY_31_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList31

@available(*, deprecated, renamed: "D3DPrimitiveTopology.controlPointPatchList32")
public let D3D_PRIMITIVE_TOPOLOGY_32_CONTROL_POINT_PATCHLIST = D3DPrimitiveTopology.controlPointPatchList32

#endif
