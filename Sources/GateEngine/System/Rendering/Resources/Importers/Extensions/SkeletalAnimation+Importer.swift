/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

extension ResourceManager {
    public func addSkeletalAnimationImporter(_ type: SkeletalAnimationImporter.Type) {
        guard importers.skeletalAnimationImporters.contains(where: {$0 == type}) == false else {return}
        importers.skeletalAnimationImporters.insert(type, at: 0)
    }
    
    fileprivate func importerForFile(_ file: URL) -> SkeletalAnimationImporter? {
        for type in self.importers.skeletalAnimationImporters {
            if type.canProcessFile(file) {
                return type.init()
            }
        }
        return nil
    }
}

public struct SkeletalAnimationImporterOptions: Equatable, Hashable {
    public var subobjectName: String? = nil

    public static func named(_ name: String) -> Self {
        return SkeletalAnimationImporterOptions(subobjectName: name)
    }

    public static var none: SkeletalAnimationImporterOptions {
        return SkeletalAnimationImporterOptions()
    }
}

public protocol SkeletalAnimationImporter: AnyObject {
    init()

    func loadData(path: String, options: SkeletalAnimationImporterOptions) async throws -> Data
    func process(data: Data, baseURL: URL, options: SkeletalAnimationImporterOptions) async throws -> SkeletalAnimation

    static func canProcessFile(_ file: URL) -> Bool
}

public extension SkeletalAnimationImporter {
    func loadData(path: String, options: SkeletalAnimationImporterOptions) async throws -> Data {
        return try await Game.shared.platform.loadResource(from: path)
    }
}

extension SkeletalAnimation {
    public convenience init(path: String, options: SkeletalAnimationImporterOptions = .none) async throws {
        let file = URL(fileURLWithPath: path)
        guard let importer: SkeletalAnimationImporter = await Game.shared.resourceManager.importerForFile(file) else {
            throw GateEngineError.failedToLoad("No importer for \(file.pathExtension).")
        }
        
        do {
            let data = try await importer.loadData(path: path, options: options)
            let animation = try await importer.process(data: data, baseURL: URL(string: path)!.deletingLastPathComponent(), options: options)
            self.init(name: animation.name, duration: animation.duration, animations: animation.animations)
        }catch {
            throw GateEngineError(decodingError: error)
        }
    }
}
