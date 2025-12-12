/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public final class WavefrontOBJImporter: GeometryImporter {
    var lines: [String] = []
    
    public required init() {}
    
    public func synchronousPrepareToImportResourceFrom(path: String) throws(GateEngineError) {
        do {
            let data = try Platform.current.synchronousLoadResource(from: path)
            guard let obj = String(data: data, encoding: .utf8) else {
                throw GateEngineError.failedToDecode("File is not UTF8 or is corrupt.")
            }
            self.lines = obj.components(separatedBy: "\n").map({
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            })
        }catch{
            throw GateEngineError(error)
        }
    }
    public func prepareToImportResourceFrom(path: String) async throws(GateEngineError) {
        do {
            let data = try await Platform.current.loadResource(from: path)
            guard let obj = String(data: data, encoding: .utf8) else {
                throw GateEngineError.failedToDecode("File is not UTF8 or is corrupt.")
            }
            self.lines = obj.components(separatedBy: "\n").map({
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            })
        }catch{
            throw GateEngineError(error)
        }
    }
    
    public func currentFileContainsMutipleResources() -> Bool {
        return lines.count(where: {$0.hasPrefix("o ")}) > 1
    }
    
    public func loadGeometry(options: GeometryImporterOptions) async throws(GateEngineError) -> RawGeometry {
        do {
            var prefix = "o "
            if let name = options.subobjectName {
                prefix += name
            }
            
            var index: Array<String>.Index = 0
            if let objectIndex = lines.firstIndex(where: { $0.hasPrefix(prefix) }) {
                index = objectIndex + 1  //Skip the object itself
            } else if let objectIndex = lines.firstIndex(where: { $0.hasPrefix("o ") }) {
                index = objectIndex + 1  //Skip the object itself
            }
            
            var positions: [Position3] = []
            var uvs: [TextureCoordinate] = []
            var normals: [Direction3] = []
            
            var rawGeometry: RawGeometry = []
            
            for line in lines[index...] {
                // If we reach the next object, exit loop
                guard line.hasPrefix("o ") == false else { break }
                if line.hasPrefix("v ") {
                    func rawPositionConvert(_ string: String) throws -> Position3 {
                        let comps = string.components(separatedBy: " ")
                        let floats = comps.compactMap({ Float($0) })
                        guard floats.count == 3 else {
                            throw GateEngineError.failedToDecode(
                                "File malformed vertex position: \(line)"
                            )
                        }
                        return Position3(floats[0], floats[1], floats[2])
                    }
                    positions.append(try rawPositionConvert(line))
                } else if line.hasPrefix("vt ") {
                    func rawUVConvert(_ string: String) throws -> TextureCoordinate {
                        let comps = string.components(separatedBy: " ")
                        let floats = comps.compactMap({ Float($0) })
                        guard floats.count == 2 else {
                            throw GateEngineError.failedToDecode(
                                "File malformed vertex texture coord: \(line)"
                            )
                        }
                        return TextureCoordinate(floats[0], 1 - floats[1])
                    }
                    uvs.append(try rawUVConvert(line))
                } else if line.hasPrefix("vn ") {
                    func rawNormalConvert(_ string: String) throws -> Direction3 {
                        let comps = string.components(separatedBy: " ")
                        let floats = comps.compactMap({ Float($0) })
                        guard floats.count == 3 else {
                            throw GateEngineError.failedToDecode(
                                "File malformed at vertex Normal: \(line)."
                            )
                        }
                        return Direction3(floats[0], floats[1], floats[2])
                    }
                    normals.append(try rawNormalConvert(line))
                } else if line.hasPrefix("f ") {
                    func rawVertexConvert(_ string: String) throws -> Vertex {
                        let comps = string.components(separatedBy: "/")
                        let indices = comps.compactMap({ Int($0) }).map({ $0 - 1 })  //convert to base zero index
                        if indices.count >= 3 {  //Has normals and possibly other stuff
                            return Vertex(position: positions[indices[0]], normal: normals[indices[2]], uvSet1: uvs[indices[1]])
                        } else if indices.count == 2 {  //Just position and texture or position and normal
                            let index1 = indices[1]
                            let hasUVs = uvs.indices.contains(index1)
                            let hasNormals = normals.indices.contains(index1)
                            return Vertex(
                                position: positions[indices[0]],
                                normal: hasNormals ? normals[indices[1]] : .zero,
                                uvSet1: hasUVs ? uvs[indices[1]] : .zero
                            )
                        } else if indices.count == 1 {  // Just position
                            return Vertex(position: positions[indices[0]])
                        } else {
                            throw GateEngineError.failedToDecode(
                                "File malformed at vertex from face: \(string)."
                            )
                        }
                    }
                    func rawTriangleConvert(_ string: String) throws -> [Triangle] {
                        let comps = string.components(separatedBy: " ")
                        var verts: [Vertex] = []
                        for raw in comps[1...] {
                            verts.append(try rawVertexConvert(raw))
                        }
                        
                        if verts.count >= 3 {  // N-Gon
                            var triangles: [Triangle] = []
                            for i in 1 ..< verts.count - 1 {
                                triangles.append(
                                    Triangle(
                                        v1: verts[0],
                                        v2: verts[i],
                                        v3: verts[i + 1],
                                        repairIfNeeded: true
                                    )
                                )
                            }
                            return triangles
                        } else {
                            throw GateEngineError.failedToDecode("File malformed at face: \(string)")
                        }
                    }
                    rawGeometry.append(contentsOf: try rawTriangleConvert(line))
                }
            }
            guard rawGeometry.isEmpty == false else {
                throw GateEngineError.failedToDecode("No triangles to create the geometry with.")
            }
            
            return rawGeometry
        }catch{
            throw GateEngineError(error)
        }
    }
    
    public static func supportedFileExtensions() -> [String] {
        return ["obj"]
    }
}
