/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import struct Foundation.Data

public protocol Platform {
    func locateResource(from path: String) async -> String?
    func loadResource(from path: String) async throws -> Data
}

@MainActor internal protocol InternalPlatform: Platform {
    func saveState(_ state: Game.State) throws
    func loadState() -> Game.State
    
    func systemTime() -> Double
    func main()
}

@_transparent
@MainActor func makeDefaultPlatform() -> InternalPlatform {
#if canImport(UIKit)
    return UIKitPlatform()
#elseif canImport(AppKit)
    return AppKitPlatform()
#elseif os(Windows)
    return Win32Platform()
#elseif os(Linux)
    return LinuxPlatform()
#elseif os(WASI)
    return WASIPlatform()
#elseif os(Android)
    return AndroidPlatform()
#else
    fatalError("The target platform is not supported.")
#endif
}
