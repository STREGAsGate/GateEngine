/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GATEENGINE_PLATFORM_SUPPORTS_FOUNDATION_FILEMANAGER
import Foundation
#endif
import GameMath

@MainActor public class TileSet: Resource, _Resource {
    internal let cacheKey: ResourceManager.Cache.TileSetKey
    
    var cache: any ResourceCache {
        return Game.unsafeShared.resourceManager.tileSetCache(for: cacheKey)!
    }
    
    @usableFromInline
    internal var backend: TileSetBackend {
        return Game.unsafeShared.resourceManager.tileSetCache(for: cacheKey)!.tileSetBackend!
    }
    
    public var texture: Texture {
        return backend.texture
    }

    public var count: Int {
        return backend.count
    }
    public var columns: Int {
        return backend.columns
    }
    public var tileSize: Size2 {
        return backend.tileSize
    }

    public var tiles: [TileSet.Tile] {
        return backend.tiles
    }
    
    public init(
        path: String,
        options: TileSetImporterOptions = .none
    ) {
        let resourceManager = Game.unsafeShared.resourceManager
        self.cacheKey = resourceManager.tileSetCacheKey(
            path: path,
            options: options
        )
        self.defaultCacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }
    
    public init(
        texture: Texture,
        count: Int,
        columns: Int,
        tileSize: Size2,
        tiles: [TileSet.Tile]
    ) {
        let resourceManager = Game.unsafeShared.resourceManager
        self.cacheKey = resourceManager.tileSetCacheKey(texture: texture,
                                                        count: count,
                                                        columns: columns,
                                                        tileSize: tileSize,
                                                        tiles: tiles)
        self.defaultCacheHint = .whileReferenced
        resourceManager.incrementReference(self.cacheKey)
    }

    public func rectForTile(_ tile: TileMap.Tile) -> Rect {
        let row = tile.id / columns
        let column = tile.id % columns
        let position = Position2(tileSize.width * Float(column), tileSize.height * Float(row))
        let size = Size2(Float(tileSize.width), Float(tileSize.height))
        return Rect(position: position, size: size)
    }
    
    deinit {
        let cacheKey = self.cacheKey
        Task {@MainActor in
            Game.unsafeShared.resourceManager.decrementReference(cacheKey)
        }
    }
}

extension TileSet: Equatable, Hashable {
    nonisolated public static func == (lhs: TileSet, rhs: TileSet) -> Bool {
        return lhs.cacheKey == rhs.cacheKey
    }

    public nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(cacheKey)
    }
}

extension TileSet {
    public struct Tile: Equatable {
        public typealias ID = Int
        public let id: ID
        public let properties: [String: String]
        public let colliders: [Collider]?

        public struct Collider: Equatable {
            public enum Kind {
                case ellipse
                case rect
            }
            public let kind: Kind
            public let center: Position2
            public let radius: Size2
        }

        public func bool(forKey key: String) -> Bool {
            if let value = properties[key] {
                return Bool(value) ?? false
            }
            return false
        }

        public func integer(forKey key: String) -> Int? {
            if let value = properties[key] {
                return Int(value)
            }
            return nil
        }
    }
}

public final class TileSetBackend {
    let texture: Texture

    var count: Int
    var columns: Int
    var tileSize: Size2

    var tiles: [TileSet.Tile]

    var state: ResourceState = .pending
    
    init(
        texture: Texture,
        count: Int,
        columns: Int,
        tileSize: Size2,
        tiles: [TileSet.Tile]
    ) {
        self.texture = texture
        self.count = count
        self.columns = columns
        self.tileSize = tileSize
        self.tiles = tiles
        self.state = .ready
    }
}


// MARK: - Resource Manager

public protocol TileSetImporter: ResourceImporter {
    func loadTileSet(options: TileSetImporterOptions) async throws(GateEngineError) -> TileSetBackend
}

public struct TileSetImporterOptions: Equatable, Hashable, Sendable {
    public static var none: TileSetImporterOptions {
        return TileSetImporterOptions()
    }
}

extension ResourceManager {
    public func addTileSetImporter(_ type: any TileSetImporter.Type) {
        guard importers.tileSetImporters.contains(where: { $0 == type }) == false else { return }
        importers.tileSetImporters.insert(type, at: 0)
    }

    fileprivate func importerForFileType(_ file: String) async throws -> (any TileSetImporter)? {
        for type in self.importers.tileSetImporters {
            if type.canProcessFile(file) {
                return try await self.importers.getImporter(path: file, type: type)
            }
        }
        return nil
    }
}

extension ResourceManager.Cache {
    @usableFromInline
    struct TileSetKey: Hashable, Sendable, CustomStringConvertible {
        let requestedPath: String
        let tileSetOptions: TileSetImporterOptions
        
        @usableFromInline
        var description: String {
            return requestedPath.first == "$" ? "(Generated)" : requestedPath
        }
    }

    @usableFromInline
    final class TileSetCache: ResourceCache {
        @usableFromInline var tileSetBackend: TileSetBackend?
        var lastLoaded: Date
        var state: ResourceState
        var referenceCount: UInt
        var minutesDead: UInt
        var cacheHint: CacheHint?
        var defaultCacheHint: CacheHint
        init() {
            self.tileSetBackend = nil
            self.lastLoaded = Date()
            self.state = .pending
            self.referenceCount = 0
            self.minutesDead = 0
            self.cacheHint = nil
            self.defaultCacheHint = .until(minutes: 5)
        }
    }
}

@MainActor
extension ResourceManager {
    func changeCacheHint(_ cacheHint: CacheHint, for key: Cache.TileSetKey) {
        if let tileSetCache = cache.tileSets[key] {
            tileSetCache.cacheHint = cacheHint
            tileSetCache.minutesDead = 0
        }
    }
    
    @MainActor func tileSetCacheKey(path: String, options: TileSetImporterOptions) -> Cache.TileSetKey {
        let key = Cache.TileSetKey(requestedPath: path, tileSetOptions: options)
        if cache.tileSets[key] == nil {
            cache.tileSets[key] = Cache.TileSetCache()
            self._reloadTileSet(for: key, isFirstLoad: true)
        }
        return key
    }
    
    @MainActor func tileSetCacheKey(texture: Texture,
                         count: Int,
                         columns: Int,
                         tileSize: Size2,
                         tiles: [TileSet.Tile]) -> Cache.TileSetKey {
        let key = Cache.TileSetKey(requestedPath: "$\(rawCacheIDGenerator.generateID())", tileSetOptions: .none)
        let cache = self.cache
        if cache.tileSets[key] == nil {
            cache.tileSets[key] = Cache.TileSetCache()
            Game.unsafeShared.resourceManager.incrementLoading(path: key.requestedPath)
            if let cache = cache.tileSets[key] {
                cache.tileSetBackend = TileSetBackend(texture: texture,
                                                      count: count,
                                                      columns: columns,
                                                      tileSize: tileSize,
                                                      tiles: tiles)
                cache.state = .ready
            }else{
                Log.warn("Resource \"(Generated TileSet)\" was deallocated before being loaded.")
            }
            Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
        }
        return key
    }
    
    @usableFromInline
    func tileSetCache(for key: Cache.TileSetKey) -> Cache.TileSetCache? {
        return cache.tileSets[key]
    }
    
    func incrementReference(_ key: Cache.TileSetKey) {
        self.tileSetCache(for: key)?.referenceCount += 1
    }
    func decrementReference(_ key: Cache.TileSetKey) {
        guard let cache = self.tileSetCache(for: key) else {return}
        cache.referenceCount -= 1
        
        if case .whileReferenced = cache.effectiveCacheHint {
            if cache.referenceCount == 0 {
                self.cache.tileSets.removeValue(forKey: key)
                Log.debug("Removing cache (no longer referenced), TileSet: \(key)")
            }
        }
    }
    
    func reloadTileSetIfNeeded(key: Cache.TileSetKey) {
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else { return }
        guard self.tileSetNeedsReload(key: key) else { return }
        self._reloadTileSet(for: key, isFirstLoad: false)
    }
    
    @MainActor func _reloadTileSet(for key: Cache.TileSetKey, isFirstLoad: Bool) {
        Game.unsafeShared.resourceManager.incrementLoading(path: key.requestedPath)
        let cache = self.cache
        Task.detached {
            let path = key.requestedPath
            
            do {
                guard let importer: any TileSetImporter = try await Game.unsafeShared.resourceManager.importerForFileType(path) else {
                    throw GateEngineError.failedToLoad("No importer for \(URL(fileURLWithPath: path).pathExtension).")
                }

                let backend = try await importer.loadTileSet(options: key.tileSetOptions)

                Task { @MainActor in
                    if let cache = cache.tileSets[key] {
                        cache.tileSetBackend = backend
                        cache.state = .ready
                    }else{
                        Log.warn("Resource \"\(path)\" was deallocated before being " + (isFirstLoad ? "loaded." : "re-loaded."))
                    }
                    Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch let error as GateEngineError {
                Task { @MainActor in
                    Log.warn("Resource \"\(path)\"", error)
                    if let cache = cache.tileSets[key] {
                        cache.state = .failed(error: error)
                    }
                    Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch let error as DecodingError {
                let error = GateEngineError(error)
                Task { @MainActor in
                    Log.warn("Resource \"\(path)\"", error)
                    if let cache = cache.tileSets[key] {
                        cache.state = .failed(error: error)
                    }
                    Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch {
                Log.fatalError("error must be a GateEngineError")
            }
        }
    }
    
    func tileSetNeedsReload(key: Cache.TileSetKey) -> Bool {
        #if GATEENGINE_ENABLE_HOTRELOADING && GATEENGINE_PLATFORM_SUPPORTS_FOUNDATION_FILEMANAGER
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else { return false }
        guard let cache = cache.tileSets[key] else { return false }
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: key.requestedPath)
            if let modified = (attributes[.modificationDate] ?? attributes[.creationDate]) as? Date
            {
                return modified > cache.lastLoaded
            } else {
                return false
            }
        } catch {
            Log.error(error)
            return false
        }
        #else
        return false
        #endif
    }
}
