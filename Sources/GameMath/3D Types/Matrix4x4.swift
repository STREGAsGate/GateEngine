/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GameMathUseSIMD
public struct Matrix4x4: Sendable {
    @usableFromInline internal var storage: [SIMD4<Float>]
    @usableFromInline internal init(storage: [SIMD4<Float>]) {
        self.storage = storage
    }

    @inlinable public var a: Float {get{storage[0][0]} set{storage[0][0] = newValue}}
    @inlinable public var b: Float {get{storage[1][0]} set{storage[1][0] = newValue}}
    @inlinable public var c: Float {get{storage[2][0]} set{storage[2][0] = newValue}}
    @inlinable public var d: Float {get{storage[3][0]} set{storage[3][0] = newValue}}
    @inlinable public var e: Float {get{storage[0][1]} set{storage[0][1] = newValue}}
    @inlinable public var f: Float {get{storage[1][1]} set{storage[1][1] = newValue}}
    @inlinable public var g: Float {get{storage[2][1]} set{storage[2][1] = newValue}}
    @inlinable public var h: Float {get{storage[3][1]} set{storage[3][1] = newValue}}
    @inlinable public var i: Float {get{storage[0][2]} set{storage[0][2] = newValue}}
    @inlinable public var j: Float {get{storage[1][2]} set{storage[1][2] = newValue}}
    @inlinable public var k: Float {get{storage[2][2]} set{storage[2][2] = newValue}}
    @inlinable public var l: Float {get{storage[3][2]} set{storage[3][2] = newValue}}
    @inlinable public var m: Float {get{storage[0][3]} set{storage[0][3] = newValue}}
    @inlinable public var n: Float {get{storage[1][3]} set{storage[1][3] = newValue}}
    @inlinable public var o: Float {get{storage[2][3]} set{storage[2][3] = newValue}}
    @inlinable public var p: Float {get{storage[3][3]} set{storage[3][3] = newValue}}

    public init(_ a: Float, _ b: Float, _ c: Float, _ d: Float,
                _ e: Float, _ f: Float, _ g: Float, _ h: Float,
                _ i: Float, _ j: Float, _ k: Float, _ l: Float,
                _ m: Float, _ n: Float, _ o: Float, _ p: Float) {
        self.storage = [SIMD4(a,e,i,m),
                        SIMD4(b,f,j,n),
                        SIMD4(c,g,k,o),
                        SIMD4(d,h,l,p)]
    }
}
#else
public struct Matrix4x4: Sendable {
    public var a: Float, b: Float, c: Float, d: Float
    public var e: Float, f: Float, g: Float, h: Float
    public var i: Float, j: Float, k: Float, l: Float
    public var m: Float, n: Float, o: Float, p: Float
    
    @inlinable
    public init(_ a: Float, _ b: Float, _ c: Float, _ d: Float,
                _ e: Float, _ f: Float, _ g: Float, _ h: Float,
                _ i: Float, _ j: Float, _ k: Float, _ l: Float,
                _ m: Float, _ n: Float, _ o: Float, _ p: Float) {
        self.a = a; self.b = b; self.c = c; self.d = d
        self.e = e; self.f = f; self.g = g; self.h = h
        self.i = i; self.j = j; self.k = k; self.l = l
        self.m = m; self.n = n; self.o = o; self.p = p
    }
}
#endif

public extension Matrix4x4 {
    @inlinable
    init(a: Float, b: Float, c: Float, d: Float,
         e: Float, f: Float, g: Float, h: Float,
         i: Float, j: Float, k: Float, l: Float,
         m: Float, n: Float, o: Float, p: Float) {
        self.init(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p)
    }
    
    @inlinable
    init(repeating value: Float) {
        self.init(a: value, b: value, c: value, d: value,
                  e: value, f: value, g: value, h: value,
                  i: value, j: value, k: value, l: value,
                  m: value, n: value, o: value, p: value)
    }
    
    @inlinable
    init(_ value: [Float]) {
        assert(value.count == 16, "Matrix4x4 must be initialized with exactly 16 elements.")
        self.init(a: value[0],  b: value[1],  c: value[2],  d: value[3],
                  e: value[4],  f: value[5],  g: value[6],  h: value[7],
                  i: value[8],  j: value[9],  k: value[10], l: value[11],
                  m: value[12], n: value[13], o: value[14], p: value[15])
    }
    
    @inlinable
    init(position: Position3, rotation: Quaternion, scale: Size3) {
        self = Self(position: position) * Self(rotation: rotation) * Self(scale: scale)
    }
}

public extension Matrix4x4 {
    static let identity = Self(a: 1, b: 0, c: 0, d: 0,
                               e: 0, f: 1, g: 0, h: 0,
                               i: 0, j: 0, k: 1, l: 0,
                               m: 0, n: 0, o: 0, p: 1)
    
    @inlinable
    mutating func becomeIdentity() {
        a = 1; b = 0; c = 0; d = 0
        e = 0; f = 1; g = 0; h = 0
        i = 0; j = 0; k = 1; l = 0
        m = 0; n = 0; o = 0; p = 1
    }
    
    #if DEBUG
    @_transparent // Force optimization in DEBUG builds for performance
    #else
    @inlinable
    #endif
    var inverse: Self {
        var a: Float = self.f * self.k * self.p
        a -= self.f * self.l * self.o
        a -= self.j * self.g * self.p
        a += self.j * self.h * self.o
        a += self.n * self.g * self.l
        a -= self.n * self.h * self.k
        var b: Float = -self.b * self.k * self.p
        b += self.b * self.l * self.o
        b += self.j * self.c * self.p
        b -= self.j * self.d * self.o
        b -= self.n * self.c * self.l
        b += self.n * self.d * self.k
        var c: Float = self.b * self.g * self.p
        c -= self.b * self.h * self.o
        c -= self.f * self.c * self.p
        c += self.f * self.d * self.o
        c += self.n * self.c * self.h
        c -= self.n * self.d * self.g
        var d: Float = -self.b * self.g * self.l
        d += self.b * self.h * self.k
        d += self.f * self.c * self.l
        d -= self.f * self.d * self.k
        d -= self.j * self.c * self.h
        d += self.j * self.d * self.g
        
        var e: Float = -self.e * self.k * self.p
        e += self.e * self.l * self.o
        e += self.i * self.g * self.p
        e -= self.i * self.h * self.o
        e -= self.m * self.g * self.l
        e += self.m * self.h * self.k
        var f: Float = self.a * self.k * self.p
        f -= self.a * self.l * self.o
        f -= self.i * self.c * self.p
        f += self.i * self.d * self.o
        f += self.m * self.c * self.l
        f -= self.m * self.d * self.k
        var g: Float = -self.a * self.g * self.p
        g += self.a * self.h * self.o
        g += self.e * self.c * self.p
        g -= self.e * self.d * self.o
        g -= self.m * self.c * self.h
        g += self.m * self.d * self.g
        var h: Float = self.a * self.g * self.l
        h -= self.a * self.h * self.k
        h -= self.e * self.c * self.l
        h += self.e * self.d * self.k
        h += self.i * self.c * self.h
        h -= self.i * self.d * self.g
        
        var i: Float = self.e * self.j * self.p
        i -= self.e * self.l * self.n
        i -= self.i * self.f * self.p
        i += self.i * self.h * self.n
        i += self.m * self.f * self.l
        i -= self.m * self.h * self.j
        var j: Float = -self.a * self.j * self.p
        j += self.a * self.l * self.n
        j += self.i * self.b * self.p
        j -= self.i * self.d * self.n
        j -= self.m * self.b * self.l
        j += self.m * self.d * self.j
        var k: Float = self.a * self.f * self.p
        k -= self.a * self.h * self.n
        k -= self.e * self.b * self.p
        k += self.e * self.d * self.n
        k += self.m * self.b * self.h
        k -= self.m * self.d * self.f
        var l: Float = -self.a * self.f * self.l
        l += self.a * self.h * self.j
        l += self.e * self.b * self.l
        l -= self.e * self.d * self.j
        l -= self.i * self.b * self.h
        l += self.i * self.d * self.f
        
        var m: Float = -self.e * self.j * self.o
        m += self.e * self.k * self.n
        m += self.i * self.f * self.o
        m -= self.i * self.g * self.n
        m -= self.m * self.f * self.k
        m += self.m * self.g * self.j
        var n: Float = self.a * self.j * self.o
        n -= self.a * self.k * self.n
        n -= self.i * self.b * self.o
        n += self.i * self.c * self.n
        n += self.m * self.b * self.k
        n -= self.m * self.c * self.j
        var o: Float = -self.a * self.f * self.o
        o += self.a * self.g * self.n
        o += self.e * self.b * self.o
        o -= self.e * self.c * self.n
        o -= self.m * self.b * self.g
        o += self.m * self.c * self.f
        var p: Float = self.a * self.f * self.k
        p -= self.a * self.g * self.j
        p -= self.e * self.b * self.k
        p += self.e * self.c * self.j
        p += self.i * self.b * self.g
        p -= self.i * self.c * self.f
        
        var inv: Matrix4x4 = Matrix4x4(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p)
        
        var det: Float = self.a * inv.a
        det += self.b * inv.b
        det += self.c * inv.i
        det += self.d * inv.m
        
        if det != 0 {
            det = 1 / det
        }
        
        for i in 0 ..< 16 {
            inv[i] *= det
        }
        
        return inv
    }
}
    //MARK: Subscript
public extension Matrix4x4 {
    @inlinable
    subscript (_ index: Int) -> Float {
        get {
            switch index {
            case 0: return a
            case 1: return b
            case 2: return c
            case 3: return d
            case 4: return e
            case 5: return f
            case 6: return g
            case 7: return h
            case 8: return i
            case 9: return j
            case 10: return k
            case 11: return l
            case 12: return m
            case 13: return n
            case 14: return o
            case 15: return p
            default:
                fatalError("Index \(index) out of range \(0 ..< 16) for type \(type(of: self))")
            }
        }
        
        set(val) {
            switch index {
            case 0: a = val
            case 1: b = val
            case 2: c = val
            case 3: d = val
            case 4: e = val
            case 5: f = val
            case 6: g = val
            case 7: h = val
            case 8: i = val
            case 9: j = val
            case 10: k = val
            case 11: l = val
            case 12: m = val
            case 13: n = val
            case 14: o = val
            case 15: p = val
            default:
                fatalError("Index \(index) out of range \(0 ..< 16) for type \(type(of: self))")
            }
        }
    }
}
public extension Matrix4x4 {
    @inlinable
    subscript (_ column: Array<Float>.Index) -> SIMD4<Float> {
        get {
            assert(column < 4, "Index \(column) out of range \(0 ..< 4) for type \(type(of: self))")
            #if GameMathUseSIMD
            return storage[column]
            #else
            switch column {
            case 0: return [a, e, i, m]
            case 1: return [b, f, j, n]
            case 2: return [c, g, k, o]
            case 3: return [m, n, o, p]
            default:
                fatalError()
            }
            #endif
        }
        set {
            assert(column < 4, "Index \(column) out of range \(0 ..< 4) for type \(type(of: self))")
            #if GameMathUseSIMD
            storage[column] = newValue
            #else
            switch column {
            case 0:
                a = newValue[0]
                e = newValue[1]
                i = newValue[2]
                m = newValue[3]
            case 1:
                b = newValue[0]
                f = newValue[1]
                j = newValue[2]
                n = newValue[3]
            case 2:
                c = newValue[0]
                g = newValue[1]
                k = newValue[2]
                o = newValue[3]
            case 3:
                m = newValue[0]
                n = newValue[1]
                o = newValue[2]
                p = newValue[3]
            default:
                fatalError()
            }
            #endif
        }
    }
}



//MARK: - Transform

public extension Matrix4x4 {
    @inlinable
    var transform: Transform3 {
        return Transform3(position: position, rotation: rotation, scale: scale)
    }
}

//MARK: Translate
public extension Matrix4x4 {
    @inlinable
    init(position: Position3) {
        self.init(1, 0, 0, position.x,
                  0, 1, 0, position.y,
                  0, 0, 1, position.z,
                  0, 0, 0, 1)
    }
    
    @inlinable
    var position: Position3 {
        get {
            return Position3(x: d, y: h, z: l)
        }
        set {
            d = newValue.x
            h = newValue.y
            l = newValue.z
        }
    }
}

//MARK: Rotate
public extension Matrix4x4 {
    @inlinable
    init(rotation quaternion: Quaternion) {
        let x: Float = quaternion.x
        let y: Float = quaternion.y
        let z: Float = quaternion.z
        let w: Float = quaternion.w


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

        #if GameMathUseSIMD
        self.storage = [SIMD4(rx, ux, fx, 0),
                        SIMD4(ry, uy, fy, 0),
                        SIMD4(rz, uz, fz, 0),
                        SIMD4(0,  0,  0,  1)]
        #else
        a = rx; b = ry; c = rz; d = 0
        e = ux; f = uy; g = uz; h = 0
        i = fx; j = fy; k = fz; l = 0
        m = 0;  n = 0;  o = 0;  p = 1
        #endif
    }
    
    @inlinable
    init(rotationWithForward forward: Direction3, up: Direction3 = .up, right: Direction3 = .right) {
        self.init(right.x,     right.y,    right.z,    0,
                  up.x,        up.y,       up.z,       0,
                  forward.x,   forward.y,  forward.z,  0,
                  0,           0,          0,          1)
    }
    
    @inlinable
    var rotation: Quaternion {
        get {
            return Quaternion(rotationMatrix: self.rotationMatrix)
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
    
    @inlinable
    var rotationMatrix: Self {
        let scale = self.scale
        return Matrix4x4(a: a/scale.x, b: b/scale.y, c: c/scale.z, d: 0,
                         e: e/scale.x, f: f/scale.y, g: g/scale.z, h: 0,
                         i: i/scale.x, j: j/scale.y, k: k/scale.z, l: 0,
                         m: 0,         n: 0,         o: 0,         p: 0)
    }
    
    @inlinable
    func lookingAt(_ position: Position3) -> Self {
        let eye = self.position
        let zaxis = Direction3(eye - position).normalized// The "forward" vector.
        let xaxis = self.rotation.up.cross(zaxis)           // The "right" vector.
        let yaxis = zaxis.cross(xaxis)                      // The "up" vector.
        
        return Matrix4x4(a: xaxis.x, b: xaxis.y, c: xaxis.z, d: -xaxis.dot(eye),
                         e: yaxis.x, f: yaxis.y, g: yaxis.z, h: -yaxis.dot(eye),
                         i: zaxis.x, j: zaxis.y, k: zaxis.z, l: -zaxis.dot(eye),
                         m: 0,       n: 0,       o: 0,       p: 1)
    }
}

//MARK: Scale
public extension Matrix4x4 {
    @inlinable
    init(scale size: Size3) {
        self.init(size.x,  0,      0,      0,
                  0,       size.y, 0,      0,
                  0,       0,      size.z, 0,
                  0,       0,      0,      1)
    }
    
    @inlinable
    var scale: Size3 {
        get {
            var w: Float = a * a
            w += e * e
            w += i * i
            var h: Float = b * b
            h += f * f
            h += j * j
            var d: Float = c * c
            d += g * g
            d += k * k
            return Size3(width: w.squareRoot(),
                         height: h.squareRoot(),
                         depth: d.squareRoot())
        }
        set {
            a = newValue.width
            f = newValue.height
            k = newValue.depth
        }
    }
}

//MARK: - Projection
public extension Matrix4x4 {
    @inlinable
    init(perspectiveWithFOV fov: Float, aspect: Float, near: Float, far: Float) {
        let tanHalfFOV: Float = tan(fov / 2);
        let zRange: Float = near - far;
        
        var a: Float = tanHalfFOV * aspect
        a = 1 / a
        let f: Float = 1 / tanHalfFOV
        var k: Float = -near - far
        k /= zRange
        var l: Float = far * near
        l *= 2
        l /= zRange
        
        self.init(a, 0, 0, 0,
                  0, f, 0, 0,
                  0, 0, k, l,
                  0, 0, 1, 0)
    }
    
    @inlinable
    init(orthographicWithTop top: Float, left: Float, bottom: Float, right: Float, near: Float, far: Float) {
        let width = right - left;
        let height = top - bottom;
        let depth = -(far - near);
        
        self.init(2 / width,   0,          0,          -(right + left) / width,
                  0,           2 / height, 0,          -(top + bottom) / height,
                  0,           0,          2 / depth,  -(far + near) / depth,
                  0,           0,          0,          1)
    }
    
    enum OrthoMatrixCenter {
        case center
        case topLeft
    }
    @inlinable
    init(orthographicWithSize size: Size2, center: OrthoMatrixCenter, near: Float, far: Float) {
        switch center {
        case .center:
            let width = size.width / 2
            let height = size.height / 2
            self.init(orthographicWithTop: -height, left: -width, bottom: height, right: width, near: near, far: far)
        case .topLeft:
            self.init(orthographicWithTop: 0, left: 0, bottom: size.height, right: size.width, near: near, far: far)
        }
    }
}

//MARK: - Graphics
extension Matrix4x4 {
    @inlinable
    public var simd: SIMD16<Float> {
        return SIMD16<Float>(a, b, c, d,
                             e, f, g, h,
                             i, j, k, l,
                             m, n, o, p)
    }
    @inlinable
    public var transposedSIMD: SIMD16<Float>  {
        return SIMD16<Float>(a, e, i, m,
                             b, f, j, n,
                             c, g, k, o,
                             d, h, l, p)
    }
}

extension Matrix4x4 {
    @inlinable
    public func transposedArray() -> [Float] {
        return [a, e, i, m,
                b, f, j, n,
                c, g, k, o,
                d, h, l, p]
    }
    
    @inlinable
    public func array() -> [Float] {
        return [a, b, c, d,
                e, f, g, h,
                i, j, k, l,
                m, n, o, p]
    }

    @inlinable
    public init(transposedArray value: [Float]) {
        assert(value.count == 16, "Matrix4x4 must be initialized with exactly 16 elements.")
        self.init(a: value[0], b: value[4], c: value[8],  d: value[12],
                  e: value[1], f: value[5], g: value[9],  h: value[13],
                  i: value[2], j: value[6], k: value[10], l: value[14],
                  m: value[3], n: value[7], o: value[11], p: value[15])
    }
    
    @inlinable
    public func transposed() -> Self {
        return Self(self.transposedArray())
    }
}

extension Matrix4x4 {
    @inlinable
    public var isFinite: Bool {
        for value in self.array() {
            guard value.isFinite else {return false}
        }
        return true
    }
}

//MARK: - Operators
#if GameMathUseSIMD
#if canImport(simd)
import simd
#endif
public extension Matrix4x4 {
    @inlinable
    static func *=(lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }
    
    @inlinable
    static func *(lhs: Self, rhs: Self) -> Self {
        #if canImport(simd)
        let r = simd_mul(simd_float4x4(lhs[0], lhs[1], lhs[2], lhs[3]),
                         simd_float4x4(rhs[0], rhs[1], rhs[2], rhs[3]))
        
        return Self(storage: [r[0], r[1], r[2], r[3]])
        #else
        let lhs = lhs.transposed()
        var mtx: Matrix4x4 = .identity
        for index1 in 0 ..< 4 {
            let v1: SIMD4<Float> = lhs[index1]
            for index2 in 0 ..< 4 {
                let index = (4 * index1) + index2
                let v2: SIMD4<Float> = rhs[index2]
                mtx[index] = (v1 * v2).sum()
            }
        }
        return mtx
        #endif
    }
}
#else
public extension Matrix4x4 {
    @inlinable
    static func *=(lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }
    
    #if DEBUG
    @_transparent // Force optimization and inlining in DEBUG builds for performance
    #else
    @inlinable
    #endif
    static func *(lhs: Self, rhs: Self) -> Self {
        var a: Float = lhs.a * rhs.a
        a += lhs.b * rhs.e
        a += lhs.c * rhs.i
        a += lhs.d * rhs.m
        var b: Float = lhs.a * rhs.b
        b += lhs.b * rhs.f
        b += lhs.c * rhs.j
        b += lhs.d * rhs.n
        var c: Float = lhs.a * rhs.c
        c += lhs.b * rhs.g
        c += lhs.c * rhs.k
        c += lhs.d * rhs.o
        var d: Float = lhs.a * rhs.d
        d += lhs.b * rhs.h
        d += lhs.c * rhs.l
        d += lhs.d * rhs.p
        
        var e: Float = lhs.e * rhs.a
        e += lhs.f * rhs.e
        e += lhs.g * rhs.i
        e += lhs.h * rhs.m
        var f: Float = lhs.e * rhs.b
        f += lhs.f * rhs.f
        f += lhs.g * rhs.j
        f += lhs.h * rhs.n
        var g: Float = lhs.e * rhs.c
        g += lhs.f * rhs.g
        g += lhs.g * rhs.k
        g += lhs.h * rhs.o
        var h: Float = lhs.e * rhs.d
        h += lhs.f * rhs.h
        h += lhs.g * rhs.l
        h += lhs.h * rhs.p
        
        var i: Float = lhs.i * rhs.a
        i += lhs.j * rhs.e
        i += lhs.k * rhs.i
        i += lhs.l * rhs.m
        var j: Float = lhs.i * rhs.b
        j += lhs.j * rhs.f
        j += lhs.k * rhs.j
        j += lhs.l * rhs.n
        var k: Float = lhs.i * rhs.c
        k += lhs.j * rhs.g
        k += lhs.k * rhs.k
        k += lhs.l * rhs.o
        var l: Float = lhs.i * rhs.d
        l += lhs.j * rhs.h
        l += lhs.k * rhs.l
        l += lhs.l * rhs.p
        
        var m: Float = lhs.m * rhs.a
        m += lhs.n * rhs.e
        m += lhs.o * rhs.i
        m += lhs.p * rhs.m
        var n: Float = lhs.m * rhs.b
        n += lhs.n * rhs.f
        n += lhs.o * rhs.j
        n += lhs.p * rhs.n
        var o: Float = lhs.m * rhs.c
        o += lhs.n * rhs.g
        o += lhs.o * rhs.k
        o += lhs.p * rhs.o
        var p: Float = lhs.m * rhs.d
        p += lhs.n * rhs.h
        p += lhs.o * rhs.l
        p += lhs.p * rhs.p
        return Self(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p)
    }
}
#endif

extension Matrix4x4: Equatable {}
extension Matrix4x4: Hashable {}
extension Matrix4x4: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p])
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let storage = try container.decode(Array<Float>.self)
        self.init(storage)
    }
}
