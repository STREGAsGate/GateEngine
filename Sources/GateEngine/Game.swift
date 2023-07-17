/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Game {
    public let platform: CurrentPlatform
    public let delegate: GameDelegate
    
    @MainActor public private(set) var state: State! = nil
    @MainActor internal private(set) var internalState: State! = nil
    
    lazy private(set) var identifier: String = delegate.resolvedGameIdentifier()
    
    nonisolated public let isHeadless: Bool
    @MainActor internal init(delegate: GameDelegate, currentPlatform: CurrentPlatform) {
        self.platform = currentPlatform
        self.delegate = delegate
        self.isHeadless = delegate.isHeadless()
    }
    
    /// The graphics library being used to render.
    nonisolated public var renderingAPI: RenderingAPI {renderer.api}
    @MainActor @usableFromInline private(set) lazy var renderer: Renderer = Renderer()
    @MainActor @usableFromInline internal var renderingIsPermitted: Bool = false
    
    @MainActor public private(set) lazy var windowManager: WindowManager = WindowManager(self)
    @MainActor @usableFromInline private(set) lazy var ecs: ECSContext = ECSContext(game: self)
    @MainActor @usableFromInline private(set) lazy var hid: HID = HID()
    @MainActor @usableFromInline private(set) lazy var resourceManager: ResourceManager = ResourceManager(game: self)
    
    @MainActor func didFinishLaunching() async {
        self.state = await platform.loadState(named: "SaveState.json")
        self.internalState = await platform.loadState(named: "GateEngine.json")
        #if !GATEENGINE_PLATFORM_CREATES_MAINWINDOW
        if isHeadless == false {
            do {
                // Allow the main window to be created even though we're not rendering
                self.renderingIsPermitted = true
                _ = try delegate.createMainWindow(game: self, identifier: WindowManager.mainWindowIdentifier)
                assert(windowManager.mainWindow?.identifier == WindowManager.mainWindowIdentifier, "Must use the provided identifier to make the mainWindow.")
                self.renderingIsPermitted = false
            }catch{
                Log.fatalError("Failed to create main window. \(error)")
            }
        }
        #endif
        
        #if !GATEENGINE_PLATFORM_DEFERS_LAUNCH
        self.addPlatformSystems()
        self.delegate.didFinishLaunching(game: self, options: [])
        #endif
        
        self.primeDeltaTime()
        
        #if !GATEENGINE_PLATFORM_EVENT_DRIVEN
        self.gameLoop()
        #endif
    }
    @MainActor func willTerminate() {
        self.delegate.willTerminate(game: self)
    }
    
    @MainActor internal func addPlatformSystems() {
        self.insertSystem(HIDSystem.self)
        self.insertSystem(AudioSystem.self)
        self.insertSystem(CacheSystem.self)
    }
    
    /// The current delta time as a Double
    @usableFromInline
    internal var highPrecisionDeltaTime: Double = 0
    private var previousTime: Double = 0
    
    @inline(__always)
    func primeDeltaTime() {
        for _ in 0 ..< 2 {
            let now: Double = Game.shared.platform.systemTime()
            self.highPrecisionDeltaTime = now - self.previousTime
            self.previousTime = now
        }
    }
    
    #if GATEENGINE_PLATFORM_EVENT_DRIVEN
    @MainActor internal func eventLoop(completion: @escaping ()->Void) {
        Task {@MainActor in
            let now: Double = Game.shared.platform.systemTime()
            self.highPrecisionDeltaTime = now - self.previousTime
            self.previousTime = now
            if await self.ecs.shouldRenderAfterUpdate(withTimePassed: Float(highPrecisionDeltaTime)) {
                Task(priority: .high) {@MainActor in
                    self.windowManager.drawWindows()
                    completion()
                }
            }else{
                #if GATEENGINE_DEBUG_RENDERING
                Log.warn("Frame Dropped", "DeltaTime:", highPrecisionDeltaTime)
                #endif
                completion()
            }
        }
    }
    #else
    internal func gameLoop() {
        Task {@MainActor in
            let now: Double = Game.shared.platform.systemTime()
            self.highPrecisionDeltaTime = now - self.previousTime
            self.previousTime = now
            if await self.ecs.shouldRenderAfterUpdate(withTimePassed: Float(highPrecisionDeltaTime)) {
                Task(priority: .high) {@MainActor in
                    self.windowManager.drawWindows()
                }
            }else{
                #if GATEENGINE_DEBUG_RENDERING
                Log.warn("Frame Dropped. DeltaTime:", Float(highPrecisionDeltaTime))
                #endif
            }
            self.gameLoop()
        }
    }
    #endif
}

extension Game {
    @usableFromInline
    static var shared: Game! = nil
}
