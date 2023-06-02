/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation
import GameMath
@_exported import GameMath

#if canImport(WinSDK)
import WinSDK
#endif

#if targetEnvironment(macCatalyst)
#error("macCatalyst is not a supported platform.")
#endif

#if os(watchOS)
#error("watchOS is not a supported platform.")
#endif

#if GATEENGINE_WASI_UNSUPPORTED_HOST && os(WASI)
#error("HTML5 builds are not supported on this platform host.")
#endif

public extension GameMath.Color {
    static let vertexColors = Color(red: -1001, green: -2002, blue: -3003, alpha: -4004)
    static let defaultDiffuseMapColor = Color(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    static let defaultNormalMapColor = Color(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0)
    static let defaultRoughnessMapColor = Color(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let defaultPointLightColor = Color(red: 1.0, green: 1.0, blue: 0.9, alpha: 1.0)
    static let defaultSpotLightColor = Color(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
    static let defaultDirectionalLightColor = Color(red: 0.7, green: 0.7, blue: 1.0, alpha: 1.0)
}

internal extension GameMath.Color {
    static let stregasgateBackground: Color = #colorLiteral(red: 0.094117634, green: 0.0941176638, blue: 0.094117634, alpha: 1)
}

extension String: Error {}

internal extension CommandLine {
#if os(macOS) || ((os(iOS) || os(tvOS)) && targetEnvironment(simulator))
    static let isDebuggingWithXcode: Bool = ProcessInfo.processInfo.environment.keys.first(where: {$0.lowercased().contains("xcode")}) != nil
#endif
}

internal enum Log {
    static var onceHashes: Set<Int> = []

    enum ANSIColors: String, CustomStringConvertible {
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
    
    @_transparent
    static var supportsColor: Bool {
        #if os(macOS) || ((os(iOS) || os(tvOS)) && targetEnvironment(simulator))
        if CommandLine.isDebuggingWithXcode {
            return false
        }
        #endif
        #if os(WASI)
        return false
        #endif
        return true
    }
    
    @_transparent
    private static func message(prefix: String, _ items: Any..., separator: String) -> String {
        var message = prefix
        for item in items {
            message += separator
            message += "\(item)"
        }
        return message
    }
    
    @_transparent
    static func info(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let message = message(prefix: "[GateEngine]", items, separator: separator)
        Swift.print(message, terminator: terminator)
        #if os(Windows)
        WinSDK.OutputDebugStringW((message + terminator).windowsUTF16)
        #endif
    }
    
    @_transparent
    static func infoOnce(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let hash = items.compactMap({$0 as? AnyHashable}).hashValue
        if onceHashes.contains(hash) == false {
            onceHashes.insert(hash)
            Self.info(items, separator: separator, terminator: terminator)
        }
    }
    
    @_transparent
    static func debug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG
        self.info(items, separator: separator, terminator: terminator)
        #endif
    }
    
    @_transparent
    static func debugOnce(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG
        let hash = items.compactMap({$0 as? AnyHashable}).hashValue
        if onceHashes.contains(hash) == false {
            onceHashes.insert(hash)
            Self.debug(items, separator: separator, terminator: terminator)
        }
        #endif
    }
    
    @_transparent
    static func warn(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let resolvedMessage: String
        if supportsColor {
            resolvedMessage = message(prefix: "[GateEngine] warning:", items, separator: separator)
        }else{
            resolvedMessage = message(prefix: "[GateEngine] \(ANSIColors.magenta)warning\(ANSIColors.default):", items, separator: separator)
        }
        Swift.print(resolvedMessage, separator: separator, terminator: terminator)
        #if os(Windows)
        WinSDK.OutputDebugStringW((resolvedMessage + terminator).windowsUTF16)
        #endif
    }
    
    @_transparent
    static func warnOnce(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let hash = items.compactMap({$0 as? AnyHashable}).hashValue
        if onceHashes.contains(hash) == false {
            onceHashes.insert(hash)
            Self.warn(items, separator: separator, terminator: terminator)
        }
    }
    
    @_transparent
    static func error(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let resolvedMessage: String
        if supportsColor {
            resolvedMessage = self.message(prefix: "[GateEngine] \(ANSIColors.red)error\(ANSIColors.default):", items, separator: separator)
        }else{
            resolvedMessage = self.message(prefix: "[GateEngine] error:", items, separator: separator)
        }
        Swift.print(resolvedMessage, separator: separator, terminator: terminator)
        #if canImport(WinSDK)
        WinSDK.OutputDebugStringW((resolvedMessage + terminator).windowsUTF16)
        #endif
    }
    
    @_transparent
    static func errorOnce(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let hash = items.compactMap({$0 as? AnyHashable}).hashValue
        if onceHashes.contains(hash) == false {
            onceHashes.insert(hash)
            Self.error(items, separator: separator, terminator: terminator)
        }
    }
    
    @_transparent
    static func assert(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {
        #if DEBUG
        let condition = condition()
        guard condition else {return}

        let resolvedMessage: String
        if supportsColor {
            resolvedMessage = self.message(prefix: "[GateEngine] \(ANSIColors.red)error\(ANSIColors.default):", message(), separator: " ")
        }else{
            resolvedMessage = self.message(prefix: "[GateEngine] error:", message(), separator: " ")
        }
        #if canImport(WinSDK)
        WinSDK.OutputDebugStringW((resolvedMessage + "/n").windowsUTF16)
        #endif
        Swift.assert(condition, resolvedMessage, file: file, line: line)
        #endif
    }
    
    static func fatalError(_ message: String, file: StaticString = #file, line: UInt = #line) -> Never {
        let resolvedMessage: String
        if supportsColor {
            resolvedMessage = self.message(prefix: "[GateEngine] \(ANSIColors.red)error\(ANSIColors.default):", message, separator: " ")
        }else{
            resolvedMessage = self.message(prefix: "[GateEngine] error:", message, separator: " ")
        }
        #if canImport(WinSDK)
        WinSDK.OutputDebugStringW((resolvedMessage + "/n").windowsUTF16)
        #endif
        return Swift.fatalError(resolvedMessage, file: file, line: line)
    }
}
