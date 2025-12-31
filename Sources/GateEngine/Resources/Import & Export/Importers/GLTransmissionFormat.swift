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
private struct GLTF: Decodable, Sendable {
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
    mutating func buffer(at index: Int) -> Data? {
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

    mutating func values<T: BinaryInteger>(forAccessor accessorIndex: Int) async -> [T]? {
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
                    array.append(Scalar(bitPattern: pattern))
                }
                return array.map({ T($0) })
            }
        }
    }

    mutating func values<T: BinaryFloatingPoint>(forAccessor accessorIndex: Int) async -> [T]? {
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
                    array.append(Scalar(bitPattern: pattern))
                }
                return array.map({ T($0) })
            }
        }
    }
    
    mutating func animationValues<T: BinaryFloatingPoint>(forAccessor accessorIndex: Int) async -> [T]? {
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
                return array.map({ T($0) / 255.0 })
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
                return array.map({ T($0) / 65535.0 })
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
                return array.map({ .maximum(T($0) / 127.0, -1.0) })
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
                return array.map({ .maximum(T($0) / 32767.0, -1.0) })
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
                    array.append(Scalar(bitPattern: pattern))
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
    var skeletonNames: [String] {self.gltf.nodes.compactMap({
        if $0.mesh != nil && $0.skin != nil {
            return $0.name
        }
        return nil
    })}
    var skinNames: [String] {self.gltf.nodes.compactMap({
        if $0.mesh != nil && $0.skin != nil {
            return $0.name
        }
        return nil
    })}
    
    /// Returns all names with annimations channels greater than 1
    var skeletalAnimationNames: [String] {
        self.gltf.animations?.compactMap({
            func nodeHasParentWithChildSkin(nodeIndex: Int) -> Bool {
                for gltfNodeIndex in gltf.nodes.indices {
                    let node = gltf.nodes[gltfNodeIndex]
                    // If the node is the parent
                    if let children = node.children, children.contains(nodeIndex) {
                        // If the parent has a child with a skin
                        if children.contains(where: {gltf.nodes[$0].skin != nil}) {
                            return true
                        }
                        break
                    }
                }
                return false
            }
            // If any node has a parent with a child with a skin, this is a skeletal animation
            if $0.channels.contains(where: {
                return nodeHasParentWithChildSkin(nodeIndex: $0.target.node)
            }) {
                return $0.name
            }
            return nil
        }) ?? []
    }
        
    
    /// Returns all names with annimations channels count of exactly 1
    var objectAnimationNames: [String] {
        self.gltf.animations?.compactMap({
            // If any nodeIndex has no parent, it's a root object
            // and can be interpretted as an object animation
            if $0.channels.contains(where: {
                let nodeIndex = $0.target.node
                if gltf.nodes.contains(where: {$0.children?.contains(nodeIndex) == true}) == false {
                    return true
                }
                return false
            }) {
                return $0.name
            }
            return nil
        }) ?? []
    }
    
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
    
    func skinName(forMesh meshName: String) -> String? {
        if let meshIndex = gltf.meshes?.firstIndex(where: {$0.name == meshName}) {
            func findIn(_ parent: Int) -> Int? {
                let node = gltf.nodes[parent]
                for index in node.children ?? [] {
                    let node = gltf.nodes[index]
                    if let skinID = node.skin, node.mesh == meshIndex {
                        return skinID
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
                        return gltf.skins?[value].name
                    }
                }
            }
        }
        return nil
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

public struct GLTransmissionFormat: ResourceImporter {
    fileprivate var gltf: GLTF! = nil
    public init() {}
    
    public mutating func synchronousPrepareToImportResourceFrom(path: String) throws(GateEngineError) {
        guard let path = Platform.current.synchronousLocateResource(from: path) else { throw .failedToLocate(resource: path, nil) }
        let baseURL = URL(fileURLWithPath: path).deletingLastPathComponent()
        do {
            let data = try Platform.current.synchronousLoadResource(from: path)
            self.gltf = try Self.gltf(from: data, baseURL: baseURL)
        }catch{
            throw GateEngineError(error)
        }
    }
    public mutating func prepareToImportResourceFrom(path: String) async throws(GateEngineError) {
        guard let path = await Platform.current.locateResource(from: path) else { throw .failedToLocate(resource: path, nil) }
        let baseURL = URL(fileURLWithPath: path).deletingLastPathComponent()
        do {
            let data = try await Platform.current.loadResource(from: path)
            self.gltf = try Self.gltf(from: data, baseURL: baseURL)
        }catch{
            throw GateEngineError(error)
        }
    }
    
    fileprivate static func gltf(from data: Data, baseURL: URL) throws -> GLTF {
        var jsonData: Data = data
        var bufferData: Data? = nil
        if data[0 ..< 4] == Data("glTF".utf8) {
            let byteCount: Int = data.advanced(by: 12).withUnsafeBytes {
                return Int(UInt32(littleEndian: $0.load(as: UInt32.self)))
            }
            jsonData = data.advanced(by: 20)[..<byteCount]
            bufferData = data.advanced(by: (byteCount + 28))
        }
        var gltf = try JSONDecoder().decode(GLTF.self, from: jsonData)
        gltf.baseURL = baseURL
        gltf.cachedBuffers[0] = bufferData
        return gltf
    }
    
    public static func supportedFileExtensions() -> [String] {
        return ["glb", "gltf"]
    }
    
    public func currentFileContainsMutipleResources() -> Bool {
        return [
            gltf.meshes?.count,
            gltf.animations?.count,
            gltf.skins?.count,
            gltf.images?.count
        ].compactMap({$0}).reduce(0, +) > 1
    }
}

extension GLTransmissionFormat: GeometryImporter {
    public mutating func loadGeometry(options: GeometryImporterOptions) async throws(GateEngineError) -> RawGeometry {
        guard gltf.meshes != nil else {throw GateEngineError.failedToDecode("File contains no geometry.")}
        
        // TODO: Disambiguate desire for subObjectName
        // Different software can output different names in different places.
        // A mesh name could end up as a node.name, material.name, or mesh.name
        // The end user needs a way to pick what they mean when they try to load geometry
        // These changes need to be reflected in CollisionMesh importing as well
        var mesh: GLTF.Mesh? = nil
        if let name = options.subobjectName {
            if let _mesh = gltf.meshes!.first(where: { $0.name == name }) {
                mesh = _mesh
            }else if let meshID = gltf.nodes.first(where: { $0.name == name })?.mesh {
                mesh = gltf.meshes![meshID]
            }else{
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
                let accessor = gltf.accessors[accessorIndex]
                switch accessor.type {
                case .vec3:
                    tangents = await gltf.values(forAccessor: accessorIndex)
                case .vec4:
                    // the 4th scalar in each primitive is for generating a bitangent
                    // Bitangent can be generated without this value, so we discard it.
                    if var _tangents: [Float] = await gltf.values(forAccessor: accessorIndex) {
                        for indexOfW in stride(from: 3, to: _tangents.count, by: 4) {
                            _tangents.remove(at: indexOfW)
                        }
                        tangents = _tangents
                    }
                default:
                    throw GateEngineError.failedToDecode("Unhandled accessor type for tangents: \(accessor.type)")
                }
                Log.assert(tangents == nil || tangents!.count == positions.count, "Tangent count doesn't match position count.")
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
                indexes: indices
            )
            geometries.append(geometry)
        }

        guard geometries.isEmpty == false else {
            throw GateEngineError.failedToDecode("Failed to decode geometry.")
        }
        
        let geometryBase: RawGeometry = {
            if geometries.count == 1 {
                return geometries[0]
            }
            return RawGeometry(combining: geometries)
        }()

        if options.applyRootTransform, let nodeIndex = gltf.scenes[gltf.scene].nodes?.first {
            let transform = gltf.nodes[nodeIndex].transform.createMatrix()
            return geometryBase * transform
        }else if options.makeInstancesReal, let sceneNodeIndicies = gltf.scenes[gltf.scene].nodes {
            var transformedGeometries: [RawGeometry] = []
            for meshIndex in gltf.meshes!.indices {
                // mesh.name is not required to be unique
                // Multiple meshes can have the same name for some reason but different content
                // So we need to loop through every mesh and check every name
                guard gltf.meshes![meshIndex].name == mesh.name else {continue}
                for sceneNodeIndex in sceneNodeIndicies {
                    guard gltf.nodes[sceneNodeIndex].mesh == meshIndex else {continue}
                    var transform: Matrix4x4 = .identity
                    
                    func applyNode(_ sceneNodeIndex: Int) {
                        transform *= gltf.nodes[sceneNodeIndex].transform.createMatrix()
                        if let parent = sceneNodeIndicies.first(where: {gltf.nodes[$0].children?.contains(sceneNodeIndex) == true}) {
                            applyNode(parent)
                        }
                    }
                    applyNode(sceneNodeIndex)
                    transformedGeometries.append(geometryBase * transform)
                }
            }
            assert(transformedGeometries.isEmpty == false)
            return RawGeometry(combining: transformedGeometries, optimizing: .byEquality)
        }else{
            return geometryBase
        }
    }
}

extension GLTransmissionFormat: SkinImporter {
    private func meshForSkin(skinID: Int) -> Int? {
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
    private mutating func inverseBindMatrices(
        from bufferView: GLTF.BufferView,
        expecting count: Int
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
    
    public mutating func loadSkin(options: SkinImporterOptions) async throws(GateEngineError) -> RawSkin {
        guard let skins = gltf.skins, skins.isEmpty == false else {
            throw GateEngineError.failedToDecode("File contains no skins.")
        }
        
        guard let meshes = gltf.meshes else {throw GateEngineError.failedToDecode("File contains no geometry.")}

        var skinIndex = 0
        if let name = options.subobjectName {
            if let skinName = self.skinName(forMesh: name), let index = skins.firstIndex(where: {$0.name == skinName}) {
                skinIndex = index
            }else{
                throw GateEngineError.failedToDecode(
                    "Couldn't find skin named \(name)."
                )
            }
        }
        
        var meshIndex = 0
        if let name = options.subobjectName {
            if let meshID = gltf.nodes.first(where: { $0.name == name })?.mesh {
                meshIndex = meshID
            } else if let _mesh = meshes.firstIndex(where: { $0.name == name }) {
                meshIndex = _mesh
            } else {
                let meshNames = meshes.map({ $0.name })
                let nodeNames = gltf.nodes.filter({ $0.mesh != nil }).map({ $0.name })
                throw GateEngineError.failedToDecode(
                    "Couldn't find geometry named \(name).\nAvailable mesh names: \(meshNames)\nAvaliable node names: \(nodeNames)"
                )
            }
        }else if let meshID = meshForSkin(skinID: skinIndex) {
            meshIndex = meshID
        }else{
            throw GateEngineError.failedToDecode("Couldn't locate skin geometry.")
        }

        let skin = skins[skinIndex]
        guard let inverseBindMatrices = await inverseBindMatrices(
            from: gltf.bufferViews[gltf.accessors[skin.inverseBindMatrices].bufferView],
            expecting: gltf.accessors[skin.inverseBindMatrices].count
        ) else {
            throw GateEngineError.failedToDecode("Failed to parse skin.")
        }

        guard meshes.indices.contains(meshIndex) else {
            throw GateEngineError.failedToDecode("Couldn't locate skin geometry.")
        }
        let mesh = meshes[meshIndex]

        guard let meshJoints: [UInt32] = await gltf.values(forAccessor: mesh.primitives[0][.joints]!) else {
            throw GateEngineError.failedToDecode("Failed to parse skin.")
        }
        guard let meshWeights: [Float] = await gltf.values(forAccessor: mesh.primitives[0][.weights]!) else {
            throw GateEngineError.failedToDecode("Failed to parse skin.")
        }

        var joints: [RawSkin.RawJoint] = []
        joints.reserveCapacity(skin.joints.count)
        for index in skin.joints.indices {
            joints.append(
                RawSkin.RawJoint(id: skin.joints[index], inverseBindMatrix: inverseBindMatrices[index])
            )
        }

        return RawSkin(joints: joints, indices: meshJoints, weights: meshWeights, bindShape: .identity)
    }
}

extension GLTransmissionFormat: SkeletonImporter {
    private func skeletonRootNode(fromChild nodeIndex: Int) -> Int? {
        func parentWithChildSkin(nodeIndex: Int) -> Int? {
            for gltfNodeIndex in gltf.nodes.indices {
                let node = gltf.nodes[gltfNodeIndex]
                // If the node is the parent
                if let children = node.children, children.contains(nodeIndex) {
                    // If the parent has a child with a skin
                    if children.contains(where: {gltf.nodes[$0].skin != nil}) {
                        return gltfNodeIndex
                    }
                    if let parent = parentWithChildSkin(nodeIndex: gltfNodeIndex) {
                        return parent
                    }
                    break
                }
            }
            return nil
        }
        return parentWithChildSkin(nodeIndex: nodeIndex)
    }
    private func skeletonNode(named name: String?) -> Int? {
        func findIn(_ parent: Int) -> Int? {
            let node = gltf.nodes[parent]
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

    public mutating func loadSkeleton(options: SkeletonImporterOptions) async throws(GateEngineError) -> RawSkeleton {
        guard let rootNode = skeletonNode(named: options.subobjectName) else {
            throw GateEngineError.failedToDecode("Couldn't find skeleton root.")
        }
        var rawSkeleton: RawSkeleton = .init(rawJoints: [])
        rawSkeleton.joints.append(
            RawSkeleton.RawJoint(id: rootNode, parent: nil, name: gltf.nodes[rootNode].name, localTransform: .default)
        )

        func addChildren(of parentJointID: Int) {
            if parentJointID != rootNode {
                for childJointID in gltf.nodes[parentJointID].children ?? [] {
                    let childNode = gltf.nodes[childJointID]
                    if childNode.skin != nil {return}
                    if childNode.mesh != nil {return}
                }
            }
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
    fileprivate func animation(named name: String?) -> GLTF.Animation? {
        if let name = name {
            return gltf.animations?.first(where: {
                $0.name.caseInsensitiveCompare(name) == .orderedSame
            })
        }
        return gltf.animations?.first
    }
    
    public mutating func loadSkeletalAnimation(options: SkeletalAnimationImporterOptions) async throws(GateEngineError) -> RawSkeletalAnimation {
        guard let animation = animation(named: options.subobjectName) else {
            throw GateEngineError.failedToDecode(
                "Couldn't find animation: \"\(options.subobjectName!)\".\nAvailable Animations: \((gltf.animations ?? []).map({$0.name}))"
            )
        }
        var animations: [Skeleton.Joint.ID: RawSkeletalAnimation.JointAnimation] = [:]
        func jointAnimation(forTarget target: Skeleton.Joint.ID, createIfNeeded: Bool) -> RawSkeletalAnimation.JointAnimation? {
            if let existing = animations[target] {
                return existing
            }
            if createIfNeeded {
                let new = RawSkeletalAnimation.JointAnimation()
                animations[target] = new
                return new
            }
            return nil
        }
        let rootJoint: RawSkeleton.RawJoint
        do {  // Add bind pose
            guard let rootNode = skeletonRootNode(fromChild: animation.channels[0].target.node) else {
                throw GateEngineError.failedToDecode("Couldn't find skeleton root.")
            }
            rootJoint = RawSkeleton.RawJoint(id: rootNode, name: gltf.nodes[rootNode].name, localTransform: .default)

            func addChildren(gltfNode: Int, parentJoint: RawSkeleton.RawJoint) {
                for index in gltf.nodes[gltfNode].children ?? [] {
                    let node = gltf.nodes[index]
                    
                    let joint = RawSkeleton.RawJoint(id: index, name: node.name, localTransform: node.transform)
                    var jointAnimation = jointAnimation(forTarget: joint.id, createIfNeeded: true)!
                    jointAnimation.positionOutput.bind = node.transform.position
                    jointAnimation.rotationOutput.bind = node.transform.rotation
                    jointAnimation.scaleOutput.bind = node.transform.scale
                    animations[index] = jointAnimation
                    
                    addChildren(gltfNode: index, parentJoint: joint)
                }
            }
            addChildren(gltfNode: rootNode, parentJoint: rootJoint)
        }

        var timeMax: Float = .nan
        var timeMin: Float = .nan

        for channel in animation.channels {
            // Don't animate the root joint
            guard channel.target.node != rootJoint.id else {continue}
            // Only animate nodes that descendants of the root joint
            guard var jointAnimation = jointAnimation(forTarget: channel.target.node, createIfNeeded: false) else {continue}

            let sampler = animation.samplers[channel.sampler]

            guard let times: [Float] = await gltf.animationValues(forAccessor: sampler.input) else {
                continue
            }
            guard let values: [Float] = await gltf.animationValues(forAccessor: sampler.output) else {
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
                case .linear:
                    jointAnimation.positionOutput.interpolation = .linear
                default:
                    throw GateEngineError.failedToDecode("Unhandled animation interpolation: \(sampler.interpolation)")
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
                case .linear:
                    jointAnimation.rotationOutput.interpolation = .linear
                default:
                    throw GateEngineError.failedToDecode("Unhandled animation interpolation: \(sampler.interpolation)")
                    
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
                case .linear:
                    jointAnimation.scaleOutput.interpolation = .linear
                default:
                    throw GateEngineError.failedToDecode("Unhandled animation interpolation: \(sampler.interpolation)")
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
        
        // Slide animations to start at time zero
        for animationKey in animations.keys {
            animations[animationKey]!.positionOutput.times = animations[animationKey]!.positionOutput.times.map({$0 - timeMin})
            animations[animationKey]!.rotationOutput.times = animations[animationKey]!.rotationOutput.times.map({$0 - timeMin})
            animations[animationKey]!.scaleOutput.times = animations[animationKey]!.scaleOutput.times.map({$0 - timeMin})
        }

        return RawSkeletalAnimation(name: animation.name, duration: duration, animations: animations)
    }
}

extension GLTransmissionFormat: ObjectAnimation3DImporter {
    public mutating func loadObjectAnimation(options: ObjectAnimation3DImporterOptions) async throws(GateEngineError) -> RawObjectAnimation3D {
        guard let animation = animation(named: options.subobjectName) else {
            throw GateEngineError.failedToDecode(
                "Couldn't find animation: \"\(options.subobjectName!)\".\nAvailable Animations: \((gltf.animations ?? []).map({$0.name}))"
            )
        }
        
        var objectAnimation = RawObjectAnimation3D.NodeAnimation()
        
        var timeMax: Float = .nan
        var timeMin: Float = .nan

        for channel in animation.channels {
            let sampler = animation.samplers[channel.sampler]

            guard let times: [Float] = await gltf.animationValues(forAccessor: sampler.input) else {
                continue
            }
            guard let values: [Float] = await gltf.animationValues(forAccessor: sampler.output) else {
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
                case .linear:
                    objectAnimation.positionOutput.interpolation = .linear
                default:
                    throw GateEngineError.failedToDecode("Unhandled animation interpolation: \(sampler.interpolation)")
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
                case .linear:
                    objectAnimation.rotationOutput.interpolation = .linear
                default:
                    throw GateEngineError.failedToDecode("Unhandled animation interpolation: \(sampler.interpolation)")
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
                case .linear:
                    objectAnimation.scaleOutput.interpolation = .linear
                default:
                    throw GateEngineError.failedToDecode("Unhandled animation interpolation: \(sampler.interpolation)")
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
        }
        
        var duration = timeMax - timeMin
        if duration.isFinite == false {
            duration = 0
        }
        
        // Slide animation to start at time zero
        objectAnimation.positionOutput.times = objectAnimation.positionOutput.times.map({$0 - timeMin})
        objectAnimation.rotationOutput.times = objectAnimation.rotationOutput.times.map({$0 - timeMin})
        objectAnimation.scaleOutput.times = objectAnimation.scaleOutput.times.map({$0 - timeMin})

        return RawObjectAnimation3D(name: animation.name, duration: timeMax, animation: objectAnimation)
    }
}

extension GLTransmissionFormat: TextureImporter {
    // TODO: Supports only PNG. Add other formats (JPEG, WebP, ...)
    public mutating func synchronousLoadTexture(options: TextureImporterOptions) throws(GateEngineError) -> RawTexture {
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
                throw .failedToLoad(resource: "GLTF Content", "No subobject found with name: \(name)")
            }
        }else{
            if let image = self.gltf.images?.first {
                imageData = try loadImageData(image: image)
            }else{
                throw .failedToLoad(resource:  "GLTF Content", "No images found in file.")
            }
        }
        
        return try PNGDecoder().decode(imageData)
    }
    
    public mutating func loadTexture(options: TextureImporterOptions) async throws(GateEngineError) -> RawTexture {
        return try synchronousLoadTexture(options: options)
    }
}

extension GLTransmissionFormat: CollisionMeshImporter {
    public mutating func loadCollisionMesh(options: CollisionMeshImporterOptions) async throws(GateEngineError) -> RawCollisionMesh {
        guard gltf.meshes != nil else {throw GateEngineError.failedToDecode("File contains no geometry.")}
        
        var mesh: GLTF.Mesh? = nil
        if let name = options.subobjectName {
            if let _mesh = gltf.meshes!.first(where: { $0.name == name }) {
                mesh = _mesh
            }else if let meshID = gltf.nodes.first(where: { $0.name == name })?.mesh {
                mesh = gltf.meshes![meshID]
            }else{
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
                let accessor = gltf.accessors[accessorIndex]
                switch accessor.type {
                case .vec3:
                    tangents = await gltf.values(forAccessor: accessorIndex)
                case .vec4:
                    // the 4th scalar in each primitive is for generating a bitangent
                    // Bitangent can be generated without this value, so we discard it.
                    if var _tangents: [Float] = await gltf.values(forAccessor: accessorIndex) {
                        for indexOfW in stride(from: 3, to: _tangents.count, by: 4) {
                            _tangents.remove(at: indexOfW)
                        }
                        tangents = _tangents
                    }
                default:
                    throw GateEngineError.failedToDecode("Unhandled accessor type for tangents: \(accessor.type)")
                }
                Log.assert(tangents == nil || tangents!.count == positions.count, "Tangent count doesn't match position count.")
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
                indexes: indices
            )
            geometries.append(geometry)
        }

        guard geometries.isEmpty == false else {
            throw GateEngineError.failedToDecode("Failed to decode geometry.")
        }
        
        let geometryBase = RawGeometry(combining: geometries)
        
        if options.applyRootTransform, let nodeIndex = gltf.scenes[gltf.scene].nodes?.first {
            let transform = gltf.nodes[nodeIndex].transform.createMatrix()
            let geometryBase = geometryBase * transform
            let triangles = geometryBase.generateCollisionTriangles(using: options.collisionAttributes)
            return RawCollisionMesh(collisionTriangles: triangles) 
        }else if options.makeInstancesReal, let sceneNodeIndicies = gltf.scenes[gltf.scene].nodes {
            var transformedGeometries: [RawGeometry] = []
            for meshIndex in gltf.meshes!.indices {
                // mesh.name is not required to be unique
                // Multiple meshes can have the same name for some reason but different content
                // So we need to loop through every mesh and check every name
                guard gltf.meshes![meshIndex].name == mesh.name else {continue}
                for sceneNodeIndex in sceneNodeIndicies {
                    guard gltf.nodes[sceneNodeIndex].mesh == meshIndex else {continue}
                    var transform: Matrix4x4 = .identity
                    
                    func applyNode(_ sceneNodeIndex: Int) {
                        transform *= gltf.nodes[sceneNodeIndex].transform.createMatrix()
                        if let parent = sceneNodeIndicies.first(where: {gltf.nodes[$0].children?.contains(sceneNodeIndex) == true}) {
                            applyNode(parent)
                        }
                    }
                    applyNode(sceneNodeIndex)
                    transformedGeometries.append(geometryBase * transform)
                }
            }
            assert(transformedGeometries.isEmpty == false)
            let geometryBase = RawGeometry(combining: transformedGeometries, optimizing: .byEquality)
            let triangles = geometryBase.generateCollisionTriangles(using: options.collisionAttributes)
            return RawCollisionMesh(collisionTriangles: triangles) 
        }else{
            let triangles = geometryBase.generateCollisionTriangles(using: options.collisionAttributes)
            return RawCollisionMesh(collisionTriangles: triangles) 
        }
    }
}
