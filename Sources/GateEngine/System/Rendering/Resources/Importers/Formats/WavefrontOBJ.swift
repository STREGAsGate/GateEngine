/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public class WavefrontOBJImporter: GeometryImporter {
    public required init() {}

    public func process(data: Data, baseURL: URL, options: GeometryImporterOptions) async throws -> RawGeometry {
        guard let obj = String(data: data, encoding: .utf8) else {
            throw GateEngineError.failedToDecode("File is not UTF8 or is corrupt.")
        }
        let lines = obj.components(separatedBy: "\n").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
        var prefix = "o "
        if let name = options.subobjectName {
            prefix += name
        }
        
        var index: Array<String>.Index = 0
        if let objectIndex = lines.firstIndex(where: {$0.hasPrefix(prefix)}) {
            index = objectIndex + 1 //Skip the object itself
        }else if let objectIndex = lines.firstIndex(where: {$0.hasPrefix("o ")}) {
            index = objectIndex + 1 //Skip the object itself
        }
        
        var positions: [Position3] = []
        var uvs: [Position2] = []
        var normals: [Direction3] = []
        
        var triangles: [Triangle] = []
        
        for line in lines[index...] {
            // If we reach the next object, exit loop
            guard line.hasPrefix("o ") == false else {break}
            if line.hasPrefix("v ") {
                func rawPositionConvert(_ string: String) throws -> Position3 {
                    let comps = string.components(separatedBy: " ")
                    let floats = comps.compactMap({Float($0)})
                    guard floats.count == 3 else {
                        throw GateEngineError.failedToDecode("File malformed vertex position: \(line)")
                    }
                    return Position3(floats[0], floats[1], floats[2])
                }
                positions.append(try rawPositionConvert(line))
            }else if line.hasPrefix("vt ") {
                func rawUVConvert(_ string: String) throws -> Position2 {
                    let comps = string.components(separatedBy: " ")
                    let floats = comps.compactMap({Float($0)})
                    guard floats.count == 2 else {
                        throw GateEngineError.failedToDecode("File malformed vertex texture coord: \(line)")
                    }
                    return Position2(floats[0], 1 - floats[1])
                }
                uvs.append(try rawUVConvert(line))
            }else if line.hasPrefix("vn ") {
                func rawNormalConvert(_ string: String) throws -> Direction3 {
                    let comps = string.components(separatedBy: " ")
                    let floats = comps.compactMap({Float($0)})
                    guard floats.count == 3 else {
                        throw GateEngineError.failedToDecode("File malformed at vertex Normal: \(line).")
                    }
                    return Direction3(floats[0], floats[1], floats[2])
                }
                normals.append(try rawNormalConvert(line))
            }else if line.hasPrefix("f ") {
                func rawVertexConvert(_ string: String) throws -> Vertex {
                    let comps = string.components(separatedBy: "/")
                    let indices = comps.compactMap({Int($0)}).map({$0 - 1}) //convert to base zero index
                    if indices.count >= 3 {//Has normals and possibly other stuff
                        return Vertex(positions[indices[0]], normals[indices[2]], uvs[indices[1]])
                    }else if indices.count == 2 {//Just position and texture
                        return Vertex(positions[indices[0]], .zero, uvs[indices[1]])
                    }else if indices.count == 1 {// Just position
                        return Vertex(positions[indices[0]], .zero, .zero)
                    }else{
                        throw GateEngineError.failedToDecode("File malformed at vertex from face: \(string).")
                    }
                }
                func rawTriangleConvert(_ string: String) throws -> [Triangle] {
                    let comps = string.components(separatedBy: " ")
                    var verts: [Vertex] = []
                    for raw in comps[1...] {
                        verts.append(try rawVertexConvert(raw))
                    }
   
                    if verts.count >= 3 {// N-Gon
                        var triangles = [Triangle(v1: verts[0], v2: verts[1], v3: verts[2], repairIfNeeded: true)]
                        for i in 1 ..< verts.count - 1 {
                            triangles.append(Triangle(v1: verts[0], v2: verts[i], v3: verts[i + 1], repairIfNeeded: true))
                        }
                        return triangles
                    }else{
                        throw GateEngineError.failedToDecode("File malformed at face: \(string)")
                    }
                }
                triangles.append(contentsOf: try rawTriangleConvert(line))
            }
        }
        guard triangles.isEmpty == false else {
            throw GateEngineError.failedToDecode("No triangles to create the geometry with.")
        }

        return RawGeometry(triangles: triangles)
    }

    public static func canProcessFile(_ file: URL) -> Bool {
        return file.pathExtension.caseInsensitiveCompare("obj") == .orderedSame
    }
}
