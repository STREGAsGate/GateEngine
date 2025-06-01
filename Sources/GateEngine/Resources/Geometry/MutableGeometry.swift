/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

/// Geometry represents a mangaed vertex buffer object.
/// It's contents are stored within GPU accessible memory and this object represents a reference to that memory.
/// When this object deinitializes it's contents will also be removed from GPU memory.
public final class MutableGeometry: Geometry {
    public var rawGeometry: RawGeometry? = nil {
        didSet {
            load()
        }
    }

    public init(rawGeometry: RawGeometry? = nil) {
        self.rawGeometry = rawGeometry
        super.init(optionalRawGeometry: rawGeometry)
    }

    private func load() {        
        guard let cache = Game.unsafeShared.resourceManager.geometryCache(for: cacheKey) else {
            return
        }
        if let rawGeometry, rawGeometry.indices.isEmpty == false {
            cache.geometryBackend = ResourceManager.geometryBackend(
                from: rawGeometry
            )
            cache.state = .ready
        }else{
            cache.geometryBackend = nil
            cache.state = .pending
        }
    }
}
