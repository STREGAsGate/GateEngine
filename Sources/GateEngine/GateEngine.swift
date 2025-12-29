/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

@_exported public import GateUtilities
@_exported public import GameMath

@_exported public import Collections

@_exported import struct Foundation.Data
@_exported import struct Foundation.Date
@_exported import struct Foundation.URL

@attached(member, names: named(phase), named(macroPhase))
public macro System(_ macroPhase: GateEngine.System.Phase) = #externalMacro(module: "ECSMacros", type: "ECSSystemMacro")

@attached(member, names: named(phase), named(macroPhase))
public macro RenderingSystem(drawing macroPhase: GateEngine.RenderingSystem.Phase) = #externalMacro(module: "ECSMacros", type: "ECSRenderingSystemMacro")

@attached(extension, conformances: Component, names: named(componentID), named(init))
public macro Component() = #externalMacro(module: "ECSMacros", type: "ECSComponentMacro")

#if canImport(WinSDK)
import WinSDK
#endif

#if HTML5
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

#if os(visionOS)
#error("visionOS is not a supported platform.")
#endif

#if os(Android)
#error("Android is not currently supported, but is planned.")
#endif

extension Color {
    internal static let stregasgateBackground: Color = #colorLiteral(red: 0.094117634,green: 0.0941176638,blue: 0.094117634,alpha: 1)
}

public enum GateEngineError: Error, Equatable, Hashable, CustomStringConvertible {
    /// An error to represent any kind of error
    case custom(category: String, message: String)
    
    case failedToLocate(resource: String, _ reason: String?)
    case failedToLoad(resource: String, _ reason: String?)
    case failedToDecode(_ reason: String)
    case failedToEncode(_ reason: String)
    
    case scriptCompileError(_ reason: String)
    case scriptCompileOutputError(_ gravityError: Gravity.Error)
    case scriptExecutionError(_ reason: String)

    case uiLayoutFailed(_ description: String)

    case failedToCreateWindow(_ reason: String)

    public var description: String {
        switch self {
        case .custom(let category, let message):
            return "\(category):\n\t" + message.replacingOccurrences(of: "\n", with: "\n\t")
            
        case .failedToLocate(let resource, let reason):
            var error = "FailedToLocate: \(resource)"
            if let reason {
                error += "\n\t" + reason.replacingOccurrences(of: "\n", with: "\n\t")
            }
            return error
        case .failedToLoad(let resource, let reason):
            var error = "FailedToLoad: \(resource)"
            if let reason {
                error += "\n\t" + reason.replacingOccurrences(of: "\n", with: "\n\t")
            }
            return error
        case .failedToDecode(let reason):
            return "FailedToDecode:\n\t" + reason.replacingOccurrences(of: "\n", with: "\n\t")
        case .failedToEncode(let reason):
            return "FailedToEncode:\n\t" + reason.replacingOccurrences(of: "\n", with: "\n\t")
        case .scriptCompileError(let reason):
            return "ScriptCompileError:\n\t" + reason.replacingOccurrences(of: "\n", with: "\n\t")
        case .scriptCompileOutputError(let gravityError):
            return "ScriptCompileError:\n\t" + gravityError.stderrOutput()
        case .scriptExecutionError(let reason):
            return "ScriptExecutionError:\n\t" + reason.replacingOccurrences(of: "\n", with: "\n\t")
        case .uiLayoutFailed(let reason):
            return "UILayoutFailed:\n\t" + reason.replacingOccurrences(of: "\n", with: "\n\t")
        case .failedToCreateWindow(let reason):
            return "FailedToCreateWindow:\n\t" + reason.replacingOccurrences(of: "\n", with: "\n\t")
        }
    }
    
    public init(_ error: some Swift.Error) {
        switch error {
        case let error as GateEngineError:
            self = error
        case let error as DecodingError:
            self.init(error)
        case let error as NSError:
            self = .failedToDecode(error.localizedDescription)
        default:
            self = .failedToDecode("\(error)")
        }
    }

    public init(_ error: DecodingError) {
        switch error {
        case let DecodingError.dataCorrupted(context):
            self = GateEngineError.failedToDecode(
                "corrupt data (\(Swift.type(of: self)): \(context))"
            )
        case let DecodingError.keyNotFound(key, context):
            self = GateEngineError.failedToDecode(
                "key '\(key)' not found: \(context.debugDescription), codingPath: \(context.codingPath)"
            )
        case let DecodingError.valueNotFound(value, context):
            self = GateEngineError.failedToDecode(
                "value '\(value)' not found: \(context.debugDescription), codingPath: \(context.codingPath)"
            )
        case let DecodingError.typeMismatch(type, context):
            self = GateEngineError.failedToDecode(
                "type '\(type)' mismatch: \(context.debugDescription), codingPath: \(context.codingPath)"
            )
        default:
            self = GateEngineError.failedToDecode("\(error)")
        }
    }
}

extension GateEngineError: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = .custom(category: "error", message: value)
    }
}

extension CommandLine {
    @usableFromInline
    static let isDebuggingWithXcode: Bool = {
        #if canImport(Darwin) || os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
        let environment = ProcessInfo.processInfo.environment
        if environment.keys.contains(where: {$0.lowercased().contains("xcode.app")}) {
            return true
        }
        if environment.values.contains(where: {$0.lowercased().contains("xcode.app")}) {
            return true
        }
        #endif
        return false
    }()
}

@usableFromInline
internal enum Log {
    @usableFromInline
    nonisolated(unsafe) static var onceHashes: Set<Int> = []

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

    @inlinable
    static var supportsANSIColor: Bool {
        if CommandLine.isDebuggingWithXcode {
            return false
        }
        #if os(WASI) || os(Windows)
        return false
        #else
        return true
        #endif
    }

    @usableFromInline
    internal static func _message(prefix: String, _ items: Any..., separator: String) -> String {
        var message = prefix
        for item in items {
            message += separator
            message += "\(item)"
        }
        return message
    }

    @usableFromInline
    static func info(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if !DISTRIBUTE
        let message = _message(prefix: "[GateEngine]", items, separator: separator)

        #if HTML5
        console.info(data: .string(message))
        #else
        Swift.print(message, terminator: terminator)
        #if os(Windows)
        WinSDK.OutputDebugStringW((message + terminator).windowsUTF16)
        #endif
        #endif
        #endif
    }

    @usableFromInline
    static func infoOnce(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if !DISTRIBUTE
        let hash = items.compactMap({ $0 as? AnyHashable }).hashValue
        if onceHashes.contains(hash) == false {
            onceHashes.insert(hash)
            Self.info(items, separator: separator, terminator: terminator)
        }
        #endif
    }

    @usableFromInline
    static func debug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG || !DISTRIBUTE
        #if HTML5
        let message = _message(prefix: "[GateEngine]", items, separator: separator)
        console.debug(data: .string(message))
        #else
        self.info(items, separator: separator, terminator: terminator)
        #endif
        #endif
    }

    @usableFromInline
    static func debugOnce(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG || !DISTRIBUTE
        let hash = items.compactMap({ $0 as? AnyHashable }).hashValue
        if onceHashes.contains(hash) == false {
            onceHashes.insert(hash)
            Self.debug(items, separator: separator, terminator: terminator)
        }
        #endif
    }

    @usableFromInline
    static func warn(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG || !DISTRIBUTE
        let resolvedMessage: String
        if supportsANSIColor {
            resolvedMessage = _message(
                prefix: "[GateEngine] \(ANSIColors.magenta)warning\(ANSIColors.default):",
                items,
                separator: separator
            )
        } else {
            resolvedMessage = _message(prefix: "[GateEngine] warning:", items, separator: separator)
        }
        #if HTML5
        console.warn(data: .string(resolvedMessage))
        #else

        #if os(Windows)
        WinSDK.OutputDebugStringW((resolvedMessage + terminator).windowsUTF16)
        #endif

        Swift.print(resolvedMessage, separator: separator, terminator: terminator)
        #endif
        #endif
    }

    @usableFromInline
    static func warnOnce(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG || !DISTRIBUTE
        let hash = items.compactMap({ $0 as? AnyHashable }).hashValue
        if onceHashes.contains(hash) == false {
            onceHashes.insert(hash)
            Self.warn(items, separator: separator, terminator: terminator)
        }
        #endif
    }

    @usableFromInline
    static func error(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG || !DISTRIBUTE
        let resolvedMessage: String
        if supportsANSIColor {
            resolvedMessage = self._message(
                prefix: "[GateEngine] \(ANSIColors.red)error\(ANSIColors.default):",
                items,
                separator: separator
            )
        } else {
            resolvedMessage = self._message(
                prefix: "[GateEngine] error:",
                items,
                separator: separator
            )
        }
        #if HTML5
        console.error(data: .string(resolvedMessage))
        #else

        #if canImport(WinSDK)
        WinSDK.OutputDebugStringW((resolvedMessage + terminator).windowsUTF16)
        #endif

        Swift.print(resolvedMessage, separator: separator, terminator: terminator)
        #endif
        #endif
    }

    @usableFromInline
    static func errorOnce(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG || !DISTRIBUTE
        let hash = items.compactMap({ $0 as? AnyHashable }).hashValue
        if onceHashes.contains(hash) == false {
            onceHashes.insert(hash)
            Self.error(items, separator: separator, terminator: terminator)
        }
        #endif
    }

    @_transparent // Must be transparent to function similar to a Swift.assert
    @usableFromInline
    static func assert(
        _ condition: @autoclosure () -> Bool,
        _ message: @autoclosure () -> String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        #if DEBUG
        let condition = condition()
        guard condition == false else { return }

        let resolvedMessage: String
        if supportsANSIColor {
            resolvedMessage = self._message(
                prefix: "[GateEngine] \(ANSIColors.red)error\(ANSIColors.default):",
                message(),
                separator: " "
            )
        } else {
            resolvedMessage = self._message(
                prefix: "[GateEngine] error:",
                message(),
                separator: " "
            )
        }

        #if canImport(WinSDK)
        WinSDK.OutputDebugStringW((resolvedMessage + "/n").windowsUTF16)
        #endif

        #if HTML5
        console.assert(condition: condition, data: .string(resolvedMessage))
        #endif

        Swift.assert(condition, resolvedMessage, file: file, line: line)
        #endif
    }

    @usableFromInline
    static func fatalError(_ message: String, file: StaticString = #file, line: UInt = #line) -> Never {
        #if DEBUG || !DISTRIBUTE
        let resolvedMessage: String
        if supportsANSIColor {
            resolvedMessage = self._message(
                prefix: "[GateEngine] \(ANSIColors.red)error\(ANSIColors.default):",
                message,
                separator: " "
            )
        } else {
            resolvedMessage = self._message(prefix: "[GateEngine] error:", message, separator: " ")
        }

        #if canImport(WinSDK)
        WinSDK.OutputDebugStringW((resolvedMessage + "/n").windowsUTF16)
        #endif

        #if HTML5
        console.assert(condition: false, data: .string(resolvedMessage))
        #endif

        return Swift.fatalError(resolvedMessage, file: file, line: line)
        #else
        return Swift.fatalError(message, file: file, line: line)
        #endif
    }
}

package func name<T>(of type: T.Type) -> String {
    let description = String(describing: type)
    if let name = description.split(separator: ".").last {
        return String(name)
    }
    return description
}
