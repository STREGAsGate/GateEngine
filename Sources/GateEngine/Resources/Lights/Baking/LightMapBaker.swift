/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct LightMapBaker: Sendable {
    nonisolated public let quality: Quality
    nonisolated public let texelDensity: Int
    nonisolated public let lights: LightSet
    nonisolated public let uvSetIndex: Int
    nonisolated public let antialiasingSamples: Int
    
    public enum Quality: Int, Comparable, Sendable {
        /// The lowest quality with all features enabled. This quality level disables shadows.
        case lowestNoShadows
        /// The lowest quality with all features enabled.
        case lowestFastest
        /// A balance of quality, prefering faster completetion but improving quality on tasts that are easy to compute
        case balanced
        /// The highest quality with all features enabled
        case highestSlowest
        
        public static func < (lhs: LightMapBaker.Quality, rhs: LightMapBaker.Quality) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
    
    public init(quality: Quality, texelsPerUnit texelDensity: Int, samplesPerTexel antialiasingSamples: Int, uvSet: UVSet = .uvSet2, lights: LightSet) {
        self.quality = quality
        self.texelDensity = Swift.max(1, texelDensity)
        self.lights = lights
        self.uvSetIndex = uvSet.index
        
        if antialiasingSamples <= 1 {
            self.antialiasingSamples = 1
        }else{
            self.antialiasingSamples = antialiasingSamples + (antialiasingSamples % 4)
        }
    }
    
    public func bake(_ sources: [Source]) async throws -> [LightMapBaker.Result] {
        Log.info("\(LightMapBaker.self): Baking...")
        Log.info("\(LightMapBaker.self): Building ray trace structure")
        let rayTraceStructure = try await self.generateRayTraceStructure(for: sources)
        
        Log.info("\(LightMapBaker.self): Building baking sources...")
        let bakedSources: [BakingSource] = try await withThrowingTaskGroup { group in
            let bakingSources = try await self.generateBakingSources(for: sources, rayTraceStructure: rayTraceStructure)
            
            for sourceIndex in bakingSources.indices {
                group.addTask {
                    var source = bakingSources[sourceIndex]
                    
                    source.triangleLightMaps = try await withThrowingTaskGroup { group in
                        for triangleIndex in source.triangleLightMaps.indices {
                            group.addTask {
                                let lightMap = try await self.bake(
                                    sourceIndex,
                                    triangleIndex: triangleIndex,
                                    sources: bakingSources,
                                    lights: lights,
                                    rayTraceStructure: rayTraceStructure
                                )
                                return (triangleIndex: triangleIndex, lightMap: lightMap)
                            }
                        }
                        
                        var lightMaps: [(triangleIndex: Int, lightMap: RawTexture)] = []
                        lightMaps.reserveCapacity(source.triangleLightMaps.count)
                        for try await result in group {
                            if Task.isCancelled {
                                throw CancellationError()
                            }
                            lightMaps.append(result)
                        }
                        return lightMaps.sorted(by: {$0.triangleIndex < $1.triangleIndex}).map(\.lightMap)
                    }
                    
                    return (index: sourceIndex, source: source)
                }
            }
            
            var bakedSources: [(index: Int, source: BakingSource)] = []
            bakedSources.reserveCapacity(bakingSources.count)
            for try await source in group {
                if Task.isCancelled {
                    throw CancellationError()
                }
                bakedSources.append(source)
                Log.info("\(LightMapBaker.self): Built baking source \(bakedSources.count)/\(bakingSources.count)")
            }
            return bakedSources.sorted(by: {$0.index < $1.index}).map(\.source)
        }

        Log.info("\(LightMapBaker.self): Baking sources... ")
        let results = try await withThrowingTaskGroup { group in
            for bakedSourceIndex in bakedSources.indices {
                group.addTask {
                    let bakedSource = bakedSources[bakedSourceIndex]
                    let atlasBuilder = TextureAtlasBuilder(blockSize: 1)
                    for textureIndex in bakedSource.triangleLightMaps.indices {
                        if Task.isCancelled {
                            throw CancellationError()
                        }
                        try atlasBuilder.insertTexture(
                            bakedSource.triangleLightMaps[textureIndex],
                            named: "\(textureIndex)",
                            sacrificePerformanceForSize: when(.release) || when(.distribute)
                        )
                    }
                    let atlas = atlasBuilder.generateAtlas()
                    var rawGeometry = bakedSource.geometry
                    for index in rawGeometry.indices {
                        switch self.uvSetIndex {
                        case 0:
                            if let uv1 = atlas.convertUV(rawGeometry[index].v1.uv1, forTexture: .named("\(index)")) {
                                rawGeometry[index].v1.uv1 = uv1
                            }
                            if let uv2 = atlas.convertUV(rawGeometry[index].v2.uv1, forTexture: .named("\(index)")) {
                                rawGeometry[index].v2.uv1 = uv2
                            }
                            if let uv3 = atlas.convertUV(rawGeometry[index].v3.uv1, forTexture: .named("\(index)")) {
                                rawGeometry[index].v3.uv1 = uv3
                            }
                        case 1:
                            if let uv1 = atlas.convertUV(rawGeometry[index].v1.uv2, forTexture: .named("\(index)")) {
                                rawGeometry[index].v1.uv2 = uv1
                            }
                            if let uv2 = atlas.convertUV(rawGeometry[index].v2.uv2, forTexture: .named("\(index)")) {
                                rawGeometry[index].v2.uv2 = uv2
                            }
                            if let uv3 = atlas.convertUV(rawGeometry[index].v3.uv2, forTexture: .named("\(index)")) {
                                rawGeometry[index].v3.uv2 = uv3
                            }
                        default:
                            fatalError()
                        }
                    }
                    
                    return (bakedSourceIndex: bakedSourceIndex, result: Result.baked(BakedStructure(geometry: rawGeometry, lightMap: atlas.rawTexture)))
                }
            }
            
            var results: [(bakedSourceIndex: Int, result: Self.Result)] = []
            results.reserveCapacity(bakedSources.count)
            for try await result in group {
                if Task.isCancelled {
                    throw CancellationError()
                }
                results.append(result)
                Log.info("\(LightMapBaker.self): Baked source \(results.count)/\(bakedSources.count)")
            }
            return results.sorted(by: {$0.bakedSourceIndex < $1.bakedSourceIndex}).map(\.result)
        }
        
        if Task.isCancelled {
            Log.info("\(LightMapBaker.self): Cancelled.")
            throw CancellationError()
        }else{
            Log.info("\(LightMapBaker.self): Done.")
            return results
        }
    }
}

public extension LightMapBaker {
    enum UVSet {
        /// The uv set represented by the property of the same name on gemoetry types
        case uvSet1
        /// The uv set represented by the property of the same name on gemoetry types
        case uvSet2
        /// - parameter index: The subscript index used to access uvSets on geometry types
        case atIndex(_ index: Int)
        
        var index: Int {
            switch self {
            case .uvSet1:
                return 0
            case .uvSet2:
                return 1
            case .atIndex(let index):
                return index
            }
        }
    }
    struct LightSet: Hashable, Equatable, Sendable {
        public let directional: DirectionalLight?
        public let pointLights: Set<PointLight>
        public let spotLights: Set<SpotLight>
        
        public init(directional: DirectionalLight?, pointLights: Set<PointLight>, spotLights: Set<SpotLight>) {
            self.directional = directional
            self.pointLights = pointLights
            self.spotLights = spotLights
        }
    }
    struct Source: Sendable {
        public let geometry: RawGeometry
        public let surface: Surface
        public let options: Options
        public enum Surface: Sendable {
            case color(_ color: Color, transparency: Transparency = .alwaysOpaque)
            case texture(diffuse: RawTexture, normal: RawTexture? = nil, metallic: RawTexture? = nil, emissive: RawTexture? = nil, transparency: Transparency = .alwaysOpaque)
        }
        public enum Transparency: Sendable {
            /// Always use 1
            case alwaysOpaque
            /// If the alpha channel is less than 1, it will be treated as 0
            case alphaChannelDiscardLessThanOne
            /// Use the alpha channel
            case alphaChannel
        }
        
        public init(geometry: RawGeometry, surface: Surface, options: Options = .default) {
            self.geometry = geometry
            self.surface = surface
            self.options = options
        }
        
        public struct Options: Sendable {
            public var radiosity: Radiosity
            public var occlusion: Occlusion
            public var packing: LightMapPacker.Options
            public var minimumTexels: Size2i
            
            public enum Radiosity: Sendable {
                /// All light will effect this source and other sources
                case fullyRadiant
                /// Only light from a `LightEmitter` will effect this source
                case directOnly
                /// Bounced light from a `LightEmitter` will effect this source as well as light from emissive textures
                case indirectOnly
            }

            public enum Occlusion: Sendable {
                /// This source casts shadows onto itself and onto others
                case fullyOccluding
                /// This source casts shadows onto other but not onto itself
                case occludedByOthers
                /// This source casts shadows onto itself but not onto others
                case occludedBySelf
            }
            
            public static var `default`: Self {
                return Self()
            }

            public init(
                radiosity: Radiosity = .fullyRadiant,
                occlusion: Occlusion = .fullyOccluding,
                minimumTexels: Size2i = Size2i(4),
                packing: LightMapPacker.Options = .none
            ) {
                self.radiosity = radiosity
                self.occlusion = occlusion
                self.packing = packing
                self.minimumTexels = max(minimumTexels, Size2i(4))
            }
        }
        
        internal var contributesToRadiosity: Bool {
            return true
        }
        internal var recieves: Bool {
            return true
        }
    }
    
    struct BakingSource: Sendable {
        let geometry: RawGeometry
        let surface: Source.Surface
        let options: Source.Options
        
        var triangleLightMaps: [RawTexture]
        var trianglesMeta: [TriangleMeta]
    }
    
    enum Result: Sendable {
        case notBaked
        case baked(_ baked: BakedStructure)
    }
    struct BakedStructure: Sendable {
        public let geometry: RawGeometry
        public let lightMap: RawTexture
        
        init(geometry: RawGeometry, lightMap: RawTexture) {
            self.geometry = geometry
            self.lightMap = lightMap
        }
    }
}

fileprivate extension LightMapBaker {
    struct Index: Hashable, Sendable {
        let source: Int
        let triangle: Int
    }
}

fileprivate extension LightMapBaker {
    func generateRayTraceStructure(for sources: [Source]) async throws -> RayTraceStructure {
        return try await RayTraceStructure(rawGeometries: sources.map({$0.geometry}))
    }
    
    func generateBakingSources(for sources: [Source], rayTraceStructure: RayTraceStructure) async throws -> [BakingSource] {
        return try await withThrowingTaskGroup { group in
            for (sourceIndex, source) in sources.enumerated() {
                group.addTask {
                    if Task.isCancelled {
                        throw CancellationError()
                    }
                    let packer = LightMapPacker(uvSet: self.uvSetIndex, texelDensity: self.texelDensity, options: source.options)
                    var geometry = source.geometry
                    let triangleLightMaps = packer.atlasPack(&geometry).map({
                        return RawTexture(
                            imageSize: $0.size,
                            imageData: Data(repeating: 0, count: $0.size.width * $0.size.height * 4)
                        )
                    })
                    
                    let triangleMeta: [TriangleMeta] = try await withThrowingTaskGroup { group in
                        let geometry = geometry
                        for (triangleIndex, lightMap) in triangleLightMaps.enumerated() {
                            group.addTask {
                                if Task.isCancelled {
                                    throw CancellationError()
                                }
                                return (triangleIndex, try await TriangleMeta(
                                    quality: quality,
                                    sourceIndex: sourceIndex,
                                    triangleIndex: triangleIndex,
                                    triangle: geometry[triangleIndex],
                                    uvSetIndex: uvSetIndex,
                                    lightMap: lightMap,
                                    texelDensity: texelDensity,
                                    antialiasingSamples: antialiasingSamples,
                                    sampleScales: Self.sampleScales,
                                    ignoringSources: [],
                                    rayTraceStructure: rayTraceStructure
                                ))
                            }
                        }
                        
                        var results: [(index: Int, meta: TriangleMeta)] = .init(minimumCapacity: triangleLightMaps.count)
                        for try await result in group {
                            results.append(result)
                        }
                        
                        return results.sorted(by: {$0.index < $1.index}).map(\.meta)
                    }
                    
                    let bakingSource = BakingSource(
                        geometry: geometry,
                        surface: source.surface,
                        options: source.options,
                        triangleLightMaps: triangleLightMaps,
                        trianglesMeta: triangleMeta
                    )
                    return (index: sourceIndex, source: bakingSource)
                }
            }
            
            var bakingSources: [(index: Int, source: BakingSource)] = .init(minimumCapacity: sources.count)
            for try await bakingSource in group {
                bakingSources.append(bakingSource)
            }
            
            return bakingSources.sorted(by: {$0.index < $1.index}).map(\.source)
        }
    }
}

fileprivate extension LightMapBaker {
    nonisolated static let sampleScales = [
        Size2f(x: -0.5, y:  0.5), // Left Bottom
        Size2f(x:  0.5, y: -0.5), // Right Top
        Size2f(x: -0.5, y: -0.5), // Left Top
        Size2f(x:  0.5, y:  0.5), // Right Bottom
        
        Size2f(x:  0,   y:  0.5), // Center Bottom
        Size2f(x:  0.5, y:  0  ), // Right Center
        Size2f(x:  0,   y: -0.5), // Center Top
        Size2f(x: -0.5, y:    0), // Left Center
        
        Size2f(x: -0.25, y:  0.25), // Left Bottom
        Size2f(x:  0.25, y: -0.25), // Right Top
        Size2f(x: -0.25, y: -0.25), // Left Top
        Size2f(x:  0.25, y:  0.25), // Right Bottom
        
        Size2f(x:  0,    y:  0.25), // Center Bottom
        Size2f(x:  0.25, y:  0   ), // Right Center
        Size2f(x:  0,    y: -0.25), // Center Top
        Size2f(x: -0.25, y:  0   ), // Left Center
        
        Size2f(x: -0.25, y:  0.5 ), // Left EdgeBottom
        Size2f(x: -0.5,  y: -0.25), // EdgeLeft Top
        Size2f(x:  0.25, y: -0.5 ), // Right EdgeTop
        Size2f(x:  0.5,  y:  0.25), // EdgeRight Bottom
        
        Size2f(x:  0.25, y:  0.5 ), // Right EdgeBottom
        Size2f(x: -0.5,  y:  0.25), // EdgeLeft Bottom
        Size2f(x: -0.25, y: -0.5 ), // Left EdgeTop
        Size2f(x:  0.5,  y: -0.25), // EdgeRight Top
    ]
    
    func bake(_ sourceIndex: Int, triangleIndex: Int, sources: [BakingSource], lights: LightSet, rayTraceStructure: RayTraceStructure) async throws -> RawTexture {
        let source = sources[sourceIndex]
        var lightMap = source.triangleLightMaps[triangleIndex]
        let metaTriangle = source.trianglesMeta[triangleIndex]
        
        for light in lights.pointLights {
            guard metaTriangle.collisionTriangle.closestSurfacePoint(from: light.position.oldVector).distance(from: light.position.oldVector) < light.radius + 0.001 else {continue}
            for metaPixel in metaTriangle.pixels {
                try await withThrowingTaskGroup { group in
                    for metaPixelSampleIndex in metaPixel.samples.indices {
                        group.addTask {
                            if Task.isCancelled {
                                throw CancellationError()
                            }
                            return await self.process(
                                metaTriangle: metaTriangle,
                                metaPixel: metaPixel,
                                metaPixelSampleIndex: metaPixelSampleIndex,
                                light: light,
                                rayTraceStructure: rayTraceStructure
                            )
                        }
                    }
                    
                    var accumulatedSamplesResults: Color = .black
                    var accumulatedSamplesCount: Int = 0
//                    var processedSamplesCount: Int = 0
                    
                    for try await result in group {
                        if let result = result {
                            accumulatedSamplesCount += 1
                            accumulatedSamplesResults += result
                        }
//                        processedSamplesCount += 1
//                        
//                        if processedSamplesCount == 4 {
//                            if accumulatedSamplesCount == 0 {
//                                // If all 4 corners of the pixel hit nothing, we're not going to hit anything
//                                group.cancelAll()
//                                break
//                            }
//                            if accumulatedSamplesResults == .black {
//                                // If all 4 corners of the pixel produced only black, we're not going to get any color
//                                group.cancelAll()
//                                break
//                            }
//                        }
                    }
                    if accumulatedSamplesCount != 0 {
                        let result: Color = accumulatedSamplesResults / Float(accumulatedSamplesCount)
                        lightMap[metaPixel.pixelIndex] += result
                    }
                }
            }
        }
        return lightMap
    }
}

fileprivate extension LightMapBaker {
    nonisolated func process(
        metaTriangle: TriangleMeta,
        metaPixel: TriangleMeta.Pixel,
        metaPixelSampleIndex: Int,
        light: PointLight,
        rayTraceStructure: RayTraceStructure
    ) async -> Color? {
        let metaSample = metaPixel.samples[metaPixelSampleIndex]
        
        // Get the attenuation of the light
        guard let attenuation = light.attenuation(to: metaSample.worldPosition) else {
            // if the light produces no attenuation, this light has no contribution
            return nil
        }
        let sampleToLight = light.position - metaSample.worldPosition
        let surfaceAngleFactor = sampleToLight.dot(metaSample.surfaceNormal)
        
        var contributionFactor = attenuation * surfaceAngleFactor

        // If the lights color contribution is greater then zero
        if contributionFactor > 0 {
            if quality != .lowestNoShadows {
                // then check if this light hits anything on its way to the pixel
                if rayTraceStructure.isObscured(
                    from: metaSample.worldPosition,
                    to: light.position,
                    ignoringSources: metaTriangle.obscureMask.sources,
                    ignoringTriangles: metaTriangle.obscureMask.triangleObscuringSets[metaPixel.obscuringSetIndex]
                ) {
                    // If the light hits something, reduce the contribution to zero
                    contributionFactor = 0
                }
            }
        }
        
        // return the lights contribution
        return light.color * contributionFactor
    }
}

extension LightMapBaker {
    struct TriangleMeta: Sendable {
        let sourceIndex: Int
        let triangleIndex: Int
        
        let collisionTriangle: CollisionTriangle
        
        let uvTriangle: Triangle2f
        
        let pixels: ContiguousArray<Pixel>
        struct Pixel: Sendable {
            let pixelIndex: Int
            let uvRect: Rect2f
            let uvBarycentric: Position3f
            let worldPosition: Position3f
            let samples: ContiguousArray<Sample>
            let obscuringSetIndex: Int
            struct Sample: Sendable {
                let uvCenter: Position2f
                let worldPosition: Position3f
                let surfaceNormal: Direction3f
            }
        }
        
        let obscureMask: ObscureMask
        struct ObscureMask: Sendable {
            let sources: Set<Int>
            let triangleObscuringSets: ContiguousArray<Set<Int>>
        }
        
        @inlinable
        @_optimize(speed)
        init(quality: Quality,
             sourceIndex: Int,
             triangleIndex: Int,
             triangle: Triangle,
             uvSetIndex: Int,
             lightMap: RawTexture,
             texelDensity: Int,
             antialiasingSamples: Int,
             sampleScales: [Size2f],
             ignoringSources: Set<Int>,
             rayTraceStructure: RayTraceStructure
        ) async throws {
            self.sourceIndex = sourceIndex
            self.triangleIndex = triangleIndex
            self.collisionTriangle = CollisionTriangle(triangle)
            let uvTriangle = switch uvSetIndex {
            case 0:
                Triangle2f(
                    p1: .init(oldVector: triangle.v1.uv1),
                    p2: .init(oldVector: triangle.v2.uv1),
                    p3: .init(oldVector: triangle.v3.uv1)
                )
            case 1:
                Triangle2f(
                    p1: .init(oldVector: triangle.v1.uv2),
                    p2: .init(oldVector: triangle.v2.uv2),
                    p3: .init(oldVector: triangle.v3.uv2)
                )
            default:
                fatalError()
            }
            self.uvTriangle = uvTriangle
            
            let triangleWorldPosition: Position3f = .init(oldVector: triangle.center)
            let triangleFaceNormal: Direction3f = .init(oldVector: triangle.faceNormal)
            
            let pixelSize = lightMap.pixelSize
            let biasPixelSize = pixelSize + (.ulpOfOne * 2)
            let overlapBiasPixelSize = biasPixelSize * 2
            let texelWorldLength: Float = (1 / Float(texelDensity)) + (.ulpOfOne * 2)
            let halfTexelWorldLength: Float = texelWorldLength * 0.5

            let results: (pixels: ContiguousArray<Pixel>, obscuringSets: ContiguousArray<Set<Int>>)
            results = try await withThrowingTaskGroup { group in
                for pixelIndex in lightMap.indices {
                    let pixelCenter: Position2f = lightMap.textureCoordinate(for: pixelIndex)
                    guard Rect2f(size: overlapBiasPixelSize, center: pixelCenter).contains(uvTriangle.nearestSurfacePosition(to: pixelCenter)) else {continue}
                    group.addTask {
                        if Task.isCancelled {
                            throw CancellationError()
                        }
                        let pixelRect = Rect2f(size: biasPixelSize, center: pixelCenter)
                        let barycentric = uvTriangle.barycentric(from: pixelCenter)
                        let pixelWorldPosition = Position3f(
                            oldVector: (triangle.v1.position * barycentric.x) + (triangle.v2.position * barycentric.y) + (triangle.v3.position * barycentric.z)
                        )
                        
                        var obscuringSet: Set<Int> = [triangleIndex]
                        switch quality {
                        case .lowestNoShadows, .lowestFastest:
                            break
                        case .balanced:
                            if uvTriangle.contains(pixelCenter) == false {
                                let obscuring = LightMapBaker._obscuringIndicies(
                                    triangleIndex: triangleIndex,
                                    triangleWorldPosition: triangleWorldPosition,
                                    triangleFaceNormal: triangleFaceNormal,
                                    sampleWorldPosition: pixelWorldPosition.moved(texelWorldLength, toward: Direction3f(from: triangleWorldPosition, to: pixelWorldPosition)),
                                    texelDensity: texelDensity,
                                    ignoringSources: ignoringSources,
                                    rayTraceStructure: rayTraceStructure
                                )
                                obscuringSet.formUnion(obscuring)
                            }
                        case .highestSlowest:
                            let projectedUV = pixelCenter.moved(pixelSize.length, toward: Direction2f(from: uvTriangle.center, to: pixelCenter))
                            if uvTriangle.contains(projectedUV) == false {
                                let sampleDirection = Direction3f(from: triangleWorldPosition, to: pixelWorldPosition)
                                let cross = triangleFaceNormal.cross(sampleDirection)
                                let projectedSample1 = pixelWorldPosition.moved(halfTexelWorldLength, toward: sampleDirection)
                                let projectedSample2 = projectedSample1.moved(halfTexelWorldLength, toward: cross)
                                let projectedSample3 = projectedSample1.moved(halfTexelWorldLength, toward: -cross)
                                for sampleWorldPosition in [projectedSample1, projectedSample2, projectedSample3] {
                                    let obscuring = LightMapBaker._obscuringIndicies(
                                        triangleIndex: triangleIndex,
                                        triangleWorldPosition: triangleWorldPosition,
                                        triangleFaceNormal: triangleFaceNormal,
                                        sampleWorldPosition: sampleWorldPosition.moved(texelWorldLength, toward: Direction3f(from: triangleWorldPosition, to: sampleWorldPosition)),
                                        texelDensity: texelDensity,
                                        ignoringSources: ignoringSources,
                                        rayTraceStructure: rayTraceStructure
                                    )
                                    obscuringSet.formUnion(obscuring)
                                }
                            }
                        }
                        
                        var samples: ContiguousArray<Pixel.Sample> = []
                        samples.reserveCapacity(antialiasingSamples)
                        
                        if antialiasingSamples == 1 {
                            let pixelSurfaceNormal = Direction3f(
                                oldVector: (triangle.v1.normal * barycentric.x) + (triangle.v2.normal * barycentric.y) + (triangle.v3.normal * barycentric.z)
                            )
                            samples.append(
                                Pixel.Sample(
                                    uvCenter: pixelCenter,
                                    worldPosition: pixelWorldPosition,
                                    surfaceNormal: pixelSurfaceNormal
                                )
                            )
                        }else{
                            for sampleIndex in 0 ..< antialiasingSamples {
                                let scale = sampleScales[sampleIndex]
                                let sampleUVCenter = pixelCenter + (pixelSize * scale)
                                let barycentric = uvTriangle.barycentric(from: sampleUVCenter)
                                let sampleWorldPosition = Position3f(
                                    oldVector: (triangle.v1.position * barycentric.x) + (triangle.v2.position * barycentric.y) + (triangle.v3.position * barycentric.z)
                                )
                                let sampleSurfaceNormal = Direction3f(
                                    oldVector: (triangle.v1.normal * barycentric.x) + (triangle.v2.normal * barycentric.y) + (triangle.v3.normal * barycentric.z)
                                )
                                
                                samples.append(
                                    Pixel.Sample(
                                        uvCenter: sampleUVCenter,
                                        worldPosition: sampleWorldPosition,
                                        surfaceNormal: sampleSurfaceNormal
                                    )
                                )
                            }
                        }
                        
                        return (
                            pixel: Pixel(
                                pixelIndex: pixelIndex,
                                uvRect: pixelRect,
                                uvBarycentric: barycentric,
                                worldPosition: pixelWorldPosition,
                                samples: samples,
                                obscuringSetIndex: 0 // <- Will be set to correct value when processing group
                            ),
                            obscuringSet: obscuringSet
                        )
                    }
                }
                var pixels: ContiguousArray<Pixel> = []
                var obscuringSets: ContiguousArray<Set<Int>> = []
                for try await groupResult in group {
                    let obscuringSetIndex: Int
                    if let existing: Int = obscuringSets.firstIndex(of: groupResult.obscuringSet) {
                        obscuringSetIndex = existing
                    }else{
                        obscuringSetIndex = obscuringSets.endIndex
                        obscuringSets.append(groupResult.obscuringSet)
                    }
                    pixels.append(
                        Pixel(
                            pixelIndex: groupResult.pixel.pixelIndex,
                            uvRect: groupResult.pixel.uvRect,
                            uvBarycentric: groupResult.pixel.uvBarycentric,
                            worldPosition: groupResult.pixel.worldPosition,
                            samples: groupResult.pixel.samples,
                            obscuringSetIndex: obscuringSetIndex
                        )
                    )
                }
                return (pixels: pixels, obscuringSets: obscuringSets)
            }
            
            self.pixels = results.pixels
            self.obscureMask = ObscureMask(sources: ignoringSources, triangleObscuringSets: results.obscuringSets)
        }
    }
    /// Triangle indicies that should be ignored during an obscured check
    @_optimize(speed)
    static func _obscuringIndicies(
        triangleIndex: Int,
        triangleWorldPosition: Position3f,
        triangleFaceNormal: Direction3f,
        sampleWorldPosition: Position3f,
        texelDensity: Int,
        ignoringSources: Set<Int>,
        rayTraceStructure: RayTraceStructure
    ) -> Set<Int> {
//        let awayFromTriCenter = Direction3f(from: triangleWorldPosition, to: sampleWorldPosition)
//        let obscuringCheckPosition = sampleWorldPosition.moved(1.335 / Float(texelDensity), toward: awayFromTriCenter)
        return rayTraceStructure.indexesObscuring(
            from: triangleWorldPosition,
            to: sampleWorldPosition.moved(0.0001, toward: triangleFaceNormal),
            ignoringSources: ignoringSources,
            ignoringTriangles: [triangleIndex]
        )
    }
}
