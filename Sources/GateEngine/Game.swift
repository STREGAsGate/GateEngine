/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Game {
    @usableFromInline
    nonisolated(unsafe) internal var unsafePlatform: Platform = Platform()
    
    @MainActor public var platform: Platform {
        get {unsafePlatform}
        set {unsafePlatform = newValue}
    }
    
    public let delegate: any GameDelegate

    @MainActor public private(set) var state: State! = nil
    @MainActor internal private(set) var internalState: State! = nil

    nonisolated(unsafe) public internal(set) lazy var info: Game.Info = Game.Info()
    
    nonisolated public let isHeadless: Bool
    @MainActor internal init(delegate: any GameDelegate) {
        self.delegate = delegate
        if delegate.isHeadless() {
            self.renderer = nil
            self.isHeadless = true
            self.renderingAPI = .headless
        } else {
            let renderer = createRenderer()
            self.renderer = renderer
            self.renderingAPI = renderer.api
            self.isHeadless = false
        }
    }

    public struct Attributes: OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        public static let renderingIsPermitted = Self(rawValue: 1 << 2)
    }
    @MainActor public internal(set) var attributes: Attributes = []

    /// The graphics library being used to render.
    public let renderingAPI: RenderingAPI
    @MainActor let renderer: (any Renderer)!

    @MainActor public private(set) lazy var windowManager: WindowManager = WindowManager(self)
    @usableFromInline
    @MainActor internal private(set) lazy var ecs: ECSContext = ECSContext()
    @MainActor public private(set) lazy var hid: HID = HID()
    public private(set) lazy var resourceManager: ResourceManager = {
        return ResourceManager(game: self)
    }()

    @MainActor func didFinishLaunching() async {
        self.state = await platform.loadState(named: "SaveState.json")
        self.internalState = await platform.loadState(named: "GateEngine.json")
        #if !GATEENGINE_PLATFORM_CREATES_MAINWINDOW
        if isHeadless == false {
            do {
                // Allow the main window to be created even though we're not rendering
                self.attributes.insert(.renderingIsPermitted)
                _ = try delegate.createMainWindow(
                    using: windowManager, 
                    with: WindowManager.mainWindowIdentifier
                )
                assert(
                    windowManager.mainWindow?.identifier == WindowManager.mainWindowIdentifier,
                    "Must use the provided identifier to make the mainWindow."
                )
                self.attributes.remove(.renderingIsPermitted)
            } catch {
                Log.fatalError("Failed to create main window. \(error)")
            }
        }
        #endif

        #if !GATEENGINE_PLATFORM_DEFERS_LAUNCH
        self.addPlatformSystems()
        await self.delegate.didFinishLaunching(game: self, options: [])
        #endif

        #if !GATEENGINE_PLATFORM_EVENT_DRIVEN
        self.gameLoop()
        #endif
    }
    @MainActor func willTerminate() {
        self.delegate.willTerminate(game: self)
    }
    
    @MainActor internal func openURLs(_ urls: [URL]) {
        self.delegate.openURLs(urls)
    }

    @MainActor internal func addPlatformSystems() {
        if isHeadless == false {
            self.insertSystem(HIDSystem.self)
            self.insertSystem(AudioSystem.self)
        }
        self.insertSystem(FinalizeSimulation.self)
        self.insertSystem(CacheSystem.self)
        self.insertSystem(DeferredDelaySystem.self)
    }

    private var deltaTimeAccumulator: Double = 0
    private var previousTime: Double = 0
    
    @MainActor
    internal static func getNextDeltaTime(accumulator: inout Double, previous: inout Double) -> Double? {
        // 240fps
        let stepDuration: Double = /* 1/240 */ 0.004166666667
        let now: Double = Platform.current.systemTime()
        let newDeltaTimeAccumulator: Double = accumulator + (now - previous)
        if newDeltaTimeAccumulator < stepDuration {
            return nil
        }

        accumulator = newDeltaTimeAccumulator
        previous = now
        let deltaTime = stepDuration * (accumulator / stepDuration)
        accumulator -= deltaTime
        // Discard times larger then 12 fps. This will cause slow down but will also reduce
        // of the chance of the simulation from breaking
        if deltaTime > /* 1/12 */ 0.08333333333 {
            return nil
        }
        
        return deltaTime
    }
    
    #if GATEENGINE_PLATFORM_EVENT_DRIVEN
    @MainActor internal func eventLoop(completion: @escaping () -> Void) {
        guard let deltaTime = Game.getNextDeltaTime(accumulator: &deltaTimeAccumulator, previous: &previousTime) else {
            completion()
            return
        }
        
        // Add a high priority Task so we can jump the line if other Tasks were started
        Task(priority: .high) { @MainActor in
            let deltaTime = Float(deltaTime)
            self.resourceManager.update(withTimePassed: deltaTime)
            await windowManager.updateWindows(deltaTime: deltaTime)
            self.windowManager.drawWindows()
            if await self.ecs.shouldRenderAfterUpdate(
                withTimePassed: Float(deltaTime)
            ) {
                self.windowManager.drawWindows()
                completion()
            } else {
                #if GATEENGINE_DEBUG_RENDERING
                Log.warn("Frame Dropped", "DeltaTime:", deltaTime)
                #endif
                completion()
            }
        }
    }
    #else
    internal func gameLoop() {
        guard let deltaTime = getNextDeltaTime() else {
            Task(priority: .high) { @MainActor in
                self.gameLoop()
            }
            return
        }
        Task(priority: .high) { @MainActor in
            if await self.ecs.shouldRenderAfterUpdate(
                withTimePassed: Float(deltaTime)
            ) {
                Task(priority: .high) { @MainActor in
                    self.windowManager.drawWindows()
                }
            } else {
                #if GATEENGINE_DEBUG_RENDERING
                Log.warn("Frame Dropped. DeltaTime:", Float(highPrecisionDeltaTime))
                #endif
            }
            self.gameLoop()
        }
    }
    #endif
}

@MainActor
public extension Game {
    /// The shared instance of Game
    static var shared: Game {
        // Should never be nil, so unsafely unwrap
        return _shared.unsafelyUnwrapped
    }
}

internal extension Game {
    nonisolated(unsafe)
    static var _shared: Game? = nil
    
    // Allow unsafe access for GateEngine use
    @usableFromInline
    nonisolated static var unsafeShared: Game {
        return _shared.unsafelyUnwrapped
    }
}
