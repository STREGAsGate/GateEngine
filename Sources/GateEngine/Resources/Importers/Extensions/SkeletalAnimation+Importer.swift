/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

extension ResourceManager {
    public func addSkeletalAnimationImporter(_ type: any SkeletalAnimationImporter.Type) {
        guard importers.skeletalAnimationImporters.contains(where: { $0 == type }) == false else {
            return
        }
        importers.skeletalAnimationImporters.insert(type, at: 0)
    }

    fileprivate func importerForFile(_ file: URL) -> (any SkeletalAnimationImporter)? {
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

    func loadData(path: String, options: SkeletalAnimationImporterOptions) async throws -> SkeletalAnimation

    static func canProcessFile(_ file: URL) -> Bool
}

extension SkeletalAnimation {
    public convenience init(path: String, options: SkeletalAnimationImporterOptions = .none)
        async throws
    {
        let file = URL(fileURLWithPath: path)
        guard
            let importer: any SkeletalAnimationImporter = await Game.shared.resourceManager
                .importerForFile(file)
        else {
            throw GateEngineError.failedToLoad("No importer for \(file.pathExtension).")
        }

        do {
            let animation = try await importer.loadData(path: path, options: options)
            self.init(
                name: animation.name,
                duration: animation.duration,
                animations: animation.animations
            )
        } catch {
            throw GateEngineError(decodingError: error)
        }
    }
}
