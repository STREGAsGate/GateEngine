/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if canImport(Foundation) && !os(WASI)
import struct Foundation.URL
import Gravity

internal func filenameCallback(fileID: UInt32, xData: UnsafeMutableRawPointer?) -> UnsafePointer<CChar>? {
    guard let gravity = unsafeBitCast(xData, to: Optional<Gravity>.self) else {return nil}
    guard let fileName = gravity.filenameForID(fileID) else {return nil}
    return fileName.withCString { source in
        return UnsafePointer(strdup(source))
    }
}

@MainActor @preconcurrency internal func loadFileCallback(file: UnsafePointer<CChar>!, size: UnsafeMutablePointer<Int>!, fileID: UnsafeMutablePointer<UInt32>!, xData: UnsafeMutableRawPointer?, isStatic: UnsafeMutablePointer<Bool>!) -> UnsafePointer<CChar>? {
    guard let cFile = file else {return nil}
    guard let gravity = unsafeBitCast(xData, to: Optional<Gravity>.self) else {return nil}
    let path = String(cString: cFile)
    let url = URL(fileURLWithPath: path)
    
    if gravity.loadedFilesByID.values.contains(where: {$0 == url}) {
        Log.debug("Gravity Skip File: \(gravity.filenameForID(0)!) ->", url.lastPathComponent, "(Already Loaded)")
        // give a fileID. Will overwrite it the next load
        fileID.pointee = UInt32(gravity.loadedFilesByID.count + 1)
        return "".withCString { sourceCode in
            return UnsafePointer(strdup(sourceCode))
        }
    }
    
    guard let sourceCode: String = {
        for baseURL in gravity.sourceCodeSearchPaths {
            let url = baseURL.appendingPathComponent(path).resolvingSymlinksInPath()
            if let data: Data = Game.sync({try? await Game.shared.platform.loadResource(from: url.path)}) {
                return String(data: data, encoding: .utf8)
            }
        }
        return nil
    }() else {return nil}

    size.pointee = sourceCode.count
    
    let newFileID = UInt32(gravity.loadedFilesByID.count + 1)
    fileID.pointee = newFileID
    Log.debug("Gravity Load File: \(gravity.filenameForID(0)!) ->", url.lastPathComponent)
    gravity.loadedFilesByID[newFileID] = url
    gravity.sourceCodeSearchPaths.insert(url.deletingLastPathComponent())
    return sourceCode.withCString { sourceCode in
        return UnsafePointer(strdup(sourceCode))
    }
}

public extension Gravity {
    /**
     Compile a gravity script.
     - parameter sourceCode: The gravity script as a `String`.
     - parameter addDebug: `true` to add debug. nil to add debug only in DEBUG configurations.
     - throws: Gravity compilation errors such as syntax problems and file loading problems.
     */
    func compile(file path: String, addDebug: Bool? = nil) async throws {
        let url =  URL(fileURLWithPath: path)
        let data = try await Game.shared.platform.loadResource(from: path)
        guard let sourceCode = String(data: data, encoding: .utf8) else {throw "File corrupted or in the wrong format."}
        self.sourceCodeBaseURL = url.deletingLastPathComponent()
        self.loadedFilesByID[0] = url
        try self.compile(source: sourceCode, addDebug: addDebug)
    }
}

#endif
