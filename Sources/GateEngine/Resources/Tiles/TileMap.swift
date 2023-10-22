/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GATEENGINE_PLATFORM_FOUNDATION_FILEMANAGER
import Foundation
#endif
import GameMath

@MainActor public final class TileMap: Resource {
    internal let cacheKey: ResourceManager.Cache.TileMapKey
    
    public var cacheHint: CacheHint {
        get { Game.shared.resourceManager.tileMapCache(for: cacheKey)!.cacheHint }
        set { Game.shared.resourceManager.changeCacheHint(newValue, for: cacheKey) }
    }

    public nonisolated var state: ResourceState {
        return Game.shared.resourceManager.tileMapCache(for: cacheKey)!.state
    }
    
    @usableFromInline
    internal var backend: TileMapBackend {
        assert(state == .ready, "This resource is not ready to be used. Make sure it's state property is .ready before accessing!")
        return Game.shared.resourceManager.tileMapCache(for: cacheKey)!.tileMapBackend!
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
        let resourceManager = Game.shared.resourceManager
        self.cacheKey = resourceManager.tileMapCacheKey(
            path: path,
            options: options
        )
        self.cacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }
    
    public init(layers: [Layer]) {
        let resourceManager = Game.shared.resourceManager
        self.cacheKey = resourceManager.tileMapCacheKey(layers: layers)
        self.cacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }
    
    public struct Tile: Equatable {
        public let id: Int
        public let options: Options
        public struct Options: OptionSet {
            public let rawValue: UInt
            public init(rawValue: UInt) {
                self.rawValue = rawValue
            }
            
            public static let flippedHorizontal    = Options(rawValue: 0x80000000)
            public static let flippedVertical      = Options(rawValue: 0x40000000)
            public static let flippedDiagonal      = Options(rawValue: 0x20000000)
            public static let rotatedHexagonal120  = Options(rawValue: 0x10000000)
        }
        
        public init(id: Int, options: Options) {
            self.id = id
            self.options = options
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
        
        public struct Coordinate: Hashable {
            public var column: Int
            public var row: Int
            
            
            public init(column: Int, row: Int) {
                self.column = column
                self.row = row
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

        init(name: String?, size: Size2, tileSize: Size2, tiles: [[Tile]]) {
            self.name = name
            self.size = size
            self.tileSize = tileSize
            self.tiles = tiles
        }
    }
    
    deinit {
        let cacheKey = self.cacheKey
        Task.detached(priority: .low) { @MainActor in
            Game.shared.resourceManager.decrementReference(cacheKey)
        }
    }
}

extension TileMap: Equatable, Hashable {
    nonisolated public static func == (lhs: TileMap, rhs: TileMap) -> Bool {
        return lhs.cacheKey == rhs.cacheKey
    }

    public func hash(into hasher: inout Hasher) {
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

public struct TileMapImporterOptions: Equatable, Hashable {
    public var subobjectName: String? = nil

    public static func named(_ name: String) -> Self {
        return TileMapImporterOptions(subobjectName: name)
    }

    public static var none: TileMapImporterOptions {
        return TileMapImporterOptions()
    }
}

public protocol TileMapImporter: AnyObject {
    init()

    func process(data: Data, baseURL: URL, options: TileMapImporterOptions) async throws -> TileMapBackend

    static func supportedFileExtensions() -> [String]
}

extension ResourceManager {
    public func addTileMapImporter(_ type: any TileMapImporter.Type) {
        guard importers.tileMapImporters.contains(where: { $0 == type }) == false else { return }
        importers.tileMapImporters.insert(type, at: 0)
    }

    fileprivate func importerForFileType(_ file: String) -> (any TileMapImporter)? {
        for type in self.importers.tileMapImporters {
            if type.supportedFileExtensions().contains(where: {
                $0.caseInsensitiveCompare(file) == .orderedSame
            }) {
                return type.init()
            }
        }
        return nil
    }
}

extension ResourceManager.Cache {
    @usableFromInline
    struct TileMapKey: Hashable {
        let requestedPath: String
        let tileMapOptions: TileMapImporterOptions
    }

    @usableFromInline
    class TileMapCache {
        @usableFromInline var tileMapBackend: TileMapBackend?
        var lastLoaded: Date
        var state: ResourceState
        var referenceCount: UInt
        var minutesDead: UInt
        var cacheHint: CacheHint
        init() {
            self.tileMapBackend = nil
            self.lastLoaded = Date()
            self.state = .pending
            self.referenceCount = 0
            self.minutesDead = 0
            self.cacheHint = .until(minutes: 5)
        }
    }
}
extension ResourceManager {
    func changeCacheHint(_ cacheHint: CacheHint, for key: Cache.TileMapKey) {
        if let tileSetCache = cache.tileMaps[key] {
            tileSetCache.cacheHint = cacheHint
            tileSetCache.minutesDead = 0
        }
    }
    
    @MainActor func tileMapCacheKey(path: String, options: TileMapImporterOptions) -> Cache.TileMapKey {
        let key = Cache.TileMapKey(requestedPath: path, tileMapOptions: options)
        if cache.tileMaps[key] == nil {
            cache.tileMaps[key] = Cache.TileMapCache()
            self._reloadTileMap(for: key, isFirstLoad: true)
        }
        return key
    }
    
    @MainActor func tileMapCacheKey(layers: [TileMap.Layer]) -> Cache.TileMapKey {
        let key = Cache.TileMapKey(requestedPath: "$\(rawCacheIDGenerator.generateID())", tileMapOptions: .none)
        if cache.tileMaps[key] == nil {
            cache.tileMaps[key] = Cache.TileMapCache()
            Game.shared.resourceManager.incrementLoading(path: key.requestedPath)
            Task.detached(priority: .high) {
                let backend = await TileMapBackend(layers: layers)
                Task { @MainActor in
                    if let cache = self.cache.tileMaps[key] {
                        cache.tileMapBackend = backend
                        cache.state = .ready
                    }else{
                        Log.warn("Resource \"(Generated TileMap)\" was deallocated before being loaded.")
                    }
                    Game.shared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            }
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
        
        if case .whileReferenced = cache.cacheHint {
            if cache.referenceCount == 0 {
                self.cache.tileMaps.removeValue(forKey: key)
                Log.debug(
                    "Removing cache (no longer referenced), TileMap:",
                    key.requestedPath.first == "$" ? "(Generated)" : key.requestedPath
                )
            }
        }
    }
    
    func reloadTileMapIfNeeded(key: Cache.TileMapKey) {
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else { return }
        Task {
            guard self.tileMapNeedsReload(key: key) else { return }
            await self._reloadTileMap(for: key, isFirstLoad: false)
        }
    }
    
    @MainActor func _reloadTileMap(for key: Cache.TileMapKey, isFirstLoad: Bool) {
        Game.shared.resourceManager.incrementLoading(path: key.requestedPath)
        Task.detached(priority: .high) {
            let path = key.requestedPath
            
            do {
                guard let fileExtension = path.components(separatedBy: ".").last else {
                    throw GateEngineError.failedToLoad("Unknown file type.")
                }
                guard
                    let importer: any TileMapImporter = Game.shared.resourceManager
                        .importerForFileType(fileExtension)
                else {
                    throw GateEngineError.failedToLoad("No importer for \(fileExtension).")
                }

                let data = try await Game.shared.platform.loadResource(from: path)
                let backend = try await importer.process(
                    data: data,
                    baseURL: URL(string: path)!.deletingLastPathComponent(),
                    options: key.tileMapOptions
                )

                Task { @MainActor in
                    if let cache = self.cache.tileMaps[key] {
                        cache.tileMapBackend = backend
                        cache.state = .ready
                    }else{
                        Log.warn("Resource \"\(path)\" was deallocated before being " + (isFirstLoad ? "loaded." : "re-loaded."))
                    }
                    Game.shared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch let error as GateEngineError {
                Task { @MainActor in
                    Log.warn("Resource \"\(path)\"", error)
                    if let cache = self.cache.tileMaps[key] {
                        cache.state = .failed(error: error)
                    }
                    Game.shared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch {
                Log.fatalError("error must be a GateEngineError")
            }
        }
    }
    
    func tileMapNeedsReload(key: Cache.TileMapKey) -> Bool {
        #if GATEENGINE_ENABLE_HOTRELOADING && GATEENGINE_PLATFORM_FOUNDATION_FILEMANAGER
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else { return false }
        guard let cache = cache.tileMaps[key] else { return false }
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
