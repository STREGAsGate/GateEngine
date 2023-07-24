/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if canImport(Foundation) && !os(WASI)
import struct Foundation.URL
import GravityC

internal func filenameCallback(fileID: UInt32, xData: UnsafeMutableRawPointer?) -> UnsafePointer<CChar>? {
    guard let gravity = unsafeBitCast(xData, to: Optional<Gravity>.self) else {return nil}
    guard let fileName = gravity.filenameForID(fileID) else {return nil}
    return fileName.withCString { source in
        return UnsafePointer(strdup(source))
    }
}

internal func loadFileCallback(file: UnsafePointer<CChar>!, size: UnsafeMutablePointer<Int>!, fileID: UnsafeMutablePointer<UInt32>!, xData: UnsafeMutableRawPointer?, isStatic: UnsafeMutablePointer<Bool>!) -> UnsafePointer<CChar>? {
    guard let cFile = file else {return nil}
    guard let gravity = unsafeBitCast(xData, to: Optional<Gravity>.self) else {return nil}
    
    let file = String(cString: cFile)
    guard let url: URL = {
        for baseURL in gravity.sourceCodeSearchPaths {
            let url = baseURL.appendingPathComponent(file).resolvingSymlinksInPath()
            if GravityC.file_exists(url.path) {
                return url
            }
        }
        return nil
    }() else {return nil}
    
    if gravity.loadedFilesByID.values.contains(where: {$0 == url}) {
        print("Gravity Skip File: \(gravity.filenameForID(0)!) ->", url.lastPathComponent, "(Already Loaded)")
        // give a fileID. Will overwrite it the next load
        fileID.pointee = UInt32(gravity.loadedFilesByID.count + 1)
        return "".withCString { sourceCode in
            return UnsafePointer(strdup(sourceCode))
        }
    }
    
    let sourceCode: String = url.path.withCString { cString in
        guard let sourceC = GravityC.file_read(cString, nil) else {return ""}
        return String(cString: sourceC)
    }

    size.pointee = sourceCode.count
    
    let newFileID = UInt32(gravity.loadedFilesByID.count + 1)
    fileID.pointee = newFileID
    print("Gravity Load File: \(gravity.filenameForID(0)!) ->", url.lastPathComponent)
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
    func compile(_ source: URL, addDebug: Bool? = nil) throws {
//        loadedFilesByID.removeAll(keepingCapacity: true)
        
        let sourceCode: String = source.path.withCString { cString in
            guard let sourceC = GravityC.file_read(cString, nil) else {return ""}
            return String(cString: sourceC)
        }
        self.sourceCodeBaseURL = source.deletingLastPathComponent()
        self.loadedFilesByID[0] = source
        try self.compile(sourceCode, addDebug: addDebug)
    }
}

#endif
