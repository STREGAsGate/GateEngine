/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(WinSDK)

import WinSDK
import Foundation

public final class Win32Platform: InternalPlatform {
    static let staticSearchPaths: [URL] = getStaticSearchPaths()
    var pathCache: [String:String] = [:]
    
    public var supportsMultipleWindows: Bool {
        return true
    }
    
    public func locateResource(from path: String) async -> String? {
        if let existing = pathCache[path] {
            return existing
        }
        let searchPaths = Game.shared.delegate.resourceSearchPaths() + Self.staticSearchPaths
        for searchPath in searchPaths {
            let file = searchPath.appendingPathComponent(path)
            let path = file.path
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        return nil
    }
    
    public func loadResource(from path: String) async throws -> Data {
        if let path = await locateResource(from: path) {
            do {
                let url: URL = URL(fileURLWithPath: path)
                return try Data(contentsOf: url, options: .mappedIfSafe)
            }catch{
                Log.error("Failed to load resource \"\(path)\".")
                throw error
            }
        }
        throw "failed to locate."
    }

    func urlForSearchPath(_ searchPath: FileSystemSearchPath, in domain: FileSystemSearchPathDomain) throws -> URL {
        func urlForFolderID(_ folderID: KNOWNFOLDERID) -> URL {
            var pwString: PWSTR! = nil
            _ = SHGetKnownFolderPath(&folderID, DWORD(KF_FLAG_DEFAULT.rawValue), nil, &pwString)
            let string: String = String(windowsUTF16: pwString)
            CoTaskMemFree(pwString)
            return URL(fileURLWithPath: string).appendingPathComponent(Game.shared.identifier)
        }
        
        func fileExists(at url: URL, asDirectory: Bool) -> Bool {
            let dwAttrib: DWORD = GetFileAttributes(url.path)
            guard dwAttrib != INVALID_FILE_ATTRIBUTES else {return false}
            if asDirectory {
                return (dwAttrib & FILE_ATTRIBUTE_DIRECTORY) != 0
            }
            return true
        }
        
        func createDirectory(at url: URL) -> Bool {
            var subPaths: [String] = [url.path]
            var url = url
            while url.path.isEmpty == false {
                url.deleteLastPathComponent()
                subPaths.append(url.path)
            }
            subPaths = subPaths.reversed()
            for subPath in subPaths {
                if fileExists(at: URL(fileURLWithPath: subPath), asDirectory: true) == false {
                    if CreateDirectoryW(url.path, nil) == false {
                        return false
                    }
                }
            }
            return true
        }
        
        let url: URL
        switch searchPath {
        case .persistant:
            switch domain {
            case .currentUser:
                url = urlForFolderID(FOLDERID_ProgramData)
            case .shared:
                url = urlForFolderID(FOLDERID_LocalAppData)
            }
        case .cache:
            switch domain {
            case .currentUser:
                url = urlForFolderID(FOLDERID_ProgramData).appendingPathComponent("Cache")
            case .shared:
                url = urlForFolderID(FOLDERID_LocalAppData).appendingPathComponent("Cache")
            }
        case .temporary:
            GetTempPathW
        }
        
        if fileExists(at: url, asDirectory: true) == false {
            if createDirectory(at: url) == false {
                throw "Failed to create directory."
            }
        }
        return url
    }
}

internal extension Win32Platform {
    private func _queryRegistry(forKey path: String, dataSize: Int) -> (data: [UInt8], size: DWORD, type: DWORD)? {
        var components: [String] = path.components(separatedBy: "\\")
        let _hkey = components.removeFirst()
        let key = components.removeLast()
        let subKey = components.joined(separator: "\\") + "\\"
        let hKey: HKEY
        switch _hkey {
        case "HKEY_CURRENT_USER":
            hKey = HKEY_CURRENT_USER
        default:
            return nil
        }

        var resultType: DWORD = 0
        var resultData: [UInt8] = Array(repeating: 0, count: dataSize)
        var resultSize: DWORD = DWORD(resultData.count)
        let nError: LSTATUS = WinSDK.RegGetValueW(hKey, subKey.windowsUTF16, key.windowsUTF16, DWORD(RRF_RT_ANY), &resultType, &resultData, &resultSize)
        if nError != ERROR_SUCCESS {
            switch nError {
            case ERROR_MORE_DATA:
                Log.error("Failed to allocate space for registry result.")
            case ERROR_FILE_NOT_FOUND:
                Log.errorOnce("Registry sub key not found:", "HKEY_CURRENT_USER\\\(key)")
            case ERROR_INVALID_PARAMETER:
                Log.error("Key permissions are wrong.")
            case ERROR_BAD_PATHNAME:
                Log.errorOnce("Registry sub key path is invalid:", key)
            default:
                Log.error("Unknown registry lookup error:", nError)
            }
            return nil
        }
        return (resultData, resultSize, resultType)
    }

    func queryRegistry(forKey path: String) -> Int? {
        guard let result = _queryRegistry(forKey: path, dataSize: MemoryLayout<Int>.size) else {return nil}
        return result.data.withUnsafeBytes{ resultData in
            switch result.type {
            case REG_DWORD, REG_DWORD_LITTLE_ENDIAN:
                return Int(littleEndian: Int(resultData.loadUnaligned(as: Int32.self)))
            case REG_DWORD_BIG_ENDIAN:
                return Int(bigEndian: Int(resultData.loadUnaligned(as: Int32.self)))
            case REG_QWORD, REG_QWORD_LITTLE_ENDIAN:
                return Int(littleEndian: Int(resultData.loadUnaligned(as: Int64.self)))
            default:
                Log.errorOnce("Registry sub key has incorrect type:", result.type)
                return nil
            }
        }
    }
    @_transparent
    func queryRegistry(forKey key: String) -> Bool {
        if let value: Int = queryRegistry(forKey: key) {
            return value != 0
        }
        return false
    }
    func queryRegistry(forKey path: String) -> String? {
        guard let result = _queryRegistry(forKey: path, dataSize: 255) else {return nil}
        return result.data.withUnsafeBytes{ data in
            switch result.type {
            case REG_SZ:
                return String(windowsUTF16: data.baseAddress!.assumingMemoryBound(to: WCHAR.self))
            case REG_EXPAND_SZ:
                let stringIn: UnsafePointer<WCHAR> = data.baseAddress!.assumingMemoryBound(to: WCHAR.self)
                let stringOut: UnsafeMutablePointer<WCHAR>! = nil
                let result = ExpandEnvironmentStringsW(stringIn, stringOut, result.size)
                if result != ERROR_SUCCESS {
                    return nil
                }
                return String(windowsUTF16: stringOut)
            default:
                return nil
            }
        }
    }
}

extension Win32Platform {
    private func makeManifest() {
        var url = URL(fileURLWithPath: CommandLine.arguments[0])
        let manifest: String = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0" xmlns:asmv3="urn:schemas-microsoft-com:asm.v3">
            <asmv3:application>
                <asmv3:windowsSettings>
                <dpiAware xmlns="http://schemas.microsoft.com/SMI/2005/WindowsSettings">true</dpiAware>
                <dpiAwareness xmlns="http://schemas.microsoft.com/SMI/2016/WindowsSettings">PerMonitorV2</dpiAwareness>
                </asmv3:windowsSettings>
            </asmv3:application>
            </assembly>
        """
        let name: String = url.lastPathComponent + ".manifest"
        url.deleteLastPathComponent()
        url.appendPathComponent(name)
        do {
            if FileManager.default.fileExists(atPath: url.path) == false {
                try manifest.write(to: url, atomically: false, encoding: .utf8)
            }
        }catch{
            Log.error("Failed to create manifest: \(name)\n", error)
        }
    }
    @MainActor func main() {
        SetProcessDpiAwareness(PROCESS_PER_MONITOR_DPI_AWARE)
        SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2)

        var msg: MSG = MSG()
        var nExitCode: Int32 = EXIT_SUCCESS

        Game.shared.didFinishLaunching()
        
        mainLoop: while true {
            if Game.shared.windowManager.windows.isEmpty {
                WinSDK.PostQuitMessage(WinSDK.EXIT_SUCCESS)
            }
            // Process all messages in thread's message queue; for GUI applications UI
            // events must have high priority.
            for window: Window in Game.shared.windowManager.windows {
                window.vSyncCalled()
            }

            while PeekMessageW(&msg, nil, 0, 0, UINT(PM_REMOVE)) {
                if msg.message == UINT(WM_QUIT) {
                    nExitCode = Int32(msg.wParam)
                    break mainLoop
                }

                TranslateMessage(&msg)
                DispatchMessageW(&msg)
            }

            var time: Date? = nil
            repeat {
                // Execute Foundation.RunLoop once and determine the next time the timer
                // fires.  At this point handle all Foundation.RunLoop timers, sources and
                // Dispatch.DispatchQueue.main tasks
                time = RunLoop.main.limitDate(forMode: .default)

                // If Foundation.RunLoop doesn't contain any timers or the timers should
                // not be running right now, we interrupt the current loop or otherwise
                // continue to the next iteration.
            } while (time?.timeIntervalSinceNow ?? -1) <= 0

            // Yield control to the system until the earlier of a requisite timer
            // expiration or a message is posted to the runloop.
            if let time: Date = time, let exactly: UInt32 = DWORD(exactly: time.timeIntervalSinceNow) {
                _ = MsgWaitForMultipleObjects(0, nil, false,
                                            exactly,
                                            DWORD(QS_ALLINPUT) | DWORD(QS_KEY) | DWORD(QS_MOUSE) | DWORD(QS_RAWINPUT))
            }
        }

        Game.shared.willTerminate()
        exit(nExitCode)
    }
}

#endif
