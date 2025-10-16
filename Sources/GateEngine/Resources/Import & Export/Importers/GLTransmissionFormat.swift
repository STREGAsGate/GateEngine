/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import class Foundation.JSONDecoder

extension GLTF {
    enum ComponentType: Int, Decodable {
        case int8 = 5120
        case int16 = 5122
        case uint8 = 5121
        case uint16 = 5123
        case uint32 = 5125
        case float32 = 5126
    }
    enum `Type`: String, Decodable {
        case scalar = "SCALAR"
        case vec2 = "VEC2"
        case vec3 = "VEC3"
        case vec4 = "VEC4"
        case mat2 = "MAT2"
        case mat3 = "MAT3"
        case mat4 = "MAT4"
    }
}
private class GLTF: Decodable {
    var baseURL: URL? = nil

    let scene: Int
    let scenes: [Scene]
    struct Scene: Decodable {
        let name: String
        let nodes: [Int]?
    }

    let nodes: [Node]
    struct Node: Decodable {
        let name: String
        let children: [Int]?
        let mesh: Int?
        let skin: Int?
        let skeleton: Int?
        let rotation: [Float]?
        let scale: [Float]?
        let translation: [Float]?

        var gameMathPosition: Position3? {
            if let array: [Float] = self.translation, array.count == 3 {
                return Position3(array)
            }
            return nil
        }
        var gameMathRotation: Quaternion? {
            if let array: [Float] = self.rotation, array.count == 4 {
                return Quaternion(x: array[0], y: array[1], z: array[2], w: array[3])
            }
            return nil
        }
        var gameMathScale: Size3? {
            if let array: [Float] = self.scale, array.count == 3 {
                return Size3(array)
            }
            return nil
        }

        var transform: Transform3 {
            var transform: Transform3 = .default
            if let position = gameMathPosition {
                transform.position = position
            }
            if let rotation = gameMathRotation {
                transform.rotation = rotation
            }
            if let scale = gameMathScale {
                transform.scale = scale
            }
            return transform
        }
    }
    
    let images: [Image]?
    struct Image: Decodable {
        let name: String
        let mimeType: String
        let uri: String?
        let bufferView: Int?
    }
    
    let textures: [Texture]?
    struct Texture: Decodable {
        let sampler: Int
        let source: Int
    }
    
    let materials: [Material]?
    struct Material: Decodable {
        let name: String
        let doubleSided: Bool
        let emissiveTexture: Texture?
        let normalTexture: Texture?
        
        struct Texture: Decodable {
            let index: Int
        }
        
        let pbrMetallicRoughness: PBRMetallicRoughness?
        struct PBRMetallicRoughness: Decodable {
            let baseColorTexture: Texture?
            let metallicRoughnessTexture: Texture?
        }
        
        let extensions: Extensions?
        struct Extensions: Decodable {
            enum CodingKeys: String, CodingKey {
                case khrMaterialsSpecular = "KHR_materials_specular"
            }
            struct KHRMaterialsSpecular: Decodable {
                let specularTexture: Texture?
                let specularColorTexture: Texture?
            }
            let khrMaterialsSpecular: KHRMaterialsSpecular?
        }
    }

    let meshes: [Mesh]?
    struct Mesh: Decodable {
        let name: String

        let primitives: [Primitive]
        struct Primitive: Decodable {
            enum AttributeName: String, Codable {
                case indices = "----"
                case position = "POSITION"
                case normal = "NORMAL"
                case tangent = "TANGENT"
                case textureCoord = "TEXCOORD_0"
                case textureCoord1 = "TEXCOORD_1"
                case textureCoord2 = "TEXCOORD_2"
                case textureCoord3 = "TEXCOORD_3"
                case textureCoord4 = "TEXCOORD_4"
                case vertexColor = "COLOR_0"
                case joints = "JOINTS_0"
                case weights = "WEIGHTS_0"

                static var textureCoordinates: [Self] {
                    return [
                        .textureCoord, .textureCoord1, .textureCoord2, .textureCoord3,
                        .textureCoord4,
                    ]
                }
            }
            let attributes: [String: Int]
            let indices: Int
            let material: Int?

            subscript(value: AttributeName) -> Int? {
                return attributes[value.rawValue]
            }
        }
    }

    let skins: [Skin]?
    struct Skin: Decodable {
        let name: String
        let inverseBindMatrices: Int
        let joints: [Int]
    }

    let animations: [Animation]?
    struct Animation: Decodable {
        let name: String
        let channels: [Channel]
        let samplers: [Sampler]
        struct Channel: Decodable {
            let sampler: Int
            let target: Target
            struct Target: Decodable {
                let node: Int
                let path: Path
                enum Path: String, Decodable {
                    case translation
                    case rotation
                    case scale
                    case weight
                }
            }
        }

        struct Sampler: Decodable {
            let input: Int
            let interpolation: Interpolation
            let output: Int
            enum Interpolation: String, Decodable {
                case linear = "LINEAR"
                case step = "STEP"
                case cubicSpline = "CUBICSPLINE"
            }
        }
    }

    let accessors: [Accessor]
    struct Accessor: Decodable {
        let bufferView: Int
        let componentType: ComponentType
        let count: Int
        let type: Type

        var primitiveCount: Int {
            switch type {
            case .scalar:
                return 1
            case .vec2:
                return 2
            case .vec3:
                return 3
            case .vec4:
                return 4
            case .mat2:
                return 4
            case .mat3:
                return 9
            case .mat4:
                return 16
            }
        }
        var expectedByteCount: Int {
            var componentBytes = 0
            switch componentType {
            case .int8:
                componentBytes = MemoryLayout<Int8>.size
            case .int16:
                componentBytes = MemoryLayout<Int16>.size
            case .uint8:
                componentBytes = MemoryLayout<UInt8>.size
            case .uint16:
                componentBytes = MemoryLayout<UInt16>.size
            case .uint32:
                componentBytes = MemoryLayout<UInt32>.size
            case .float32:
                componentBytes = MemoryLayout<Float32>.size
            }
            return componentBytes * primitiveCount * count
        }
    }

    let bufferViews: [BufferView]
    struct BufferView: Decodable {
        let buffer: Int
        let byteLength: Int
        let byteOffset: Int
    }

    let buffers: [Buffer]
    struct Buffer: Decodable {
        let byteLength: Int
        let uri: String?
    }

    lazy var cachedBuffers: [Data?] = Array(repeating: nil, count: buffers.count)
    func buffer(at index: Int) -> Data? {
        // Buffer 0 is pre-cached for glb files
        // So `existing` will always be present for index 0 of a glb file
        if let existing = cachedBuffers[index] {
            return existing
        }
        guard let uri = buffers[index].uri else { return nil }

        var buffer: Data? = nil
        if uri.hasPrefix("data"), let index = uri.firstIndex(of: ",") {
            let base64String = uri[uri.index(after: index)...]
            buffer = Data(base64Encoded: String(base64String))
        } else {
            buffer = try? Platform.current.synchronousLoadResource(
                from: self.baseURL!.appendingPathComponent(uri).path
            )
        }

        cachedBuffers[index] = buffer
        assert(buffer?.count == buffers[index].byteLength)
        return buffer
    }

    func values<T: BinaryInteger>(forAccessor accessorIndex: Int) async -> [T]? {
        let accessor = accessors[accessorIndex]
        let bufferView = bufferViews[accessor.bufferView]
        let count = accessor.count * accessor.primitiveCount

        return buffer(at: bufferView.buffer)?.withUnsafeBytes {
            switch accessor.componentType {
            case .uint8:
                typealias Scalar = UInt8
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    array.append(
                        Scalar(littleEndian: $0.load(fromByteOffset: offset, as: Scalar.self))
                    )
                }
                return array.map({ T($0) })
            case .uint16:
                typealias Scalar = UInt16
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    array.append(
                        Scalar(littleEndian: $0.load(fromByteOffset: offset, as: Scalar.self))
                    )
                }
                return array.map({ T($0) })
            case .uint32:
                typealias Scalar = UInt32
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    array.append(
                        Scalar(littleEndian: $0.load(fromByteOffset: offset, as: Scalar.self))
                    )
                }
                return array.map({ T($0) })
            case .int8:
                typealias Scalar = Int8
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    array.append(
                        Scalar(littleEndian: $0.load(fromByteOffset: offset, as: Scalar.self))
                    )
                }
                return array.map({ T($0) })
            case .int16:
                typealias Scalar = Int16
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    array.append(
                        Scalar(littleEndian: $0.load(fromByteOffset: offset, as: Scalar.self))
                    )
                }
                return array.map({ T($0) })
            case .float32:
                typealias Scalar = Float
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    let pattern = UInt32(
                        littleEndian: $0.load(fromByteOffset: offset, as: UInt32.self)
                    )
                    array.append(Float(bitPattern: pattern))
                }
                return array.map({ T($0) })
            }
        }
    }

    func values<T: BinaryFloatingPoint>(forAccessor accessorIndex: Int) async -> [T]? {
        let accessor = accessors[accessorIndex]
        let bufferView = bufferViews[accessor.bufferView]
        let count = accessor.count * accessor.primitiveCount

        return buffer(at: bufferView.buffer)?.withUnsafeBytes {
            switch accessor.componentType {
            case .uint8:
                typealias Scalar = UInt8
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    array.append(
                        Scalar(littleEndian: $0.load(fromByteOffset: offset, as: Scalar.self))
                    )
                }
                return array.map({ T($0) })
            case .uint16:
                typealias Scalar = UInt16
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    array.append(
                        Scalar(littleEndian: $0.load(fromByteOffset: offset, as: Scalar.self))
                    )
                }
                return array.map({ T($0) })
            case .uint32:
                typealias Scalar = UInt32
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    array.append(
                        Scalar(littleEndian: $0.load(fromByteOffset: offset, as: Scalar.self))
                    )
                }
                return array.map({ T($0) })
            case .int8:
                typealias Scalar = Int8
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    array.append(
                        Scalar(littleEndian: $0.load(fromByteOffset: offset, as: Scalar.self))
                    )
                }
                return array.map({ T($0) })
            case .int16:
                typealias Scalar = Int16
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    array.append(
                        Scalar(littleEndian: $0.load(fromByteOffset: offset, as: Scalar.self))
                    )
                }
                return array.map({ T($0) })
            case .float32:
                typealias Scalar = Float
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    let pattern = UInt32(
                        littleEndian: $0.load(fromByteOffset: offset, as: UInt32.self)
                    )
                    array.append(Float(bitPattern: pattern))
                }
                return array.map({ T($0) })
            }
        }
    }
}

// Helpers for exploring the gltf document
public extension GLTransmissionFormat {
    var meshNames: [String] {self.gltf.meshes?.map(\.name) ?? []}
    var materialNames: [String] {self.gltf.materials?.map(\.name) ?? []}
    var imageNames: [String] {self.gltf.images?.map(\.name) ?? []}
    
    func meshNames(usingMaterialNamed materialName: String) -> [String] {
        guard let materialIndex = self.gltf.materials?.firstIndex(where: {$0.name == materialName}) else {return []}
        
        var names: Set<String> = []
        for mesh in gltf.meshes ?? [] {
            for primitive in mesh.primitives {
                if primitive.material == materialIndex {
                    names.insert(mesh.name)
                }
            }
        }
        return Array(names)
    }
    
    func meshNamesWithNoMaterial() -> [String] {
        var names: Set<String> = []
        for mesh in gltf.meshes ?? [] {
            for primitive in mesh.primitives {
                if primitive.material == nil {
                    names.insert(mesh.name)
                }
            }
        }
        return Array(names)
    }
    
    enum TextureType {
        case pbrBaseColor
        case pbrMetallicRoughness
        case emissive
        case normal
        
        /// The `KHR_materials_specular` extension's `specularTexture`
        case khrMaterialsSpecular
        /// The `KHR_materials_specular` extension's `specularColorTexture`
        case khrMaterialsSpecularColor
    }
    /**
         Obtain the name of the image that matches the textureType
     */
    func imageName(ofTextureType type: TextureType, inMaterialNamed materialName: String) -> String? {
        guard let material = self.gltf.materials?.first(where: {$0.name == materialName}) else {return nil}
        
        func textureName(fromIndex index: Int?) -> String? {
            guard let index else {return nil}
            guard let imageIndex = gltf.textures?[index].source else {return nil}
            return gltf.images?[imageIndex].name
        }
        
        switch type {
        case .pbrBaseColor:
            return textureName(fromIndex: material.pbrMetallicRoughness?.baseColorTexture?.index)
        case .pbrMetallicRoughness:
            return textureName(fromIndex: material.pbrMetallicRoughness?.metallicRoughnessTexture?.index)
        case .emissive:
            return textureName(fromIndex: material.emissiveTexture?.index)
        case .normal:
            return textureName(fromIndex: material.normalTexture?.index)
        case .khrMaterialsSpecular:
            return textureName(fromIndex: material.extensions?.khrMaterialsSpecular?.specularTexture?.index)
        case .khrMaterialsSpecularColor:
            return textureName(fromIndex: material.extensions?.khrMaterialsSpecular?.specularColorTexture?.index)
        }
    }
}

public final class GLTransmissionFormat: ResourceImporter {
    fileprivate var gltf: GLTF! = nil
    required public init() {}
    
    public func synchronousPrepareToImportResourceFrom(path: String) throws(GateEngineError) {
        guard let path = Platform.current.synchronousLocateResource(from: path) else {throw .failedToLocate}
        let baseURL = URL(fileURLWithPath: path).deletingLastPathComponent()
        do {
            let data = try Platform.current.synchronousLoadResource(from: path)
            self.gltf = try gltf(from: data, baseURL: baseURL)
        }catch{
            throw GateEngineError(error)
        }
    }
    public func prepareToImportResourceFrom(path: String) async throws(GateEngineError) {
        guard let path = await Platform.current.locateResource(from: path) else {throw .failedToLocate}
        let baseURL = URL(fileURLWithPath: path).deletingLastPathComponent()
        do {
            let data = try await Platform.current.loadResource(from: path)
            self.gltf = try gltf(from: data, baseURL: baseURL)
        }catch{
            throw GateEngineError(error)
        }
    }
    
    fileprivate func gltf(from data: Data, baseURL: URL) throws -> GLTF {
        var jsonData: Data = data
        var bufferData: Data? = nil
        if data[0 ..< 4] == Data("glTF".utf8) {
            let byteCount: Int = data.advanced(by: 12).withUnsafeBytes {
                return Int(UInt32(littleEndian: $0.load(as: UInt32.self)))
            }
            jsonData = data.advanced(by: 20)[..<byteCount]
            bufferData = data.advanced(by: (byteCount + 28))
        }
        let gltf = try JSONDecoder().decode(GLTF.self, from: jsonData)
        gltf.baseURL = baseURL
        gltf.cachedBuffers[0] = bufferData
        return gltf
    }
    
    public static func supportedFileExtensions() -> [String] {
        return ["gltf", "glb"]
    }
    
    public func currentFileContainsMutipleResources() -> Bool {
        return [
            gltf.meshes?.count,
            gltf.animations?.count,
            gltf.skins?.count,
        ].compactMap({$0}).reduce(0, +) > 1
    }
    
}

extension GLTransmissionFormat: GeometryImporter {
    public func loadGeometry(options: GeometryImporterOptions) async throws -> RawGeometry {
        guard gltf.meshes != nil else {throw GateEngineError.failedToDecode("File contains no geometry.")}
        
        var mesh: GLTF.Mesh? = nil
        if let name = options.subobjectName {
            if let meshID = gltf.nodes.first(where: { $0.name == name })?.mesh {
                mesh = gltf.meshes![meshID]
            } else if let _mesh = gltf.meshes!.first(where: { $0.name == name }) {
                mesh = _mesh
            } else {
                let meshNames = gltf.meshes!.map({ $0.name })
                let nodeNames = gltf.nodes.filter({ $0.mesh != nil }).map({ $0.name })
                throw GateEngineError.failedToDecode(
                    "Couldn't find geometry named \(name).\nAvailable mesh names: \(meshNames)\nAvaliable node names: \(nodeNames)"
                )
            }
        } else {
            mesh = gltf.meshes!.first
        }
        guard let mesh = mesh else {
            throw GateEngineError.failedToDecode("No geometry.")
        }

        var geometries: [RawGeometry] = []

        for primitive in mesh.primitives {
            guard let indices: [UInt16] = await gltf.values(forAccessor: primitive.indices) else {
                continue
            }

            guard let positionsAccessorIndex = primitive[.position] else { continue }
            guard let positions: [Float] = await gltf.values(forAccessor: positionsAccessorIndex)
            else { continue }

            var uvSets: [[Float]] = []
            for setID in GLTF.Mesh.Primitive.AttributeName.textureCoordinates {
                if let uvsAccessorIndex = primitive[setID] {
                    if let uvs: [Float] = await gltf.values(forAccessor: uvsAccessorIndex) {
                        uvSets.append(uvs)
                    }
                } else {
                    break
                }
            }

            var normals: [Float]? = nil
            if let normalsAccessorIndex = primitive[.normal] {
                normals = await gltf.values(forAccessor: normalsAccessorIndex)
            }

            var tangents: [Float]? = nil
            if let accessorIndex = primitive[.tangent] {
                tangents = await gltf.values(forAccessor: accessorIndex)
                #warning("Tangents not filtered to vec3")
            }

            var colors: [Float]? = nil
            if let accessorIndex = primitive[.vertexColor] {
                switch gltf.accessors[accessorIndex].componentType {
                case .uint8:
                    if let eightBit: [UInt8] = await gltf.values(forAccessor: accessorIndex) {
                        colors = eightBit.map({ Float($0) / Float(UInt8.max) })
                    }
                case .uint16:
                    if let eightBit: [UInt16] = await gltf.values(forAccessor: accessorIndex) {
                        colors = eightBit.map({ Float($0) / Float(UInt16.max) })
                    }
                case .float32:
                    colors = await gltf.values(forAccessor: accessorIndex)
                default:
                    fatalError()
                }
                // Add alpha component if needed
                if let _colors = colors, gltf.accessors[accessorIndex].type == .vec3 {
                    var colors: [Float] = []
                    colors.reserveCapacity((_colors.count / 3) * 4)
                    for index in stride(from: 0, to: colors.count, by: 3) {
                        colors.append(contentsOf: _colors[index ..< index + 3])
                        colors.append(1)
                    }
                }
            }

            let geometry = RawGeometry(
                positions: positions,
                uvSets: uvSets,
                normals: normals,
                tangents: tangents,
                colors: colors,
                indices: indices
            )
            geometries.append(geometry)
        }

        guard geometries.isEmpty == false else {
            throw GateEngineError.failedToDecode("Failed to decode geometry.")
        }
        
        if geometries.count == 1 {
            if options.applyRootTransform, let nodeIndex = gltf.scenes[gltf.scene].nodes?[0] {
                let transform = gltf.nodes[nodeIndex].transform.createMatrix()
                return geometries[0] * transform
            }else{
                return geometries[0]
            }
        }else{
            var geometry = RawGeometry(geometries: geometries)
            if options.applyRootTransform, let nodeIndex = gltf.scenes[gltf.scene].nodes?[0] {
                let transform = gltf.nodes[nodeIndex].transform.createMatrix()
                geometry = geometry * transform
            }
            return geometry
        }
    }
}

extension GLTransmissionFormat: SkinImporter {
    private func meshForSkin(skinID: Int, in gltf: GLTF) -> Int? {
        func findIn(_ parent: Int) -> Int? {
            let node = gltf.nodes[parent]
            for index in node.children ?? [] {
                let node = gltf.nodes[index]
                if node.skin == skinID {
                    return node.mesh
                }
            }
            for index in node.children ?? [] {
                if let value = findIn(index) {
                    return value
                }
            }
            return nil
        }
        if let sceneNodes = gltf.scenes[gltf.scene].nodes {
            for index in sceneNodes {
                if let value = findIn(index) {
                    return value
                }
            }
        }
        return nil
    }
    private func inverseBindMatrices(
        from bufferView: GLTF.BufferView,
        expecting count: Int,
        in gltf: GLTF
    ) async -> [Matrix4x4]? {
        guard
            let buffer = gltf.buffer(at: bufferView.buffer)?.advanced(
                by: bufferView.byteOffset
            )
        else { return nil }
        let count = count * 16
        var array = [Float](repeating: 0, count: count)

        for index in 0 ..< count {
            buffer.advanced(by: index * MemoryLayout<Float>.size).withUnsafeBytes {
                let pattern = UInt32(littleEndian: $0.load(as: UInt32.self))
                array[index] = Float(bitPattern: pattern)
            }
        }

        return stride(from: 0, to: array.count, by: 16).map({ Array(array[$0 ..< $0 + 16]) }).map({
            Matrix4x4(transposedArray: $0)
        })
    }
    
    public func loadSkin(options: SkinImporterOptions) async throws(GateEngineError) -> Skin {
        guard let skins = gltf.skins, skins.isEmpty == false else {
            throw GateEngineError.failedToDecode("File contains no skins.")
        }
        
        guard gltf.meshes != nil else {throw GateEngineError.failedToDecode("File contains no geometry.")}

        var skinIndex = 0
        if let name = options.subobjectName {
            if let direct = gltf.skins?.firstIndex(where: {
                $0.name.caseInsensitiveCompare(name) == .orderedSame
            }) {
                skinIndex = direct
            } else if let nodeSkinIndex = gltf.nodes.first(where: {
                $0.skin != nil && $0.name == name
            })?.skin {
                skinIndex = nodeSkinIndex
            }
        }

        let skin = skins[skinIndex]
        guard
            let inverseBindMatrices = await inverseBindMatrices(
                from: gltf.bufferViews[skin.inverseBindMatrices],
                expecting: skin.joints.count,
                in: gltf
            )
        else {
            throw GateEngineError.failedToDecode("Failed to parse skin.")
        }

        guard let meshID = meshForSkin(skinID: skinIndex, in: gltf) else {
            throw GateEngineError.failedToDecode("Couldn't locate skin geometry.")
        }
        let mesh = gltf.meshes![meshID]

        guard
            let meshJoints: [UInt32] = await gltf.values(forAccessor: mesh.primitives[0][.joints]!)
        else {
            throw GateEngineError.failedToDecode("Failed to parse skin.")
        }
        guard
            let meshWeights: [Float] = await gltf.values(forAccessor: mesh.primitives[0][.weights]!)
        else {
            throw GateEngineError.failedToDecode("Failed to parse skin.")
        }

        var joints: [Skin.Joint] = []
        joints.reserveCapacity(skin.joints.count)
        for index in skin.joints.indices {
            joints.append(
                Skin.Joint(id: skin.joints[index], inverseBindMatrix: inverseBindMatrices[index])
            )
        }

        return Skin(joints: joints, indices: meshJoints, weights: meshWeights, bindShape: .identity)
    }
}

extension GLTransmissionFormat: SkeletonImporter {    
    private func skeletonNode(named name: String?, in gltf: GLTF) -> Int? {
        func findIn(_ parent: Int) -> Int? {
            let node = gltf.nodes[parent]
            for index in node.children ?? [] {
                let node = gltf.nodes[index]
                if let skeleton = node.skeleton {
                    if let name = name {
                        guard node.name.caseInsensitiveCompare(name) == .orderedSame else {
                            continue
                        }
                    }
                    return skeleton
                }
            }
            for index in node.children ?? [] {
                if let value = findIn(index) {
                    return value
                }
            }
            return nil
        }
        if let sceneNodes = gltf.scenes[gltf.scene].nodes {
            for index in sceneNodes {
                if let value = findIn(index) {
                    return value
                }
            }
        }
        return gltf.scenes[gltf.scene].nodes?.first
    }

    public func loadSkeleton(options: SkeletonImporterOptions) async throws(GateEngineError) -> RawSkeleton {
        guard let rootNode = skeletonNode(named: options.subobjectName, in: gltf) else {
            throw GateEngineError.failedToDecode("Couldn't find skeleton root.")
        }
        var rawSkeleton: RawSkeleton = .init()
        rawSkeleton.joints.append(
            RawSkeleton.RawJoint(id: rootNode, parent: nil, name: gltf.nodes[rootNode].name, localTransform: gltf.nodes[rootNode].transform)
        )

        func addChildren(of parentJointID: Int) {
            for childJointID in gltf.nodes[parentJointID].children ?? [] {
                let childNode = gltf.nodes[childJointID]
                rawSkeleton.joints.append(
                    RawSkeleton.RawJoint(id: childJointID, parent: parentJointID, name: childNode.name, localTransform: childNode.transform)
                )
                addChildren(of: childJointID)
            }
        }
        addChildren(of: rootNode)
        return rawSkeleton
    }
}

extension GLTransmissionFormat: SkeletalAnimationImporter {
    fileprivate func animation(named name: String?, from gltf: GLTF) -> GLTF.Animation? {
        if let name = name {
            return gltf.animations?.first(where: {
                $0.name.caseInsensitiveCompare(name) == .orderedSame
            })
        }
        return gltf.animations?.first
    }
    
    public func process(data: Data, baseURL: URL, options: SkeletalAnimationImporterOptions) async throws -> SkeletalAnimationBackend {
        let gltf = try gltf(from: data, baseURL: baseURL)

        guard let animation = animation(named: options.subobjectName, from: gltf) else {
            throw GateEngineError.failedToDecode(
                "Couldn't find animation: \"\(options.subobjectName!)\".\nAvailable Animations: \((gltf.animations ?? []).map({$0.name}))"
            )
        }
        var animations: [Skeleton.Joint.ID: SkeletalAnimation.JointAnimation] = [:]
        func jointAnimation(forTarget target: Skeleton.Joint.ID) -> SkeletalAnimation.JointAnimation {
            if let existing = animations[target] {
                return existing
            }
            let new = SkeletalAnimation.JointAnimation()
            animations[target] = new
            return new
        }
        do {  // Add bind pose
            guard let rootNode = skeletonNode(named: nil, in: gltf) else {
                throw GateEngineError.failedToDecode("Couldn't find skeleton root.")
            }
            let rootJoint = Skeleton.Joint(id: rootNode, name: gltf.nodes[rootNode].name)
            rootJoint.localTransform = gltf.nodes[rootNode].transform

            func addChildren(gltfNode: Int, parentJoint: Skeleton.Joint) {
                for index in gltf.nodes[gltfNode].children ?? [] {
                    let node = gltf.nodes[index]

                    var jointAnimation = animations[index] ?? SkeletalAnimation.JointAnimation()
                    jointAnimation.positionOutput.bind = node.transform.position
                    jointAnimation.rotationOutput.bind = node.transform.rotation
                    jointAnimation.scaleOutput.bind = node.transform.scale
                    animations[index] = jointAnimation
                }
            }
            addChildren(gltfNode: rootNode, parentJoint: rootJoint)
        }

        var timeMax: Float = .nan
        var timeMin: Float = .nan

        for channel in animation.channels {
            var jointAnimation = jointAnimation(forTarget: channel.target.node)

            let sampler = animation.samplers[channel.sampler]

            guard let times: [Float] = await gltf.values(forAccessor: sampler.input) else {
                continue
            }
            guard let values: [Float] = await gltf.values(forAccessor: sampler.output) else {
                continue
            }

            switch channel.target.path {
            case .translation:
                jointAnimation.positionOutput.times = times
                jointAnimation.positionOutput.positions = stride(from: 0, to: values.count, by: 3)
                    .map({
                        return Position3(x: values[$0 + 0], y: values[$0 + 1], z: values[$0 + 2])
                    })
                switch sampler.interpolation {
                case .step:
                    jointAnimation.positionOutput.interpolation = .step
                default:
                    jointAnimation.positionOutput.interpolation = .linear
                }
            case .rotation:
                jointAnimation.rotationOutput.times = times
                jointAnimation.rotationOutput.rotations = stride(from: 0, to: values.count, by: 4)
                    .map({
                        return Quaternion(
                            x: values[$0 + 0],
                            y: values[$0 + 1],
                            z: values[$0 + 2],
                            w: values[$0 + 3]
                        )
                    })
                switch sampler.interpolation {
                case .step:
                    jointAnimation.rotationOutput.interpolation = .step
                default:
                    jointAnimation.rotationOutput.interpolation = .linear
                }
            case .scale:
                jointAnimation.scaleOutput.times = times
                jointAnimation.scaleOutput.scales = stride(from: 0, to: values.count, by: 3).map({
                    return Size3(
                        width: values[$0 + 0],
                        height: values[$0 + 1],
                        depth: values[$0 + 2]
                    )
                })
                switch sampler.interpolation {
                case .step:
                    jointAnimation.scaleOutput.interpolation = .step
                default:
                    jointAnimation.scaleOutput.interpolation = .linear
                }
            case .weight:
                break
            }

            if let max = times.max() {
                timeMax = .maximum(max, timeMax)
            }
            if let min = times.min() {
                timeMin = .minimum(min, timeMin)
            }
            
            animations[channel.target.node] = jointAnimation
        }
        
        var duration = timeMax - timeMin
        if duration.isFinite == false {
            duration = 0
        }

        return SkeletalAnimationBackend(name: animation.name, duration: duration, animations: animations)
    }
}

extension GLTransmissionFormat: ObjectAnimation3DImporter {   
    public func process(data: Data, baseURL: URL, options: ObjectAnimation3DImporterOptions) async throws -> ObjectAnimation3DBackend {
        let gltf = try gltf(from: data, baseURL: baseURL)
        
        guard let animation = animation(named: options.subobjectName, from: gltf) else {
            throw GateEngineError.failedToDecode(
                "Couldn't find animation: \"\(options.subobjectName!)\".\nAvailable Animations: \((gltf.animations ?? []).map({$0.name}))"
            )
        }
        
        var objectAnimation = ObjectAnimation3D.Animation()
        
        var timeMax: Float = .nan

        for channel in animation.channels {
            let sampler = animation.samplers[channel.sampler]

            guard let times: [Float] = await gltf.values(forAccessor: sampler.input) else {
                continue
            }
            guard let values: [Float] = await gltf.values(forAccessor: sampler.output) else {
                continue
            }

            switch channel.target.path {
            case .translation:
                objectAnimation.positionOutput.times = times
                objectAnimation.positionOutput.positions = stride(from: 0, to: values.count, by: 3)
                    .map({
                        return Position3(x: values[$0 + 0], y: values[$0 + 1], z: values[$0 + 2])
                    })
                switch sampler.interpolation {
                case .step:
                    objectAnimation.positionOutput.interpolation = .step
                default:
                    objectAnimation.positionOutput.interpolation = .linear
                }
            case .rotation:
                objectAnimation.rotationOutput.times = times
                objectAnimation.rotationOutput.rotations = stride(from: 0, to: values.count, by: 4)
                    .map({
                        return Quaternion(
                            x: values[$0 + 0],
                            y: values[$0 + 1],
                            z: values[$0 + 2],
                            w: values[$0 + 3]
                        )
                    })
                switch sampler.interpolation {
                case .step:
                    objectAnimation.rotationOutput.interpolation = .step
                default:
                    objectAnimation.rotationOutput.interpolation = .linear
                }
            case .scale:
                objectAnimation.scaleOutput.times = times
                objectAnimation.scaleOutput.scales = stride(from: 0, to: values.count, by: 3).map({
                    return Size3(
                        width: values[$0 + 0],
                        height: values[$0 + 1],
                        depth: values[$0 + 2]
                    )
                })
                switch sampler.interpolation {
                case .step:
                    objectAnimation.scaleOutput.interpolation = .step
                default:
                    objectAnimation.scaleOutput.interpolation = .linear
                }
            case .weight:
                break
            }

            timeMax = .maximum(times.max()!, timeMax)
        }

        return ObjectAnimation3DBackend(name: animation.name, duration: timeMax, animation: objectAnimation)
    }
}

extension GLTransmissionFormat: TextureImporter {
    // TODO: Supports only PNG. Add other formats (JPEG, WebP, ...)
    public func loadTexture(options: TextureImporterOptions) throws(GateEngineError) -> (data: Data, size: GameMath.Size2) {
        let imageData: Data
        func loadImageData(image: GLTF.Image) throws(GateEngineError) -> Data {
            if let uri = image.uri {
                return try Platform.current.synchronousLoadResource(
                    from: self.gltf.baseURL!.appendingPathComponent(uri).path
                )
            }else if let bufferIndex = image.bufferView {
                let view = self.gltf.bufferViews[bufferIndex]
                
                if let buffer = self.gltf.buffer(at: view.buffer) {
                    return Data(buffer[view.byteOffset..<view.byteOffset+view.byteLength])
                }else{
                    throw .failedToDecode("The file does not contain a buffer with index: \(view.buffer)")
                }
            }else{
                throw .failedToDecode("The gltf file is using an unsupported feature or may be corrupt.")
            }
        }
        if let name = options.subobjectName {
            if let image = self.gltf.images?.first(where: {$0.name.caseInsensitiveCompare(name) == .orderedSame}) {
                imageData = try loadImageData(image: image)
            }else{
                throw .failedToLoad("No subobject found with name: \(name)")
            }
        }else{
            if let image = self.gltf.images?.first {
                imageData = try loadImageData(image: image)
            }else{
                throw .failedToLoad("No images found in file.")
            }
        }
        
        let image = try PNGDecoder().decode(imageData)
        return (image.data, Size2(Float(image.width), Float(image.height)))
    }
}
