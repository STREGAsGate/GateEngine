/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct TexturePath: Equatable, Hashable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible {
    public typealias StringLiteralType = String
    public var value: String
    public var description: String { value }
    public init(stringLiteral value: String) {
        self.value = value
    }

    /// A simple texture suitable for a placeholder
    @inlinable
    public static var checkerPattern: TexturePath { "GateEngine/Textures/CheckerPattern.png" }
}

public struct GeoemetryPath: Equatable, Hashable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible {
    public typealias StringLiteralType = String
    public var value: String
    public var description: String { value }
    public init(stringLiteral value: String) {
        self.value = value
    }

    /// A 1x1x1 Cube
    @inlinable
    public static var unitCube: GeoemetryPath { "GateEngine/Primitives/Unit Cube.obj" }
    /// A 1x1x1 Geosphere
    @inlinable
    public static var unitSphere: GeoemetryPath { "GateEngine/Primitives/Unit Sphere.obj" }
    /// A 1x1x1 Plane
    @inlinable
    public static var unitPlane: GeoemetryPath { "GateEngine/Primitives/Unit Plane.obj" }
    /// A 1x1x1 Joint Shape
    @inlinable
    public static var unitJoint: GeoemetryPath { "GateEngine/Primitives/Unit Joint.obj" }
    /// A 1x1x1 Cube with normals flipped
    @inlinable
    public static var unitSkyBox: GeoemetryPath { "GateEngine/Primitives/Unit SkyBox.obj" }
}
