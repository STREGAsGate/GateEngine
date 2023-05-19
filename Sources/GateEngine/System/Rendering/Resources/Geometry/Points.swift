/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

/** Geometry represents a mangaed vertex buffer object.
It's contents are stored within GPU accessible memory and this object represents a reference to that memory.
When this object deinitializes it's contents will also be removed from GPU memory.
*/
@MainActor public class Points: Resource {
    @usableFromInline
    internal let cacheKey: ResourceManager.Cache.GeometryKey
    
    @usableFromInline
    internal var backend: GeometryBackend? {
        return Game.shared.resourceManager.geometryCache(for: cacheKey)?.geometryBackend
    }
    
    public var cacheHint: CacheHint {
        get {Game.shared.resourceManager.geometryCache(for: cacheKey)!.cacheHint}
        set {Game.shared.resourceManager.changeCacheHint(newValue, for: cacheKey)}
    }
    
    public var state: ResourceState {
        return Game.shared.resourceManager.geometryCache(for: cacheKey)!.state
    }
    
    public init(path: String, options: GeometryImporterOptions = .none) {
        let resourceManager = Game.shared.resourceManager
        self.cacheKey = resourceManager.geometryCacheKey(path: path, options: options)
        self.cacheHint = .whileReferenced
        resourceManager.incrementReference(self.cacheKey)
    }
    
    public init(_ rawPoints: RawPoints) {
        let resourceManager = Game.shared.resourceManager
        self.cacheKey = resourceManager.geometryCacheKey(rawPoints: rawPoints)
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

extension Points: Equatable, Hashable {
    nonisolated public static func == (lhs: Points, rhs: Points) -> Bool {
        return lhs.cacheKey == rhs.cacheKey
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(cacheKey)
    }
}
