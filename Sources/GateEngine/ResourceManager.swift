/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GATEENGINE_PLATFORM_SUPPORTS_FOUNDATION_FILEMANAGER
import class Foundation.FileManager
#endif

extension ResourceManager {
    struct Importers {
        internal var textureImporters: [any TextureImporter.Type] = [PNGImporter.self]
        
        internal var geometryImporters: [any GeometryImporter.Type] = [GLTransmissionFormat.self, WavefrontOBJImporter.self]
        internal var skeletonImporters: [any SkeletonImporter.Type] = [GLTransmissionFormat.self]
        internal var skinImporters: [any SkinImporter.Type] = [GLTransmissionFormat.self]
        internal var skeletalAnimationImporters: [any SkeletalAnimationImporter.Type] = [GLTransmissionFormat.self]
        
        internal var tileSetImporters: [any TileSetImporter.Type] = [/*TiledTileSetImporter.self*/]
        internal var tileMapImporters: [any TileMapImporter.Type] = [/*TiledTileMapImporter.self*/]
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
    
    let rawCacheIDGenerator = IDGenerator<UInt>()
    
    var accumulatedSeconds: Double = 0
    
    public let game: Game
    public init(game: Game) {
        self.game = game
    }
    
    func update(withTimePassed deltaTime: Double) {
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
                    Log.debug("Removing cache (no longer referenced), Object:", key.requestedPath.first == "$" ? "(Generated Texture)" : key.requestedPath)
                }
            case .until(minutes: let minutes):
                if cache.referenceCount == 0 {
                    cache.minutesDead += 1
                    if cache.minutesDead == minutes {
                        self.cache.textures.removeValue(forKey: key)
                        Log.debug("Removing cache (unused for \(cache.minutesDead) min), Object:", key.requestedPath.first == "$" ? "(Generated Texture)" : key.requestedPath)
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
                    Log.debug("Removing cache (no longer referenced), Object:", key.requestedPath.first == "$" ? "(Generated Geometry)" : key.requestedPath)
                }
            case .until(minutes: let minutes):
                if cache.referenceCount == 0 {
                    cache.minutesDead += 1
                    if cache.minutesDead == minutes {
                        self.cache.geometries.removeValue(forKey: key)
                        Log.debug("Removing cache (unused for \(cache.minutesDead) min), Object:", key.requestedPath.first == "$" ? "(Generated Geometry)" : key.requestedPath)
                    }
                }else{
                    cache.minutesDead = 0
                }
            }
        }
    }
}

extension ResourceManager {
    @usableFromInline
    class Cache {
        var textures: [TextureKey : TextureCache] = [:]
        var geometries: [GeometryKey : GeometryCache] = [:]
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
            weak var audioBuffer: (any AudioBufferBackend)? = nil
        }
        var audioBuffers: [AudioBufferKey : AudioBufferCache] = [:]
    }
}


// MARK: - Geometry
internal extension ResourceManager.Cache {
    @usableFromInline
    struct GeometryKey: Hashable {
        let requestedPath: String
        let geometryOptions: GeometryImporterOptions
    }
    
    @usableFromInline
    class GeometryCache {
        @usableFromInline var geometryBackend: (any GeometryBackend)?
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
            Task.detached(priority: .low) {
                do {
                    let geometry = try await RawGeometry(path: path, options: options)
                    let backend = await self.geometryBackend(from: geometry)
                    Task {@MainActor in
                        self.cache.geometries[key]!.geometryBackend = backend
                        self.cache.geometries[key]!.state = .ready
                    }
                }catch let error as GateEngineError {
                    Task {@MainActor in
                        Log.warn("Resource \"\(path)\"", error)
                        self.cache.geometries[key]!.state = .failed(error: error)
                    }
                }catch{
                    Log.fatalError("error must be a GateEngineError")
                }
            }
        }
        return key
    }
    
    func geometryCacheKey(rawGeometry geometry: RawGeometry?) -> Cache.GeometryKey {
        let path = "$\(rawCacheIDGenerator.generateID())"
        let key = Cache.GeometryKey(requestedPath: path, geometryOptions: .none)
        if cache.geometries[key] == nil {
            cache.geometries[key] = Cache.GeometryCache()
            if let geometry = geometry {
                Task.detached(priority: .low) {
                    let backend = await self.geometryBackend(from: geometry)
                    Task {@MainActor in
                        self.cache.geometries[key]!.geometryBackend = backend
                        self.cache.geometries[key]!.state = .ready
                    }
                }
            }
        }
        return key
    }
    
    @usableFromInline
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
        Task.detached(priority: .low) {
            guard self.geometryNeedsReload(key: key) else {return}
            guard let cache = self.geometryCache(for: key) else {return}
            let geometry = try await RawGeometry(path: key.requestedPath, options: key.geometryOptions)
            let backend = await self.geometryBackend(from: geometry)
            Task {@MainActor in
                cache.geometryBackend = backend
            }
        }
    }
    
    func geometryNeedsReload(key: Cache.GeometryKey) -> Bool {
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else {return false}
        #if GATEENGINE_ENABLE_HOTRELOADING && GATEENGINE_PLATFORM_SUPPORTS_FOUNDATION_FILEMANAGER
        guard let cache = cache.geometries[key] else {return false}
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: key.requestedPath)
            if let modified = (attributes[.modificationDate] ?? attributes[.creationDate]) as? Date {
                return modified > cache.lastLoaded
            }else{
                return false
            }
        }catch{
            Log.error(error)
            return false
        }
        #else
        return false
        #endif
    }
    
    func geometryBackend(from raw: RawGeometry) async -> any GeometryBackend {
#if GATEENGINE_FORCE_OPNEGL_APPLE
        return await OpenGLGeometry(geometry: raw)
#elseif canImport(MetalKit)
        #if canImport(OpenGL_GateEngine)
        if await MetalRenderer.isSupported == false {
            return await OpenGLGeometry(geometry: raw)
        }
        #endif
        return await MetalGeometry(geometry: raw)
#elseif canImport(WebGL2)
        return await WebGL2Geometry(geometry: raw)
#elseif canImport(WinSDK)
        return await DX12Geometry(geometry: raw)
#elseif canImport(OpenGL_GateEngine)
        return await OpenGLGeometry(geometry: raw)
#else
        #error("Not implemented")
#endif
    }
}

// MARK: - SkinnedGeometry
internal extension ResourceManager.Cache {
    @usableFromInline
    struct SkinnedGeometryKey: Hashable {
        let requestedPath: String
        let geometryOptions: GeometryImporterOptions
        let skinOptions: SkinImporterOptions
    }
    
    class SkinnedGeometryCache {
        var geometryBackend: (any GeometryBackend)?
        var skinJoints: [Skin.Joint]?
        var lastLoaded: Date
        var state: ResourceState
        var referenceCount: UInt
        var minutesDead: UInt
        var cacheHint: CacheHint
        init() {
            self.geometryBackend = nil
            self.skinJoints = nil
            self.lastLoaded = Date()
            self.state = .pending
            self.referenceCount = 0
            self.minutesDead = 0
            self.cacheHint = .until(minutes: 5)
        }
    }
}
internal extension ResourceManager {
    func changeCacheHint(_ cacheHint: CacheHint, for key: Cache.SkinnedGeometryKey) {
        cache.skinnedGeometries[key]?.cacheHint = cacheHint
        cache.skinnedGeometries[key]?.minutesDead = 0
    }
    
    func skinnedGeometryCacheKey(path: String, geometryOptions: GeometryImporterOptions, skinOptions: SkinImporterOptions) -> Cache.SkinnedGeometryKey {
        let key = Cache.SkinnedGeometryKey(requestedPath: path, geometryOptions: geometryOptions, skinOptions: skinOptions)
        if cache.skinnedGeometries[key] == nil {
            cache.skinnedGeometries[key] = Cache.SkinnedGeometryCache()
            Task.detached(priority: .low) {
                do {
                    let geometry = try await RawGeometry(path: path, options: geometryOptions)
                    let skin = try await Skin(path: key.requestedPath, options: skinOptions)
                    let backend = await self.geometryBackend(from: geometry, skin: skin)
                    Task {@MainActor in
                        if let cache = self.cache.skinnedGeometries[key] {
                            cache.geometryBackend = backend
                            cache.skinJoints = skin.joints
                            cache.state = .ready
                        }
                    }
                }catch let error as GateEngineError {
                    Task {@MainActor in
                        Log.warn("Resource \"\(path)\"", error)
                        self.cache.skinnedGeometries[key]!.state = .failed(error: error)
                    }
                }catch{
                    Log.fatalError("error must be a GateEngineError")
                }
            }
        }
        return key
    }
    
    func skinnedGeometryCacheKey(rawGeometry geometry: RawGeometry?, skin: Skin) -> Cache.SkinnedGeometryKey {
        let path = "$\(rawCacheIDGenerator.generateID())"
        let key = Cache.SkinnedGeometryKey(requestedPath: path, geometryOptions: .none, skinOptions: .none)
        if cache.skinnedGeometries[key] == nil {
            cache.skinnedGeometries[key] = Cache.SkinnedGeometryCache()
            if let geometry = geometry {
                Task.detached(priority: .low) {
                    let backend = await self.geometryBackend(from: geometry, skin: skin)
                    Task {@MainActor in
                        if let cache = self.cache.skinnedGeometries[key] {
                            cache.geometryBackend = backend
                            cache.state = .ready
                        }
                    }
                }
            }
        }
        return key
    }
    
    func skinnedGeometryCache(for key: Cache.SkinnedGeometryKey) -> Cache.SkinnedGeometryCache? {
        return cache.skinnedGeometries[key]
    }
    
    func incrementReference(_ key: Cache.SkinnedGeometryKey) {
        self.skinnedGeometryCache(for: key)?.referenceCount += 1
    }
    func decrementReference(_ key: Cache.SkinnedGeometryKey) {
        self.skinnedGeometryCache(for: key)?.referenceCount -= 1
    }
    
    func reloadSkinnedGeometryIfNeeded(key: Cache.SkinnedGeometryKey) {
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else {return}
        Task.detached(priority: .low) {
            guard self.skinnedGeometryNeedsReload(key: key) else {return}
            let geometry = try await RawGeometry(path: key.requestedPath, options: key.geometryOptions)
            let skin = try await Skin(path: key.requestedPath, options: key.skinOptions)
            let backend = await self.geometryBackend(from: geometry, skin: skin)
            Task {@MainActor in
                if let cache = self.cache.skinnedGeometries[key] {
                    cache.geometryBackend = backend
                    cache.skinJoints = skin.joints
                }
            }
        }
    }
    
    func skinnedGeometryNeedsReload(key: Cache.SkinnedGeometryKey) -> Bool {
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else {return false}
        #if GATEENGINE_ENABLE_HOTRELOADING
        guard let cache = cache.skinnedGeometries[key] else {return false}
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: key.requestedPath)
            if let modified = (attributes[.modificationDate] ?? attributes[.creationDate]) as? Date {
                return modified > cache.lastLoaded
            }else{
                return false
            }
        }catch{
            Log.error(error)
            return false
        }
        #else
        return false
        #endif
    }
    
    func geometryBackend(from raw: RawGeometry, skin: Skin) async -> any GeometryBackend {
#if GATEENGINE_FORCE_OPNEGL_APPLE
        return await OpenGLGeometry(geometry: raw, skin: skin)
#elseif canImport(MetalKit)
    #if canImport(OpenGL_GateEngine)
        if await MetalRenderer.isSupported == false {
            return await OpenGLGeometry(geometry: raw, skin: skin)
        }
    #endif
        return await MetalGeometry(geometry: raw, skin: skin)
#elseif canImport(WebGL2)
        return await WebGL2Geometry(geometry: raw, skin: skin)
#elseif canImport(WinSDK)        
        return await DX12Geometry(geometry: raw, skin: skin)
#elseif canImport(OpenGL_GateEngine)        
        return await OpenGLGeometry(geometry: raw, skin: skin)
#else
        #error("Not implemented")
#endif
    }
}

// MARK: - Lines
internal extension ResourceManager {
    func geometryCacheKey(rawLines lines: RawLines?) -> Cache.GeometryKey {
        let path = "$\(rawCacheIDGenerator.generateID())"
        let key = Cache.GeometryKey(requestedPath: path, geometryOptions: .none)
        if cache.geometries[key] == nil {
            cache.geometries[key] = Cache.GeometryCache()
            if let lines = lines {
                Task.detached(priority: .low) {
                    let backend = await self.geometryBackend(from: lines)
                    Task {@MainActor in
                        self.cache.geometries[key]!.geometryBackend = backend
                        self.cache.geometries[key]!.state = .ready
                    }
                }
            }
        }
        return key
    }
    
    func geometryBackend(from raw: RawLines) async -> any GeometryBackend {
#if GATEENGINE_FORCE_OPNEGL_APPLE
        return await OpenGLGeometry(lines: raw)
#elseif canImport(MetalKit)
        #if canImport(GLKit)
        if await MetalRenderer.isSupported == false {
            return await OpenGLGeometry(lines: raw)
        }
        #endif
        return await MetalGeometry(lines: raw)
#elseif canImport(WebGL2)
        return await WebGL2Geometry(lines: raw)
#elseif canImport(WinSDK)
        return await DX12Geometry(lines: raw)
#elseif canImport(OpenGL_GateEngine)
        return await OpenGLGeometry(lines: raw)
#else
#error("Not implemented")
#endif
    }
}

// MARK: - Points
internal extension ResourceManager {
    func geometryCacheKey(rawPoints points: RawPoints?) -> Cache.GeometryKey {
        let path = "$\(rawCacheIDGenerator.generateID())"
        let key = Cache.GeometryKey(requestedPath: path, geometryOptions: .none)
        if cache.geometries[key] == nil {
            cache.geometries[key] = Cache.GeometryCache()
            if let points {
                Task.detached(priority: .low) {
                    let backend = await self.geometryBackend(from: points)
                    Task {@MainActor in
                        self.cache.geometries[key]!.geometryBackend = backend
                        self.cache.geometries[key]!.state = .ready
                    }
                }
            }
        }
        return key
    }
    
    func geometryBackend(from raw: RawPoints) async -> any GeometryBackend {
#if GATEENGINE_FORCE_OPNEGL_APPLE
        return await OpenGLGeometry(points: raw)
#elseif canImport(MetalKit)
        #if canImport(GLKit)
        if await MetalRenderer.isSupported == false {
            return await OpenGLGeometry(points: raw)
        }
        #endif
        return await MetalGeometry(points: raw)
#elseif canImport(WebGL2)
        return await WebGL2Geometry(points: raw)
#elseif canImport(WinSDK)
        return await DX12Geometry(points: raw)
#elseif canImport(OpenGL_GateEngine)
        return await OpenGLGeometry(points: raw)
#else
#error("Not implemented")
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
        var textureBackend: (any TextureBackend)?
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
    
    func textureCacheKey(data: Data, size: Size2, mipMapping: MipMapping) -> Cache.TextureKey {
        let path = "$\(rawCacheIDGenerator.generateID())"
        let key = Cache.TextureKey(requestedPath: path, mipMapping: mipMapping, textureOptions: .none)
        if cache.textures[key] == nil {
            cache.textures[key] = Cache.TextureCache()
            Task.detached(priority: .low) {
                let backend = await self.textureBackend(data:data, size: size, mipMapping: mipMapping)
                Task {@MainActor in
                    self.cache.textures[key]!.textureBackend = backend
                    self.cache.textures[key]!.state = .ready
                }
            }
        }
        return key
    }
    
    func textureCacheKey(renderTargetBackend: any RenderTargetBackend) -> Cache.TextureKey {
        let path = "$\(rawCacheIDGenerator.generateID())"
        let key = Cache.TextureKey(requestedPath: path, mipMapping: .none, textureOptions: .none)
        if cache.textures[key] == nil {
            let newCache = Cache.TextureCache()
            newCache.isRenderTarget = true
            cache.textures[key] = newCache
            Task.detached(priority: .low) {
                let backend = await self.textureBackend(renderTargetBackend: renderTargetBackend)
                Task {@MainActor in
                    self.cache.textures[key]!.textureBackend = backend
                    self.cache.textures[key]!.state = .ready
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
        if key.requestedPath[key.requestedPath.startIndex] != "$" {
            Task.detached(priority: .low) {
                if self.textureNeedsReload(key: key) {
                    self._reloadTexture(key: key)
                }
            }
        }
    }
    
    @inline(__always)
    private func _reloadTexture(key: Cache.TextureKey) {
        Task.detached(priority: .low) {
            do {
                let path = key.requestedPath
                guard let fileExtension = path.components(separatedBy: ".").last else {
                    throw GateEngineError.failedToLoad("Unknown file type.")
                }
                guard let importer = await Game.shared.resourceManager.textureImporterForFile(URL(fileURLWithPath: key.requestedPath)) else {
                    throw GateEngineError.failedToLoad("No importer for \(fileExtension).")
                }
                
                let v = try await importer.loadData(path: path, options: key.textureOptions)
                guard v.data.isEmpty == false else {throw GateEngineError.failedToLoad("File is empty.")}
                let texture = try importer.process(data: v.data, size: v.size, options: key.textureOptions)
                
                let backend = await self.textureBackend(data: texture.data, size: texture.size, mipMapping: key.mipMapping)
                Task {@MainActor in
                    self.cache.textures[key]!.textureBackend = backend
                    self.cache.textures[key]!.state = .ready
                }
            }catch let error as GateEngineError {
                Task {@MainActor in
                    Log.warn("Resource \"\(key.requestedPath)\"", error)
                    self.cache.textures[key]!.state = .failed(error: error)
                }
            }catch{
                Log.fatalError("error must be a GateEngineError")
            }
        }
    }
    
    func textureNeedsReload(key: Cache.TextureKey) -> Bool {
        // Skip if made from rawCacheID
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else {return false}
        #if GATEENGINE_ENABLE_HOTRELOADING
        guard let cache = cache.textures[key] else {return false}
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: key.requestedPath)
            if let modified = (attributes[.modificationDate] ?? attributes[.creationDate]) as? Date {
                return modified > cache.lastLoaded
            }else{
                return false
            }
        }catch{
            Log.error(error)
            return false
        }
        #else
        return false
        #endif
    }
    
    func textureBackend(data: Data, size: Size2, mipMapping: MipMapping) async -> any TextureBackend {
#if GATEENGINE_FORCE_OPNEGL_APPLE
        return await OpenGLTexture(data: data, size: size, mipMapping: mipMapping)
#elseif canImport(MetalKit)
        #if canImport(GLKit)
        if await MetalRenderer.isSupported == false {
            return await OpenGLTexture(data: data, size: size, mipMapping: mipMapping)
        }
        #endif
        return await MetalTexture(data: data, size: size, mipMapping: mipMapping)
#elseif canImport(WebGL2)
        return await WebGL2Texture(data: data, size: size, mipMapping: mipMapping)
#elseif canImport(WinSDK)
        return await DX12Texture(data: data, size: size, mipMapping: mipMapping)
#elseif canImport(OpenGL_GateEngine)
        return await OpenGLTexture(data: data, size: size, mipMapping: mipMapping)
#else
        #error("Not implemented")
#endif
    }
    func textureBackend(renderTargetBackend: any RenderTargetBackend) async -> any TextureBackend {
#if GATEENGINE_FORCE_OPNEGL_APPLE
        return await OpenGLTexture(renderTargetBackend: renderTargetBackend)
#elseif canImport(MetalKit)
        #if canImport(GLKit)
        if await MetalRenderer.isSupported == false {
            return await OpenGLTexture(renderTargetBackend: renderTargetBackend)
        }
        #endif
        return await MetalTexture(renderTargetBackend: renderTargetBackend)
#elseif canImport(WebGL2)
        return await WebGL2Texture(renderTargetBackend: renderTargetBackend)
#elseif canImport(WinSDK)
        return await DX12Texture(renderTargetBackend: renderTargetBackend)
#elseif canImport(OpenGL_GateEngine)
        return await OpenGLTexture(renderTargetBackend: renderTargetBackend)
#else
        #error("Not implemented")
#endif
    }
}
