/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

/// UVs from a piece of renderable geometry
public struct CollisionAttributeUVs {
    /// Each of the UV sets that was present on the renderable triangle primitive
    public let uvSets: [TriangleUVs]
    /// UVs from a piece of renderable geometry
    public struct TriangleUVs {
        /// UV position for vertex 1
        public let uv1: TextureCoordinate
        /// UV position for vertex 2
        public let uv2: TextureCoordinate
        /// UV position for vertex 3
        public let uv3: TextureCoordinate
        
        package init(uv1: TextureCoordinate, uv2: TextureCoordinate, uv3: TextureCoordinate) {
            self.uv1 = uv1
            self.uv2 = uv2
            self.uv3 = uv3
        }
    }
    
    package init(uvSets: [TriangleUVs]) {
        self.uvSets = uvSets
    }
}

public protocol CollisionAttributesType: RawRepresentable, Equatable, Sendable where RawValue == UInt32 {
    var rawValue: RawValue { get }
    init(rawValue: RawValue)
    
    static func parseTriangleUVs(_ triangleUVs: CollisionAttributeUVs) -> RawValue
}

public extension CollisionAttributesType {
    static func parseTriangleUVs(_ triangleUVs: CollisionAttributeUVs) -> RawValue {
        var value: RawValue = 0
        for uvSetIndex in triangleUVs.uvSets.indices {
            let uvSet = triangleUVs.uvSets[uvSetIndex]
            let range: Float = 3
            let uidx: Float = floor(uvSet.uv1.x * range)
            let vidx: Float = floor(uvSet.uv1.y * range)
            
            guard uidx >= 0 && uidx < range else {continue}
            guard vidx >= 0 && vidx < range else {continue}
            
            let row = UInt32(vidx) * UInt32(range)
            let shift = (UInt32(range * range) * UInt32(uvSetIndex)) + (row + UInt32(uidx) + 1)
            value |= (1 << shift)
        }
        return value
    }
}

public protocol CollisionAttributesGroup: RawRepresentable, Equatable, Sendable where RawValue == UInt64 {
    associatedtype Group1: CollisionAttributesType
    associatedtype Group2: CollisionAttributesType
    var group1: Group1 {get set}
    var group2: Group2 {get set}
    
    init(group1: Group1, group2: Group2)
    init(rawValue: RawValue)
}

extension CollisionAttributesGroup {
    public var rawValue: RawValue {
        return RawValue(group1.rawValue) << 32 | RawValue(group2.rawValue)
    }
    public init(rawValue: RawValue) {
        let group1 = Group1(rawValue: Group1.RawValue(rawValue >> 32))
        let group2 = Group2(rawValue: Group2.RawValue(truncatingIfNeeded: rawValue))
        self.init(group1: group1, group2: group2)
    }
    
    package init(parsingUVs triangleUVs: CollisionAttributeUVs) {
        let group1 = Group1(rawValue: Group1.parseTriangleUVs(triangleUVs))
        let group2 = Group2(rawValue: Group2.parseTriangleUVs(triangleUVs))
        self.init(group1: group1, group2: group2)
    }
}

public struct BasicCollisionAttributes: CollisionAttributesGroup {
    public var group1: FlagAttributes
    public var group2: ValueAttributes
    public init(group1: FlagAttributes, group2: ValueAttributes) {
        self.group1 = group1
        self.group2 = group2
    }
  
    public var flags: FlagAttributes {
        get { group1 }
        set { group1 = newValue }
    }
    public struct FlagAttributes: CollisionAttributesType, OptionSet, Sendable {
        public typealias RawValue = UInt32
        public var rawValue: RawValue
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public static let none: Self = .init(rawValue: 0)
    }

    public var values: ValueAttributes {
        get { group2 }
        set { group2 = newValue }
    }
    public struct ValueAttributes: CollisionAttributesType {
        public typealias RawValue = UInt32
        public var rawValue: RawValue
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public mutating func setBool(_ value: Bool, at index: Int) {
            let bool: RawValue = 1 << RawValue(index)
            self.rawValue &= ~bool
            self.rawValue |= bool
        }
        
        public func getBool(at index: Int) -> Bool {
            let bool: RawValue = 1 << RawValue(index)
            return (self.rawValue & bool) == bool
        }
    }
}
