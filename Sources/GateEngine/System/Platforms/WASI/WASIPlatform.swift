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
    var pathCache: [String:String] = [:]
    static let staticSearchPaths: [Foundation.URL] = {
        func getGameModuleName(_ delegate: AnyObject) -> String {
            let ref = String(reflecting: type(of: delegate))
            return String(ref.split(separator: ".")[0])
        }
        let gameModule = getGameModuleName(Game.shared.delegate)
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
            Log.error("Failed to load any resource bundles! Check code signing and directory premissions.")
        }else{
            Log.debug("Loaded static resource search paths:", files.map({
                return "\n\"" + $0.path + "/\","
            }).joined(), "\n  (note: These do not include any GameDelegate provided search paths)\n")
        }
        return files
    }()

    public func locateResource(from path: String) async -> String? {
        if let existing = pathCache[path] {
            Log.info("Located Resource: \"\(path)\" at \"\(existing)\"")
            return existing
        }
        let delegatePaths = await Game.shared.delegate.resourceSearchPaths()

        let searchPaths = OrderedSet(delegatePaths + Self.staticSearchPaths)
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
        
        Log.debug("Failed to located Resource: \"\(path)\"")
        return nil
    }
    
    public func loadResourceAsArrayBuffer(from path: String) async throws -> ArrayBuffer {
        if let path = await locateResource(from: path) {
            Log.debug("Loading Resource: \"\(path)\"")
            do {
                if let object = try await fetch(path).object {
                    if let response = Response(from: object) {
                        return try await response.arrayBuffer()
                    }
                }
            }catch{
                Log.error("Failed to load resource \"\(path)\".")
                throw error
            }
        }
        
        throw "failed to locate."
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
    
    func saveStateURL() throws -> URL {
        fatalError()
    }
    
    func saveState(_ state: Game.State) throws {
        let window: DOM.Window = globalThis
        window.localStorage["SaveState.data"] = try JSONEncoder().encode(state).base64EncodedString()
    }
    
    func loadState() -> Game.State {
        let window: DOM.Window = globalThis
        if let base64 = window.localStorage["SaveState.data"], let data = Data(base64Encoded: base64) {
            do {
                return try JSONDecoder().decode(Game.State.self, from: data)
            }catch{
                Log.error("Game.State failed to restore:", error)
            }
        }
        return Game.State()
    }
    
    func systemTime() -> Double {
#if os(WASI)
        var time = timespec()
        let CLOCK_MONOTONIC = clockid_t(bitPattern: 1)
        if clock_gettime(CLOCK_MONOTONIC, &time) != 0 {
            return -1
        }
        return Double(time.tv_sec) + (Double(time.tv_nsec) / 1e+9)
#else
        return Date().timeIntervalSinceReferenceDate
#endif
    }
    
    public var supportsMultipleWindows: Bool {
        return false
    }
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
        Log.info("Notice: Failed resource errors emitted from the browser are normal. Ignore them. Only rely on the logs starting with \"[GateEngine]\".")
        Game.shared.didFinishLaunching()
        Game.shared.insertSystem(WASIUserActivationRenderingSystem.self)
    }
}

fileprivate final class WASIUserActivationRenderingSystem: RenderingSystem {
    let text = Text(string: "Click to Start", pointSize: 64, style: .bold, color: .white)
    let banner = Sprite(texture: Texture(path: "GateEngine/Branding/Banner Logo Transparent.png", sizeHint: Size2(1200, 244)), bounds: Rect(size: Size2(1200, 244)), sampleFilter: .linear)
    
    override func setup(game: Game) {
        game.windowManager.mainWindow?.clearColor = .stregasgateBackground
    }
    
    override func render(game: Game, window: Window, withTimePassed deltaTime: Float) {
        var canvas = Canvas(window: window)
        
        canvas.insert(banner, at: Position2(window.interfaceSize / 2), scale: Size2(window.interfaceSize.width / (banner.bounds.size.width * 1.25)))
        
        var textPosition = Position2((window.interfaceSize / 2) - (text.size / 2))
        textPosition.y = window.interfaceSize.height - text.size.height - max(window.safeAreaInsets.bottom, 60)
        canvas.insert(text, at: textPosition)
        
        window.insert(canvas)
        
        if game.hid.mouse.button(.button1).isPressed {
            game.removeSystem(self)
            
            game.addPlatformSystems()
            game.delegate.didFinishLaunching(game: game, options: [])
        }
    }
    
    override func teardown(game: Game) {
        game.windowManager.mainWindow?.clearColor = .black
    }
}

extension DOM.Navigator {
    enum Browser {
        case safari
        case chrome
        case fireFox
        case opera
        case unknown
    }
    var browser: Browser {
        let string: String = globalThis.navigator.userAgent
//        let vendor = globalThis.navigator.vendor
//        let version = globalThis.navigator.appVersion
        if string.contains("Chrome") {
            return .chrome
        }
        if string.contains("Safari") {
            return .safari
        }
        if string.contains("FireFox") {
            return .fireFox
        }
        if string.contains("Opera") {
            return .opera
        }
        return .unknown
    }
}

#if os(WASI) && !GATEENGINE_PLATFORM_SINGLETHREADED
#error("WASI must be single threaded.")
#endif

#endif
