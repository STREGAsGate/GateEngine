/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

extension ResourceManager {
    public func addTextureImporter(_ type: any TextureImporter.Type, atEnd: Bool = false) {
        guard importers.textureImporters.contains(where: {$0 == type}) == false else {return}
        if atEnd {
            importers.textureImporters.append(type)
        }else{
            importers.textureImporters.insert(type, at: 0)
        }
    }
    
    internal func textureImporterForFile(_ file: URL) -> (any TextureImporter)? {
        for type in self.importers.textureImporters {
            if type.canProcessFile(file) {
                return type.init()
            }
        }
        return nil
    }
}

public struct TextureImporterOptions: Equatable, Hashable {
    public var subobjectName: String? = nil
    public var option1: Bool = false
    
    public static func with(name: String? = nil, option1: Bool = false) -> Self {
        return TextureImporterOptions(subobjectName: name, option1: option1)
    }
    
    public static var option1: TextureImporterOptions {
        return TextureImporterOptions(subobjectName: nil, option1: true)
    }
    
    public static func named(_ name: String) -> Self {
        return TextureImporterOptions(subobjectName: name)
    }

    public static var none: TextureImporterOptions {
        return TextureImporterOptions()
    }
}

public protocol TextureImporter: AnyObject {
    init()
    
    func loadData(path: String, options: TextureImporterOptions) async throws -> (data: Data, size: Size2?)

    func process(data: Data, size: Size2?, options: TextureImporterOptions) throws -> (data: Data, size: Size2)

    static func canProcessFile(_ file: URL) -> Bool
}

public extension TextureImporter {
    func loadData(path: String, options: TextureImporterOptions) async throws -> (data: Data, size: Size2?) {
        return (try await Game.shared.platform.loadResource(from: path), nil)
    }
}
