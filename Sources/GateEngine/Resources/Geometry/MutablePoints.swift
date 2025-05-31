/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public class MutablePoints: Points {
    public var rawPoints: RawPoints? = nil {
        didSet {
            load()
        }
    }

    public init(rawPoints: RawPoints? = nil) {
        self.rawPoints = rawPoints
        super.init(optionalRawPoints: rawPoints)
    }

    private func load() {
        guard let cache = Game.unsafeShared.resourceManager.geometryCache(for: cacheKey) else {
            return
        }
        if let rawPoints, rawPoints.indices.isEmpty == false {
            cache.state = .ready
            cache.geometryBackend = ResourceManager.geometryBackend(from: rawPoints)
        }else{
            cache.geometryBackend = nil
            cache.state = .pending
        }
    }
}
