/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation
import Gravity

internal func filenameCallback(
    fileID: UInt32,
    xData: UnsafeMutableRawPointer?
) -> UnsafePointer<CChar>? {
    guard let gravity = unsafeBitCast(xData, to: Optional<Gravity>.self) else { return nil }
    guard let fileName = gravity.filenameForID(fileID) else { return nil }
    return fileName.withCString { source in
        return UnsafePointer(strdup(source))
    }
}

internal func loadFileCallback(
    file: UnsafePointer<CChar>!,
    size: UnsafeMutablePointer<Int>!,
    fileID: UnsafeMutablePointer<UInt32>!,
    xData: UnsafeMutableRawPointer?,
    isStatic: UnsafeMutablePointer<Bool>!
) -> UnsafePointer<CChar>? {
    guard let cFile = file else { return nil }
    guard let gravity = unsafeBitCast(xData, to: Optional<Gravity>.self) else { return nil }
    let path = String(cString: cFile)
    guard let url = URL(string: path) else { return nil }

    if gravity.loadedFilesByID.values.contains(where: { $0 == url }) {
        Log.debug(
            "Gravity Skip File: \(gravity.filenameForID(0)!) ->",
            url.lastPathComponent,
            "(Already Loaded)"
        )
        // give a fileID. Will overwrite it the next load
        fileID.pointee = UInt32(gravity.loadedFilesByID.count + 1)
        return "".withCString { sourceCode in
            return UnsafePointer(strdup(sourceCode))
        }
    }

    guard let sourceCode = gravity.getSourceCode(forIncludedFile: url) else {
        return nil
    }

    let newFileID = UInt32(gravity.loadedFilesByID.count + 1)
    fileID.pointee = newFileID
    Log.debug("Gravity Load File: \(gravity.filenameForID(0)!) ->", url.lastPathComponent)
    gravity.loadedFilesByID[newFileID] = url
    size.pointee = sourceCode.count
    return sourceCode.withCString { sourceCode in
        #if os(Windows)
        return UnsafePointer(_strdup(sourceCode))
        #else
        return UnsafePointer(strdup(sourceCode))
        #endif
    }
}

extension Gravity {
    private func fileIncludesFromSource(_ source: String) -> Set<URL> {
        var imports = source.components(separatedBy: .newlines)
        imports = imports.filter({ $0.contains("#include") })
        imports = imports.compactMap({
            let trimSet = CharacterSet.whitespacesAndNewlines.union(.init(charactersIn: ";\"'"))
            return $0.components(separatedBy: .whitespaces).last?.trimmingCharacters(in: trimSet)
        })
        let urls = imports.compactMap({ URL(string: $0) })
        return Set(urls)
    }

    private func sourceCode(forFileIncludes includes: Set<URL>) async throws -> [URL: String] {
        return try await withThrowingTaskGroup(of: (url: URL, sourceCode: String).self) { group in
            for url in includes {
                group.addTask {
                    let data = try await Platform.current.loadResource(from: url.path)
                    guard let sourceCode = String(data: data, encoding: .utf8) else {
                        throw GateEngineError.failedToLoad(
                            "File is corrupt or in the wrong format."
                        )
                    }
                    return (url, sourceCode)
                }
            }

            var sources: [URL: String] = [:]
            sources.reserveCapacity(includes.count)

            for try await result in group {
                sources[result.url] = result.sourceCode
            }

            return sources
        }
    }

    private func cacheIncludes(fromSource sourceCode: String) async throws {
        let includes = self.fileIncludesFromSource(sourceCode).filter({
            return self.hasSourceCacheForInclude($0) == false
        })
        let sources = try await self.sourceCode(forFileIncludes: includes)
        self.appendIncludesCache(sources)
        for pair in sources {
            try await cacheIncludes(fromSource: pair.value)
        }
    }

    /**
     Compile a gravity script.
     - parameter sourceCode: The gravity script as a `String`.
     - parameter addDebug: `true` to add debug. nil to add debug only in DEBUG configurations.
     - throws: Gravity compilation errors such as syntax problems and file loading problems.
     */
    public func compile(file path: String, addDebug: Bool? = nil) async throws {
        let url = URL(fileURLWithPath: path)
        let baseURL = url.deletingLastPathComponent()
        let data = try await Platform.current.loadResource(from: path)
        guard let sourceCode = String(data: data, encoding: .utf8) else {
            throw GateEngineError.scriptCompileError("File corrupted or in the wrong format.")
        }

        try await cacheIncludes(fromSource: sourceCode)

        self.sourceCodeBaseURL = baseURL
        self.loadedFilesByID[0] = url
        try self.compile(source: sourceCode, addDebug: addDebug)
        self.clearFileIncludeSourceCode()
    }
}
