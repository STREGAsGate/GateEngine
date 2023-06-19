/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation
import GameMath

public final class Game {
    public let platform: CurrentPlatform = CurrentPlatform()
    
    public let delegate: GameDelegate
    
    @MainActor public private(set) lazy var state: State = platform.loadState()

    lazy private(set) var identifier: String = delegate.resolvedGameIdentifier()
    
    nonisolated public let isHeadless: Bool
    @MainActor internal init(delegate: GameDelegate) {
        self.delegate = delegate
        self.isHeadless = delegate.isHeadless()
    }
    
    /// The graphics library being used to render.
    nonisolated public var renderingAPI: RenderingAPI {renderer.api}
    @MainActor @usableFromInline let renderer: Renderer = Renderer()
    @MainActor @usableFromInline internal var renderingIsPermitted: Bool = false
    
    @MainActor public private(set) lazy var windowManager: WindowManager = WindowManager(self)
    @MainActor @usableFromInline private(set) lazy var ecs: ECSContext = ECSContext(game: self)
    @MainActor @usableFromInline private(set) lazy var hid: HID = HID()
    @MainActor @usableFromInline private(set) lazy var resourceManager: ResourceManager = ResourceManager(game: self)
    
    @MainActor func didFinishLaunching() {
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
        
        self.primeDeltaTime()
        
        #if !GATEENGINE_PLATFORM_DEFERS_LAUNCH
        self.addPlatformSystems()
        self.delegate.didFinishLaunching(game: self, options: [])
        #endif
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

@MainActor extension Game {
    public func saveState() throws {
        try platform.saveState(state)
    }
    public class State: Codable {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        private var bools: [String : Bool]
        private var integers: [String : Int64]
        private var doubles: [String : Double]
        private var strings: [String : String]
        enum CodingKeys: CodingKey {
            case bools
            case integers
            case doubles
            case strings
        }
        
        public func setValue(_ value: Bool, forKey key: String) {
            assert(key.isAscii, "ASCII characters are required for state keys for compatibility reasons.")
            bools.updateValue(value, forKey: key)
        }
        public func boolForKey(_ key: String) -> Bool {
            return bools[key] == true
        }
        
        
        public func setValue<T: BinaryInteger>(_ value: T, forKey key: String) {
            assert(key.isAscii, "ASCII characters are required for state keys for compatibility reasons.")
            assert(MemoryLayout<T>.size <= MemoryLayout<Int64>.size, "\(T.self) is not guaranteed to fit in state storage and cannot be used.")
            integers.updateValue(Int64(value), forKey: key)
        }
        public func integerForKey<T: BinaryInteger>(_ key: String, ofType: T.Type = Int.self) -> T? {
            if let int = integers[key] {
                return T(int)
            }
            return nil
        }
        
        
        public func setValue<T: BinaryFloatingPoint>(_ value: T, forKey key: String) {
            assert(key.isAscii, "ASCII characters are required for state keys for compatibility reasons.")
            assert(MemoryLayout<T>.size <= MemoryLayout<Double>.size, "\(T.self) is not guaranteed to fit in state storage and cannot be used.")
            doubles.updateValue(Double(value), forKey: key)
        }
        public func floatForKey<T: BinaryFloatingPoint>(_ key: String, ofType: T.Type = Float.self) -> T? {
            if let double = doubles[key] {
                return T(double)
            }
            return nil
        }
        
        public func setValue(_ value: String, forKey key: String) {
            assert(key.isAscii, "ASCII characters are required for state keys for compatibility reasons.")
            assert(value.isAscii, "ASCII characters are required for state string values for compatibility reasons.")
            strings.updateValue(value, forKey: key)
        }
        public func stringForKey(_ key: String) -> String? {
            return strings[key]
        }
        
        public func encode<T: Codable>(_ value: T, forKey key: String) throws {
            assert(key.isAscii, "ASCII characters are required for state keys for compatibility reasons.")
            let data = try encoder.encode(value)
            let string = data.base64EncodedString()
            self.setValue(string, forKey: key)
        }
        public func decode<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
            if let string = self.stringForKey(key) {
                if let data = Data(base64Encoded: string) {
                    return try decoder.decode(type, from: data)
                }
            }
            return nil
        }
        
        public func removeValueForKey(_ key: String) {
            bools.removeValue(forKey: key)
            integers.removeValue(forKey: key)
            doubles.removeValue(forKey: key)
            strings.removeValue(forKey: key)
        }

        internal init() {
            bools = [:]
            integers = [:]
            doubles = [:]
            strings = [:]
        }
        
        @MainActor public func save() throws {
            try Game.shared.platform.saveState(self)
        }
    }
}

fileprivate extension String {
    var isAscii: Bool {
        for char in self {
            for code in char.unicodeScalars {
                guard code.isASCII else {return false}
            }
        }
        return true
    }
}
