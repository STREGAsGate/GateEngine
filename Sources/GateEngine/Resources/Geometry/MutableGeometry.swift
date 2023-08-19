/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

/// Geometry represents a mangaed vertex buffer object.
/// It's contents are stored within GPU accessible memory and this object represents a reference to that memory.
/// When this object deinitializes it's contents will also be removed from GPU memory.
public class MutableGeometry: Geometry {
    public var rawGeometry: RawGeometry? = nil {
        didSet {
            load()
        }
    }

    @usableFromInline
    internal init(rawGeometry: RawGeometry? = nil) {
        self.rawGeometry = rawGeometry
        super.init(rawGeometry)
    }

    private func load() {
        guard let rawGeometry = rawGeometry else { return }
        Task {
            guard let cache = Game.shared.resourceManager.geometryCache(for: cacheKey) else {
                return
            }
            cache.geometryBackend = await Game.shared.resourceManager.geometryBackend(
                from: rawGeometry
            )
            Task { @MainActor in
                cache.state = .ready
            }
        }
    }
}
