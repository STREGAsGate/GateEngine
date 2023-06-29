/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(WinSDK)

import Foundation
import FileSystem

public struct Win32FileSystem: FileSystem {
    public func itemExists(at url: URL) -> Bool {
        let dwAttrib: DWORD = GetFileAttributes(url.path)
        return dwAttrib != INVALID_FILE_ATTRIBUTES
    }
    
    public func createDirectory(at url: URL) throws {
        var subPaths: [String] = [url.path]
        var url = url
        while url.path.isEmpty == false {
            url.deleteLastPathComponent()
            subPaths.append(url.path)
        }
        subPaths = subPaths.reversed()
        for subPath in subPaths {
            if itemExists(at: URL(fileURLWithPath: subPath)) == false {
                if CreateDirectoryW(url.path, nil) == false {
                    return false
                }
            }
        }
        return true
    }
    
    func urlForFolderID(_ folderID: KNOWNFOLDERID) -> URL {
        var pwString: PWSTR! = nil
        _ = SHGetKnownFolderPath(&folderID, DWORD(KF_FLAG_DEFAULT.rawValue), nil, &pwString)
        let string: String = String(windowsUTF16: pwString)
        CoTaskMemFree(pwString)
        return URL(fileURLWithPath: string).appendingPathComponent(Game.shared.identifier)
    }
    
    public func urlForSearchPath(_ searchPath: FileSystemSearchPath, in domain: FileSystemSearchPathDomain) throws -> URL {
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
#endif
