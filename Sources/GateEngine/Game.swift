/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation
import GameMath

@MainActor public final class Game {
    internal let internalPlatform: InternalPlatform = makeDefaultPlatform()
    public var platform: Platform {return internalPlatform}
    public let delegate: GameDelegate
    
    public private(set) lazy var state: State = internalPlatform.loadState()
    
    public let isHeadless: Bool
    internal init(delegate: GameDelegate) {
        self.delegate = delegate
        self.isHeadless = delegate.isHeadless()
    }
    
    @usableFromInline let renderer: Renderer = Renderer()
    @usableFromInline internal var renderingIsPermitted: Bool = false
    
    public private(set) lazy var windowManager: WindowManager = WindowManager(self)
    @usableFromInline private(set) lazy var ecs: ECSContext = ECSContext(game: self)
    @usableFromInline private(set) lazy var hid: HID = HID()
    @usableFromInline private(set) lazy var resourceManager: ResourceManager = ResourceManager(game: self)
    
    func didFinishLaunching() {
        if isHeadless == false {
            do {
                // Allow the main window to be created even though we're not rendering
                self.renderingIsPermitted = true
                try delegate.createMainWindow(game: self, identifier: windowManager.mainWindowIdentifier)
                assert(windowManager.mainWindow?.identifier == windowManager.mainWindowIdentifier, "Must use the provided identifier to make the mainWindow.")
                self.renderingIsPermitted = false
            }catch{
                fatalError("[GateEngine] Failed to create main window. \(error)")
            }
        }
        self.addPlatformSystems()
        self.delegate.didFinishLaunching(game: self, options: [])
        #if !GATEENGINE_PLATFORM_SINGLETHREADED
        self.gameLoop()
        #endif
    }
    func willTerminate() {
        self.delegate.willTerminate(game: self)
    }
    
    internal func addPlatformSystems() {
        self.insertSystem(HIDSystem.self)
        self.insertSystem(AudioSystem.self)
        self.insertSystem(CacheSystem.self)
    }
    
    #if !GATEENGINE_PLATFORM_SINGLETHREADED
    private var previousTime: Double = 0
    internal func gameLoop() {
        Task(priority: .high) {@MainActor in
            let now: Double = Game.shared.internalPlatform.systemTime()
            let deltaTime: Double = now - self.previousTime
            self.previousTime = now
            if self.ecs.shouldRenderAfterUpdate(withTimePassed: Float(deltaTime)) {
                self.windowManager.drawWindows()
            }
            self.gameLoop()
        }
    }
    #endif
    
    @usableFromInline
    static var shared: Game! = nil
}

extension Game {
    public func saveState() throws {
        try internalPlatform.saveState(state)
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
            try Game.shared.internalPlatform.saveState(self)
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
