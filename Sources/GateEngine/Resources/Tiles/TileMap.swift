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

@MainActor public final class TileMap: Resource, _Resource {
    internal let cacheKey: ResourceManager.Cache.TileMapKey
    
    var cache: any ResourceCache {
        return Game.unsafeShared.resourceManager.tileMapCache(for: cacheKey)!
    }
    
    @usableFromInline
    internal var backend: TileMapBackend {
        assert(state == .ready, "This resource is not ready to be used. Make sure it's state property is .ready before accessing!")
        return Game.unsafeShared.resourceManager.tileMapCache(for: cacheKey)!.tileMapBackend!
    }
    
    public var layers: [Layer] {
        return self.backend.layers
    }

    public var size: Size2 {
        return layers.first?.size ?? .zero
    }

    public init(
        path: String,
        options: TileMapImporterOptions = .none
    ) {
        let resourceManager = Game.unsafeShared.resourceManager
        self.cacheKey = resourceManager.tileMapCacheKey(
            path: path,
            options: options
        )
        self.defaultCacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }
    
    public init(layers: [Layer]) {
        let resourceManager = Game.unsafeShared.resourceManager
        self.cacheKey = resourceManager.tileMapCacheKey(layers: layers)
        self.defaultCacheHint = .whileReferenced
        resourceManager.incrementReference(self.cacheKey)
    }
    
    public struct Tile: Equatable, Sendable, ExpressibleByIntegerLiteral, ExpressibleByNilLiteral {        
        public let id: Int
        public let options: Options
        public struct Options: OptionSet, Equatable, Sendable {
            public let rawValue: UInt
            public init(rawValue: UInt) {
                self.rawValue = rawValue
            }
            
            /// Inverts pixels along x axis
            public static let flippedHorizontal    = Options(rawValue: 0x80000000)
            /// Inverts pixels along y axis
            public static let flippedVertical      = Options(rawValue: 0x40000000)
            /// Inverts pixels along x axis and inverts pixels along y axis
            /// - note: This option can be combined with ``flippedHorizontal`` and ``flippedVertical`` to create rotations
            public static let flippedDiagonal      = Options(rawValue: 0x20000000)
            
            public static let rotatedHexagonal120  = Options(rawValue: 0x10000000)
            
            /**
             Causes the tile to draw with pixels inverted along the x axis.
             - note: This convenience option is identical to ``flippedHorizontal``.
             */
            @inlinable
            public static var flipX: Self {Self.flippedHorizontal}
            
            /**
             Causes the tile to draw with pixels inverted along the y axis.
             - note: This convenience option is identical to ``flippedVertical``.
             */
            @inlinable
            public static var flipY: Self {Self.flippedVertical}
            
            
            @inlinable
            public static var rotated90: Self {[.flippedHorizontal, .flippedDiagonal]}
            @inlinable
            public static var rotated180: Self {[.flippedVertical]}
            @inlinable
            public static var rotated270: Self {[.flippedVertical, .flippedDiagonal]}
        }
        
        public init(id: Int, options: Options) {
            self.id = id
            self.options = options
        }
        
        public typealias IntegerLiteralType = Int
        public init(integerLiteral value: Int) {
            self.id = value
            self.options = []
        }
        
        public init(nilLiteral: ()) {
            self = .empty
        }
        
        public static let empty = Tile(id: -1, options: [])
        
        public static func id(_ id: Int, _ options: Options = []) -> Self {
            return .init(id: id, options: options)
        }
    }
    

    public struct Layer {
        public let name: String?
        public let size: Size2
        public let tileSize: Size2
        public let tiles: [[Tile]]
        
        public var rows: Int {
            return tiles.count
        }
        public var columns: Int {
            return tiles.first?.count ?? 0
        }
        
        public struct Coordinate: Hashable, ExpressibleByArrayLiteral, Sendable {
            public var column: Int
            public var row: Int
            
            public init(column: Int, row: Int) {
                self.column = column
                self.row = row
            }
            
            public typealias ArrayLiteralElement = Int
            public init(arrayLiteral elements: Int...) {
                assert(elements.count == 2, "A Coordinate must have exactly 2 elements.")
                self.init(column: elements[0], row: elements[1])
            }
            
            static func + (lhs: Coordinate, rhs: Coordinate) -> Coordinate {
                return Coordinate(column: lhs.column + rhs.column, row: lhs.row + rhs.row)
            }
            static func - (lhs: Coordinate, rhs: Coordinate) -> Coordinate {
                return Coordinate(column: lhs.column - rhs.column, row: lhs.row - rhs.row)
            }
            static func * (lhs: Coordinate, rhs: Coordinate) -> Coordinate {
                return Coordinate(column: lhs.column * rhs.column, row: lhs.row * rhs.row)
            }
            static func / (lhs: Coordinate, rhs: Coordinate) -> Coordinate {
                return Coordinate(column: lhs.column / rhs.column, row: lhs.row / rhs.row)
            }
        }

        public func containsCoordinate(_ coordinate: Coordinate) -> Bool {
            return tiles.indices.contains(coordinate.row)
            && tiles[coordinate.row].indices.contains(coordinate.column)
        }
        
        public func coordinate(at position: Position2) -> Coordinate? {
            let row = Int(position.y / tileSize.height)
            let column = Int(position.x / tileSize.width)
            if tiles.indices.contains(row) && tiles[row].indices.contains(column) {
                return Coordinate(column: column, row: row)
            }
            return nil
        }
        
        public func tileAtCoordinate(_ coordinate: TileMap.Layer.Coordinate) -> TileMap.Tile {
            assert(containsCoordinate(coordinate), "Coordinate out of range")
            return tiles[coordinate.row][coordinate.column]
        }

        public func tileAtPosition(_ position: Position2) -> TileMap.Tile? {
            guard let coordinate = coordinate(at: position) else {return nil}
            return tileAtCoordinate(coordinate)
        }
        
        public func rectForTileAt(_ coordinate: Coordinate) -> Rect {
            assert(containsCoordinate(coordinate), "Coordinate out of range")
            let x = Float(coordinate.column)
            let y = Float(coordinate.row)
            let position = Position2(x, y) * tileSize
            return Rect(position: position, size: tileSize)
        }

        public init(name: String?, size: Size2, tileSize: Size2, tiles: [[Tile]]) {
            self.name = name
            self.size = size
            self.tileSize = tileSize
            self.tiles = tiles
        }
    }
    
    deinit {
        let cacheKey = self.cacheKey
        Task {@MainActor in
            Game.unsafeShared.resourceManager.decrementReference(cacheKey)
        }
    }
}

extension TileMap: Equatable, Hashable {
    nonisolated public static func == (lhs: TileMap, rhs: TileMap) -> Bool {
        return lhs.cacheKey == rhs.cacheKey
    }

    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(cacheKey)
    }
}

@MainActor public class TileMapBackend {
    public let layers: [TileMap.Layer]
    
    init(layers: [TileMap.Layer]) {
        self.layers = layers
    }
}

// MARK: - Resource Manager

public struct TileMapImporterOptions: Equatable, Hashable, Sendable {
    public var subobjectName: String? = nil

    public static func named(_ name: String) -> Self {
        return TileMapImporterOptions(subobjectName: name)
    }

    public static var none: TileMapImporterOptions {
        return TileMapImporterOptions()
    }
}

public protocol TileMapImporter: ResourceImporter {
    func loadTileMap(options: TileMapImporterOptions) async throws(GateEngineError) -> TileMapBackend
}

extension ResourceManager {
    public func addTileMapImporter(_ type: any TileMapImporter.Type) {
        guard importers.tileMapImporters.contains(where: { $0 == type }) == false else { return }
        importers.tileMapImporters.insert(type, at: 0)
    }

    fileprivate func importerForFileType(_ file: String) async throws -> (any TileMapImporter)? {
        for type in self.importers.tileMapImporters {
            if type.canProcessFile(file) {
                return try await self.importers.getImporter(path: file, type: type)
            }
        }
        return nil
    }
}

extension ResourceManager.Cache {
    @usableFromInline
    struct TileMapKey: Hashable, Sendable, CustomStringConvertible {
        let requestedPath: String
        let tileMapOptions: TileMapImporterOptions
        
        @usableFromInline
        var isGenerated: Bool {
            return self.requestedPath[self.requestedPath.startIndex] == "$"
        }
        
        @usableFromInline
        var description: String {
            var string = self.isGenerated ? "(Generated)" : self.requestedPath
            if let name = self.tileMapOptions.subobjectName {
                string += ", Named: \(name)"
            }
            return string
        }
    }

    @usableFromInline
    final class TileMapCache: ResourceCache {
        @usableFromInline var tileMapBackend: TileMapBackend?
        var lastLoaded: Date
        var state: ResourceState
        var referenceCount: UInt
        var minutesDead: UInt
        var cacheHint: CacheHint?
        var defaultCacheHint: CacheHint
        init() {
            self.tileMapBackend = nil
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
    func changeCacheHint(_ cacheHint: CacheHint, for key: Cache.TileMapKey) {
        if let tileSetCache = cache.tileMaps[key] {
            tileSetCache.cacheHint = cacheHint
            tileSetCache.minutesDead = 0
        }
    }
    
    func tileMapCacheKey(path: String, options: TileMapImporterOptions) -> Cache.TileMapKey {
        let key = Cache.TileMapKey(requestedPath: path, tileMapOptions: options)
        if cache.tileMaps[key] == nil {
            cache.tileMaps[key] = Cache.TileMapCache()
            self._reloadTileMap(for: key, isFirstLoad: true)
        }
        return key
    }
    
    func tileMapCacheKey(layers: [TileMap.Layer]) -> Cache.TileMapKey {
        let key = Cache.TileMapKey(requestedPath: "$\(rawCacheIDGenerator.generateID())", tileMapOptions: .none)
        let cache = self.cache
        if cache.tileMaps[key] == nil {
            cache.tileMaps[key] = Cache.TileMapCache()
            Game.unsafeShared.resourceManager.incrementLoading(path: key.requestedPath)
            if let cache = cache.tileMaps[key] {
                cache.tileMapBackend = TileMapBackend(layers: layers)
                cache.state = .ready
            }else{
                Log.warn("Resource \"(Generated TileMap)\" was deallocated before being loaded.")
            }
            Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
        }
        return key
    }
    
    @usableFromInline
    func tileMapCache(for key: Cache.TileMapKey) -> Cache.TileMapCache? {
        return cache.tileMaps[key]
    }
    
    func incrementReference(_ key: Cache.TileMapKey) {
        self.tileMapCache(for: key)?.referenceCount += 1
    }
    func decrementReference(_ key: Cache.TileMapKey) {
        guard let cache = self.tileMapCache(for: key) else {return}
        cache.referenceCount -= 1
        
        if case .whileReferenced = cache.effectiveCacheHint {
            if cache.referenceCount == 0 {
                self.cache.tileMaps.removeValue(forKey: key)
                Log.debug("Removing cache (no longer referenced), TileMap: \(key)")
            }
        }
    }
    
    func reloadTileMapIfNeeded(key: Cache.TileMapKey) {
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else { return }
        guard self.tileMapNeedsReload(key: key) else { return }
        self._reloadTileMap(for: key, isFirstLoad: false)
    }
    
    func _reloadTileMap(for key: Cache.TileMapKey, isFirstLoad: Bool) {
        Game.unsafeShared.resourceManager.incrementLoading(path: key.requestedPath)
        let cache = self.cache
        Task.detached {
            let path = key.requestedPath
            
            do {
                guard 
                    let importer: any TileMapImporter = try await Game.unsafeShared.resourceManager.importerForFileType(path)
                else {
                    throw GateEngineError.failedToLoad(resource: path, "No TileMapImporter for \(URL(fileURLWithPath: path).pathExtension).")
                }

                let backend = try await importer.loadTileMap(options: key.tileMapOptions)

                Task { @MainActor in
                    if let cache = cache.tileMaps[key] {
                        cache.tileMapBackend = backend
                        cache.state = .ready
                    }else{
                        Log.warn("Resource \"\(path)\" was deallocated before being " + (isFirstLoad ? "loaded." : "re-loaded."))
                    }
                    Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch let error as GateEngineError {
                Task { @MainActor in
                    Log.warn("Resource \"\(path)\"", error)
                    if let cache = cache.tileMaps[key] {
                        cache.state = .failed(error: error)
                    }
                    Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch {
                Log.fatalError("error must be a GateEngineError")
            }
        }
    }
    
    func tileMapNeedsReload(key: Cache.TileMapKey) -> Bool {
        #if GATEENGINE_ENABLE_HOTRELOADING && GATEENGINE_PLATFORM_HAS_SynchronousFileSystem
        guard key.isGenerated == false else { return false }
        guard let cache = cache.tileMaps[key], cache.referenceCount > 0 else { return false }
        guard let path = Platform.current.synchronousLocateResource(from: key.requestedPath) else {return false}
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            if let modified = (attributes[.modificationDate] ?? attributes[.creationDate]) as? Date {
                return Calendar.current.compare(modified, to: cache.lastLoaded, toGranularity: .second) == .orderedDescending
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
