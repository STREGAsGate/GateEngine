/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public enum OpenGL {
    public enum Blending {
        public enum Equation { 
                case min
                case max
                case add
                case subtract
                case reverseSubtract
            
            @inlinable @inline(__always) internal var value: Int32 {
                switch self {
                case .min: return GL_MIN
                case .max: return GL_MAX
                case .add: return GL_FUNC_ADD
                case .subtract: return GL_FUNC_SUBTRACT
                case .reverseSubtract: return GL_FUNC_REVERSE_SUBTRACT
                }
            }
        }
        public enum Function {
            ///(0,0,0,0)
            case zero
            ///(1,1,1,1)
            case one
            ///(Rs0kR,Gs0kG,Bs0kB,As0kA)
            case sourceColor
            ///(1,1,1,1)−(Rs0kR,Gs0kG,Bs0kB,As0kA)
            case oneMinusSourceColor
            ///(RdkR,GdkG,BdkB,AdkA)
            case destinationColor
            ///(1,1,1,1)−(RdkR,GdkG,BdkB,AdkA)
            case oneMinusDestinationColor
            ///(As0kA,As0kA,As0kA,As0kA)
            case sourceAlpha
            ///(1,1,1,1)−(As0kA,As0kA,As0kA,As0kA)
            case oneMinusSourceAlpha
            ///(AdkA,AdkA,AdkA,AdkA)
            case destinationAlpha
            ///(1,1,1,1)−(AdkA,AdkA,AdkA,AdkA)
            case oneMinusDestinationAlpha
            ///(Rc,Gc,Bc,Ac)
            case constantColor
            ///(1,1,1,1)−(Rc,Gc,Bc,Ac)
            case oneMinusConstantColor
            ///(Ac,Ac,Ac,Ac)
            case constantAlpha
            ///(1,1,1,1)−(Ac,Ac,Ac,Ac)
            case oneMinusConstantAlpha
            ///(i,i,i,1)
            case sourceAlphaSaturate
            
            @inlinable @inline(__always) internal var value: Int32 {
                switch self {
                case .zero: return GL_ZERO
                case .one: return GL_ONE
                case .sourceColor: return GL_SRC_COLOR
                case .oneMinusSourceColor: return GL_ONE_MINUS_SRC_COLOR
                case .destinationColor: return GL_DST_COLOR
                case .oneMinusDestinationColor: return GL_ONE_MINUS_DST_COLOR
                case .sourceAlpha: return GL_SRC_ALPHA
                case .oneMinusSourceAlpha: return GL_ONE_MINUS_SRC_ALPHA
                case .destinationAlpha: return GL_DST_ALPHA
                case .oneMinusDestinationAlpha: return GL_ONE_MINUS_DST_ALPHA
                case .constantColor: return GL_CONSTANT_COLOR
                case .oneMinusConstantColor: return GL_ONE_MINUS_CONSTANT_COLOR
                case .constantAlpha: return GL_CONSTANT_ALPHA
                case .oneMinusConstantAlpha: return GL_ONE_MINUS_CONSTANT_ALPHA
                case .sourceAlphaSaturate: return GL_SRC_ALPHA_SATURATE
                }
            }
        }
    }
    public enum Format {
        case red
        case rgb
        case rgba
        case depth
        
        @inlinable @inline(__always) internal var value: Int32 {
            switch self {
            case .red: return GL_RED
            case .rgb: return GL_RGB
            case .rgba: return GL_RGBA
            case .depth: return GL_DEPTH_COMPONENT
            }
        }
        
        public enum Internal {
            case red
            case rgb
            case rgba
            case srgba
            case depth
            
            @inlinable @inline(__always) internal var value: Int32 {
                switch self {
                case .red: return GL_RED
                case .rgb: return GL_RGB
                case .rgba: return GL_RGBA
                case .srgba: return GL_SRGB_ALPHA
                case .depth: return GL_DEPTH_COMPONENT32F
                }
            }
        }

    }
    public enum Elements {
        public enum Mode {
            case triangles
            case triangleStrip
            case points
            case lines
            case lineStrip
            
            @inlinable @inline(__always) internal var value: Int32 {
                switch self {
                case .triangles: return GL_TRIANGLES
                case .triangleStrip: return GL_TRIANGLE_STRIP
                case .points: return GL_POINTS
                case .lines: return GL_LINES
                case .lineStrip: return GL_LINE_STRIP
                }
            }
        }
    }
    public enum Types {
        case int32
        case uint32
        case uint16
        case uint8
        case float
        
        @inlinable @inline(__always) internal var value: Int32 {
            switch self {
            case .int32: return GL_INT
            case .uint32: return GL_UNSIGNED_INT
            case .uint16: return GL_UNSIGNED_SHORT
            case .uint8: return GL_UNSIGNED_BYTE
            case .float: return GL_FLOAT
            }
        }
    }
    public enum PixelStore {
        public enum Alignment {
            case pack
            case unpack
            
            @inlinable @inline(__always) internal var value: Int32 {
                switch self {
                case .pack: return GL_PACK_ALIGNMENT
                case .unpack: return GL_UNPACK_ALIGNMENT
                }
            }
        }
    }
    public enum Description {
        case vendor
        case renderer
        case version
        case shadingLanguageVersion
        
        @inlinable @inline(__always) internal var value: Int32 {
            switch self {
            case .vendor: return GL_VENDOR
            case .renderer: return GL_RENDERER
            case .version: return GL_VERSION
            case .shadingLanguageVersion: return GL_SHADING_LANGUAGE_VERSION
            }
        }
    }
    public enum Properties {
        case maxTextureSize
        case maxTextureUnits
        case drawFramebufferBinding
        
        @inlinable @inline(__always) internal var value: Int32 {
            switch self {
            case .maxTextureSize:
                return GL_MAX_TEXTURE_SIZE
            case .maxTextureUnits:
                return GL_MAX_TEXTURE_IMAGE_UNITS
            case .drawFramebufferBinding:
                return GL_DRAW_FRAMEBUFFER_BINDING
            }
        }
    }
    public enum Buffer {
        public enum Target {
            case array
            case elementArray
            
            @inlinable @inline(__always) internal var value: Int32 {
                switch self {
                case .array:
                    return GL_ARRAY_BUFFER
                case .elementArray:
                    return GL_ELEMENT_ARRAY_BUFFER
                }
            }
        }
        public enum Data {
            public enum Usage {
                case `static`
                case dynamic
                
                @inlinable @inline(__always) internal var value: Int32 {
                    switch self {
                    case .static:
                        return GL_STATIC_DRAW
                    case .dynamic:
                        return GL_DYNAMIC_DRAW
                    }
                }
            }
        }
    }
    public enum Framebuffer {
        public enum Status: Equatable {
            case complete
            case incompleteAttachment
            case incompleteMissingAttachment
            #if os(macOS)
            case incompleteDrawBuffer
            case incompleteReadBuffer
            case incompleteLayerTargets
            #endif
            case unsupported
            case incompleteMultisample
            case undefined
            ///
            case unknown(Int32)
            
            @inlinable @inline(__always) internal var value: Int32 {
                switch self {
                case .complete: return GL_FRAMEBUFFER_COMPLETE
                case .incompleteAttachment: return GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT
                case .incompleteMissingAttachment: return GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT
                #if os(macOS)
                case .incompleteDrawBuffer: return GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER
                case .incompleteReadBuffer: return GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER
                case .incompleteLayerTargets: return GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS
                #endif
                case .unsupported: return GL_FRAMEBUFFER_UNSUPPORTED
                case .incompleteMultisample: return GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE
                case .undefined: return GL_FRAMEBUFFER_UNDEFINED
                case .unknown(_): return GL_FRAMEBUFFER_UNDEFINED
                }
            }
            
            @inlinable @inline(__always) static func fromValue(_ value: Int32) -> Status {
                switch value {
                case GL_FRAMEBUFFER_COMPLETE: return .complete
                case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT: return .incompleteAttachment
                case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT: return .incompleteMissingAttachment
                #if os(macOS)
                case GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER: return .incompleteDrawBuffer
                case GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER: return .incompleteReadBuffer
                case GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS: return .incompleteLayerTargets
                #endif
                case GL_FRAMEBUFFER_UNSUPPORTED: return .unsupported
                case GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE: return .incompleteMultisample
                case GL_FRAMEBUFFER_UNDEFINED: return .undefined
                default: return .unknown(value)
                }
            }
        }
        public enum Target {
            case draw
            case read
            
            @inlinable @inline(__always) var value: Int32 {
                switch self {
                case .draw:
                    return GL_FRAMEBUFFER
                case .read:
                    return GL_READ_FRAMEBUFFER
                }
            }
        }
        public enum ReadWrite {
            case color(_ index: Int)
            case front
            case back
            
            @inlinable @inline(__always) var value: Int32 {
                switch self {
                case .color(0): return GL_COLOR_ATTACHMENT0
                case .color(1): return GL_COLOR_ATTACHMENT1
                case .color(2): return GL_COLOR_ATTACHMENT2
                case .color(3): return GL_COLOR_ATTACHMENT3
                case .color(4): return GL_COLOR_ATTACHMENT4
                case .color(5): return GL_COLOR_ATTACHMENT5
                case .color(6): return GL_COLOR_ATTACHMENT6
                case .color(7): return GL_COLOR_ATTACHMENT7
                case .color(8): return GL_COLOR_ATTACHMENT8
                case .color(9): return GL_COLOR_ATTACHMENT9
                case .color(10): return GL_COLOR_ATTACHMENT10
                case .color(11): return GL_COLOR_ATTACHMENT11
                case .color(12): return GL_COLOR_ATTACHMENT12
                case .color(13): return GL_COLOR_ATTACHMENT13
                case .color(14): return GL_COLOR_ATTACHMENT14
                case .color(15): return GL_COLOR_ATTACHMENT15
                case .front: return GL_FRONT
                case .back: return GL_BACK
                default:
                    fatalError("Not a valid framebuffer read or write target")
                }
            }
        }
        public enum Attachment {
            case color(_ index: Int)
            case depth
            case stencil
            
            public enum Parameter {
                case type
                case name
                
                @inlinable @inline(__always) internal var value: Int32 {
                    switch self {
                    case .type:
                        return GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE
                    case .name:
                        return GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME
                    }
                }
            }
            
            @inlinable @inline(__always) internal var value: Int32 {
                switch self {
                case .color(0): return GL_COLOR_ATTACHMENT0
                case .color(1): return GL_COLOR_ATTACHMENT1
                case .color(2): return GL_COLOR_ATTACHMENT2
                case .color(3): return GL_COLOR_ATTACHMENT3
                case .color(4): return GL_COLOR_ATTACHMENT4
                case .color(5): return GL_COLOR_ATTACHMENT5
                case .color(6): return GL_COLOR_ATTACHMENT6
                case .color(7): return GL_COLOR_ATTACHMENT7
                case .color(8): return GL_COLOR_ATTACHMENT8
                case .color(9): return GL_COLOR_ATTACHMENT9
                case .color(10): return GL_COLOR_ATTACHMENT10
                case .color(11): return GL_COLOR_ATTACHMENT11
                case .color(12): return GL_COLOR_ATTACHMENT12
                case .color(13): return GL_COLOR_ATTACHMENT13
                case .color(14): return GL_COLOR_ATTACHMENT14
                case .color(15): return GL_COLOR_ATTACHMENT15
                case .depth: return GL_DEPTH_ATTACHMENT
                case .stencil: return GL_STENCIL_ATTACHMENT
                default:
                    fatalError("Not a valid framebuffer attachment")
                }
            }
        }
    }
    
    public enum Capability {
        case depthTest
        case cullFace
        case blend
        @inlinable @inline(__always) internal var value: Int32 {
            switch self {
            case .depthTest:
                return GL_DEPTH_TEST
            case .cullFace:
                return GL_CULL_FACE
            case .blend:
                return GL_BLEND
            }
        }
    }
    
    public enum Shader {
        public enum Kind {
            case vertex
            #if os(macOS)
            case geometry
            #endif
            case fragment
            
            @inlinable @inline(__always) internal var value: Int32 {
                switch self {
                case .vertex:
                    return GL_VERTEX_SHADER
                #if os(macOS)
                case .geometry:
                    return GL_GEOMETRY_SHADER
                #endif
                case .fragment:
                    return GL_FRAGMENT_SHADER
                }
            }
        }
        
        public enum Program {
            public enum Property {
                case linkStatus
                case infoLogLength
                case validateStatus
                @inlinable @inline(__always) internal var value: Int32 {
                    switch self {
                    case .linkStatus:
                        return GL_LINK_STATUS
                    case .infoLogLength:
                        return GL_INFO_LOG_LENGTH
                    case .validateStatus:
                        return GL_VALIDATE_STATUS
                    }
                }
            }
        }
        
        public enum Property {
            case compileStatus
            case infoLogLength
            
            @inlinable @inline(__always) internal var value: Int32 {
                switch self {
                case .compileStatus:
                    return GL_COMPILE_STATUS
                case .infoLogLength:
                    return GL_INFO_LOG_LENGTH
                }
            }
        }
    }
    
    public enum Texture {
        public enum Blending {
            public enum Function {
                case neverSucceed
                case alwaysSucceed
                
                case equalTo
                case notEqualTo
                
                case lessThan
                case greaterThan

                case lessThanOrEqualTo
                case greaterThanOrEqualTo
                
                @inlinable @inline(__always) internal var value: Int32 {
                    switch self {
                    case .neverSucceed: return GL_NEVER
                    case .alwaysSucceed: return GL_ALWAYS
                    case .equalTo: return GL_EQUAL
                    case .notEqualTo: return GL_NOTEQUAL
                    case .lessThan: return GL_LESS
                    case .greaterThan: return GL_GREATER
                    case .lessThanOrEqualTo: return GL_LEQUAL
                    case .greaterThanOrEqualTo: return GL_GEQUAL
                    }
                }
            }
        }
        public enum Target {
            case texture2D
            
            @inlinable @inline(__always) internal var value: Int32 {
                switch self {
                case .texture2D:
                    return GL_TEXTURE_2D
                }
            }
        }
        public enum Unit {
            case texture(_ index: Int)
            
            @inlinable @inline(__always) internal var value: Int32 {
                switch self {
                case .texture(0): return GL_TEXTURE0
                case .texture(1): return GL_TEXTURE1
                case .texture(2): return GL_TEXTURE2
                case .texture(3): return GL_TEXTURE3
                case .texture(4): return GL_TEXTURE4
                case .texture(5): return GL_TEXTURE5
                case .texture(6): return GL_TEXTURE6
                case .texture(7): return GL_TEXTURE7
                case .texture(8): return GL_TEXTURE8
                case .texture(9): return GL_TEXTURE9
                case .texture(10): return GL_TEXTURE10
                case .texture(11): return GL_TEXTURE11
                case .texture(12): return GL_TEXTURE12
                case .texture(13): return GL_TEXTURE13
                case .texture(14): return GL_TEXTURE14
                case .texture(15): return GL_TEXTURE15
                case .texture(16): return GL_TEXTURE16
                case .texture(17): return GL_TEXTURE17
                case .texture(18): return GL_TEXTURE18
                case .texture(19): return GL_TEXTURE19
                case .texture(20): return GL_TEXTURE20
                case .texture(21): return GL_TEXTURE21
                case .texture(22): return GL_TEXTURE22
                case .texture(23): return GL_TEXTURE23
                case .texture(24): return GL_TEXTURE24
                case .texture(25): return GL_TEXTURE25
                case .texture(26): return GL_TEXTURE26
                case .texture(27): return GL_TEXTURE27
                case .texture(28): return GL_TEXTURE28
                case .texture(29): return GL_TEXTURE29
                case .texture(30): return GL_TEXTURE30
                case .texture(31): return GL_TEXTURE31
                default:
                    fatalError("Not a valid texture unit")
                }
            }
        }
        
        public enum Filter {
            case minimize
            case magnify
            
            @inlinable @inline(__always) internal var value: Int32 {
                switch self {
                case .minimize: return GL_TEXTURE_MIN_FILTER
                case .magnify: return GL_TEXTURE_MAG_FILTER
                }
            }
            
            public enum Method {
                case linear
                case nearest
                
                case linearMipMap
                case nearestMipMap
                
                @inlinable @inline(__always) internal var value: Int32 {
                    switch self {
                    case .linear: return GL_LINEAR
                    case .nearest: return GL_NEAREST
                    case .linearMipMap: return GL_LINEAR_MIPMAP_LINEAR
                    case .nearestMipMap: return GL_NEAREST_MIPMAP_NEAREST
                    }
                }
            }
        }
        
        public enum Wrap {
            case horizontal
            case vertical
            @inlinable @inline(__always) internal var value: Int32 {
                switch self {
                case .horizontal: return GL_TEXTURE_WRAP_S
                case .vertical: return GL_TEXTURE_WRAP_T
                }
            }
            
            public enum Method {
                case `repeat`
                case clampToEdge
                
                @inlinable @inline(__always) internal var value: Int32 {
                    switch self {
                    case .repeat: return GL_REPEAT
                    case .clampToEdge: return GL_CLAMP_TO_EDGE
                    }
                }
            }
        }
    }
    
    public struct ClearMask: OptionSet {
        public typealias RawValue = UInt32
        public var rawValue: RawValue
        
        public static let color = ClearMask(rawValue: 0 << 1)
        public static let depth = ClearMask(rawValue: 0 << 2)
        public static let stencil = ClearMask(rawValue: 0 << 3)
        
        @inlinable @inline(__always)
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        @inlinable @inline(__always) internal var value: Int32 {
            var value: Int32 = 0
            if self.contains(.color) {
                value |= GL_COLOR_BUFFER_BIT
            }
            if self.contains(.depth) {
                value |= GL_DEPTH_BUFFER_BIT
            }
            if self.contains(.stencil) {
                value |= GL_STENCIL_BUFFER_BIT
            }
            return value
        }
    }
    
    public enum FaceWinding {
        case clockwise
        case counterClockwise
        
        @inlinable @inline(__always) var value: Int32 {
            switch self {
            case .clockwise:
                return GL_CW
            case .counterClockwise:
                return GL_CCW
            }
        }
    }
    
    public enum CullFace {
        case front
        case back
        
        @inlinable @inline(__always) var value: Int32 {
            switch self {
            case .front:
                return GL_FRONT
            case .back:
                return GL_BACK
            }
        }
    }
    
    public struct Error: Swift.Error, CustomStringConvertible {
        public let kind: Kind
        public let function: StaticString
        public let possibleReasons: [String]
        @inlinable @inline(__always) public var localizedDescription: String {
            var string = "\n \(function) \(kind)"
            if possibleReasons.isEmpty == false {
                string += ": Possible Reasons..."
            }
            for reason in possibleReasons {
                string += "\n\t\t" + reason
            }
            return string + "\n"
        }
        @inlinable @inline(__always) public var description: String {
            return self.localizedDescription
        }
        @inlinable @inline(__always) internal init(_ kind: Kind, _ function: StaticString, _ possibleReasons: String...) {
            self.kind = kind
            self.function = function
            self.possibleReasons = possibleReasons
        }
        @inlinable @inline(__always) internal init(_ kind: Kind, _ function: StaticString, _ possibleReasons: [String]) {
            self.kind = kind
            self.function = function
            self.possibleReasons = possibleReasons
        }
        
        public enum Kind: Int {
            case none
            case invalidEnum
            case invalidValue
            case invalidOperation
            case outOfMemory
            case invalidFramebufferOperation
            case unknown
            
            @inlinable @inline(__always) internal static func fromValue(_ value: Int32) -> Kind {
                switch value {
                case GL_NO_ERROR: return .none
                case GL_INVALID_ENUM: return .invalidEnum
                case GL_INVALID_VALUE: return .invalidValue
                case GL_INVALID_OPERATION: return .invalidOperation
                case GL_OUT_OF_MEMORY: return .outOfMemory
                case GL_INVALID_FRAMEBUFFER_OPERATION: return .invalidOperation
                default: return .unknown
                }
            }
        }
    }
}

public let glDefaultDepth = GL_DEPTH
public let glBackBuffer = GL_BACK

@inlinable @inline(__always) public func glFrontFacing(_ mode: OpenGL.FaceWinding) {
    _glFrontFacing(GLenum(mode.value))
}

@inlinable @inline(__always) public func glCullFace(_ mode: OpenGL.CullFace) {
    _glCullFace(GLenum(mode.value))
}

@inlinable @inline(__always) public func glCheckFramebufferStatus(target: OpenGL.Framebuffer.Target) -> OpenGL.Framebuffer.Status {
    return OpenGL.Framebuffer.Status.fromValue(Int32(_glCheckFramebufferStatus(GLenum(target.value))))
}

@inlinable @inline(__always) public func glGenFramebuffers(count: Int) -> [GLuint] {
    var framebuffers: [GLuint] = Array(repeating: 0, count: count)
    _glGenFramebuffers(GLsizei(count), &framebuffers)
    return framebuffers
}

@inlinable @inline(__always) public func glBindFramebuffer(_ framebuffer: GLuint, as target: OpenGL.Framebuffer.Target = .draw) {
    _glBindFramebuffer(GLenum(target.value), framebuffer)
}

@inlinable @inline(__always) public func glDeleteFramebuffers(_ buffers: [GLuint]) {
    _glDeleteFramebuffers(GLsizei(buffers.count), buffers)
}

@inlinable @inline(__always) public func glDeleteFramebuffers(_ buffers: GLuint...) {
    _glDeleteFramebuffers(GLsizei(buffers.count), buffers)
}

@inlinable @inline(__always) public func glGetFramebufferAttachmentParameter<T: FixedWidthInteger>(target: OpenGL.Framebuffer.Target, attachment: OpenGL.Framebuffer.Attachment, parameter: OpenGL.Framebuffer.Attachment.Parameter) -> T {
    var params: GLint = 0
    _glGetFramebufferAttachmentParameteriv(GLenum(target.value), GLenum(attachment.value), GLenum(parameter.value), &params)
    return T(params)
}

// Int
@_transparent
public func glUniform1i(location: GLint, value1: Int32) throws {
    _glUniform1i(location, value1)
}

@_transparent
public func glUniform2i(location: GLint, value1: Int32, value2: Int32) throws {
    _glUniform2i(location, value1, value2)
}

@_transparent
public func glUniform3i(location: GLint, value1: Int32, value2: Int32, value3: Int32) throws {
    _glUniform3i(location, value1, value2, value3)
}

@_transparent
public func glUniform4i(location: GLint, value1: Int32, value2: Int32, value3: Int32, value4: Int32) throws {
    _glUniform4i(location, value1, value2, value3, value4)
}

// UInt
@_transparent
public func glUniform1ui(location: GLint, value1: UInt32) throws {
    _glUniform1ui(location, value1)
}

@_transparent
public func glUniform2ui(location: GLint, value1: UInt32, value2: UInt32) throws {
    _glUniform2ui(location, value1, value2)
}

@_transparent
public func glUniform3ui(location: GLint, value1: UInt32, value2: UInt32, value3: UInt32) throws {
    _glUniform3ui(location, value1, value2, value3)
}

@_transparent
public func glUniform4ui(location: GLint, value1: UInt32, value2: UInt32, value3: UInt32, value4: UInt32) throws {
    _glUniform4ui(location, value1, value2, value3, value4)
}

// Float
@_transparent
public func glUniform1f(location: GLint, value1: Float) throws {
    _glUniform1f(location, value1)
}

@_transparent
public func glUniform2f(location: GLint, value1: Float, value2: Float) throws {
    _glUniform2f(location, value1, value2)
}

@_transparent
public func glUniform3f(location: GLint, value1: Float, value2: Float, value3: Float) throws {
    _glUniform3f(location, value1, value2, value3)
}

@_transparent
public func glUniform4f(location: GLint, value1: Float, value2: Float, value3: Float, value4: Float) throws {
    _glUniform4f(location, value1, value2, value3, value4)
}

@inlinable @inline(__always) public func glUniformMatrix3fv(location: GLint, transpose: Bool, values: [[GLfloat]]) {
    var floats: [GLfloat] = []
    for array in values {
        floats.append(contentsOf: array)
    }
    _glUniformMatrix3fv(location, GLsizei(values.count), transpose ? GLboolean(GL_TRUE) : GLboolean(GL_FALSE), floats)
}

@inlinable @inline(__always) public func glUniformMatrix3fv(location: GLint, transpose: Bool, values: [GLfloat]...) {
    var floats: [GLfloat] = []
    for array in values {
        floats.append(contentsOf: array)
    }
    _glUniformMatrix3fv(location, GLsizei(values.count), transpose ? GLboolean(GL_TRUE) : GLboolean(GL_FALSE), floats)
}

@inlinable @inline(__always) public func glUniformMatrix4fv(location: GLint, transpose: Bool, values: [[GLfloat]]) {
    var floats: [GLfloat] = []
    floats.reserveCapacity(values.count * 16)
    for array in values {
        floats.append(contentsOf: array)
    }
    _glUniformMatrix4fv(location, GLsizei(values.count), transpose ? GLboolean(GL_TRUE) : GLboolean(GL_FALSE), floats)
}

@inlinable @inline(__always) public func glUniformMatrix4fv(location: GLint, transpose: Bool, values: [GLfloat]) {
    values.withUnsafeBufferPointer { floats in
        _glUniformMatrix4fv(location, GLsizei(values.count / 16), transpose ? GLboolean(GL_TRUE) : GLboolean(GL_FALSE), floats.baseAddress)
    }
}

@inlinable @inline(__always) public func glGetShaderInfoLog(shader: GLuint) throws -> String? {
    let length: GLint = try glGetShaderiv(shader: shader, property: .infoLogLength)
    guard length > 0 else {return nil}
    var str = [GLchar](repeating: GLchar(0), count: Int(length) + 1)
    var size: GLsizei = 0
    _glGetShaderInfoLog(shader, GLsizei(length), &size, &str)
    return String(cString: str)
}

@inlinable @inline(__always) public func glGetShaderiv<T: FixedWidthInteger>(shader: GLuint, property: OpenGL.Shader.Property) throws -> T {
    var param: GLint = -1
    _glGetShaderiv(shader, GLenum(property.value), &param)
    
    let error = OpenGL_GateEngine.glGetError()
    switch error {
    case .invalidOperation:
        throw OpenGL.Error(.invalidOperation, #function, ["shader compiler is not supported.",
                                                          "shader does not refer to a shader object."])
    case .invalidEnum:
        throw OpenGL.Error(error, #function, "property is not an accepted value.")
    case .invalidValue:
        throw OpenGL.Error(error, #function, "shader is not a value generated by OpenGL.")
    default:
        if error != .none {
            throw OpenGL.Error(error, #function)
        }
    }
    
    return T(param)
}

@inlinable @inline(__always) public func glGetShaderCompileStatus(shader: GLuint) throws -> Bool {
    return try glGetShaderiv(shader: shader, property: .compileStatus) == GL_TRUE
}

@inlinable @inline(__always) public func glGetProgramiv<T: FixedWidthInteger>(program: GLuint, property: OpenGL.Shader.Program.Property) -> T {
    var param: GLint = -1
    _glGetProgramiv(program, GLenum(property.value), &param)
    return T(param)
}

@inlinable @inline(__always) public func glGetAttribLocation(program: GLuint, attribute: String) -> GLint {
    return _glGetAttribLocation(program, attribute.cString(using: .ascii))
}

@inlinable @inline(__always) public func glShaderSource(shader: GLuint, source: String) throws {
    source.withCString { (glcSource) in
        var glcSource: UnsafePointer<GLchar>? = glcSource
        var length = GLint(source.count)
        _glShaderSource(shader, 1, &glcSource, &length)
    }
}

@inlinable @inline(__always) public func glBindBuffer(_ buffer: GLuint, as target: OpenGL.Buffer.Target) {
    _glBindBuffer(GLenum(target.value), buffer)
}

@_disfavoredOverload
@inlinable @inline(__always) public func glBufferData<D: Collection>(_ data: D, withUsage usage: OpenGL.Buffer.Data.Usage, as target: OpenGL.Buffer.Target) {
    data.withContiguousStorageIfAvailable { buffer in
        _glBufferData(GLenum(target.value), GLsizeiptr(MemoryLayout<D>.stride * data.count), buffer.baseAddress, GLenum(usage.value))
    }
}

@inlinable @inline(__always) public func glBufferData(_ data: [Int32], withUsage usage: OpenGL.Buffer.Data.Usage, as target: OpenGL.Buffer.Target) {
    data.withUnsafeBufferPointer { buffer in
        _glBufferData(GLenum(target.value), GLsizeiptr(MemoryLayout<Int32>.stride * data.count), buffer.baseAddress, GLenum(usage.value))
    }
}

@inlinable @inline(__always) public func glBufferData(_ data: [UInt16], withUsage usage: OpenGL.Buffer.Data.Usage, as target: OpenGL.Buffer.Target) {
    data.withUnsafeBufferPointer { buffer in
        _glBufferData(GLenum(target.value), GLsizeiptr(MemoryLayout<UInt16>.stride * data.count), buffer.baseAddress, GLenum(usage.value))
    }
}

@inlinable @inline(__always) public func glBufferData(_ data: [UInt32], withUsage usage: OpenGL.Buffer.Data.Usage, as target: OpenGL.Buffer.Target) {
    data.withUnsafeBufferPointer { buffer in
        _glBufferData(GLenum(target.value), GLsizeiptr(MemoryLayout<UInt32>.stride * data.count), buffer.baseAddress, GLenum(usage.value))
    }
}

@inlinable @inline(__always) public func glBufferData(_ data: [Float], withUsage usage: OpenGL.Buffer.Data.Usage, as target: OpenGL.Buffer.Target) {
    data.withUnsafeBufferPointer { buffer in
        _glBufferData(GLenum(target.value), GLsizeiptr(MemoryLayout<Float>.stride * data.count), buffer.baseAddress, GLenum(usage.value))
    }
}

@inlinable @inline(__always) public func glBufferData(_ data: Data, withUsage usage: OpenGL.Buffer.Data.Usage, as target: OpenGL.Buffer.Target) {
    data.withUnsafeBytes { (pointer) -> Void in
        _glBufferData(GLenum(target.value), GLsizeiptr(MemoryLayout<UInt8>.stride * data.count), pointer.baseAddress, GLenum(usage.value))
    }
}

@inlinable @inline(__always) public func glTexParameter(target: OpenGL.Texture.Target = .texture2D, filtering parameter: OpenGL.Texture.Filter, by method: OpenGL.Texture.Filter.Method) {
    _glTexParameteri(GLenum(target.value), GLenum(parameter.value), method.value)
}

@inlinable @inline(__always) public func glTexParameter(target: OpenGL.Texture.Target = .texture2D, wrapping wrap: OpenGL.Texture.Wrap, by method: OpenGL.Texture.Wrap.Method) {
    _glTexParameteri(GLenum(target.value), GLenum(wrap.value), method.value)
}

@inlinable @inline(__always) public func glTexParameter(target: OpenGL.Texture.Target = .texture2D, comparingBy method: OpenGL.Texture.Blending.Function) {
    _glTexParameteri(GLenum(target.value), GLenum(GL_TEXTURE_COMPARE_FUNC), method.value)
}

@inlinable @inline(__always) public func glGetIntegerv<T: FixedWidthInteger>(property: OpenGL.Properties) -> T? {
    var value: GLint = -1
    _glGetIntegerv(GLenum(property.value), &value)
    return value != -1 ? T(value) : nil
}

@inlinable @inline(__always) public func glBindTexture(_ texture: GLuint, as target: OpenGL.Texture.Target = .texture2D) {
    _glBindTexture(GLenum(target.value), texture)
}

@inlinable @inline(__always) public func glGenTextures() -> GLuint {
    return glGenTextures(count: 1)[0]
}

@inlinable @inline(__always) public func glGenTextures(count: GLsizei) -> [GLuint] {
    var textures: [GLuint] = Array(repeating: 0, count: Int(count))
    _glGenTextures(count, &textures)
    return textures
}

@inlinable @inline(__always) public func glDeleteTextures(_ textures: GLuint...) {
    var mutableTextures = textures
    _glDeleteTextures(GLsizei(textures.count), &mutableTextures)
}

@inlinable @inline(__always) public func glActiveTexture(unit: OpenGL.Texture.Unit) {
    _glActiveTexture(GLenum(unit.value))
}

@inlinable @inline(__always) public func glPixelStorei(parameter: OpenGL.PixelStore.Alignment, value: GLint) {
    _glPixelStorei(GLenum(parameter.value), value)
}

@inlinable @inline(__always) public func glTexImage2D(target: OpenGL.Texture.Target = .texture2D, level: Int = 0, internalFormat: OpenGL.Format.Internal, width: Int, height: Int, border: Int = 0, format: OpenGL.Format, type: OpenGL.Types, pixels: Data? = nil) {
    if let pixels = pixels {
        pixels.withUnsafeBytes { (data) in
            _glTexImage2D(GLenum(target.value), GLint(level), internalFormat.value, GLsizei(width), GLsizei(height), GLint(border), GLenum(format.value), GLenum(type.value), data.baseAddress)
        }
    }else{
        _glTexImage2D(GLenum(target.value), GLint(level), internalFormat.value, GLsizei(width), GLsizei(height), GLint(border), GLenum(format.value), GLenum(type.value), nil)
    }
}

@inlinable @inline(__always) public func glVertexAttribPointer(attributeIndex index: GLuint, unitsPerComponent size: GLint, unitType type: OpenGL.Types, componentsAreNormalized normalized: Bool = false, stride: GLsizei = 0, pointer: UnsafeMutableRawPointer! = nil) {
    _glVertexAttribPointer(index, size, GLenum(type.value), normalized ? GLboolean(GL_TRUE) : GLboolean(GL_FALSE), stride, pointer)
}

@inlinable @inline(__always) public func glVertexAttribDivisor(_ index: GLuint, divisor: GLuint) {
    _glVertexAttribDivisor(index, divisor: divisor)
}

@inlinable @inline(__always) public func glGetError() -> OpenGL.Error.Kind {
    let val: GLenum = _glGetError()
    return OpenGL.Error.Kind.fromValue(Int32(val))
}

@inlinable @inline(__always) public func glEnable(capability: OpenGL.Capability) {
    _glEnable(GLenum(capability.value))
}

@inlinable @inline(__always) public func glDisable(capability: OpenGL.Capability) {
    _glDisable(GLenum(capability.value))
}

@inlinable @inline(__always) public func glGenBuffer() -> GLuint {
    return glGenBuffers(count: 1)[0]
}

@inlinable @inline(__always) public func glGenBuffers(count: GLint) -> [GLuint] {
    var buffers: [GLuint] = Array(repeating: 0, count: Int(count))
    _glGenBuffers(count, &buffers)
    return buffers
}

@inlinable @inline(__always) public func glDeleteBuffers(_ buffers: [GLuint]) {
    _glDeleteBuffers(GLsizei(buffers.count), buffers)
}

@inlinable @inline(__always) public func glDeleteBuffers(_ buffers: GLuint...) {
    _glDeleteBuffers(GLsizei(buffers.count), buffers)
}

@inlinable @inline(__always) public func glClearColor(red: GLfloat, green: GLfloat, blue: GLfloat, alpha: GLfloat) {
    _glClearColor(red, green, blue, alpha)
}

@inlinable @inline(__always) public func glClearColor(_ color: [GLfloat]) {
    if color.count == 0 {
        _glClearColor(0, 0, 0, 0)
    }else if color.count == 1 {
        _glClearColor(color[0], color[0], color[0], color[0])
    }else{
        let red = color[0]
        let green = color.count >= 2 ? color[1] : 0
        let blue = color.count >= 3 ? color[2] : 0
        let alpha = color.count >= 4 ? color[3] : 0
        _glClearColor(red, green, blue, alpha)
    }
}

@inlinable @inline(__always) public func glClearColor(_ red: GLfloat, _ green: GLfloat, _ blue: GLfloat, _ alpha: GLfloat) {
    _glClearColor(red, green, blue, alpha)
}

@inlinable @inline(__always) public func glClearDepth(_ value: GLfloat) {
    _glClearDepth(value)
}

@inlinable @inline(__always) public func glClear(_ mask: OpenGL.ClearMask) {
    _glClear(GLenum(mask.value))
}

@inlinable @inline(__always) public func glGenVertexArrays(count: GLint) -> [GLuint] {
    var arrays: [GLuint] = Array(repeating: 0, count: Int(count))
    _glGenVertexArrays(count, &arrays)
    return arrays
}

@inlinable @inline(__always) public func glDeleteVertexArrays(_ arrays: [GLuint]) {
    _glDeleteVertexArrays(GLsizei(arrays.count), arrays)
}

@inlinable @inline(__always) public func glDeleteVertexArrays(_ arrays: GLuint...) {
    _glDeleteVertexArrays(GLsizei(arrays.count), arrays)
}

@inlinable @inline(__always) public func glViewport(x: GLint, y: GLint, width: GLsizei, height: GLsizei) {
    _glViewport(x, y, width, height)
}

@inlinable @inline(__always) public func glScissor(x: GLint, y: GLint, width: GLsizei, height: GLsizei) {
    _glScissor(x, y, width, height)
}

@inlinable @inline(__always) public func glGetString(describing name: OpenGL.Description) throws -> String  {
    guard let pointer = _glGetString(GLenum(name.value)), pointer.pointee != 0 else {
        let kind: OpenGL.Error.Kind = glGetError()
        switch kind {
        case .invalidEnum: throw OpenGL.Error(kind, #function, "not an accepted value")
        default: throw OpenGL.Error(kind, #function)
        }
    }
    var string: String! = nil
    pointer.withMemoryRebound(to: GLubyte.self, capacity: MemoryLayout.size(ofValue: pointer)) {
        string = String(cString: $0)
    }
    return string
}

@inlinable @inline(__always) public func glDrawElements(mode: OpenGL.Elements.Mode, count: GLsizei, type: OpenGL.Types, indices: UnsafeRawPointer! = nil) throws {
    _glDrawElements(GLenum(mode.value), count, GLenum(type.value), indices)
    let error = OpenGL_GateEngine.glGetError()
    switch error {
    case .invalidOperation:
        throw OpenGL.Error(error, #function, ["a geometry shader is active and mode is incompatible with the input primitive type of the geometry shader in the currently installed program object",
                                              "a non-zero buffer object name is bound to an enabled array or the element array and the buffer object's data store is currently mapped."])
    case .invalidValue:
        throw OpenGL.Error(error, #function, "count is negative.")
    case .invalidEnum:
        throw OpenGL.Error(error, #function, "mode is not an accepted value.")
    case .none:
        fallthrough
    default: break
    }
}

@inlinable @inline(__always) public func glDrawElementsInstanced(mode: OpenGL.Elements.Mode, count: GLsizei, type: OpenGL.Types, indices: UnsafeRawPointer! = nil, instanceCount: GLsizei) throws {
    _glDrawElementsInstanced(GLenum(mode.value), count, GLenum(type.value), indices, instanceCount)
    let error = OpenGL_GateEngine.glGetError()
    switch error {
    case .invalidOperation:
        throw OpenGL.Error(error, #function, ["a geometry shader is active and mode is incompatible with the input primitive type of the geometry shader in the currently installed program object",
                                              "a non-zero buffer object name is bound to an enabled array or the element array and the buffer object's data store is currently mapped."])
    case .invalidValue:
        throw OpenGL.Error(error, #function, "count is negative.")
    case .invalidEnum:
        throw OpenGL.Error(error, #function, "mode is not an accepted value.")
    case .none:
        fallthrough
    default: break
    }
}

@inlinable @inline(__always) public func glGetUniformBlockIndex(inProgram program: GLuint, named uniformBlockName: String) throws -> GLuint? {
    guard let cString = uniformBlockName.cString(using: .nonLossyASCII) else {throw OpenGL.Error(.unknown, #function, "name must be ascii encodable")}
    let index = _glGetUniformBlockIndex(program, cString)
    if index != GL_INVALID_INDEX {
        return index
    }
    return nil
}

@inlinable @inline(__always) public func glGetUniformLocation(inProgram program: GLuint, named name: String) throws -> GLint? {
    guard let cString = name.cString(using: .nonLossyASCII) else {throw OpenGL.Error(.unknown, #function, "name must be ascii encodable")}
    let location = _glGetUniformLocation(program, cString)
    if location > -1 {
        return location
    }
    return nil
}

@inlinable @inline(__always) public func glCreateShader(ofType kind: OpenGL.Shader.Kind) -> GLuint {
    return _glCreateShader(GLenum(kind.value))
}

@inlinable @inline(__always) public func glGetProgramInfoLog(forProgram program: GLuint) -> String {
    let length: GLint = glGetProgramiv(program: program, property: .infoLogLength)
    var str = [GLchar](repeating: GLchar(0), count: Int(length) + 1)
    var size: GLsizei = 0
    _glGetProgramInfoLog(program, GLsizei(length), &size, &str)
    return String(cString: str)
}

@inlinable @inline(__always) public func glLinkProgram(_ program: GLuint) {
    _glLinkProgram(program)
}

@inlinable @inline(__always) public func glValidateProgram(_ program: GLuint) {
    _glValidateProgram(program)
}

@inlinable @inline(__always) public func glDeleteShader(_ shader: GLuint) {
    _glDeleteShader(shader)
}

@inlinable @inline(__always) public func glAttachShader(_ shader: GLuint, toProgram program: GLuint) {
    _glAttachShader(program, shader)
}

@inlinable @inline(__always) public func glCreateProgram() -> GLuint {
    return _glCreateProgram()
}

@inlinable @inline(__always) public func glGenerateMipmap(target: OpenGL.Texture.Target) {
    _glGenerateMipmap(GLenum(target.value))
}

@inlinable @inline(__always) public func glDeleteProgram(_ program: GLuint) {
    _glDeleteProgram(program)
}

@inlinable @inline(__always) public func glUseProgram(_ program: GLuint) {
    _glUseProgram(program)
}

@inlinable @inline(__always) public func glCompileShader(_ shader: GLuint) {
    _glCompileShader(shader)
}

@inlinable @inline(__always) public func glEnableVertexAttribArray(attributeIndex name: GLuint) {
    _glEnableVertexAttribArray(name)
}

@inlinable @inline(__always) public func glDisableVertexAttribArray(attributeIndex name: GLuint) {
    _glDisableVertexAttribArray(name)
}

@inlinable @inline(__always) public func glBindVertexArray(_ array: GLuint) {
    _glBindVertexArray(array)
}

@inlinable @inline(__always) public func glDepthFunc(_ function: OpenGL.Texture.Blending.Function) {
    _glDepthFunc(GLenum(function.value))
}

@inlinable @inline(__always) public func glDepthMask(_ enabled: Bool) {
    _glDepthMask(enabled ? GLboolean(GL_TRUE) : GLboolean(GL_FALSE))
}

@inlinable @inline(__always) public func glFramebufferTexture2D(target: OpenGL.Framebuffer.Target = .draw, attachment: OpenGL.Framebuffer.Attachment, textureTarget textarget: OpenGL.Texture.Target = .texture2D, texture: GLuint, level: GLint = 0) {
    _glFramebufferTexture2D(GLenum(target.value), GLenum(attachment.value), GLenum(textarget.value), texture, level)
}

@inlinable @inline(__always) public func glDrawBuffers(_ buffers: [OpenGL.Framebuffer.Attachment]) {
    _glDrawBuffers(GLsizei(buffers.count), buffers.map({GLenum($0.value)}))
}

@inlinable @inline(__always) public func glDrawArrays(mode: OpenGL.Elements.Mode, startIndex first: Int, numberOfComponents count: Int) {
    _glDrawArrays(GLenum(mode.value), GLint(first), GLsizei(count))
}

@inlinable @inline(__always) public func glBlendEquationSeparate(_ modeRGB: OpenGL.Blending.Equation, _ modeAlpha: OpenGL.Blending.Equation) {
    _glBlendEquationSeparate(GLenum(modeRGB.value), GLenum(modeAlpha.value))
}

@inlinable @inline(__always) public func glBlendEquation(_ equation: OpenGL.Blending.Equation) {
    _glBlendEquation(GLenum(equation.value))
}

@inlinable @inline(__always) public func glBlendFunc(source: OpenGL.Blending.Function, destination: OpenGL.Blending.Function) {
    _glBlendFunc(GLenum(source.value), GLenum(destination.value))
}

@inlinable @inline(__always) public func glBlendFuncSeparate(sourceRGB: OpenGL.Blending.Function, destinationRGB: OpenGL.Blending.Function, sourceAlpha: OpenGL.Blending.Function, destinationAlpha: OpenGL.Blending.Function) {
    _glBlendFuncSeparate(GLenum(sourceRGB.value), GLenum(destinationRGB.value), sfactorAlpha: GLenum(sourceAlpha.value), dfactorAlpha: GLenum(destinationAlpha.value))
}

@inlinable @inline(__always) public func glReadBuffer(_ target: OpenGL.Framebuffer.ReadWrite) {
    _glReadBuffer(GLenum(target.value))
}

@inlinable @inline(__always) public func glReadPixels(x: Int, y: Int, width: Int, height: Int, format: OpenGL.Format) -> [UInt8] {
    var pixels: [UInt8]
    switch format {
    case .depth, .red:
        pixels = Array<UInt8>(repeating: 0, count: (width * height) * 1)
    case .rgb:
        pixels = Array<UInt8>(repeating: 0, count: (width * height) * 3)
    case .rgba:
        pixels = Array<UInt8>(repeating: 0, count: (width * height) * 4)
    }
    _glReadPixels(GLint(x), GLint(y), GLsizei(width), GLsizei(height), GLenum(format.value), GLenum(OpenGL.Types.uint8.value), &pixels)
    return pixels
}

@inlinable @inline(__always) public func glFlush() {
    _glFlush()
}
