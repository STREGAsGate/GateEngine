/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
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
fileprivate class GLTF: Decodable {
    var baseURL: URL? = nil
    
    let scene: Int
    let scenes: Array<Scene>
    struct Scene: Decodable {
        let name: String
        let nodes: Array<Int>
    }
    
    let nodes: Array<Node>
    struct Node: Decodable {
        let name: String
        let children: Array<Int>?
        let mesh: Int?
        let skin: Int?
        let skeleton: Int?
        let rotation: Array<Float>?
        let scale: Array<Float>?
        let translation: Array<Float>?

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
    
    let meshes: Array<Mesh>
    struct Mesh: Decodable {
        let name: String

        let primitives: Array<Primitive>
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
                    return [.textureCoord, .textureCoord1, .textureCoord2, .textureCoord3, .textureCoord4]
                }
            }
            let attributes: Dictionary<String, Int>
            let indices: Int
            let material: Int?
            
            subscript (value: AttributeName) -> Int? {
                return attributes[value.rawValue]
            }
        }
    }
    
    let skins: Array<Skin>?
    struct Skin: Decodable {
        let name: String
        let inverseBindMatrices: Int
        let joints: Array<Int>
    }
    
    let animations: Array<Animation>?
    struct Animation: Decodable {
        let name: String
        let channels: Array<Channel>
        let samplers: Array<Sampler>
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

    let accessors: Array<Accessor>
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

    let bufferViews: Array<BufferView>
    struct BufferView: Decodable {
        let buffer: Int
        let byteLength: Int
        let byteOffset: Int
    }

    let buffers: Array<Buffer>
    struct Buffer: Decodable {
        let byteLength: Int
        let uri: String?
    }
    
    lazy var cachedBuffers: [Data?] = Array(repeating: nil, count: buffers.count)
    func buffer(at index: Int) async -> Data? {
        if let existing = cachedBuffers[index] {
            return existing
        }
        guard let uri = buffers[index].uri else {return nil}

        var buffer: Data? = nil
        if uri.hasPrefix("data"), let index = uri.firstIndex(of: ",") {
            let base64String = uri[uri.index(after: index)...]
            buffer = Data(base64Encoded: String(base64String))
        }else{
            buffer = try? await Game.shared.platform.loadResource(from: self.baseURL!.appendingPathComponent(uri).path)
        }

        cachedBuffers[index] = buffer
        assert(buffer?.count == buffers[index].byteLength)
        return buffer
    }

    func values<T: BinaryInteger>(forAccessor accessorIndex: Int) async -> [T]? {
        let accessor = accessors[accessorIndex]
        let bufferView = bufferViews[accessor.bufferView]
        let count = accessor.count * accessor.primitiveCount

        return await buffer(at: bufferView.buffer)?.withUnsafeBytes {
            switch accessor.componentType {
            case .uint8:
                typealias Scalar = UInt8
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    array.append(Scalar(littleEndian: $0.load(fromByteOffset: offset, as: Scalar.self)))
                }
                return array.map({T($0)})
            case .uint16:
                typealias Scalar = UInt16
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    array.append(Scalar(littleEndian: $0.load(fromByteOffset: offset, as: Scalar.self)))
                }
                return array.map({T($0)})
            case .uint32:
                typealias Scalar = UInt32
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    array.append(Scalar(littleEndian: $0.load(fromByteOffset: offset, as: Scalar.self)))
                }
                return array.map({T($0)})
            case .int8:
                typealias Scalar = Int8
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    array.append(Scalar(littleEndian: $0.load(fromByteOffset: offset, as: Scalar.self)))
                }
                return array.map({T($0)})
            case .int16:
                typealias Scalar = Int16
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    array.append(Scalar(littleEndian: $0.load(fromByteOffset: offset, as: Scalar.self)))
                }
                return array.map({T($0)})
            case .float32:
                typealias Scalar = Float
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    let pattern = UInt32(littleEndian: $0.load(fromByteOffset: offset, as: UInt32.self))
                    array.append(Float(bitPattern: pattern))
                }
                return array.map({T($0)})
            }
        }
    }
    
    func values<T: BinaryFloatingPoint>(forAccessor accessorIndex: Int) async -> [T]? {
        let accessor = accessors[accessorIndex]
        let bufferView = bufferViews[accessor.bufferView]
        let count = accessor.count * accessor.primitiveCount

        return await buffer(at: bufferView.buffer)?.withUnsafeBytes {
            switch accessor.componentType {
            case .uint8:
                typealias Scalar = UInt8
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    array.append(Scalar(littleEndian: $0.load(fromByteOffset: offset, as: Scalar.self)))
                }
                return array.map({T($0)})
            case .uint16:
                typealias Scalar = UInt16
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    array.append(Scalar(littleEndian: $0.load(fromByteOffset: offset, as: Scalar.self)))
                }
                return array.map({T($0)})
            case .uint32:
                typealias Scalar = UInt32
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    array.append(Scalar(littleEndian: $0.load(fromByteOffset: offset, as: Scalar.self)))
                }
                return array.map({T($0)})
            case .int8:
                typealias Scalar = Int8
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    array.append(Scalar(littleEndian: $0.load(fromByteOffset: offset, as: Scalar.self)))
                }
                return array.map({T($0)})
            case .int16:
                typealias Scalar = Int16
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    array.append(Scalar(littleEndian: $0.load(fromByteOffset: offset, as: Scalar.self)))
                }
                return array.map({T($0)})
            case .float32:
                typealias Scalar = Float
                let size = MemoryLayout<Scalar>.size
                var array: [Scalar] = []
                array.reserveCapacity(count)
                for index in 0 ..< count {
                    let offset = (index * size) + bufferView.byteOffset
                    let pattern = UInt32(littleEndian: $0.load(fromByteOffset: offset, as: UInt32.self))
                    array.append(Float(bitPattern: pattern))
                }
                return array.map({T($0)})
            }
        }
    }
}

public class GLTransmissionFormat {
    required public init() {}

    fileprivate func gltf(from data: Data, baseURL: URL) throws -> GLTF {
        var jsonData: Data = data
        var bufferData: Data? = nil
        if data[0..<4] == Data("glTF".utf8) {
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
    
    public static func canProcessFile(_ file: URL) -> Bool {
        let fileType = file.pathExtension
        if fileType.caseInsensitiveCompare("glb") == .orderedSame {
            return true
        }
        if fileType.caseInsensitiveCompare("gltf") == .orderedSame {
            return true
        }
        return false
    }
}

extension GLTransmissionFormat: GeometryImporter {
    public func process(data: Data, baseURL: URL, options: GeometryImporterOptions) async throws -> RawGeometry {
        let gltf = try gltf(from: data, baseURL: baseURL)

        var mesh: GLTF.Mesh? = nil
        if let name = options.subobjectName {
            if let meshID = gltf.nodes.first(where: {$0.name == name})?.mesh {
                mesh = gltf.meshes[meshID]
            }else if let _mesh = gltf.meshes.first(where: {$0.name == name}) {
                mesh = _mesh
            }else{
                let meshNames = gltf.meshes.map({$0.name})
                let nodeNames = gltf.nodes.filter({$0.mesh != nil}).map({$0.name})
                throw "Couldn't find geometry named \(name).\nAvailable mesh names: \(meshNames)\nAvaliable node names: \(nodeNames)"
            }
        }else{
            mesh = gltf.meshes.first
        }
        guard let mesh = mesh else {
            throw "No geometry."
        }
        
        var geometries: [RawGeometry] = []
        
        for primitive in mesh.primitives {
            guard let indices: [UInt16] = await gltf.values(forAccessor: primitive.indices) else {continue}

            guard let positionsAccessorIndex = primitive[.position] else {continue}
            guard let positions: [Float] = await gltf.values(forAccessor: positionsAccessorIndex) else {continue}

            var uvSets: [[Float]] = []
            for setID in GLTF.Mesh.Primitive.AttributeName.textureCoordinates {
                if let uvsAccessorIndex = primitive[setID] {
                    if let uvs: [Float] = await gltf.values(forAccessor: uvsAccessorIndex) {
                        uvSets.append(uvs)
                    }
                }else{
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
                        colors = eightBit.map({Float($0) / Float(UInt8.max)})
                    }
                case .uint16:
                    if let eightBit: [UInt16] = await gltf.values(forAccessor: accessorIndex) {
                        colors = eightBit.map({Float($0) / Float(UInt16.max)})
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
            
            let geometry = RawGeometry(positions: positions, uvSets: uvSets, normals: normals, tangents: tangents, colors: colors, indices: indices)
            geometries.append(geometry)
        }
        
        guard geometries.isEmpty == false else {throw "Failed to decode geometry."}

        var geometry = RawGeometry(geometries: geometries)
        if options.applyRootTransform {
            let transform = gltf.nodes[gltf.scenes[gltf.scene].nodes[0]].transform.createMatrix()
            geometry = geometry * transform
        }
        
        return geometry
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
        for index in gltf.scenes[gltf.scene].nodes {
            if let value = findIn(index) {
                return value
            }
        }
        return nil
    }
    private func inverseBindMatrices(from bufferView: GLTF.BufferView, expecting count: Int, in gltf: GLTF) async -> [Matrix4x4]? {
        guard let buffer = await gltf.buffer(at: bufferView.buffer)?.advanced(by: bufferView.byteOffset) else {return nil}
        let count = count * 16
        var array = Array<Float>(repeating: 0, count: count)

        for index in 0 ..< count {
            buffer.advanced(by: index * MemoryLayout<Float>.size).withUnsafeBytes {
                let pattern = UInt32(littleEndian: $0.load(as: UInt32.self))
                array[index] = Float(bitPattern: pattern)
            }
        }
        
        return stride(from: 0, to: array.count, by: 16).map({Array(array[$0 ..< $0 + 16])}).map({Matrix4x4(transposedArray: $0)})
    }
    public func process(data: Data, baseURL: URL, options: SkinImporterOptions) async throws -> Skin {
        let gltf = try gltf(from: data, baseURL: baseURL)
        guard let skins = gltf.skins, skins.isEmpty == false else {
            throw "File contains no skins."
        }
        
        var skinIndex = 0
        if let desired = options.subobjectName {
            if let direct = gltf.skins?.firstIndex(where: {$0.name.caseInsensitiveCompare(options.subobjectName ?? "") == .orderedSame}) {
                skinIndex = direct
            }else if let nodeSkinIndex = gltf.nodes.first(where: {$0.skin != nil && $0.name == desired})?.skin {
                skinIndex = nodeSkinIndex
            }
        }
        
        let skin = skins[skinIndex]
        guard let inverseBindMatrices = await inverseBindMatrices(from: gltf.bufferViews[skin.inverseBindMatrices], expecting: skin.joints.count, in: gltf) else {
            throw "Failed to parse skin."
        }
        
        guard let meshID = meshForSkin(skinID: skinIndex, in: gltf) else {
            throw "Couldn't locate skin geometry."
        }
        let mesh = gltf.meshes[meshID]
        
        guard let meshJoints: [UInt32] = await gltf.values(forAccessor: mesh.primitives[0][.joints]!) else {
            throw "Failed to parse skin."
        }
        guard let meshWeights: [Float] = await gltf.values(forAccessor: mesh.primitives[0][.weights]!) else {
            throw "Failed to parse skin."
        }
        
        var joints: [Skin.Joint] = []
        joints.reserveCapacity(skin.joints.count)
        for index in skin.joints.indices {
            joints.append(Skin.Joint(id: skin.joints[index], inverseBindMatrix: inverseBindMatrices[index]))
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
                        guard node.name.caseInsensitiveCompare(name) == .orderedSame else {continue}
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
        for index in gltf.scenes[gltf.scene].nodes {
            if let value = findIn(index) {
                return value
            }
        }
        return gltf.scenes[gltf.scene].nodes.first
    }
    public func process(data: Data, baseURL: URL, options: SkeletonImporterOptions) throws -> Skeleton.Joint {
        let gltf = try gltf(from: data, baseURL: baseURL)
        guard let rootNode = skeletonNode(named: options.subobjectName, in: gltf) else {
            throw "Couldn't find skeleton root."
        }
        let rootJoint = Skeleton.Joint(id: rootNode, name: gltf.nodes[rootNode].name)
        rootJoint.localTransform = gltf.nodes[rootNode].transform
        
        func addChildren(gltfNode: Int, parentJoint: Skeleton.Joint) {
            for index in gltf.nodes[gltfNode].children ?? [] {
                let node = gltf.nodes[index]
                let joint = Skeleton.Joint(id: index, name: node.name)
                joint.localTransform = node.transform
                joint.parent = parentJoint
                addChildren(gltfNode: index, parentJoint: joint)
            }
        }
        addChildren(gltfNode: rootNode, parentJoint: rootJoint)
        return rootJoint
    }
}

extension GLTransmissionFormat: SkeletalAnimationImporter {
    fileprivate func animation(named name: String?, from gltf: GLTF) -> GLTF.Animation? {
        if let name = name {
            return gltf.animations?.first(where: {$0.name.caseInsensitiveCompare(name) == .orderedSame})
        }
        return gltf.animations?.first
    }
    public func process(data: Data, baseURL: URL, options: SkeletalAnimationImporterOptions) async throws -> SkeletalAnimation {
        let gltf = try gltf(from: data, baseURL: baseURL)
        
        guard let animation = animation(named: options.subobjectName, from: gltf) else {
            throw "Couldn't find animation: \"\(options.subobjectName!)\".\nAvailable Animations: \((gltf.animations ?? []).map({$0.name}))"
        }
        var animations: [Skeleton.Joint.ID : SkeletalAnimation.JointAnimation] = [:]
        func jointAnimation(forTarget target: Skeleton.Joint.ID) -> SkeletalAnimation.JointAnimation {
            if let existing = animations[target] {
                return existing
            }
            let new = SkeletalAnimation.JointAnimation()
            animations[target] = new
            return new
        }
        do {// Add bind pose
            guard let rootNode = skeletonNode(named: nil, in: gltf) else {
                throw "Couldn't find skeleton root."
            }
            let rootJoint = Skeleton.Joint(id: rootNode, name: gltf.nodes[rootNode].name)
            rootJoint.localTransform = gltf.nodes[rootNode].transform
            
            func addChildren(gltfNode: Int, parentJoint: Skeleton.Joint) {
                for index in gltf.nodes[gltfNode].children ?? [] {
                    let node = gltf.nodes[index]
                    
                    let jointAnimation = jointAnimation(forTarget: index)
                    jointAnimation.positionOutput.times.append(0)
                    jointAnimation.positionOutput.positions.append(node.transform.position)
                    jointAnimation.positionOutput.interpolation = .step
                    
                    jointAnimation.rotationOutput.times.append(0)
                    jointAnimation.rotationOutput.rotations.append(node.transform.rotation)
                    jointAnimation.rotationOutput.interpolation = .step
                    
                    jointAnimation.scaleOutput.times.append(0)
                    jointAnimation.scaleOutput.scales.append(node.transform.scale)
                    jointAnimation.scaleOutput.interpolation = .step
                }
            }
            addChildren(gltfNode: rootNode, parentJoint: rootJoint)
        }
        
        var timeMax: Float = -1000000000
        
        for channel in animation.channels {
            let jointAnimation = jointAnimation(forTarget: channel.target.node)

            let sampler = animation.samplers[channel.sampler]
            
            guard let times: [Float] = await gltf.values(forAccessor: sampler.input) else {continue}
            guard let values: [Float] = await gltf.values(forAccessor: sampler.output) else {continue}

            switch channel.target.path {
            case .translation:
                jointAnimation.positionOutput.times = times
                jointAnimation.positionOutput.positions = stride(from: 0, to: values.count, by: 3).map({
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
                jointAnimation.rotationOutput.rotations = stride(from: 0, to: values.count, by: 4).map({
                    return Quaternion(x: values[$0 + 0], y: values[$0 + 1], z: values[$0 + 2], w: values[$0 + 3])
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
                    return Size3(width: values[$0 + 0], height: values[$0 + 1], depth: values[$0 + 2])
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
            
            timeMax = .maximum(times.max()!, timeMax)
        }

        return SkeletalAnimation(name: animation.name, duration: timeMax, animations: animations)
    }
}
