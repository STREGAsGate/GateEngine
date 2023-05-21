/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct TexturePath: ExpressibleByStringLiteral, CustomStringConvertible {
    public typealias StringLiteralType = String
    public var value: String
    public var description: String {value}
    public init(stringLiteral value: String) {
        self.value = value
    }
    
    /// A simple texture suitable for a placeholder
    @inlinable @inline(__always)
    public static var checkerPattern: TexturePath {"GateEngine/Textures/CheckerPattern.png"}
}

public struct GeoemetryPath: ExpressibleByStringLiteral, CustomStringConvertible {
    public typealias StringLiteralType = String
    public var value: String
    public var description: String {value}
    public init(stringLiteral value: String) {
        self.value = value
    }
    
    /// A 1x1x1 Cube
    @inlinable @inline(__always)
    public static var unitCube: GeoemetryPath {"GateEngine/Primitives/Unit Cube.obj"}
    /// A 1x1x1 Geosphere
    @inlinable @inline(__always)
    public static var unitSphere: GeoemetryPath {"GateEngine/Primitives/Unit Sphere.obj"}
    /// A 1x1x1 Plane
    @inlinable @inline(__always)
    public static var unitPlane: GeoemetryPath {"GateEngine/Primitives/Unit Plane.obj"}
}
