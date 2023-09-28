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
    func rebuildText() {
        let systemsFrameTime = game.ecs.performance!.systemsFrameTime
        let renderingSystemsFrameTime = game.ecs.performance!.renderingSystemsFrameTime

        var string: String = "\(game.ecs.performance!.fps) FPS"
        if game.ecs.performance!.totalDroppedFrames > 0 {
            string += ", \(game.ecs.performance!.totalDroppedFrames) All Time Dropped"
        }
        string += "\n\n"
        string += String(format: "%.1fms Total Systems Time", systemsFrameTime + renderingSystemsFrameTime)
        string += "\n\(String(format: "%.1fms", renderingSystemsFrameTime)) Rendering Systems"
        string += "\n\(String(format: "%.1fms", systemsFrameTime)) Systems\n"
        string += "\n\(game.entities.count) Entities,"
        string += " \(game.resourceManager.cache.geometries.count) Geometries,"
        string += " \(game.resourceManager.cache.textures.count) Textures\n"

        for statistic in game.ecs.performance!.averageSortedStatistics() {
            string += "\n"
            let duration = statistic.value
            string += String(format: "%.1fms ", duration) + statistic.key
        }
        text.string = string
    }

    let tickDuration: Float = 3
    var cumulativeTime: Float = 0
    public override func render(game: Game, window: Window, withTimePassed deltaTime: Float) {
        cumulativeTime += deltaTime
        if cumulativeTime > tickDuration {
            rebuildText()
            cumulativeTime = 0
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
