/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if GATEENGINE_PLATFORM_HAS_FILESYSTEM && GATEENGINE_PLATFORM_HAS_SynchronousFileSystem

import Foundation

public protocol SynchronousFileSystem: Sendable {
    func itemExists(at path: String) -> Bool
    func itemType(at path: String) -> FileSystemItemType?

    func contentsOfDirectory(at path: String) throws -> [String]
    func createDirectory(at path: String) throws

    func deleteItem(at path: String) throws
    func moveItem(at originPath: String, to destinationPath: String) throws

    func read(from path: String) throws -> Data
    func write(_ data: Data, to path: String, options: FileSystemWriteOptions) throws

    func resolvePath(_ path: String) throws -> String
    func pathForSearchPath(
        _ searchPath: FileSystemSearchPath,
        in domain: FileSystemSearchPathDomain
    ) throws -> String
}

#if GATEENGINE_PLATFORM_SUPPORTS_FOUNDATION_FILEMANAGER
import Foundation

extension SynchronousFileSystem {
    public func itemExists(at path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    public func itemType(at path: String) -> FileSystemItemType? {
        var isDirectory: ObjCBool = ObjCBool(false)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        if exists {
            if isDirectory.boolValue {
                return .directory
            }
            return .file
        }
        return nil
    }

    public func contentsOfDirectory(at path: String) throws -> [String] {
        return try FileManager.default.contentsOfDirectory(atPath: path)
    }

    public func createDirectory(at path: String) throws {
        let url = URL(fileURLWithPath: path)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    public func deleteItem(at path: String) throws {
        try FileManager.default.removeItem(atPath: path)
    }

    public func moveItem(at originPath: String, to destinationPath: String) throws {
        try FileManager.default.moveItem(atPath: originPath, toPath: destinationPath)
    }

    public func read(from path: String) throws -> Data {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        return data
    }

    public func write(_ data: Data, to path: String, options: FileSystemWriteOptions = .default) throws {
        func writeData(to destinationPath: String) throws {
            try data.write(to: URL(fileURLWithPath: destinationPath), options: [])
        }
        func createDirectoryIfNeeded(at dirPath: String) throws {
            if itemExists(at: dirPath) == false {
                try createDirectory(at: dirPath)
            }
        }
        if options.contains(.createDirectories) {
            let dirPath = URL(fileURLWithPath: path).deletingLastPathComponent().path
            try createDirectoryIfNeeded(at: dirPath)
        }
        if options.contains(.atomically) {
            let tmpDir = URL(fileURLWithPath: try pathForSearchPath(.temporary, in: .currentUser))
            let tmpPath = tmpDir.appendingPathComponent(
                URL(fileURLWithPath: path).lastPathComponent
            ).path
            try createDirectoryIfNeeded(at: tmpDir.path)
            try writeData(to: tmpPath)
            try moveItem(at: tmpPath, to: path)
        } else {
            try writeData(to: path)
        }
    }

    public func resolvePath(_ path: String) throws -> String {
        var url = URL(fileURLWithPath: path)

        // Expand symlinks
        url.resolveSymlinksInPath()

        // Expand .. and remove .
        url.standardize()

        // Expand Tilde
        #if canImport(Foundation.NSString)
        url = URL(fileURLWithPath: (url.path as NSString).expandingTildeInPath)
        #endif

        return url.path
    }
}
#endif

#endif
