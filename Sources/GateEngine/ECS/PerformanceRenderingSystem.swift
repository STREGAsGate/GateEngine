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
    @inline(__always)
    func rebuildText() {
        let systemsFrameTime = game.ecs.performance!.systemsFrameTime
        let renderingSystemsFrameTime = game.ecs.performance!.renderingSystemsFrameTime
        
        var string: String = "\(game.ecs.performance!.fps) FPS"
        if game.ecs.performance!.totalDroppedFrames > 0 {
            string += ", \(game.ecs.performance!.totalDroppedFrames) All Time Dropped"
        }
        string += "\n"
        string += "\n" + String(format: "%.3fms Total Time", systemsFrameTime + renderingSystemsFrameTime)
        string += "\n\(String(format: "%.3fms", renderingSystemsFrameTime)) Rendering Systems"
        string += "\n\(String(format: "%.3fms", systemsFrameTime)) Systems\n"
        string += "\n\(game.entities.count) Entities, \(game.resourceManager.cache.geometries.count) Geometries, \(game.resourceManager.cache.textures.count) Textures\n"
        var total: Double = 0
        for statistic in game.ecs.performance!.averageSortedStatistics() {
            string += "\n"
            let duration = statistic.value * 1000
            total += duration
            string += String(format: "%.3fms ", duration) + statistic.key
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
        
        guard text.isReady else {return}
        
        var canvas: Canvas = Canvas(window: window)
        let position = Position2(.maximum(10, window.safeAreaInsets.leading), .maximum(10, window.safeAreaInsets.top))
        canvas.insert(Rect(size: text.size).inset(by: Insets(-4)), color: Color(0, 0, 0, 0.5), at: position)
        canvas.insert(text, at: position)
        window.insert(canvas)
    }
    
    required public init() {

    }
    
    public override class func sortOrder() -> RenderingSystemSortOrder? {
        return .performance
    }
}
