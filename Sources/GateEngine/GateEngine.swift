/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

// Windows doesn't always link @_exported, so we import too.
import GameMath
@_exported import GameMath

import Foundation
@_exported import struct Foundation.Date
@_exported import struct Foundation.Data
@_exported import struct Foundation.URL
@_exported import func Foundation.ceil
@_exported import func Foundation.floor
@_exported import func Foundation.round
@_exported import func Foundation.pow
@_exported import func Foundation.sin
@_exported import func Foundation.cos
@_exported import func Foundation.tan
@_exported import func Foundation.acos
@_exported import func Foundation.atan2

#if canImport(WinSDK)
import WinSDK
#endif

#if os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT
import JavaScriptKit
import WebAPIBase
#endif

#if targetEnvironment(macCatalyst)
#error("macCatalyst is not a supported platform. Use macOS instead.")
#endif

#if os(watchOS)
// Apple doesn't allow 3rd party developers to use Metal on watchOS so it's not possible to run an engine.
// Apple's own SceneKit engine does use Metal on watchOS, but GateEngine isn't allowed to do the same.
#error("watchOS is not a supported platform.")
#endif

#if swift(>=5.9)
#if os(xrOS)
#error("visionOS is not a supported platform.")
#endif
#endif

#if os(Android)
#error("Android is not currently supported, but is planned.")
#endif

#if GATEENGINE_WASI_UNSUPPORTED_HOST && os(WASI)
#error("HTML5 builds are not supported on this host platform. Use macOS or Linux.")
#endif

extension Color {
    internal static let stregasgateBackground: Color = #colorLiteral(red: 0.094117634, green: 0.0941176638, blue: 0.094117634, alpha: 1)
}

extension String: Error {}

internal extension CommandLine {
#if os(macOS) || ((os(iOS) || os(tvOS)) && targetEnvironment(simulator))
    @usableFromInline
    static let isDebuggingWithXcode: Bool = ProcessInfo.processInfo.environment.keys.first(where: {$0.lowercased().contains("xcode")}) != nil
#endif
}

@usableFromInline
internal enum Log {
    @usableFromInline
    static var onceHashes: Set<Int> = []

    @usableFromInline
    enum ANSIColors: String, CustomStringConvertible {
        @usableFromInline
        var description: String {
            return self.rawValue
        }
        
        case black = "\u{001B}[0;30m"
        case red = "\u{001B}[0;31m"
        case green = "\u{001B}[0;32m"
        case yellow = "\u{001B}[0;33m"
        case blue = "\u{001B}[0;34m"
        case magenta = "\u{001B}[0;35m"
        case cyan = "\u{001B}[0;36m"
        case white = "\u{001B}[0;37m"
        case `default` = "\u{001B}[0;0m"
    }
    
    @inline(__always) @usableFromInline
    static var supportsColor: Bool {
        #if os(macOS) || ((os(iOS) || os(tvOS)) && targetEnvironment(simulator))
        if CommandLine.isDebuggingWithXcode {
            return false
        }
        #endif
        #if os(WASI) || os(Windows)
        return false
        #else
        return true
        #endif
    }
    
    @_transparent @usableFromInline
    internal static func _message(prefix: String, _ items: Any..., separator: String) -> String {
        var message = prefix
        for item in items {
            message += separator
            message += "\(item)"
        }
        return message
    }
    
    @_transparent @usableFromInline
    static func info(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let message = _message(prefix: "[GateEngine]", items, separator: separator)
        
        #if os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT
        console.info(data: .string(message))
        #else
        Swift.print(message, terminator: terminator)
        #if os(Windows)
        WinSDK.OutputDebugStringW((message + terminator).windowsUTF16)
        #endif
        #endif
    }
    
    @_transparent @usableFromInline
    static func infoOnce(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let hash = items.compactMap({$0 as? AnyHashable}).hashValue
        if onceHashes.contains(hash) == false {
            onceHashes.insert(hash)
            Self.info(items, separator: separator, terminator: terminator)
        }
    }
    
    @_transparent @usableFromInline
    static func debug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG
        #if os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT
        let message = _message(prefix: "[GateEngine]", items, separator: separator)
        console.debug(data: .string(message))
        #else
        self.info(items, separator: separator, terminator: terminator)
        #endif
        #endif
    }
    
    @_transparent @usableFromInline
    static func debugOnce(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG
        let hash = items.compactMap({$0 as? AnyHashable}).hashValue
        if onceHashes.contains(hash) == false {
            onceHashes.insert(hash)
            Self.debug(items, separator: separator, terminator: terminator)
        }
        #endif
    }
    
    @_transparent @usableFromInline
    static func warn(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let resolvedMessage: String
        if supportsColor {
            resolvedMessage = _message(prefix: "[GateEngine] \(ANSIColors.magenta)warning\(ANSIColors.default):", items, separator: separator)
        }else{
            resolvedMessage = _message(prefix: "[GateEngine] warning:", items, separator: separator)
        }
        #if os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT
        console.warn(data: .string(resolvedMessage))
        #else
        
        #if os(Windows)
        WinSDK.OutputDebugStringW((resolvedMessage + terminator).windowsUTF16)
        #endif
        
        Swift.print(resolvedMessage, separator: separator, terminator: terminator)
        #endif
    }
    
    @_transparent @usableFromInline
    static func warnOnce(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let hash = items.compactMap({$0 as? AnyHashable}).hashValue
        if onceHashes.contains(hash) == false {
            onceHashes.insert(hash)
            Self.warn(items, separator: separator, terminator: terminator)
        }
    }
    
    @_transparent @usableFromInline
    static func error(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let resolvedMessage: String
        if supportsColor {
            resolvedMessage = self._message(prefix: "[GateEngine] \(ANSIColors.red)error\(ANSIColors.default):", items, separator: separator)
        }else{
            resolvedMessage = self._message(prefix: "[GateEngine] error:", items, separator: separator)
        }
        #if os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT
        console.error(data: .string(resolvedMessage))
        #else
        
        #if canImport(WinSDK)
        WinSDK.OutputDebugStringW((resolvedMessage + terminator).windowsUTF16)
        #endif
        
        Swift.print(resolvedMessage, separator: separator, terminator: terminator)
        #endif
    }
    
    @_transparent @usableFromInline
    static func errorOnce(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let hash = items.compactMap({$0 as? AnyHashable}).hashValue
        if onceHashes.contains(hash) == false {
            onceHashes.insert(hash)
            Self.error(items, separator: separator, terminator: terminator)
        }
    }
    
    @_transparent @usableFromInline
    static func assert(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {
        #if DEBUG
        let condition = condition()
        guard condition == false else {return}

        let resolvedMessage: String
        if supportsColor {
            resolvedMessage = self._message(prefix: "[GateEngine] \(ANSIColors.red)error\(ANSIColors.default):", message(), separator: " ")
        }else{
            resolvedMessage = self._message(prefix: "[GateEngine] error:", message(), separator: " ")
        }
        
        #if canImport(WinSDK)
        WinSDK.OutputDebugStringW((resolvedMessage + "/n").windowsUTF16)
        #endif
        
        #if os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT
        console.assert(condition: condition, data: .string(resolvedMessage))
        #endif
        
        Swift.assert(condition, resolvedMessage, file: file, line: line)
        #endif
    }
    
    @usableFromInline
    static func fatalError(_ message: String, file: StaticString = #file, line: UInt = #line) -> Never {
        let resolvedMessage: String
        if supportsColor {
            resolvedMessage = self._message(prefix: "[GateEngine] \(ANSIColors.red)error\(ANSIColors.default):", message, separator: " ")
        }else{
            resolvedMessage = self._message(prefix: "[GateEngine] error:", message, separator: " ")
        }
        
        #if canImport(WinSDK)
        WinSDK.OutputDebugStringW((resolvedMessage + "/n").windowsUTF16)
        #endif
        
        #if os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT
        console.assert(condition: false, data: .string(resolvedMessage))
        #endif
        
        return Swift.fatalError(resolvedMessage, file: file, line: line)
    }
}

internal extension Game {
    @MainActor static func sync<Result>(_ closure: @escaping (() async -> Result)) -> Result {
        var result: Optional<Result> = nil
        var done = false
        // Becuase it's going to block, make it high priority
        Task(priority: .high) { @MainActor in
            result = await closure()
            done = true
        }
        while done != true {
            #if !os(WASI)
            RunLoop.current.run(until: Date())
            #endif
        }
        return result!
    }
}
