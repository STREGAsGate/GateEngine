/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct LightMapPacker: Sendable {
    public let uvSet: Int
    public let texelDensity: Int
    public let options: LightMapBaker.Source.Options
    
    public struct Options: OptionSet, Equatable, Hashable, Sendable {
        public let rawValue: UInt8
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        /// No options
        public static let none: Self = []
        
        /// The output texture size will have an aspect ration 1:1 and width will be equal to height
        public static let allowRotation: Self = Self(rawValue: 1 << 0)

        public static var optimize: Self {
            return [.allowRotation, ]
        }
    }
    
    /**
     - parameter uvSet: The uvSet index to replace when packing geometry. Index 0 is uvSet1.
     - parameter texelDensity: The desired number of lightmap texels per unit.
     - parameter optimize: When true additional compute will be used to reduce the resulting lightmap size by packing UVs more efficiently.
     */
    public init(uvSet: Int = 1, texelDensity: Int, options: LightMapBaker.Source.Options) {
        self.uvSet = uvSet
        self.texelDensity = texelDensity
        self.options = options
    }
    
    struct PackedTriangle {
        let texelDensity: Int
        let original: Triangle
        let unwrapped: UnwrappedTriangle
        let options: LightMapBaker.Source.Options
        
        @inlinable
        var p1: Position2f {
            return unwrapped.p1
        }
        @inlinable
        var p2: Position2f {
            return unwrapped.p2
        }
        @inlinable
        var p3: Position2f {
            return unwrapped.p3
        }
        
        @inlinable
        var minTextureSize: Size2f {
            return Size2f(options.minimumTexels)
        }
        
        @inlinable
        var textureSize: Size2f {
            let minX = Swift.min(p1.x, p2.x, p3.x)
            let maxX = Swift.max(p1.x, p2.x, p3.x)
            
            let minY = Swift.min(p1.y, p2.y, p3.y)
            let maxY = Swift.max(p1.y, p2.y, p3.y)
            
            let width = abs(minX.distance(to: maxX))
            let height = abs(minY.distance(to: maxY))
            
            var size = Size2f(width: width, height: height) * Float(texelDensity)

            let minTextureSize = self.minTextureSize
            if size.x < minTextureSize.width {
                size.x = minTextureSize.width
            }
            if size.y < minTextureSize.height {
                size.y = minTextureSize.height
            }
            
            // Round up
            size += size.truncatingRemainder(dividingBy: 2.0)

            return size
        }
        
        private var _max: Position2f {
            return Position2f(
                x: Swift.max(Float(self.p1.x), Float(self.p2.x), Float(self.p3.x)),
                y: Swift.max(Float(self.p1.y), Float(self.p2.y), Float(self.p3.y))
            )
        }
        
        var v1UV: Position2f {
            return Position2f(self.p1) / _max
        }
        var v2UV: Position2f {
            return Position2f(self.p2) / _max
        }
        var v3UV: Position2f {
            return Position2f(self.p3) / _max
        }
        
        var atlasTexture: AtlasTexture {
            return AtlasTexture(size: Size2i(self.textureSize))
        }
        
        init(triangle: Triangle, texelDensity: Int, options: LightMapBaker.Source.Options) {
            self.init(
                original: triangle,
                unwrappedTriangle: UnwrappedTriangle(triangle: triangle, texelDensity: texelDensity, options: options.packing),
                texelDensity: texelDensity,
                options: options
            )
        }
        
        private init(original: Triangle, unwrappedTriangle: UnwrappedTriangle, texelDensity: Int, options: LightMapBaker.Source.Options) {
            self.original = original
            self.texelDensity = texelDensity
            self.unwrapped = unwrappedTriangle
            self.options = options
        }
    }
    
    struct UnwrappedTriangle {
        let p1: Position2f
        let p2: Position2f
        let p3: Position2f
        
        init(triangle: Triangle, texelDensity: Int, options: Options) {
            // Project the triangle onto a 2D plane with the face normal pointing toward the viewer
            var projectionRotation: Quaternion = Quaternion(direction: -triangle.faceNormal)
            
            #if false // TODO: Implement smart rotation and scaling
            if options.contains(.allowRotation) {
                // Find the triangles longest edge
                let longestLine: Line3D = {
                    let line1 = Line3D(triangle.v1.position, triangle.v2.position)
                    let line2 = Line3D(triangle.v2.position, triangle.v3.position)
                    let line3 = Line3D(triangle.v3.position, triangle.v1.position)
                    let sortedLines = [
                        (index: 0, length: line1.length),
                        (index: 1, length: line2.length),
                        (index: 2, length: line3.length)
                    ].sorted(by: { lhs, rhs in
                        return lhs.length >= rhs.length
                    })
                    
                    switch sortedLines[0].index {
                    case 0:
                        return line1
                    case 1:
                        return line2
                    default:
                        return line3
                    }
                }()
                
                // Find a rotation so the longest side runs down the bottom left to top right of a bounding box
                let longestTowardCenter = Direction3(from: longestLine.center, to: triangle.center)
                let bottomRightToTopLeft = Direction3(from: Position3(1, 1, 0), to: Position3(0, 0, 0))
                let angleRotation = Quaternion(
                    longestTowardCenter.angle(to: bottomRightToTopLeft),
                    axis: -triangle.faceNormal
                )
                
                // Combine rotations
                projectionRotation *= angleRotation
            }
            #endif
            
            // Unwrap the triangle
            let projectedP1 = triangle.v1.position.rotated(around: triangle.center, by: projectionRotation)
            let projectedP2 = triangle.v2.position.rotated(around: triangle.center, by: projectionRotation)
            let projectedP3 = triangle.v3.position.rotated(around: triangle.center, by: projectionRotation)

            // Offset the projected points
            let p1 = Position2f(x: projectedP1.x, y: projectedP1.y)
            let p2 = Position2f(x: projectedP2.x, y: projectedP2.y)
            let p3 = Position2f(x: projectedP3.x, y: projectedP3.y)
            
            // Find an offset that can move the points so the resulting bounding box has a top left point of zero
            let offset = Position2f(
                x: Swift.min(p1.x, p2.x, p3.x),
                y: Swift.min(p1.y, p2.y, p3.y)
            )
            
            self.p1 = p1 - offset
            self.p2 = p2 - offset
            self.p3 = p3 - offset
        }
    }
    
    public struct AtlasTexture {
        public let size: Size2i
    }
    
    public struct AtlasTextureLuxel {
        let position: Position3f
        let texturePixel: Position2i
    }
    
    /// Moves each individual triangle's UVs into it's own 0 to 1 space, after baking the textures use the TextureAtlasBuilder to pack inot a single atlas
    public func atlasPack(_ rawGeometry: inout RawGeometry) -> [AtlasTexture] {
        var textures: [AtlasTexture] = []
        textures.reserveCapacity(rawGeometry.count)
        
        for index in rawGeometry.indices {
            let packed = PackedTriangle(triangle: rawGeometry[index], texelDensity: texelDensity, options: options)
            
            textures.append(packed.atlasTexture)
            
            let pixelSize: Size2f = Size2f.one / Size2f(packed.atlasTexture.size)
            let halfSize: Size2f = pixelSize * 0.5
            
//            let textureSize = Size2f(packed.atlasTexture.size)
            
            var uv1 = packed.v1UV
            var uv2 = packed.v2UV
            var uv3 = packed.v3UV
            
            if uv1.x < pixelSize.width + halfSize.width {
                uv1.x = pixelSize.width + halfSize.width
            }
            if uv1.x > 1 - (pixelSize.width + halfSize.width) {
                uv1.x = 1 - (pixelSize.width + halfSize.width)
            }
            if uv1.y < pixelSize.height + halfSize.width {
                uv1.y = pixelSize.height + halfSize.width
            }
            if uv1.y > 1 - (pixelSize.height + halfSize.width) {
                uv1.y = 1 - (pixelSize.height + halfSize.width)
            }

            if uv2.x < pixelSize.width + halfSize.width {
                uv2.x = pixelSize.width + halfSize.width
            }
            if uv2.x > 1 - (pixelSize.width + halfSize.width) {
                uv2.x = 1 - (pixelSize.width + halfSize.width)
            }
            if uv2.y < pixelSize.height + halfSize.width {
                uv2.y = pixelSize.height + halfSize.width
            }
            if uv2.y > 1 - (pixelSize.height + halfSize.width) {
                uv2.y = 1 - (pixelSize.height + halfSize.width)
            }

            if uv3.x < pixelSize.width + halfSize.width {
                uv3.x = pixelSize.width + halfSize.width
            }
            if uv3.x > 1 - (pixelSize.width + halfSize.width) {
                uv3.x = 1 - (pixelSize.width + halfSize.width)
            }
            if uv3.y < pixelSize.height + halfSize.width {
                uv3.y = pixelSize.height + halfSize.width
            }
            if uv3.y > 1 - (pixelSize.height + halfSize.width) {
                uv3.y = 1 - (pixelSize.height + halfSize.width)
            }
            
            switch uvSet {
            case 0:
                rawGeometry[index].v1.uv1 = TextureCoordinate(uv1)
                rawGeometry[index].v2.uv1 = TextureCoordinate(uv2)
                rawGeometry[index].v3.uv1 = TextureCoordinate(uv3)
            case 1:
                rawGeometry[index].v1.uv2 = TextureCoordinate(uv1)
                rawGeometry[index].v2.uv2 = TextureCoordinate(uv2)
                rawGeometry[index].v3.uv2 = TextureCoordinate(uv3)
            default:
                fatalError("Only uvSet 0 and 1 are supported for now.")
            }
        }
        
        return textures
    }
}



extension LightMapPacker {
    struct SearchGrid {
        var rows: [[Bool]] = []
        var width: Int {
            return rows.first?.count ?? 0
        }
        var height: Int {
            return rows.count
        }
        
        mutating func markAsOccupied(_ occupied: Bool, _ rect: Rect2i) {
            // Insert new rows
            while rows.count < rect.y + rect.height {
                rows.append(Array(repeating: false, count: self.width))
            }
            // Insert new columns
            while rows[0].count < rect.x + rect.width {
                for rowIndex in rows.indices {
                    rows[rowIndex].append(false)
                }
            }
            // Mark occupied
            for row in rect.y ..< rect.y + rect.height {
                for column in rect.x ..< rect.x + rect.width {
                    rows[row][column] = occupied
                }
            }
        }
        
        func isOccupied(_ rect: Rect2i) -> Bool {
            if rect.x < self.width && rect.y < self.height {
                for row in rect.y ..< min(rect.y + rect.height, self.height) {
                    for column in rect.x ..< min(rect.x + rect.width, self.width) {
                        if rows[row][column] == true {
                            // If any slot is occupied, the rectangle wont fit here
                            return true
                        }
                    }
                }
            }
            return false
        }
        
        mutating func firstUnoccupiedFor(_ size: Size2i, markOccupied: Bool) -> Position2i {
            for rowIndex in 0 ..< self.height {
                for columnIndex in 0 ..< self.width {
                    guard columnIndex + width < self.width else { break }
                    let rect = Rect2i(origin: Position2i(x: columnIndex, y: rowIndex), size: size)
                    if self.isOccupied(rect) == false {
                        if markOccupied {
                            self.markAsOccupied(true, rect)
                        }
                        return Position2i(x: columnIndex, y: rowIndex)
                    }
                }
            }
            
            let coord: Position2i
            // Attempt to keep the search grid a square
            if self.width + size.width > self.height + size.height {
                // Prefer vertical expansion
                coord = Position2i(x: 0, y: self.height)
            }else{
                // Prefer horizontal expansion
                coord = Position2i(x: self.width, y: 0)
            }
            if markOccupied {
                self.markAsOccupied(true, Rect2i(origin: coord, size: size))
            }
            return coord
        }
    }
}
