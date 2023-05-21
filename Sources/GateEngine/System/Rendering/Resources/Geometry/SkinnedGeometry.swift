/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

internal protocol SkinnedGeometryBackend: AnyObject {
    init(geometry: RawGeometry, skin: Skin)
}

/** Geometry represents a mangaed vertex buffer object.
It's contents are stored within GPU accessible memory and this object represents a reference to that memory.
When this object deinitializes it's contents will also be removed from GPU memory.
*/
@MainActor public class SkinnedGeometry: Resource {
    @usableFromInline
    internal let cacheKey: ResourceManager.Cache.SkinnedGeometryKey
    
    @usableFromInline
    internal var backend: GeometryBackend? {
        return Game.shared.resourceManager.skinnedGeometryCache(for: cacheKey)?.geometryBackend
    }
    
    @usableFromInline
    internal var skinJoints: [Skin.Joint]? {
        return Game.shared.resourceManager.skinnedGeometryCache(for: cacheKey)?.skinJoints
    }
    
    public var cacheHint: CacheHint {
        get {Game.shared.resourceManager.skinnedGeometryCache(for: cacheKey)!.cacheHint}
        set {Game.shared.resourceManager.changeCacheHint(newValue, for: cacheKey)}
    }
    
    public var state: ResourceState {
        return Game.shared.resourceManager.skinnedGeometryCache(for: cacheKey)!.state
    }
    
    @inlinable @inline(__always) @_disfavoredOverload
    public convenience init(as path: GeoemetryPath, geometryOptions: GeometryImporterOptions = .none, skinOptions: SkinImporterOptions = .none) {
        self.init(path: path.value, geometryOptions: geometryOptions, skinOptions: skinOptions)
    }
    
    public init(path: String, geometryOptions: GeometryImporterOptions = .none, skinOptions: SkinImporterOptions = .none) {
        let resourceManager = Game.shared.resourceManager
        self.cacheKey = resourceManager.skinnedGeometryCacheKey(path: path, geometryOptions: geometryOptions, skinOptions: skinOptions)
        self.cacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }
    
    public init(rawGeometry: RawGeometry, skin: Skin) {
        let resourceManager = Game.shared.resourceManager
        self.cacheKey = resourceManager.skinnedGeometryCacheKey(rawGeometry: rawGeometry, skin: skin)
        self.cacheHint = .whileReferenced
        resourceManager.incrementReference(self.cacheKey)
    }
    
    deinit {
        let cacheKey = self.cacheKey
        Task(priority: .low) {@MainActor in
            Game.shared.resourceManager.decrementReference(cacheKey)
        }
    }
}
extension SkinnedGeometry: Equatable, Hashable {
    nonisolated public static func == (lhs: SkinnedGeometry, rhs: SkinnedGeometry) -> Bool {
        return lhs.cacheKey == rhs.cacheKey
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(cacheKey)
    }
}
