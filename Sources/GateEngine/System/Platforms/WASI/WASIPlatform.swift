/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT
import Foundation
import Collections
import DOM
import JavaScriptKit
import JavaScriptEventLoop

public final class WASIPlatform: Platform, InternalPlatform {
    public static let fileSystem: WASIFileSystem = WASIFileSystem()
    var staticResourceLocations: [URL]
    var pathCache: [String:String] = [:]
    
    init(delegate: any GameDelegate) {
        self.staticResourceLocations = Self.staticResourceLocations(delegate: delegate)
    }
    
    static func staticResourceLocations(delegate: any GameDelegate) -> [Foundation.URL] {
        func getGameModuleName(_ delegate: AnyObject) -> String {
            let ref = String(reflecting: type(of: delegate))
            return String(ref.split(separator: ".")[0])
        }
        let gameModule = getGameModuleName(delegate)
        final class GateEngineModuleLocator {}
        let engineModule = getGameModuleName(GateEngineModuleLocator())
        let files = [
            /*
             Engine resources.
             - First so projects with delegate defined paths are the most efficient
             */
            Foundation.URL(fileURLWithPath: "\(engineModule)_\(engineModule).resources"),
            
            // For when the package and target share a name for convenience
            Foundation.URL(fileURLWithPath: "\(gameModule)_\(gameModule).resources"),
            
            // Root
            Foundation.URL(fileURLWithPath: Bundle.main.bundlePath),
        ]
        if files.isEmpty {
            Log.error("Failed to load any resource bundles! Check code signing and directory permissions.")
        }else{
            Log.debug("Loaded static resource search paths: (GameDelegate search paths not included)", files.map({
                let path = $0.path
                if path == "." || path == "./" || path.isEmpty {
                    // Already root
                    return "\n    \"[WebDir]/\","
                }
                return "\n    \"[WebDir]/" + path + "/\","
            }).joined(), "\n")
        }
        return files
    }

    public func locateResource(from path: String) async -> String? {
        if let existing = pathCache[path] {
            return existing
        }
        let delegatePaths = Game.shared.delegate.customResourceLocations()

        let searchPaths = OrderedSet(delegatePaths + staticResourceLocations)
        for searchPath in searchPaths {
            let newPath = searchPath.appendingPathComponent(path).path
            if let object = try? await fetch(newPath, ["method": "HEAD"]).object {
                if Response(from: object)?.ok == true {
                    pathCache[path] = newPath
                    Log.debug("Located Resource: \"\(path)\" at \"\(newPath)\"")
                    return newPath
                }
            }
        }
        
        Log.debug("Failed to locate Resource: \"\(path)\"")
        return nil
    }
    
    public func loadResourceAsArrayBuffer(from path: String) async throws -> ArrayBuffer {
        if let resolvedPath = await locateResource(from: path) {
            do {
                if let object = try await fetch(path).object {
                    if let response = Response(from: object) {
                        return try await response.arrayBuffer()
                    }
                }
            }catch{
                Log.error("Failed to load resource \"\(resolvedPath)\".", error)
                throw GateEngineError.failedToLoad("\(error)")
            }
        }
        
        throw GateEngineError.failedToLocate
    }
    
    public func loadResource(from path: String) async throws -> Data {
        let arrayBuffer: ArrayBuffer = try await loadResourceAsArrayBuffer(from: path)
        return Data(arrayBuffer)
    }
    
    @inline(__always)
    func fetch(_ url: String, _ options: [String: JSValue] = [:]) async throws -> JSValue {
        let jsFetch = JSObject.global.fetch.function!
        return try await JSPromise(jsFetch(url, options).object!)!.value
    }
    
    func saveStatePath(forStateNamed name: String) throws -> String {
        return URL(fileURLWithPath: try fileSystem.pathForSearchPath(.persistent, in: .currentUser)).appendingPathComponent(name).path
    }
    
    func saveState(_ state: Game.State, as name: String) async throws {
        let data = try JSONEncoder().encode(state)
        let path = try self.saveStatePath(forStateNamed: name)
        let dir = URL(fileURLWithPath: path).deletingLastPathComponent().path
        if await fileSystem.itemExists(at: dir) == false {
            try await fileSystem.createDirectory(at: dir)
        }
        try await fileSystem.write(data, to: path)
    }
    
    func loadState(named name: String) async -> Game.State {
        do {
            let data = try await fileSystem.read(from: try saveStatePath(forStateNamed: name))
            let state = try JSONDecoder().decode(Game.State.self, from: data)
            state.name = name
            return state
        }catch{
            if let error = error as? String, error != "No such file or directory." {
                Log.error("Game State \"\(name)\" failed to restore:", error)
            }
            return Game.State(name: name)
        }
    }
    
    func systemTime() -> Double {
        #if os(WASI)
        var time = timespec()
        let CLOCK_MONOTONIC = clockid_t(bitPattern: 1)
        if clock_gettime(CLOCK_MONOTONIC, &time) != 0 {
            return -1
        }
        return Double(time.tv_sec) + (Double(time.tv_nsec) / 1e+9)
        #else //GATEENGINE_ENABLE_WASI_IDE_SUPPORT
        return Date().timeIntervalSinceReferenceDate
        #endif
    }
    
    public var supportsMultipleWindows: Bool {
        return false
    }
    
    internal enum Browser: CustomStringConvertible {
        case safari(version: Version)
        case mobileSafari(version: Version)
        case chrome(version: Version)
        case fireFox(version: Version)
        case edge(version: Version)
        case opera(version: Version)
        case unknown(name: String, version: Version)
        
        struct Version: CustomStringConvertible {
            let major: UInt
            let minor: UInt
            let patch: UInt
            let build: UInt
            
            var description: String {
                return "\(major).\(minor).\(patch).\(build)"
            }
        }
        var description: String {
            switch self {
            case let .safari(version: Version):
                return "Safari \(Version)"
            case let .mobileSafari(version: Version):
                return "Mobile Safari \(Version)"
            case let .chrome(version: Version):
                return "Chrome \(Version)"
            case let .fireFox(version: Version):
                return "FireFox \(Version)"
            case let .edge(version: Version):
                return "Edge \(Version)"
            case let .opera(version: Version):
                return "Opera \(Version)"
            case let .unknown(name, version):
                return name + " \(version)"
            }
        }
    }
    
    var browser: Browser {Self.browser}
    internal static let browser: Browser = {
        let string: String = globalThis.navigator.userAgent
        let name = globalThis.navigator.appName
        
        //TODO: Regex this whole thing...
        
        func version(from string: String) -> Browser.Version {
            var fail: Bool = false
            let versionComponents = string.components(separatedBy: ".").map({
                if let v = UInt($0) {
                    return v
                }
                fail = true
                return 0
            })
            if fail {
                return Browser.Version(major: 0, minor: 0, patch: 0, build: 0)
            }
            let version: Browser.Version
            switch versionComponents.count {
            case 1:
                version = Browser.Version(major: versionComponents[0], minor: 0, patch: 0, build: 0)
            case 2:
                version = Browser.Version(major: versionComponents[0], minor: versionComponents[1], patch: 0, build: 0)
            case 3:
                version = Browser.Version(major: versionComponents[0], minor: versionComponents[1], patch: versionComponents[2], build: 0)
            case 4:
                version = Browser.Version(major: versionComponents[0], minor: versionComponents[1], patch: versionComponents[2], build: versionComponents[3])
            default:
                Log.warn("Failed to determine browser version.")
                version = Browser.Version(major: 0, minor: 0, patch: 0, build: 0)
            }
            return version
        }
        
        if string.contains("OPR") {
            let versionString = string.components(separatedBy: "OPR/")[1]
            return .opera(version: version(from: versionString))
        }
        if string.contains("Edg") {
            let versionString = string.components(separatedBy: "Edg/")[1]
            return .edge(version: version(from: versionString))
        }
        if string.contains("Firefox") {
            let versionString = string.components(separatedBy: "Firefox/")[1]
            return .fireFox(version: version(from: versionString))
        }
        
        // Non-Google user agents contain Chrome, so check for Chrame almost last
        if string.contains("Chrome") {
            let versionString = string.components(separatedBy: ")").last!.components(separatedBy: "/")[1].components(separatedBy: " ")[0]
            return .chrome(version: version(from: versionString))
        }
        // Non-Apple user agents contain Safari, so check for Safari last
        if string.contains("Mobile") && string.contains("Safari") && string.contains("iPhone OS") {
            let versionString = string.components(separatedBy: ")").last!.components(separatedBy: "/")[1].components(separatedBy: " ")[0]
            return .mobileSafari(version: version(from: versionString))
        }
        if string.contains("Safari") {
            let versionString = string.components(separatedBy: ")").last!.components(separatedBy: "/")[1].components(separatedBy: " ")[0]
            return .safari(version: version(from: versionString))
        }
        let versionString = string.components(separatedBy: ")").last!.components(separatedBy: "/")[1].components(separatedBy: " ")[0]
        return .unknown(name: name, version: version(from: versionString))
    }()
}

extension WASIPlatform {
    @MainActor func setupDocument() {
        globalThis.onbeforeunload = { event -> String? in
            Game.shared.willTerminate()
            return nil
        }
        let document: Document = globalThis.document

        if let ele = document.head?.children.namedItem(name: "viewport") {
            if let meta = HTMLMetaElement(from: ele) {
                meta.content += ", viewport-fit=cover"
            }
        }

        if let style = HTMLStyleElement(from: document.createElement(localName: "style")) {
            style.innerText = """
html, body, canvas {
    margin: 0 !important; padding: 0 !important; height: 100%; overflow: hidden;
    width: 100%;
    width: -moz-available;          /* WebKit-based browsers will ignore this. */
    width: -webkit-fill-available;  /* Mozilla-based browsers will ignore this. */
    width: fill-available;
}
:root {
    --sat: env(safe-area-inset-top);
    --sar: env(safe-area-inset-right);
    --sab: env(safe-area-inset-bottom);
    --sal: env(safe-area-inset-left);
}
"""
            _ = document.body?.appendChild(node: style)
        }
    }
}

extension WASIPlatform {
    @MainActor func main() {
        JavaScriptEventLoop.installGlobalExecutor()
        setupDocument()
        Log.info("Notice: Browser resource errors are expected and normal. Ignore them. Only rely on the logs starting with \"[GateEngine]\".")
        Log.info("Detected Browser As:", Game.shared.platform.browser)
        Task(priority: .high) {@MainActor in
            await Game.shared.didFinishLaunching()
            Game.shared.insertSystem(WASIUserActivationRenderingSystem.self)
        }
    }
}

fileprivate final class WASIUserActivationRenderingSystem: RenderingSystem {
    let text = Text(string: "Click to Start", pointSize: 64, style: .bold, color: .white)
    let banner = Sprite(texture: Texture(path: "GateEngine/Branding/Banner Logo Transparent.png", sizeHint: Size2(1200, 244)), bounds: Rect(size: Size2(1200, 244)), sampleFilter: .linear)
    
    override func setup(game: Game) {
        game.insertSystem(HIDSystem.self)
        game.windowManager.mainWindow?.clearColor = .stregasgateBackground
        banner.texture.cacheHint = .whileReferenced
    }
    
    var somethingWasPressed = false
    override func render(game: Game, window: Window, withTimePassed deltaTime: Float) {
        var canvas = Canvas()
        
        canvas.insert(banner, at: Position2(window.size / 2), scale: Size2(window.size.width) / (banner.bounds.size.width * 1.25))
        
        var textPosition = Position2((window.size / 2) - (text.size / 2))
        textPosition.y = window.size.height - text.size.height - max(window.safeAreaInsets.bottom, 60)
        canvas.insert(text, at: textPosition)
        
        window.insert(canvas)
        
        var noInputsPressed: Bool = true
        if game.hid.gamePads.any.button.confirmButton.isPressed {
            somethingWasPressed = true
            noInputsPressed = false
        }
        if game.hid.screen.anyTouch(withGesture: .touchDown) != nil {
            somethingWasPressed = true
            noInputsPressed = false
        }
        if game.hid.keyboard.pressedButtons().isEmpty == false {
            somethingWasPressed = true
            noInputsPressed = false
        }
        if game.hid.mouse.button(.primary).isPressed {
            somethingWasPressed = true
            noInputsPressed = false
        }
        
        // If something was pressed and nothing is currently pressed
        // This ensures inputs from this screen are not immediteley sent to the game
        // Since no other platform would have this happen, doing this will reduce platform specific per-project bugs.
        if somethingWasPressed && noInputsPressed {
            game.removeSystem(self)
        }
    }
    
    override func teardown(game: Game) {
        game.windowManager.mainWindow?.clearColor = .black
        game.addPlatformSystems()
        Task {
            await game.delegate.didFinishLaunching(game: game, options: [])
        }
    }
}

#if os(WASI) && !GATEENGINE_PLATFORM_EVENT_DRIVEN
#error("WASI must be event driven.")
#endif

#endif
