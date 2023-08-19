/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

extension ResourceManager {
    public func addSkinImporter(_ type: any SkinImporter.Type) {
        guard importers.skinImporters.contains(where: { $0 == type }) == false else { return }
        importers.skinImporters.insert(type, at: 0)
    }

    fileprivate func importerForFile(_ file: URL) -> (any SkinImporter)? {
        for type in self.importers.skinImporters {
            if type.canProcessFile(file) {
                return type.init()
            }
        }
        return nil
    }
}

public struct SkinImporterOptions: Equatable, Hashable {
    public var subobjectName: String? = nil

    public static func named(_ name: String) -> Self {
        return SkinImporterOptions(subobjectName: name)
    }

    public static var none: SkinImporterOptions {
        return SkinImporterOptions()
    }
}

public protocol SkinImporter: AnyObject {
    init()

    func loadData(path: String, options: SkinImporterOptions) async throws -> Skin

    static func canProcessFile(_ file: URL) -> Bool
}

extension Skin {
    public init(path: String, options: SkinImporterOptions = .none) async throws {
        let file = URL(fileURLWithPath: path)
        guard
            let importer: any SkinImporter = await Game.shared.resourceManager.importerForFile(file)
        else {
            throw GateEngineError.failedToLoad("No importer for \(file.pathExtension).")
        }

        do {
            self = try await importer.loadData(path: path, options: options)
        } catch {
            throw GateEngineError(decodingError: error)
        }
    }
}
