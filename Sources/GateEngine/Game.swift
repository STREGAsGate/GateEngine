/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Game {
    public let platform: CurrentPlatform
    public let delegate: any GameDelegate

    @MainActor public private(set) var state: State! = nil
    @MainActor internal private(set) var internalState: State! = nil

    lazy private(set) var identifier: String = delegate.resolvedGameIdentifier()

    nonisolated public let isHeadless: Bool
    @MainActor internal init(delegate: any GameDelegate, currentPlatform: CurrentPlatform) {
        self.platform = currentPlatform
        self.delegate = delegate
        if delegate.isHeadless() {
            self.renderer = nil
            self.isHeadless = true
            self.renderingAPI = .headless
        } else {
            let renderer = Renderer()
            self.renderer = renderer
            self.renderingAPI = renderer._backend.renderingAPI
            self.isHeadless = false
        }
    }

    public struct Attributes: OptionSet {
        public let rawValue: UInt
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        public static let renderingIsPermitted = Self(rawValue: 1 << 2)
    }
    @MainActor public internal(set) var attributes: Attributes = []

    /// The graphics library being used to render.
    public let renderingAPI: RenderingAPI
    @MainActor @usableFromInline let renderer: Renderer!

    @MainActor public private(set) lazy var windowManager: WindowManager = WindowManager(self)
    @MainActor @usableFromInline private(set) lazy var ecs: ECSContext = ECSContext()
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
    @inline(__always)
    internal static func getNextDeltaTime(accumulator: inout Double, previous: inout Double) -> Double? {
        // 240fps
        let stepDuration: Double = /* 1/240 */ 0.004166666667
        let now: Double = Game.shared.platform.systemTime()
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
            Task(priority: .high) { @MainActor in
                self.windowManager.drawWindows()
                completion()
            }
            if await self.ecs.shouldRenderAfterUpdate(
                withTimePassed: Float(deltaTime)
            ) {
                // Add a high priority Task so we can jump the line if other Tasks were started
                Task(priority: .high) { @MainActor in
                    self.windowManager.drawWindows()
                    completion()
                }
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

extension Game {
    @MainActor
    @usableFromInline
    static var shared: Game! = nil
}
