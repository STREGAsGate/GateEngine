/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation
import Atomics

extension ResourceManager {
    struct Importers {
        internal var textureImporters: [TextureImporter.Type] = [PNGImporter.self]
        
        internal var geometryImporters: [GeometryImporter.Type] = [GLTransmissionFormat.self, WavefrontOBJImporter.self]
        internal var skeletonImporters: [SkeletonImporter.Type] = [GLTransmissionFormat.self]
        internal var skinImporters: [SkinImporter.Type] = [GLTransmissionFormat.self]
        internal var skeletalAnimationImporters: [SkeletalAnimationImporter.Type] = [GLTransmissionFormat.self]
        
        internal var tileSetImporters: [TileSetImporter.Type] = [/*TiledTileSetImporter.self*/]
        internal var tileMapImporters: [TileMapImporter.Type] = [/*TiledTileMapImporter.self*/]
    }
}

public enum CacheHint {
    /// The resource will stay in memory until the CachedHint is manually changed to something else
    case forever
    /// The resource will remain cached while it is referenced
    case whileReferenced
    /// The resource will remain cached for `minutes` of not being referenced
    case until(minutes: UInt)
}

public class ResourceManager {
    internal var importers: Importers = Importers()
    internal let cache: Cache = Cache()
    
    var rawCacheID = ManagedAtomic<UInt>(0)
    
    var accumulatedSeconds: Float = 0
    
    public let game: Game
    public init(game: Game) {
        self.game = game
    }
    
    func update(withTimePassed deltaTime: Float) {
        accumulatedSeconds += deltaTime
        if accumulatedSeconds > 60 {
            accumulatedSeconds -= 60
            incrementMinutes()
        }
    }
    
    @inline(__always)
    func incrementMinutes() {
        for key in cache.textures.keys {
            guard let cache = cache.textures[key] else {continue}
            
            switch cache.cacheHint {
            case .forever:
                continue
            case .whileReferenced:
                if cache.referenceCount == 0 {
                    self.cache.textures.removeValue(forKey: key)
                    #if DEBUG
                    print("[GateEngine] Removing cache (no longer referenced)", key.requestedPath)
                    #endif
                }
            case .until(minutes: let minutes):
                if cache.referenceCount == 0 {
                    cache.minutesDead += 1
                    if cache.minutesDead == minutes {
                        self.cache.textures.removeValue(forKey: key)
                        #if DEBUG
                        print("[GateEngine] Removing cache (unsused for \(cache.minutesDead) min)", key.requestedPath)
                        #endif
                    }
                }else{
                    cache.minutesDead = 0
                }
            }
        }
        
        for key in cache.geometries.keys {
            guard let cache = cache.geometries[key] else {continue}
            
            switch cache.cacheHint {
            case .forever:
                continue
            case .whileReferenced:
                if cache.referenceCount == 0 {
                    self.cache.geometries.removeValue(forKey: key)
                    #if DEBUG
                    print("[GateEngine] Removing cache (no longer referenced)", key.requestedPath)
                    #endif
                }
            case .until(minutes: let minutes):
                if cache.referenceCount == 0 {
                    cache.minutesDead += 1
                    if cache.minutesDead == minutes {
                        self.cache.geometries.removeValue(forKey: key)
                        #if DEBUG
                        print("[GateEngine] Removing cache (unsused for \(cache.minutesDead) min)", key.requestedPath)
                        #endif
                    }
                }else{
                    cache.minutesDead = 0
                }
            }
        }
    }
}

extension ResourceManager {
    class Cache {
        // Texture
        var textures: [TextureKey : TextureCache] = [:]
        
        // Geometry
        var geometries: [GeometryKey : GeometryCache] = [:]
        
        // SkinnedGeometry
        struct SkinnedGeometryKey: Hashable {
            let path: String
            let geometryOptions: GeometryImporterOptions
            let skinOptions: SkinImporterOptions
        }
        struct SkinnedGeometryCache {
            weak var skinnedGeometry: SkinnedGeometryBackend? = nil
        }
        var skinnedGeometries: [SkinnedGeometryKey : SkinnedGeometryCache] = [:]
        
        // Skeleton
        struct SkeletalAnimationKey: Hashable {
            let path: String
            let options: SkeletalAnimationImporterOptions
        }
        struct SkeletalAnimationCache {
            weak var skeletalAnimation: SkeletalAnimation? = nil
        }
        var skeletalAnimations: [SkeletalAnimationKey : SkeletalAnimationCache] = [:]
        
        // AudioBuffer
        struct AudioBufferKey: Hashable {
            let path: String
        }
        struct AudioBufferCache {
            weak var audioBuffer: AudioBufferBackend? = nil
        }
        var audioBuffers: [AudioBufferKey : AudioBufferCache] = [:]
    }
}


// MARK: - Geometry
internal extension ResourceManager.Cache {
    struct GeometryKey: Hashable {
        let requestedPath: String
        let geometryOptions: GeometryImporterOptions
    }
    
    class GeometryCache {
        var geometryBackend: GeometryBackend?
        var lastLoaded: Date
        var state: ResourceState
        var referenceCount: UInt
        var minutesDead: UInt
        var cacheHint: CacheHint
        init() {
            self.geometryBackend = nil
            self.lastLoaded = Date()
            self.state = .pending
            self.referenceCount = 0
            self.minutesDead = 0
            self.cacheHint = .until(minutes: 5)
        }
    }
}
internal extension ResourceManager {
    func changeCacheHint(_ cacheHint: CacheHint, for key: Cache.GeometryKey) {
        cache.geometries[key]?.cacheHint = cacheHint
        cache.geometries[key]?.minutesDead = 0
    }
    
    func geometryCacheKey(path: String, options: GeometryImporterOptions) -> Cache.GeometryKey {
        let key = Cache.GeometryKey(requestedPath: path, geometryOptions: options)
        if cache.geometries[key] == nil {
            cache.geometries[key] = Cache.GeometryCache()
            Task {
                do {
                    let geometry = try await RawGeometry(path: path, options: options)
                    let backend = await geometryBackend(from: geometry)
                    Task {@MainActor in
                        cache.geometries[key]!.geometryBackend = backend
                        cache.geometries[key]!.state = .ready
                    }
                }catch{
                    Task {@MainActor in
                        cache.geometries[key]!.state = .failed(reason: "\(error)")
                    }
                }
            }
        }
        return key
    }
    
    func geometryCacheKey(rawGeometry geometry: RawGeometry?) -> Cache.GeometryKey {
        let path = "$\(rawCacheID.wrappingIncrementThenLoad(ordering: .sequentiallyConsistent))"
        let key = Cache.GeometryKey(requestedPath: path, geometryOptions: .none)
        if cache.geometries[key] == nil {
            cache.geometries[key] = Cache.GeometryCache()
            if let geometry = geometry {
                Task {
                    let backend = await geometryBackend(from: geometry)
                    Task {@MainActor in
                        cache.geometries[key]!.geometryBackend = backend
                        cache.geometries[key]!.state = .ready
                    }
                }
            }
        }
        return key
    }
    
    func geometryCache(for key: Cache.GeometryKey) -> Cache.GeometryCache? {
        return cache.geometries[key]
    }
    
    func incrementReference(_ key: Cache.GeometryKey) {
        self.geometryCache(for: key)?.referenceCount += 1
    }
    func decrementReference(_ key: Cache.GeometryKey) {
        self.geometryCache(for: key)?.referenceCount -= 1
    }
    
    func reloadGeometryIfNeeded(key: Cache.GeometryKey) {
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else {return}
        Task {
            guard self.geometryNeedsReload(key: key) else {return}
            guard let cache = self.geometryCache(for: key) else {return}
            let geometry = try await RawGeometry(path: key.requestedPath, options: key.geometryOptions)
            let backend = await geometryBackend(from: geometry)
            Task {@MainActor in
                cache.geometryBackend = backend
            }
        }
    }
    
    func geometryNeedsReload(key: Cache.GeometryKey) -> Bool {
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else {return false}
        #if SUPPORTS_HOTRELOADING
        guard let cache = cache.geometries[key] else {return false}
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: key.requestedPath)
            if let modified = (attributes[.modificationDate] ?? attributes[.creationDate]) as? Date {
                return modified > cache.lastLoaded
            }else{
                return false
            }
        }catch{
            print(error.localizedDescription)
            return false
        }
        #else
        return false
        #endif
    }
    
    func geometryBackend(from raw: RawGeometry) async -> GeometryBackend {
#if canImport(MetalKit)
        return await MetalGeometry(geometry: raw)
#elseif canImport(WebGL2)
        return await WebGL2Geometry(geometry: raw)
#endif
    }
}

// MARK: - Lines
internal extension ResourceManager {
    func geometryCacheKey(rawLines lines: RawLines?) -> Cache.GeometryKey {
        let path = "$\(rawCacheID.wrappingIncrementThenLoad(ordering: .sequentiallyConsistent))"
        let key = Cache.GeometryKey(requestedPath: path, geometryOptions: .none)
        if cache.geometries[key] == nil {
            cache.geometries[key] = Cache.GeometryCache()
            if let lines = lines {
                Task {
                    let backend = await geometryBackend(from: lines)
                    Task {@MainActor in
                        cache.geometries[key]!.geometryBackend = backend
                        cache.geometries[key]!.state = .ready
                    }
                }
            }
        }
        return key
    }
    
    func geometryBackend(from raw: RawLines) async -> GeometryBackend {
        #if canImport(MetalKit)
        return await MetalGeometry(lines: raw)
        #elseif canImport(WebGL2)
        return await WebGL2Geometry(lines: raw)
        #endif
    }
}

// MARK: - Points
internal extension ResourceManager {
    func geometryCacheKey(rawPoints points: RawPoints?) -> Cache.GeometryKey {
        let path = "$\(rawCacheID.wrappingIncrementThenLoad(ordering: .sequentiallyConsistent))"
        let key = Cache.GeometryKey(requestedPath: path, geometryOptions: .none)
        if cache.geometries[key] == nil {
            cache.geometries[key] = Cache.GeometryCache()
            if let points {
                Task {
                    let backend = await geometryBackend(from: points)
                    Task {@MainActor in
                        cache.geometries[key]!.geometryBackend = backend
                        cache.geometries[key]!.state = .ready
                    }
                }
            }
        }
        return key
    }
    
    func geometryBackend(from raw: RawPoints) async -> GeometryBackend {
        #if canImport(MetalKit)
        return await MetalGeometry(points: raw)
        #elseif canImport(WebGL2)
        return await WebGL2Geometry(points: raw)
        #endif
    }
}

// MARK: - Texture
internal extension ResourceManager.Cache {
    struct TextureKey: Hashable {
        let requestedPath: String
        let mipMapping: MipMapping
        let textureOptions: TextureImporterOptions
    }
    
    class TextureCache {
        var isRenderTarget: Bool
        var textureBackend: TextureBackend?
        var lastLoaded: Date
        var state: ResourceState
        var referenceCount: UInt
        var minutesDead: UInt
        var cacheHint: CacheHint
        init() {
            self.isRenderTarget = false
            self.textureBackend = nil
            self.lastLoaded = Date()
            self.state = .pending
            self.referenceCount = 0
            self.minutesDead = 0
            self.cacheHint = .until(minutes: 5)
        }
    }
}
internal extension ResourceManager {
    func changeCacheHint(_ cacheHint: CacheHint, for key: Cache.TextureKey) {
        cache.textures[key]?.cacheHint = cacheHint
        cache.textures[key]?.minutesDead = 0
    }
    
    func textureCacheKey(path: String, mipMapping: MipMapping, options: TextureImporterOptions) -> Cache.TextureKey {
        let key = Cache.TextureKey(requestedPath: path, mipMapping: mipMapping, textureOptions: options)
        if cache.textures[key] == nil {
            cache.textures[key] = Cache.TextureCache()
            _reloadTexture(key: key)
        }
        return key
    }
    
    func texureCacheKey(data: Data, size: Size2, mipMapping: MipMapping) -> Cache.TextureKey {
        let path = "$\(rawCacheID.wrappingIncrementThenLoad(ordering: .sequentiallyConsistent))"
        let key = Cache.TextureKey(requestedPath: path, mipMapping: mipMapping, textureOptions: .none)
        if cache.textures[key] == nil {
            cache.textures[key] = Cache.TextureCache()
            Task {
                let backend = await textureBackend(data:data, size: size, mipMapping: mipMapping)
                Task {@MainActor in
                    cache.textures[key]!.textureBackend = backend
                    cache.textures[key]!.state = .ready
                }
            }
        }
        return key
    }
    
    func texureCacheKey(renderTargetBackend: RenderTargetBackend) -> Cache.TextureKey {
        let path = "$\(rawCacheID.wrappingIncrementThenLoad(ordering: .sequentiallyConsistent))"
        let key = Cache.TextureKey(requestedPath: path, mipMapping: .none, textureOptions: .none)
        if cache.textures[key] == nil {
            let newCache = Cache.TextureCache()
            newCache.isRenderTarget = true
            cache.textures[key] = newCache
            Task {
                let backend = await textureBackend(renderTargetBackend: renderTargetBackend)
                Task {@MainActor in
                    cache.textures[key]!.textureBackend = backend
                    cache.textures[key]!.state = .ready
                }
            }
        }
        return key
    }
    
    func textureCache(for key: Cache.TextureKey) -> Cache.TextureCache? {
        return cache.textures[key]
    }
    
    func incrementReference(_ key: Cache.TextureKey) {
        self.textureCache(for: key)?.referenceCount += 1
    }
    func decrementReference(_ key: Cache.TextureKey) {
        self.textureCache(for: key)?.referenceCount -= 1
    }
    
    func reloadTextureIfNeeded(key: Cache.TextureKey) {
        // Skip if made from rawCacheID
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else {return}
        Task {
            guard self.textureNeedsReload(key: key) else {return}
            _reloadTexture(key: key)
        }
    }
    
    @inline(__always)
    private func _reloadTexture(key: Cache.TextureKey) {
        Task {
            do {
                let path = key.requestedPath
                guard let fileExtension = path.components(separatedBy: ".").last else {
                    throw "Unknown file type."
                }
                guard let importer = await Game.shared.resourceManager.textureImporterForFileType(fileExtension) else {
                    throw "No importer for \(fileExtension)."
                }
                
                let v = try await importer.loadData(path: path, options: key.textureOptions)
                guard v.data.isEmpty == false else {throw "No data found at " + path}
                let texture = try importer.process(data: v.data, size: v.size, options: key.textureOptions)
                
                let backend = await textureBackend(data: texture.data, size: texture.size, mipMapping: key.mipMapping)
                Task {@MainActor in
                    cache.textures[key]!.textureBackend = backend
                    cache.textures[key]!.state = .ready
                }
            }catch{
                Task {@MainActor in
                    cache.textures[key]!.state = .failed(reason: "\(error)")
                }
            }
        }
    }
    
    func textureNeedsReload(key: Cache.TextureKey) -> Bool {
        // Skip if made from rawCacheID
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else {return false}
        #if SUPPORTS_HOTRELOADING
        guard let cache = cache.textures[key] else {return false}
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: key.requestedPath)
            if let modified = (attributes[.modificationDate] ?? attributes[.creationDate]) as? Date {
                return modified > cache.lastLoaded
            }else{
                return false
            }
        }catch{
            print(error.localizedDescription)
            return false
        }
        #else
        return false
        #endif
    }
    
    func textureBackend(data: Data, size: Size2, mipMapping: MipMapping) async -> TextureBackend {
#if canImport(MetalKit)
        return await MetalTexture(data: data, size: size, mipMapping: mipMapping)
#elseif canImport(WebGL2)
        return await WebGL2Texture(data: data, size: size, mipMapping: mipMapping)
#endif
    }
    func textureBackend(renderTargetBackend: RenderTargetBackend) async -> TextureBackend {
#if canImport(MetalKit)
        return await MetalTexture(renderTargetBackend: renderTargetBackend)
#elseif canImport(WebGL2)
        return await WebGL2Texture(renderTargetBackend: renderTargetBackend)
#endif
    }
}
