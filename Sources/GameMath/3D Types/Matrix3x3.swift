/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GameMathUseSIMD
public struct Matrix3x3: Sendable {
    public var a, b, c: Float
    public var e, f, g: Float
    public var i, j, k: Float

    @inlinable
    public init(_ a: Float, _ b: Float, _ c: Float,
                _ e: Float, _ f: Float, _ g: Float,
                _ i: Float, _ j: Float, _ k: Float) {
        self.a = a; self.b = b; self.c = c;
        self.e = e; self.f = f; self.g = g;
        self.i = i; self.j = j; self.k = k;
    }
}
#else
public struct Matrix3x3: Sendable {
    public var a, b, c: Float
    public var e, f, g: Float
    public var i, j, k: Float

    @inlinable
    public init(_ a: Float, _ b: Float, _ c: Float,
                _ e: Float, _ f: Float, _ g: Float,
                _ i: Float, _ j: Float, _ k: Float) {
        self.a = a; self.b = b; self.c = c;
        self.e = e; self.f = f; self.g = g;
        self.i = i; self.j = j; self.k = k;
    }
}
#endif
 
public extension Matrix3x3 {
    @inlinable
    init(a: Float, b: Float, c: Float,
                e: Float, f: Float, g: Float,
                i: Float, j: Float, k: Float) {
        self.init(a, b, c, e, f, g, i, j, k)
    }
    
    @inlinable
    init(_ matrix4: Matrix4x4) {
        self.a = matrix4.a; self.b = matrix4.b; self.c = matrix4.c;
        self.e = matrix4.e; self.f = matrix4.f; self.g = matrix4.g;
        self.i = matrix4.i; self.j = matrix4.j; self.k = matrix4.k;
    }
    
    @inlinable
    init() {
        self.a = 0; self.b = 0; self.c = 0;
        self.e = 0; self.f = 0; self.g = 0;
        self.i = 0; self.j = 0; self.k = 0;
    }
    
    //MARK: Subscript
    @inlinable
    subscript (_ index: Int) -> Float {
        get {
            switch index {
            case 0: return a
            case 1: return b
            case 2: return c
            case 3: return e
            case 4: return f
            case 5: return g
            case 6: return i
            case 7: return j
            case 8: return k
            default:
                fatalError("Index \(index) out of range \(0 ..< 9) for type \(type(of: self))")
            }
        }
        set(val) {
            switch index {
            case 0: a = val
            case 1: b = val
            case 2: c = val
            case 3: e = val
            case 4: f = val
            case 5: g = val
            case 6: i = val
            case 7: j = val
            case 8: k = val
            default:
                fatalError("Index \(index) out of range \(0 ..< 9) for type \(type(of: self))")
            }
        }
    }
    
    @inlinable
    subscript (_ column: Array<Float>.Index) -> Array<Float> {
        get {
            switch column {
            case 0: return [a, e, i]
            case 1: return [b, f, j]
            case 2: return [c, g, k]
            default:
                fatalError("Column \(column) out of range \(0 ..< 3) for type \(type(of: self))")
            }
        }
        set {
            switch column {
            case 0:
                a = newValue[0]
                e = newValue[1]
                i = newValue[2]
            case 1:
                b = newValue[0]
                f = newValue[1]
                j = newValue[2]
            case 2:
                c = newValue[0]
                g = newValue[1]
                k = newValue[2]
            default:
                fatalError("Column \(column) out of range \(0 ..< 3) for type \(type(of: self))")
            }
        }
    }

    @inlinable
    subscript <V: Vector3>(_ index: Array<Float>.Index) -> V {
        get {
            switch index {
            case 0: return V(a, b, c)
            case 1: return V(e, f, g)
            case 2: return V(i, j, k)
            default:
                fatalError("Index \(index) out of range \(0 ..< 3) for type \(type(of: self))")
            }
        }
        set {
            switch index {
            case 0:
                a = newValue.x
                b = newValue.y
                c = newValue.z
            case 1:
                e = newValue.x
                f = newValue.y
                g = newValue.z
            case 2:
                i = newValue.x
                j = newValue.y
                k = newValue.z
            default:
                fatalError("Index \(index) out of range \(0 ..< 3) for type \(type(of: self))")
            }
        }
    }
}

public extension Matrix3x3 {
    @inlinable
    init(direction: Direction3, up: Direction3 = .up, right: Direction3 = .right) {
        var xaxis: Direction3
        if direction == up {
            xaxis = right
        }else{
            xaxis = up.cross(direction).normalized
            if xaxis.isFinite == false {
                xaxis = direction
            }
        }
        
        var yaxis = direction.cross(xaxis).normalized
        if yaxis.isFinite == false {
            yaxis = up
        }
        
        a = xaxis.x
        e = yaxis.x
        i = direction.x
        
        b = xaxis.y
        f = yaxis.y
        j = direction.y
        
        c = xaxis.z
        g = yaxis.z
        k = direction.z
    }
    
    @inlinable
    var rotation: Quaternion {
        get {
            return Quaternion(rotationMatrix: self)
        }
        set {
            let w: Float = newValue.w
            let x: Float = newValue.x
            let y: Float = newValue.y
            let z: Float = newValue.z
            
            var fx: Float = x * z
            fx -= w * y
            fx *= 2
            
            var fy: Float = y * z
            fy += w * x
            fy *= 2
            
            var fz: Float = x * x
            fz += y * y
            fz *= 2
            fz = 1 - fz
            
            
            var ux: Float = x * y
            ux += w * z
            ux *= 2
            
            var uy: Float = x * x
            uy += z * z
            uy *= 2
            uy = 1 - uy
            
            var uz: Float = y * z
            uz -= w * x
            uz *= 2
            
            
            var rx: Float = y * y
            rx += z * z
            rx *= 2
            rx = 1 - rx
            
            var ry: Float = x * y
            ry -= w * z
            ry *= 2
            
            var rz: Float = x * z
            rz += w * y
            rz *= 2
            
            a = rx; b = ry; c = rz
            e = ux; f = uy; g = uz
            i = fx; j = fy; k = fz
        }
    }
}

public extension Matrix3x3 {
    @inlinable
    func transposedArray() -> [Float] {
        return [a, e, i,
                b, f, j,
                c, g, k]
    }
    @inlinable
    func array() -> [Float] {
        return [a, b, c,
                e, f, g,
                i, j, k]
    }
}

extension Matrix3x3: Equatable {}
extension Matrix3x3: Hashable {}
extension Matrix3x3: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(a)
        try container.encode(b)
        try container.encode(c)
        try container.encode(e)
        try container.encode(f)
        try container.encode(g)
        try container.encode(i)
        try container.encode(j)
        try container.encode(k)
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.a = try container.decode(Float.self)
        self.b = try container.decode(Float.self)
        self.c = try container.decode(Float.self)
        self.e = try container.decode(Float.self)
        self.f = try container.decode(Float.self)
        self.g = try container.decode(Float.self)
        self.i = try container.decode(Float.self)
        self.j = try container.decode(Float.self)
        self.k = try container.decode(Float.self)
    }
}
