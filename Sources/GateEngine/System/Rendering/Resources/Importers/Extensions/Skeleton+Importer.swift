/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

extension ResourceManager {
    public func addSkeletonImporter(_ type: SkeletonImporter.Type) {
        guard importers.skeletonImporters.contains(where: {$0 == type}) == false else {return}
        importers.skeletonImporters.insert(type, at: 0)
    }
    
    internal func importerForFile(_ file: URL) -> SkeletonImporter? {
        for type in self.importers.skeletonImporters {
            if type.canProcessFile(file) {
                return type.init()
            }
        }
        return nil
    }
}

public struct SkeletonImporterOptions: Equatable, Hashable {
    public var subobjectName: String? = nil

    public static func named(_ name: String) -> Self {
        return SkeletonImporterOptions(subobjectName: name)
    }

    public static var none: SkeletonImporterOptions {
        return SkeletonImporterOptions()
    }
}

public protocol SkeletonImporter: AnyObject {
    init()
    
    func loadData(path: String, options: SkeletonImporterOptions) async throws -> Data
    func process(data: Data, baseURL: URL, options: SkeletonImporterOptions) async throws -> Skeleton.Joint

    static func canProcessFile(_ file: URL) -> Bool
}

public extension SkeletonImporter {
    func loadData(path: String, options: SkeletonImporterOptions) async throws -> Data {
        return try await Game.shared.platform.loadResource(from: path)
    }
}

extension Skeleton {
    public convenience init(path: String, options: SkeletonImporterOptions = .none) async throws {
        let file = URL(fileURLWithPath: path)
        guard let importer = await Game.shared.resourceManager.importerForFile(file) else {
            throw "No importer for \(file.pathExtension)."
        }
        
        do {
            let data = try await importer.loadData(path: path, options: options)
            let rootJoint = try await importer.process(data: data, baseURL: URL(string: path)!.deletingLastPathComponent(), options: options)
            self.init(rootJoint: rootJoint)
        }catch let DecodingError.dataCorrupted(context) {
            throw "corrupt data (\(Swift.type(of: self)): \(context))"
        }catch let DecodingError.keyNotFound(key, context) {
            throw "key '\(key)' not found: \(context.debugDescription), codingPath: \(context.codingPath)"
        }catch let DecodingError.valueNotFound(value, context) {
            throw "value '\(value)' not found: \(context.debugDescription), codingPath: \(context.codingPath)"
        }catch let DecodingError.typeMismatch(type, context)  {
            throw "type '\(type)' mismatch: \(context.debugDescription), codingPath: \(context.codingPath)"
        }catch {
            throw "\(error)"
        }
    }
}
