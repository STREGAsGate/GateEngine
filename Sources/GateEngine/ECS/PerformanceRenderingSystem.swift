/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class PerformanceRenderingSystem: RenderingSystem {
    public override func setup(game: Game) {
        game.ecs.recordPerformance()
    }

    lazy var text: Text = Text(string: "Accumulating Statistics...", pointSize: 20, color: .green)
    func rebuildText() -> Bool {
        let performance = game.ecs.performance!
        let systemsFrameTime = performance.systemsFrameTime
        let renderingSystemsFrameTime = performance.renderingSystemsFrameTime
        let totalSystemTime = systemsFrameTime + renderingSystemsFrameTime
        let frameTime = performance.frameTime * 1000
        
        // Prevent division by zero
        guard totalSystemTime != 0 else {return false}
        
        var string: String = "\(performance.fps) FPS"
        if performance.totalDroppedFrames > 0 {
            string += ", \(performance.totalDroppedFrames) All Time Dropped"
        }
        string += "\n"
        string += String(format: "%.1fms Frame Time", frameTime)
        string += "\n\n"
        
        string += String(format: "%.1fms Total Systems Time", totalSystemTime * 1000)
        string += "\n\(String(format: "%02d%%", Int((renderingSystemsFrameTime / totalSystemTime) * 100))) Rendering Systems"
        string += "\n\(String(format: "%02d%%", Int((systemsFrameTime / totalSystemTime) * 100))) Systems\n"
        string += "\n\(game.entities.count) Entities,"
        string += " \(game.resourceManager.cache.geometries.count) Geometries,"
        string += " \(game.resourceManager.cache.textures.count) Textures\n"

        for statistic in performance.averageSortedStatistics() {
            string += "\n"
            let duration = statistic.value
            string += String(format: "%02d%% ", Int((duration / totalSystemTime) * 100)) + statistic.key
        }
        text.string = string
        
        return true
    }

    let tickDuration: Float = 3
    var cumulativeTime: Float = 0
    public override func render(game: Game, window: Window, withTimePassed deltaTime: Float) {
        cumulativeTime += deltaTime
        if cumulativeTime > tickDuration {
            let didRebuild = rebuildText()
            if didRebuild {
                cumulativeTime = 0
            }
        }

        guard text.isReady else { return }

        let x: Float = .maximum(10, window.safeAreaInsets.leading)
        let y: Float = .maximum(10, window.safeAreaInsets.top)
        let position = Position2(x, y)

        var canvas: Canvas = Canvas(window: window)
        canvas.insert(
            Rect(size: text.size).inset(by: Insets(-4)),
            color: Color(0, 0, 0, 0.6),
            at: position
        )
        canvas.insert(text, at: position)
        window.insert(canvas)
    }

    required public init() {}
    public override class func sortOrder() -> RenderingSystemSortOrder? { .performance }
}
