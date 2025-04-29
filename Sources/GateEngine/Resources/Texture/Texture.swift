/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GATEENGINE_PLATFORM_SUPPORTS_FOUNDATION_FILEMANAGER
import Foundation
#endif

public enum MipMapping: Hashable, Sendable {
    /// No mipmapping
    case none
    /// Automatically generates mipmaps up to provided level
    case auto(levels: Int = .max)
}

@usableFromInline
@MainActor internal protocol TextureBackend: AnyObject {
    var size: Size2 { get }
    init(data: Data, size: Size2, mipMapping: MipMapping)
    init(renderTargetBackend: any RenderTargetBackend)
    func replaceData(with data: Data, size: Size2, mipMapping: MipMapping)
}

/// Texture represents a managed bitmap buffer object.
/// It's contents are stored within GPU accessible memory and this object represents a reference to that memory.
/// When this object deinitializes it's contents will also be removed from GPU memory.
@MainActor public class Texture: Resource, _Resource {
    internal let cacheKey: ResourceManager.Cache.TextureKey
    var cache: any ResourceCache { 
        return Game.shared.resourceManager.textureCache(for: cacheKey)!
    }
    internal unowned var renderTarget: (any _RenderTargetProtocol)?
    private let sizeHint: Size2?

    /** The dimensions of the texture.
     Guaranteed accurate when state is .ready, otherwise fails or returns the provided hint placeholder.
     */
    public var size: Size2 {
        if state == .ready {
            return textureBackend!.size
        }
        if let sizeHint: Size2 = sizeHint {
            return sizeHint
        }
        fatalError(
            "The state must be \(ResourceState.ready), or a sizeHint must be provided during init, before accessing this property."
        )
    }
    
    /** Check if accessing the size property will be valid
     If the texture is not yet loaded the true size is unavailable.
     If a sizeHint was provided, the size will be available even when the texture is not yet loaded.
     */
    public var sizeIsAvailable: Bool {
        if state == .ready {
            return true
        }
        return sizeHint != nil
    }

    @usableFromInline
    internal var isRenderTarget: Bool {
        return renderTarget != nil
    }

    @usableFromInline
    internal var textureBackend: (any TextureBackend)? {
        return Game.shared.resourceManager.textureCache(for: cacheKey)?.textureBackend
    }
    
    @inlinable
    public func replaceData(with data: Data, size: Size2, mipMapping: MipMapping) {
        textureBackend?.replaceData(with: data, size: size, mipMapping: mipMapping)
    }

    /**
     Create a new texture.

     - parameter path: The package resource path. This path is relative to a package resource. Using a fullyqualified disc path will fail.
     - parameter sizeHint: This hint will be returned by the `Texture.size` property before the texture data has been loaded. After the Texture data has loaded the actual texture file dimensions will be returned by `Texture.size`.
     - parameter options: Options that will be given to the texture importer.
     - parameter mipMapping: The mip level to generate for this texture.
     */
    @inlinable @_disfavoredOverload
    public convenience init(
        as path: TexturePath,
        sizeHint: Size2? = nil,
        mipMapping: MipMapping = .auto(),
        options: TextureImporterOptions = .none
    ) {
        self.init(path: path.value, sizeHint: sizeHint, mipMapping: mipMapping, options: options)
    }

    /**
     Create a new texture.

     - parameter path: The package resource path. This path is relative to a package resource. Using a fullyqualified disc path will fail.
     - parameter sizeHint: This hint will be returned by the `Texture.size` property before the texture data has been loaded. After the Texture data has loaded the actual texture file dimensions will be returned by `Texture.size`.
     - parameter options: Options that will be given to the texture importer.
     - parameter mipMapping: The mip level to generate for this texture.
     */
    public init(
        path: String,
        sizeHint: Size2? = nil,
        mipMapping: MipMapping = .auto(),
        options: TextureImporterOptions = .none
    ) {
        let resourceManager = Game.shared.resourceManager
        self.renderTarget = nil
        self.cacheKey = resourceManager.textureCacheKey(
            path: path,
            mipMapping: mipMapping,
            options: options
        )
        self.sizeHint = sizeHint
        self.defaultCacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }

    public init(data: Data, size: Size2, mipMapping: MipMapping) {
        let resourceManager = Game.shared.resourceManager
        self.renderTarget = nil
        self.cacheKey = resourceManager.textureCacheKey(
            data: data,
            size: size,
            mipMapping: mipMapping
        )
        self.sizeHint = size
        self.defaultCacheHint = .whileReferenced
        resourceManager.incrementReference(self.cacheKey)
    }

    init(renderTarget: any _RenderTargetProtocol) {
        renderTarget.reshapeIfNeeded()
        let resourceManager = Game.shared.resourceManager
        self.renderTarget = renderTarget
        self.cacheKey = resourceManager.textureCacheKey(
            renderTargetBackend: renderTarget.renderTargetBackend
        )
        self.sizeHint = renderTarget.size
        self.defaultCacheHint = .whileReferenced
        resourceManager.incrementReference(self.cacheKey)
    }

    deinit {
        Game.unsafeShared.resourceManager.decrementReference(cacheKey)
    }
}

extension Texture: Equatable, Hashable {
    nonisolated public static func == (lhs: Texture, rhs: Texture) -> Bool {
        return lhs.cacheKey == rhs.cacheKey
    }

    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(cacheKey)
    }
}


// MARK: - Resource Manager

public protocol TextureImporter: ResourceImporter {
    func loadTexture(options: TextureImporterOptions) async throws -> (data: Data, size: Size2)
}

public struct TextureImporterOptions: Equatable, Hashable, Sendable {
    public var subobjectName: String? = nil
    public var option1: Bool = false

    public static func with(name: String? = nil, option1: Bool = false) -> Self {
        return TextureImporterOptions(subobjectName: name, option1: option1)
    }

    public static var option1: TextureImporterOptions {
        return TextureImporterOptions(subobjectName: nil, option1: true)
    }

    public static func named(_ name: String) -> Self {
        return TextureImporterOptions(subobjectName: name)
    }

    public static var none: TextureImporterOptions {
        return TextureImporterOptions()
    }
}

extension ResourceManager {
    public func addTextureImporter(_ type: any TextureImporter.Type, atEnd: Bool = false) {
        guard importers.textureImporters.contains(where: { $0 == type }) == false else { return }
        if atEnd {
            importers.textureImporters.append(type)
        } else {
            importers.textureImporters.insert(type, at: 0)
        }
    }

    internal func textureImporterForPath(_ path: String) async throws -> (any TextureImporter)? {
        for type in self.importers.textureImporters {
            if type.canProcessFile(path) {
                return try await self.importers.getImporter(path: path, type: type)
            }
        }
        return nil
    }
}

extension ResourceManager.Cache {
    struct TextureKey: Hashable, Sendable, CustomStringConvertible {
        let requestedPath: String
        let mipMapping: MipMapping
        let textureOptions: TextureImporterOptions
        
        @usableFromInline
        var description: String {
            var string = requestedPath.first == "$" ? "(Generated)" : requestedPath
            if let name = textureOptions.subobjectName {
                string += ", Named: \(name)"
            }
            if case .auto(.max) = mipMapping {
                string += ", MipMapping: auto(levels: .max)"
            }else{
                string += ", MipMapping: \(mipMapping)"
            }
            return string
        }
    }

    final class TextureCache: ResourceCache {
        var isRenderTarget: Bool
        var textureBackend: (any TextureBackend)?
        var lastLoaded: Date
        var state: ResourceState
        var referenceCount: UInt
        var minutesDead: UInt
        var cacheHint: CacheHint?
        var defaultCacheHint: CacheHint
        init() {
            self.isRenderTarget = false
            self.textureBackend = nil
            self.lastLoaded = Date()
            self.state = .pending
            self.referenceCount = 0
            self.minutesDead = 0
            self.cacheHint = nil
            self.defaultCacheHint = .until(minutes: 5)
        }
    }
}

extension ResourceManager {
    func changeCacheHint(_ cacheHint: CacheHint, for key: Cache.TextureKey) {
        if let cache = self.cache.textures[key] {
            cache.cacheHint = cacheHint
            cache.minutesDead = 0
        }
    }

    @MainActor func textureCacheKey(path: String, mipMapping: MipMapping, options: TextureImporterOptions)
        -> Cache.TextureKey
    {
        let key = Cache.TextureKey(
            requestedPath: path,
            mipMapping: mipMapping,
            textureOptions: options
        )
        if cache.textures[key] == nil {
            cache.textures[key] = Cache.TextureCache()
            _reloadTexture(key: key)
        }
        return key
    }

    @MainActor func textureCacheKey(data: Data, size: Size2, mipMapping: MipMapping) -> Cache.TextureKey {
        let path = "$\(rawCacheIDGenerator.generateID())"
        let key = Cache.TextureKey(
            requestedPath: path,
            mipMapping: mipMapping,
            textureOptions: .none
        )
        if cache.textures[key] == nil {
            cache.textures[key] = Cache.TextureCache()
            Game.shared.resourceManager.incrementLoading(path: key.requestedPath)
            Task.detached(priority: .high) {
                let backend = await self.textureBackend(
                    data: data,
                    size: size,
                    mipMapping: mipMapping
                )
                Task { @MainActor in
                    if let cache = self.cache.textures[key] {
                        cache.textureBackend = backend
                        cache.state = .ready
                    }else{
                        Log.warn("Resource \"\(path)\" was deallocated before being loaded.")
                    }
                    Game.shared.resourceManager.decrementLoading(path: key.requestedPath)
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
            Task.detached(priority: .high) {
                let backend = await self.textureBackend(renderTargetBackend: renderTargetBackend)
                Task { @MainActor in
                    if let cache = self.cache.textures[key] {
                        cache.textureBackend = backend
                        cache.state = .ready
                    }else{
                        Log.warn("Resource \"(Generated Texture)\" was deallocated before being loaded.")
                    }
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
        guard let cache = self.textureCache(for: key) else {return}
        cache.referenceCount -= 1
        
        if case .whileReferenced = cache.effectiveCacheHint {
            if cache.referenceCount == 0 {
                self.cache.textures.removeValue(forKey: key)
                Log.debug("Removing cache (no longer referenced), Texture: \(key)")
            }
        }
    }

    func reloadTextureIfNeeded(key: Cache.TextureKey) {
        // Skip if made from rawCacheID
        if key.requestedPath[key.requestedPath.startIndex] != "$" {
            Task {
                if self.textureNeedsReload(key: key) {
                    await self._reloadTexture(key: key)
                }
            }
        }
    }

    @MainActor 
    private func _reloadTexture(key: Cache.TextureKey) {
        Game.shared.resourceManager.incrementLoading(path: key.requestedPath)
        Task.detached(priority: .high) {
            do {
                let path = key.requestedPath
                let fileExtension = URL(fileURLWithPath: path).pathExtension
                if fileExtension.isEmpty {
                    throw GateEngineError.failedToLoad("Unknown file type.")
                }
                
                guard
                    let importer = try await Game.shared.resourceManager.textureImporterForPath(path)
                else {
                    throw GateEngineError.failedToLoad("No importer for \(fileExtension).")
                }

                let texture = try await importer.loadTexture(options: key.textureOptions)
                guard texture.data.isEmpty == false else {
                    throw GateEngineError.failedToLoad("File is empty.")
                }

                let backend = await self.textureBackend(
                    data: texture.data,
                    size: texture.size,
                    mipMapping: key.mipMapping
                )
                Task { @MainActor in
                    if let cache = self.cache.textures[key] {
                        cache.textureBackend = backend
                        cache.state = .ready
                    }else{
                        Log.warn("Resource \"\(path)\" was deallocated before being re-loaded.")
                    }
                    Game.shared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch let error as GateEngineError {
                Task { @MainActor in
                    Log.warn("Resource \"\(key.requestedPath)\"", error)
                    if let cache = self.cache.textures[key] {
                        cache.state = .failed(error: error)
                    }
                    Game.shared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch {
                Log.fatalError("error must be a GateEngineError")
            }
        }
    }

    func textureNeedsReload(key: Cache.TextureKey) -> Bool {
        // Skip if made from rawCacheID
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else { return false }
        #if GATEENGINE_ENABLE_HOTRELOADING
        guard let cache = cache.textures[key] else { return false }
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

    func textureBackend(data: Data, size: Size2, mipMapping: MipMapping) async -> any TextureBackend
    {
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
