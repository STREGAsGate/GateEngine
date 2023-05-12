/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation
import GameMath

public enum MipMapping: Hashable {
    /// No mipmapping
    case none
    /// Automatically generates mipmaps up to provided level
    case auto(levels: Int = .max)
}

@MainActor internal protocol TextureBackend: AnyObject {
    var size: Size2 {get}
    init(data: Data, size: Size2, mipMapping: MipMapping)
    init(renderTargetBackend: RenderTargetBackend)
    func replaceData(with data: Data, size: Size2, mipMapping: MipMapping)
}

/** Texture represents a mangaed bitmap buffer object.
 It's contents are stored within GPU accessible memory and this object represents a reference to that memory.
 When this object deinitializes it's contents will also be removed from GPU memory.
 */
@MainActor public class Texture: Resource {
    internal let cacheKey: ResourceManager.Cache.TextureKey
    internal var renderTarget: (any _RenderTargetProtocol)?
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
        fatalError("The state must be \(ResourceState.ready), or a sizeHint must be provided during init, before accessing this property.")
    }
    
    internal var isRenderTarget: Bool {
        return renderTarget != nil
    }

    internal var textureBackend: TextureBackend? {
        return Game.shared.resourceManager.textureCache(for: cacheKey)?.textureBackend
    }
    
    public var cacheHint: CacheHint {
        get {Game.shared.resourceManager.textureCache(for: cacheKey)!.cacheHint}
        set {Game.shared.resourceManager.changeCacheHint(newValue, for: cacheKey)}
    }
    
    public var state: ResourceState {
        return Game.shared.resourceManager.textureCache(for: cacheKey)!.state
    }
    
    /**
     Create a new texture.
     
     - parameter path: The package resource path. This path is relative to a package resource. Using a fullyqualified disc path will fail.
     - parameter sizeHint: This hint will be returned by the `Texture.size` property before the texture data has been loaded. After the Texture data has loaded the actual texture file dimenstions will be returned by `Texture.size`.
     - parameter options: Options that will be given to the texture importer.
     - parameter mipMapping: The mip level to generate for this texture.
     */
    public init(path: String, sizeHint: Size2? = nil, mipMapping: MipMapping = .auto(), options: TextureImporterOptions = .none) {
        let resourceManager = Game.shared.resourceManager
        self.renderTarget = nil
        self.cacheKey = resourceManager.textureCacheKey(path: path, mipMapping: mipMapping, options: options)
        self.sizeHint = sizeHint
        self.cacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }
    
    public init(data: Data, size: Size2, mipMapping: MipMapping) {
        let resourceManager = Game.shared.resourceManager
        self.renderTarget = nil
        self.cacheKey = resourceManager.texureCacheKey(data: data, size: size, mipMapping: mipMapping)
        self.sizeHint = size
        self.cacheHint = .whileReferenced
        resourceManager.incrementReference(self.cacheKey)
    }
    
    init(renderTarget: any _RenderTargetProtocol) {
        let resourceManager = Game.shared.resourceManager
        self.renderTarget = renderTarget
        self.cacheKey = resourceManager.texureCacheKey(renderTargetBackend: renderTarget.backend)
        self.sizeHint = renderTarget.size
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

extension Texture: Equatable, Hashable {
    nonisolated public static func == (lhs: Texture, rhs: Texture) -> Bool {
        return lhs.cacheKey == rhs.cacheKey
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(cacheKey)
    }
}
