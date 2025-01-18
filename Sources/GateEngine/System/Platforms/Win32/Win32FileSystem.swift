/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(WinSDK)
import Foundation
import WinSDK

public struct Win32FileSystem: FileSystem {
    @MainActor
    func urlForFolderID(_ folderID: KNOWNFOLDERID) -> URL {
        var folderID: KNOWNFOLDERID = folderID
        var pwString: PWSTR! = nil
        _ = SHGetKnownFolderPath(&folderID, DWORD(KF_FLAG_DEFAULT.rawValue), nil, &pwString)
        let string: String = String(windowsUTF16: pwString)
        CoTaskMemFree(pwString)
        return URL(fileURLWithPath: string).appendingPathComponent(Game.shared.identifier)
    }

    @MainActor
    public func pathForSearchPath(
        _ searchPath: FileSystemSearchPath,
        in domain: FileSystemSearchPathDomain
    ) throws -> String {
        switch searchPath {
        case .persistent:
            switch domain {
            case .currentUser:
                return urlForFolderID(FOLDERID_ProgramData).path
            case .shared:
                return urlForFolderID(FOLDERID_LocalAppData).path
            }
        case .cache:
            switch domain {
            case .currentUser:
                return urlForFolderID(FOLDERID_ProgramData).appendingPathComponent("Cache").path
            case .shared:
                return urlForFolderID(FOLDERID_LocalAppData).appendingPathComponent("Cache").path
            }
        case .temporary:
            let length: DWORD = 128
            var buffer: [UInt16] = Array(repeating: 0, count: Int(length))
            _ = GetTempPathW(length, &buffer)
            return String(windowsUTF16: buffer)
        }
    }
}
#endif
