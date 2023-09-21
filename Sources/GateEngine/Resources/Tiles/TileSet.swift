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

@MainActor public class TileSet: Resource {
    internal let cacheKey: ResourceManager.Cache.TileSetKey
    
    public var cacheHint: CacheHint {
        get { Game.shared.resourceManager.tileSetCache(for: cacheKey)!.cacheHint }
        set { Game.shared.resourceManager.changeCacheHint(newValue, for: cacheKey) }
    }

    public var state: ResourceState {
        return Game.shared.resourceManager.tileSetCache(for: cacheKey)!.state
    }
    
    @usableFromInline
    internal var backend: TileSetBackend {
        return Game.shared.resourceManager.tileSetCache(for: cacheKey)!.tileSetBackend!
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
        let resourceManager = Game.shared.resourceManager
        self.cacheKey = resourceManager.tileSetCacheKey(
            path: path,
            options: options
        )
        self.cacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }
    
    public init(
        texture: Texture,
        count: Int,
        columns: Int,
        tileSize: Size2,
        tiles: [TileSet.Tile]
    ) {
        let resourceManager = Game.shared.resourceManager
        self.cacheKey = resourceManager.tileSetCacheKey(texture: texture,
                                                        count: count,
                                                        columns: columns,
                                                        tileSize: tileSize,
                                                        tiles: tiles)
        self.cacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }

    public func rectForTile(_ tile: Int) -> Rect {
        let row = tile / columns
        let column = tile % columns
        let position = Position2(tileSize.width * Float(column), tileSize.height * Float(row))
        let size = Size2(Float(tileSize.width), Float(tileSize.height))
        return Rect(position: position, size: size)
    }
    
    deinit {
        let cacheKey = self.cacheKey
        Task.detached(priority: .low) { @MainActor in
            Game.shared.resourceManager.decrementReference(cacheKey)
        }
    }
}

extension TileSet: Equatable, Hashable {
    nonisolated public static func == (lhs: TileSet, rhs: TileSet) -> Bool {
        return lhs.cacheKey == rhs.cacheKey
    }

    public func hash(into hasher: inout Hasher) {
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

public protocol TileSetImporter: AnyObject {
    init()

    func process(data: Data, baseURL: URL, options: TileSetImporterOptions) async throws -> TileSetBackend

    static func supportedFileExtensions() -> [String]
}

public struct TileSetImporterOptions: Equatable, Hashable {
    public static var none: TileSetImporterOptions {
        return TileSetImporterOptions()
    }
}

extension ResourceManager {
    public func addTileSetImporter(_ type: any TileSetImporter.Type) {
        guard importers.tileSetImporters.contains(where: { $0 == type }) == false else { return }
        importers.tileSetImporters.insert(type, at: 0)
    }

    fileprivate func importerForFileType(_ file: String) -> (any TileSetImporter)? {
        for type in self.importers.tileSetImporters {
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
    struct TileSetKey: Hashable {
        let requestedPath: String
        let tileSetOptions: TileSetImporterOptions
    }

    @usableFromInline
    class TileSetCache {
        @usableFromInline var tileSetBackend: TileSetBackend?
        var lastLoaded: Date
        var state: ResourceState
        var referenceCount: UInt
        var minutesDead: UInt
        var cacheHint: CacheHint
        init() {
            self.tileSetBackend = nil
            self.lastLoaded = Date()
            self.state = .pending
            self.referenceCount = 0
            self.minutesDead = 0
            self.cacheHint = .until(minutes: 5)
        }
    }
}
extension ResourceManager {
    func changeCacheHint(_ cacheHint: CacheHint, for key: Cache.TileSetKey) {
        if let tileSetCache = cache.tileSets[key] {
            tileSetCache.cacheHint = cacheHint
            tileSetCache.minutesDead = 0
        }
    }
    
    func tileSetCacheKey(path: String, options: TileSetImporterOptions) -> Cache.TileSetKey {
        let key = Cache.TileSetKey(requestedPath: path, tileSetOptions: options)
        if cache.tileSets[key] == nil {
            cache.tileSets[key] = Cache.TileSetCache()
            self._reloadTileSet(for: key)
        }
        return key
    }
    
    func tileSetCacheKey(texture: Texture,
                         count: Int,
                         columns: Int,
                         tileSize: Size2,
                         tiles: [TileSet.Tile]) -> Cache.TileSetKey {
        let key = Cache.TileSetKey(requestedPath: "$\(rawCacheIDGenerator.generateID())", tileSetOptions: .none)
        if cache.tileSets[key] == nil {
            cache.tileSets[key] = Cache.TileSetCache()
            Task.detached(priority: .low) {
                let backend = TileSetBackend(texture: texture,
                                             count: count,
                                             columns: columns,
                                             tileSize: tileSize,
                                             tiles: tiles)
                
                Task { @MainActor in
                    self.cache.tileSets[key]!.tileSetBackend = backend
                    self.cache.tileSets[key]!.state = .ready
                }
            }
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
        self.tileSetCache(for: key)?.referenceCount -= 1
    }
    
    func reloadTileSetIfNeeded(key: Cache.TileSetKey) {
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else { return }
        Task.detached(priority: .low) {
            guard self.tileSetNeedsReload(key: key) else { return }
            self._reloadTileSet(for: key)
        }
    }
    
    func _reloadTileSet(for key: Cache.TileSetKey) {
        Task.detached(priority: .low) {
            let path = key.requestedPath
            
            do {
                guard let fileExtension = path.components(separatedBy: ".").last else {
                    throw GateEngineError.failedToLoad("Unknown file type.")
                }
                guard
                    let importer: any TileSetImporter = await Game.shared.resourceManager
                        .importerForFileType(fileExtension)
                else {
                    throw GateEngineError.failedToLoad("No importer for \(fileExtension).")
                }

                let data = try await Game.shared.platform.loadResource(from: path)
                let backend = try await importer.process(
                    data: data,
                    baseURL: URL(string: path)!.deletingLastPathComponent(),
                    options: key.tileSetOptions
                )

                Task { @MainActor in
                    self.cache.tileSets[key]!.tileSetBackend = backend
                    self.cache.tileSets[key]!.state = .ready
                }
            } catch let error as GateEngineError {
                Task { @MainActor in
                    Log.warn("Resource \"\(path)\"", error)
                    self.cache.tileSets[key]!.state = .failed(error: error)
                }
            } catch let error as DecodingError {
                let error = GateEngineError(decodingError: error)
                Task { @MainActor in
                    Log.warn("Resource \"\(path)\"", error)
                    self.cache.tileSets[key]!.state = .failed(error: error)
                }
            } catch {
                Log.fatalError("error must be a GateEngineError")
            }
        }
    }
    
    func tileSetNeedsReload(key: Cache.TileSetKey) -> Bool {
        #if GATEENGINE_ENABLE_HOTRELOADING && GATEENGINE_PLATFORM_FOUNDATION_FILEMANAGER
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
