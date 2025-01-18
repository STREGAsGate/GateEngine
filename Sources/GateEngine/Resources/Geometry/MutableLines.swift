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
        guard let rawPoints = rawPoints else { return }
        Task(priority: .high) {
            guard let cache = Game.shared.resourceManager.geometryCache(for: cacheKey) else {
                return
            }
            cache.geometryBackend = await Game.shared.resourceManager.geometryBackend(
                from: rawPoints
            )
            Task { @MainActor in
                cache.state = .ready
            }
        }
    }
}
