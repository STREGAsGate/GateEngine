/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(OpenGL_Linux)
import OpenGL_Linux

@_transparent @usableFromInline internal var GL_VENDOR: Int32 {return OpenGL_Linux.GL_VENDOR}
@_transparent @usableFromInline internal var GL_RENDERER: Int32 {return OpenGL_Linux.GL_RENDERER}
@_transparent @usableFromInline internal var GL_VERSION: Int32 {return OpenGL_Linux.GL_VERSION}
@_transparent @usableFromInline internal var GL_SHADING_LANGUAGE_VERSION: Int32 {return OpenGL_Linux.GL_SHADING_LANGUAGE_VERSION}

@_transparent @usableFromInline internal var GL_MAX_TEXTURE_SIZE: Int32 {return OpenGL_Linux.GL_MAX_TEXTURE_SIZE}
@_transparent @usableFromInline internal var GL_MAX_TEXTURE_IMAGE_UNITS: Int32 {return OpenGL_Linux.GL_MAX_TEXTURE_IMAGE_UNITS}
@_transparent @usableFromInline internal var GL_DRAW_FRAMEBUFFER_BINDING: Int32 {return OpenGL_Linux.GL_DRAW_FRAMEBUFFER_BINDING}

@_transparent @usableFromInline internal var GL_TRUE: Int32 {return OpenGL_Linux.GL_TRUE}
@_transparent @usableFromInline internal var GL_FALSE: Int32 {return OpenGL_Linux.GL_FALSE}

@_transparent @usableFromInline internal var GL_INT: Int32 {return OpenGL_Linux.GL_INT}
@_transparent @usableFromInline internal var GL_UNSIGNED_INT: Int32 {return OpenGL_Linux.GL_UNSIGNED_INT}
@_transparent @usableFromInline internal var GL_UNSIGNED_BYTE: Int32 {return OpenGL_Linux.GL_UNSIGNED_BYTE}
@_transparent @usableFromInline internal var GL_UNSIGNED_SHORT: Int32 {return OpenGL_Linux.GL_UNSIGNED_SHORT}
@_transparent @usableFromInline internal var GL_FLOAT: Int32 {return OpenGL_Linux.GL_FLOAT}

@_transparent @usableFromInline internal var GL_TRIANGLES: Int32 {return OpenGL_Linux.GL_TRIANGLES}
@_transparent @usableFromInline internal var GL_TRIANGLE_STRIP: Int32 {return OpenGL_Linux.GL_TRIANGLE_STRIP}
@_transparent @usableFromInline internal var GL_POINTS: Int32 {return OpenGL_Linux.GL_POINTS}
@_transparent @usableFromInline internal var GL_LINES: Int32 {return OpenGL_Linux.GL_LINES}
@_transparent @usableFromInline internal var GL_LINE_STRIP: Int32 {return OpenGL_Linux.GL_LINE_STRIP}

@_transparent @usableFromInline internal var GL_NO_ERROR: Int32 {return OpenGL_Linux.GL_NO_ERROR}
@_transparent @usableFromInline internal var GL_INVALID_ENUM: Int32 {return OpenGL_Linux.GL_INVALID_ENUM}
@_transparent @usableFromInline internal var GL_INVALID_VALUE: Int32 {return OpenGL_Linux.GL_INVALID_VALUE}
@_transparent @usableFromInline internal var GL_INVALID_OPERATION: Int32 {return OpenGL_Linux.GL_INVALID_OPERATION}
@_transparent @usableFromInline internal var GL_OUT_OF_MEMORY: Int32 {return OpenGL_Linux.GL_OUT_OF_MEMORY}
@_transparent @usableFromInline internal var GL_INVALID_FRAMEBUFFER_OPERATION: Int32 {return OpenGL_Linux.GL_INVALID_FRAMEBUFFER_OPERATION}
@_transparent @usableFromInline internal var GL_INVALID_INDEX: UInt32 {return OpenGL_Linux.GL_INVALID_INDEX}

@_transparent @usableFromInline internal var GL_FRAMEBUFFER_COMPLETE: Int32 {return OpenGL_Linux.GL_FRAMEBUFFER_COMPLETE}
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT: Int32 {return OpenGL_Linux.GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT}
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT: Int32 {return OpenGL_Linux.GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT}
#if os(macOS)
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER: Int32 {return OpenGL_Linux.GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER}
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER: Int32 {return OpenGL_Linux.GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER}
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS: Int32 {return OpenGL_Linux.GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS}
#endif
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_UNSUPPORTED: Int32 {return OpenGL_Linux.GL_FRAMEBUFFER_UNSUPPORTED}
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE: Int32 {return OpenGL_Linux.GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE}
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_UNDEFINED: Int32 {return OpenGL_Linux.GL_FRAMEBUFFER_UNDEFINED}

@_transparent @usableFromInline internal var GL_FRAMEBUFFER: Int32 {return OpenGL_Linux.GL_FRAMEBUFFER}
@_transparent @usableFromInline internal var GL_DRAW_FRAMEBUFFER: Int32 {return OpenGL_Linux.GL_DRAW_FRAMEBUFFER}
@_transparent @usableFromInline internal var GL_READ_FRAMEBUFFER: Int32 {return OpenGL_Linux.GL_READ_FRAMEBUFFER}

@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT0: Int32 {return OpenGL_Linux.GL_COLOR_ATTACHMENT0}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT1: Int32 {return OpenGL_Linux.GL_COLOR_ATTACHMENT1}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT2: Int32 {return OpenGL_Linux.GL_COLOR_ATTACHMENT2}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT3: Int32 {return OpenGL_Linux.GL_COLOR_ATTACHMENT3}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT4: Int32 {return OpenGL_Linux.GL_COLOR_ATTACHMENT4}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT5: Int32 {return OpenGL_Linux.GL_COLOR_ATTACHMENT5}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT6: Int32 {return OpenGL_Linux.GL_COLOR_ATTACHMENT6}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT7: Int32 {return OpenGL_Linux.GL_COLOR_ATTACHMENT7}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT8: Int32 {return OpenGL_Linux.GL_COLOR_ATTACHMENT8}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT9: Int32 {return OpenGL_Linux.GL_COLOR_ATTACHMENT9}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT10: Int32 {return OpenGL_Linux.GL_COLOR_ATTACHMENT10}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT11: Int32 {return OpenGL_Linux.GL_COLOR_ATTACHMENT11}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT12: Int32 {return OpenGL_Linux.GL_COLOR_ATTACHMENT12}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT13: Int32 {return OpenGL_Linux.GL_COLOR_ATTACHMENT13}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT14: Int32 {return OpenGL_Linux.GL_COLOR_ATTACHMENT14}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT15: Int32 {return OpenGL_Linux.GL_COLOR_ATTACHMENT15}
@_transparent @usableFromInline internal var GL_DEPTH_ATTACHMENT: Int32 {return OpenGL_Linux.GL_DEPTH_ATTACHMENT}
@_transparent @usableFromInline internal var GL_STENCIL_ATTACHMENT: Int32 {return OpenGL_Linux.GL_STENCIL_ATTACHMENT}

@_transparent @usableFromInline internal var GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE: Int32 {return OpenGL_Linux.GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE}
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME: Int32 {return OpenGL_Linux.GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME}

@_transparent @usableFromInline internal var GL_DEPTH_TEST: Int32 {return OpenGL_Linux.GL_DEPTH_TEST}
@_transparent @usableFromInline internal var GL_CULL_FACE: Int32 {return OpenGL_Linux.GL_CULL_FACE}
@_transparent @usableFromInline internal var GL_BLEND: Int32 {return OpenGL_Linux.GL_BLEND}

@_transparent @usableFromInline internal var GL_STATIC_DRAW: Int32 {return OpenGL_Linux.GL_STATIC_DRAW}
@_transparent @usableFromInline internal var GL_DYNAMIC_DRAW: Int32 {return OpenGL_Linux.GL_DYNAMIC_DRAW}

@_transparent @usableFromInline internal var GL_ARRAY_BUFFER: Int32 {return OpenGL_Linux.GL_ARRAY_BUFFER}
@_transparent @usableFromInline internal var GL_ELEMENT_ARRAY_BUFFER: Int32 {return OpenGL_Linux.GL_ELEMENT_ARRAY_BUFFER}

@_transparent @usableFromInline internal var GL_COMPILE_STATUS: Int32 {return OpenGL_Linux.GL_COMPILE_STATUS}
@_transparent @usableFromInline internal var GL_INFO_LOG_LENGTH: Int32 {return OpenGL_Linux.GL_INFO_LOG_LENGTH}
@_transparent @usableFromInline internal var GL_LINK_STATUS: Int32 {return OpenGL_Linux.GL_LINK_STATUS}
@_transparent @usableFromInline internal var GL_VALIDATE_STATUS: Int32 {return OpenGL_Linux.GL_VALIDATE_STATUS}

@_transparent @usableFromInline internal var GL_VERTEX_SHADER: Int32 {return OpenGL_Linux.GL_VERTEX_SHADER}
@_transparent @usableFromInline internal var GL_FRAGMENT_SHADER: Int32 {return OpenGL_Linux.GL_FRAGMENT_SHADER}
#if os(macOS)
@_transparent @usableFromInline internal var GL_GEOMETRY_SHADER: Int32 {return OpenGL_Linux.GL_GEOMETRY_SHADER}
#endif
@_transparent @usableFromInline internal var GL_TEXTURE_COMPARE_FUNC: Int32 {return OpenGL_Linux.GL_TEXTURE_COMPARE_FUNC}

@_transparent @usableFromInline internal var GL_NEAREST: Int32 {return OpenGL_Linux.GL_NEAREST}
@_transparent @usableFromInline internal var GL_LINEAR: Int32 {return OpenGL_Linux.GL_LINEAR}
@_transparent @usableFromInline internal var GL_NEAREST_MIPMAP_NEAREST: Int32 {return OpenGL_Linux.GL_NEAREST_MIPMAP_NEAREST}
@_transparent @usableFromInline internal var GL_LINEAR_MIPMAP_NEAREST: Int32 {return OpenGL_Linux.GL_LINEAR_MIPMAP_NEAREST}
@_transparent @usableFromInline internal var GL_NEAREST_MIPMAP_LINEAR: Int32 {return OpenGL_Linux.GL_NEAREST_MIPMAP_LINEAR}
@_transparent @usableFromInline internal var GL_LINEAR_MIPMAP_LINEAR: Int32 {return OpenGL_Linux.GL_LINEAR_MIPMAP_LINEAR}
@_transparent @usableFromInline internal var GL_TEXTURE_MAG_FILTER: Int32 {return OpenGL_Linux.GL_TEXTURE_MAG_FILTER}
@_transparent @usableFromInline internal var GL_TEXTURE_MIN_FILTER: Int32 {return OpenGL_Linux.GL_TEXTURE_MIN_FILTER}
@_transparent @usableFromInline internal var GL_TEXTURE_WRAP_S: Int32 {return OpenGL_Linux.GL_TEXTURE_WRAP_S}
@_transparent @usableFromInline internal var GL_TEXTURE_WRAP_T: Int32 {return OpenGL_Linux.GL_TEXTURE_WRAP_T}
@_transparent @usableFromInline internal var GL_CLAMP_TO_EDGE: Int32 {return OpenGL_Linux.GL_CLAMP_TO_EDGE}
@_transparent @usableFromInline internal var GL_REPEAT: Int32 {return OpenGL_Linux.GL_REPEAT}

@_transparent @usableFromInline internal var GL_NEVER: Int32 {return OpenGL_Linux.GL_NEVER}
@_transparent @usableFromInline internal var GL_LESS: Int32 {return OpenGL_Linux.GL_LESS}
@_transparent @usableFromInline internal var GL_EQUAL: Int32 {return OpenGL_Linux.GL_EQUAL}
@_transparent @usableFromInline internal var GL_LEQUAL: Int32 {return OpenGL_Linux.GL_LEQUAL}
@_transparent @usableFromInline internal var GL_GREATER: Int32 {return OpenGL_Linux.GL_GREATER}
@_transparent @usableFromInline internal var GL_NOTEQUAL: Int32 {return OpenGL_Linux.GL_NOTEQUAL}
@_transparent @usableFromInline internal var GL_GEQUAL: Int32 {return OpenGL_Linux.GL_GEQUAL}
@_transparent @usableFromInline internal var GL_ALWAYS: Int32 {return OpenGL_Linux.GL_ALWAYS}

@_transparent @usableFromInline internal var GL_TEXTURE_2D: Int32 {return OpenGL_Linux.GL_TEXTURE_2D}
@_transparent @usableFromInline internal var GL_RENDERBUFFER: Int32 {return OpenGL_Linux.GL_RENDERBUFFER}
@_transparent @usableFromInline internal var GL_DEPTH_COMPONENT: Int32 {return OpenGL_Linux.GL_DEPTH_COMPONENT}

@_transparent @usableFromInline internal var GL_PACK_ALIGNMENT: Int32 {return OpenGL_Linux.GL_PACK_ALIGNMENT}
@_transparent @usableFromInline internal var GL_UNPACK_ALIGNMENT: Int32 {return OpenGL_Linux.GL_UNPACK_ALIGNMENT}

@_transparent @usableFromInline internal var GL_COLOR_BUFFER_BIT: Int32 {return OpenGL_Linux.GL_COLOR_BUFFER_BIT}
@_transparent @usableFromInline internal var GL_DEPTH_BUFFER_BIT: Int32 {return OpenGL_Linux.GL_DEPTH_BUFFER_BIT}
@_transparent @usableFromInline internal var GL_STENCIL_BUFFER_BIT: Int32 {return OpenGL_Linux.GL_STENCIL_BUFFER_BIT}

@_transparent @usableFromInline internal var GL_TEXTURE0: Int32 {return OpenGL_Linux.GL_TEXTURE0}
@_transparent @usableFromInline internal var GL_TEXTURE1: Int32 {return OpenGL_Linux.GL_TEXTURE1}
@_transparent @usableFromInline internal var GL_TEXTURE2: Int32 {return OpenGL_Linux.GL_TEXTURE2}
@_transparent @usableFromInline internal var GL_TEXTURE3: Int32 {return OpenGL_Linux.GL_TEXTURE3}
@_transparent @usableFromInline internal var GL_TEXTURE4: Int32 {return OpenGL_Linux.GL_TEXTURE4}
@_transparent @usableFromInline internal var GL_TEXTURE5: Int32 {return OpenGL_Linux.GL_TEXTURE5}
@_transparent @usableFromInline internal var GL_TEXTURE6: Int32 {return OpenGL_Linux.GL_TEXTURE6}
@_transparent @usableFromInline internal var GL_TEXTURE7: Int32 {return OpenGL_Linux.GL_TEXTURE7}
@_transparent @usableFromInline internal var GL_TEXTURE8: Int32 {return OpenGL_Linux.GL_TEXTURE8}
@_transparent @usableFromInline internal var GL_TEXTURE9: Int32 {return OpenGL_Linux.GL_TEXTURE9}
@_transparent @usableFromInline internal var GL_TEXTURE10: Int32 {return OpenGL_Linux.GL_TEXTURE10}
@_transparent @usableFromInline internal var GL_TEXTURE11: Int32 {return OpenGL_Linux.GL_TEXTURE11}
@_transparent @usableFromInline internal var GL_TEXTURE12: Int32 {return OpenGL_Linux.GL_TEXTURE12}
@_transparent @usableFromInline internal var GL_TEXTURE13: Int32 {return OpenGL_Linux.GL_TEXTURE13}
@_transparent @usableFromInline internal var GL_TEXTURE14: Int32 {return OpenGL_Linux.GL_TEXTURE14}
@_transparent @usableFromInline internal var GL_TEXTURE15: Int32 {return OpenGL_Linux.GL_TEXTURE15}
@_transparent @usableFromInline internal var GL_TEXTURE16: Int32 {return OpenGL_Linux.GL_TEXTURE16}
@_transparent @usableFromInline internal var GL_TEXTURE17: Int32 {return OpenGL_Linux.GL_TEXTURE17}
@_transparent @usableFromInline internal var GL_TEXTURE18: Int32 {return OpenGL_Linux.GL_TEXTURE18}
@_transparent @usableFromInline internal var GL_TEXTURE19: Int32 {return OpenGL_Linux.GL_TEXTURE19}
@_transparent @usableFromInline internal var GL_TEXTURE20: Int32 {return OpenGL_Linux.GL_TEXTURE20}
@_transparent @usableFromInline internal var GL_TEXTURE21: Int32 {return OpenGL_Linux.GL_TEXTURE21}
@_transparent @usableFromInline internal var GL_TEXTURE22: Int32 {return OpenGL_Linux.GL_TEXTURE22}
@_transparent @usableFromInline internal var GL_TEXTURE23: Int32 {return OpenGL_Linux.GL_TEXTURE23}
@_transparent @usableFromInline internal var GL_TEXTURE24: Int32 {return OpenGL_Linux.GL_TEXTURE24}
@_transparent @usableFromInline internal var GL_TEXTURE25: Int32 {return OpenGL_Linux.GL_TEXTURE25}
@_transparent @usableFromInline internal var GL_TEXTURE26: Int32 {return OpenGL_Linux.GL_TEXTURE26}
@_transparent @usableFromInline internal var GL_TEXTURE27: Int32 {return OpenGL_Linux.GL_TEXTURE27}
@_transparent @usableFromInline internal var GL_TEXTURE28: Int32 {return OpenGL_Linux.GL_TEXTURE28}
@_transparent @usableFromInline internal var GL_TEXTURE29: Int32 {return OpenGL_Linux.GL_TEXTURE29}
@_transparent @usableFromInline internal var GL_TEXTURE30: Int32 {return OpenGL_Linux.GL_TEXTURE30}
@_transparent @usableFromInline internal var GL_TEXTURE31: Int32 {return OpenGL_Linux.GL_TEXTURE31}

@_transparent @usableFromInline internal var GL_RED: Int32 {return OpenGL_Linux.GL_RED}
@_transparent @usableFromInline internal var GL_RGB: Int32 {return OpenGL_Linux.GL_RGB}
@_transparent @usableFromInline internal var GL_RGBA: Int32 {return OpenGL_Linux.GL_RGBA}
@_transparent @usableFromInline internal var GL_SRGB_ALPHA: Int32 {return OpenGL_Linux.GL_SRGB_ALPHA}

@_transparent @usableFromInline internal var GL_DEPTH_COMPONENT32F: Int32 {return OpenGL_Linux.GL_DEPTH_COMPONENT32F}

public typealias GLbitfield = OpenGL_Linux.GLbitfield
public typealias GLenum = OpenGL_Linux.GLenum
public typealias GLuint = OpenGL_Linux.GLuint
public typealias GLint = OpenGL_Linux.GLint
public typealias GLsizei = OpenGL_Linux.GLsizei
public typealias GLsizeiptr = OpenGL_Linux.GLsizeiptr
public typealias GLboolean = OpenGL_Linux.GLboolean
public typealias GLbyte = OpenGL_Linux.GLbyte
public typealias GLubyte = OpenGL_Linux.GLubyte
public typealias GLchar = OpenGL_Linux.GLchar
public typealias GLfloat = OpenGL_Linux.GLfloat
#if os(macOS)
public typealias GLdouble = OpenGL_Linux.GLdouble
#endif

@_transparent @usableFromInline internal var GL_MIN: Int32 {return OpenGL_Linux.GL_MIN}
@_transparent @usableFromInline internal var GL_MAX: Int32 {return OpenGL_Linux.GL_MAX}
@_transparent @usableFromInline internal var GL_FUNC_ADD: Int32 {return OpenGL_Linux.GL_FUNC_ADD}
@_transparent @usableFromInline internal var GL_FUNC_SUBTRACT: Int32 {return OpenGL_Linux.GL_FUNC_SUBTRACT}
@_transparent @usableFromInline internal var GL_FUNC_REVERSE_SUBTRACT: Int32 {return OpenGL_Linux.GL_FUNC_REVERSE_SUBTRACT}

@_transparent @usableFromInline internal var GL_ZERO: Int32 {return OpenGL_Linux.GL_ZERO}
@_transparent @usableFromInline internal var GL_ONE: Int32 {return OpenGL_Linux.GL_ONE}
@_transparent @usableFromInline internal var GL_SRC_COLOR: Int32 {return OpenGL_Linux.GL_SRC_COLOR}
@_transparent @usableFromInline internal var GL_ONE_MINUS_SRC_COLOR: Int32 {return OpenGL_Linux.GL_ONE_MINUS_SRC_COLOR}
@_transparent @usableFromInline internal var GL_DST_COLOR: Int32 {return OpenGL_Linux.GL_DST_COLOR}
@_transparent @usableFromInline internal var GL_ONE_MINUS_DST_COLOR: Int32 {return OpenGL_Linux.GL_ONE_MINUS_DST_COLOR}
@_transparent @usableFromInline internal var GL_SRC_ALPHA: Int32 {return OpenGL_Linux.GL_SRC_ALPHA}
@_transparent @usableFromInline internal var GL_ONE_MINUS_SRC_ALPHA: Int32 {return OpenGL_Linux.GL_ONE_MINUS_SRC_ALPHA}
@_transparent @usableFromInline internal var GL_DST_ALPHA: Int32 {return OpenGL_Linux.GL_DST_ALPHA}
@_transparent @usableFromInline internal var GL_ONE_MINUS_DST_ALPHA: Int32 {return OpenGL_Linux.GL_ONE_MINUS_DST_ALPHA}
@_transparent @usableFromInline internal var GL_CONSTANT_COLOR: Int32 {return OpenGL_Linux.GL_CONSTANT_COLOR}
@_transparent @usableFromInline internal var GL_ONE_MINUS_CONSTANT_COLOR: Int32 {return OpenGL_Linux.GL_ONE_MINUS_CONSTANT_COLOR}
@_transparent @usableFromInline internal var GL_CONSTANT_ALPHA: Int32 {return OpenGL_Linux.GL_CONSTANT_ALPHA}
@_transparent @usableFromInline internal var GL_ONE_MINUS_CONSTANT_ALPHA: Int32 {return OpenGL_Linux.GL_ONE_MINUS_CONSTANT_ALPHA}
@_transparent @usableFromInline internal var GL_SRC_ALPHA_SATURATE: Int32 {return OpenGL_Linux.GL_SRC_ALPHA_SATURATE}

@_transparent @usableFromInline internal var GL_FRONT: Int32 {return OpenGL_Linux.GL_FRONT}
@_transparent @usableFromInline internal var GL_BACK: Int32 {return OpenGL_Linux.GL_BACK}

@_transparent @usableFromInline internal var GL_CW: Int32 {return OpenGL_Linux.GL_CW}
@_transparent @usableFromInline internal var GL_CCW: Int32 {return OpenGL_Linux.GL_CCW}

@_transparent @usableFromInline internal var GL_DEPTH: Int32 {return OpenGL_Linux.GL_DEPTH}

@_transparent @usableFromInline internal func _glFrontFacing(_ mode: GLenum) {
    OpenGL_Linux.glFrontFace(mode)
}

@_transparent @usableFromInline internal func _glCullFace(_ mode: GLenum) {
    OpenGL_Linux.glCullFace(mode)
}

//framebuffer
@_transparent @usableFromInline internal func _glCheckFramebufferStatus(_ target: GLenum) -> GLenum {
    return OpenGL_Linux.glCheckFramebufferStatus(target)
}

@_transparent @usableFromInline internal func _glGenFramebuffers(_ count: GLsizei, _ framebuffers: UnsafeMutablePointer<GLuint>!) {
    OpenGL_Linux.glGenFramebuffers(count, framebuffers)
}

@_transparent @usableFromInline internal func _glBindFramebuffer(_ target: GLenum, _ framebuffer: GLuint) {
    OpenGL_Linux.glBindFramebuffer(UInt32(target), framebuffer)
}

@_transparent @usableFromInline internal func _glDeleteFramebuffers(_ count: GLint,_ buffers: UnsafePointer<UInt32>?) {
    OpenGL_Linux.glDeleteFramebuffers(count, buffers)
}

@_transparent @usableFromInline internal func _glGetFramebufferAttachmentParameteriv(_ target: GLenum, _ attachment: GLenum, _ pname: GLenum, _ params: UnsafeMutablePointer<GLint>!) {
    OpenGL_Linux.glGetFramebufferAttachmentParameteriv(target, attachment, pname, params)
}

//shader

@_transparent @usableFromInline internal func _glGetShaderInfoLog(_ shader: GLuint, _ maxLength: GLsizei, _ length: UnsafeMutablePointer<GLsizei>?, _ infoLog: UnsafeMutablePointer<GLchar>?) {
    OpenGL_Linux.glGetShaderInfoLog(shader, maxLength, length, infoLog)
}

//glUniform

@_transparent @usableFromInline internal func _glUniform1i(_ location: GLint, _ v1: GLint) {
    OpenGL_Linux.glUniform1i(location, v1)
}

@_transparent @usableFromInline internal func _glUniform2i(_ location: GLint, _ v1: GLint, _ v2: GLint) {
    OpenGL_Linux.glUniform2i(location, v1, v2)
}

@_transparent @usableFromInline internal func _glUniform3i(_ location: GLint, _ v1: GLint, _ v2: GLint, _ v3: GLint) {
    OpenGL_Linux.glUniform3i(location, v1, v2, v3)
}

@_transparent @usableFromInline internal func _glUniform4i(_ location: GLint, _ v1: GLint, _ v2: GLint, _ v3: GLint, _ v4: GLint) {
    OpenGL_Linux.glUniform4i(location, v1, v2, v3, v4)
}

@_transparent @usableFromInline internal func _glUniform1ui(_ location: GLint, _ v1: GLuint) {
    OpenGL_Linux.glUniform1ui(location, v1)
}

@_transparent @usableFromInline internal func _glUniform2ui(_ location: GLint, _ v1: GLuint, _ v2: GLuint) {
    OpenGL_Linux.glUniform2ui(location, v1, v2)
}

@_transparent @usableFromInline internal func _glUniform3ui(_ location: GLint, _ v1: GLuint, _ v2: GLuint, _ v3: GLuint) {
    OpenGL_Linux.glUniform3ui(location, v1, v2, v3)
}

@_transparent @usableFromInline internal func _glUniform4ui(_ location: GLint, _ v1: GLuint, _ v2: GLuint, _ v3: GLuint, _ v4: GLuint) {
    OpenGL_Linux.glUniform4ui(location, v1, v2, v3, v4)
}

@_transparent @usableFromInline internal func _glUniform1f(_ location: GLint, _ v1: GLfloat) {
    OpenGL_Linux.glUniform1f(location, v1)
}

@_transparent @usableFromInline internal func _glUniform2f(_ location: GLint, _ v1: GLfloat, _ v2: GLfloat) {
    OpenGL_Linux.glUniform2f(location, v1, v2)
}

@_transparent @usableFromInline internal func _glUniform3f(_ location: GLint, _ v1: GLfloat, _ v2: GLfloat, _ v3: GLfloat) {
    OpenGL_Linux.glUniform3f(location, v1, v2, v3)
}

@_transparent @usableFromInline internal func _glUniform4f(_ location: GLint, _ v1: GLfloat, _ v2: GLfloat, _ v3: GLfloat, _ v4: GLfloat) {
    OpenGL_Linux.glUniform4f(location, v1, v2, v3, v4)
}

@_transparent @usableFromInline internal func _glGetProgramiv(_ program: GLuint, _ pname: GLenum, _ params:  UnsafeMutablePointer<GLint>?) {
    OpenGL_Linux.glGetProgramiv(program, pname, params)
}

@_transparent @usableFromInline internal func _glGetAttribLocation(_ program: GLuint, _ name: UnsafePointer<GLchar>!) -> GLint {
    return OpenGL_Linux.glGetAttribLocation(program, name)
}

@_transparent @usableFromInline internal func _glAttachShader(_ program: GLuint, _ shader: GLuint) {
    OpenGL_Linux.glAttachShader(program, shader)
}

@_transparent @usableFromInline internal func _glCreateProgram() -> GLuint {
    return OpenGL_Linux.glCreateProgram()
}

@_transparent @usableFromInline internal func _glGenerateMipmap(_ target: GLenum) {
    OpenGL_Linux.glGenerateMipmap(target)
}

@_transparent @usableFromInline internal func _glDeleteProgram(_ program: GLuint) {
    OpenGL_Linux.glDeleteProgram(program)
}

@_transparent @usableFromInline internal func _glUseProgram(_ program: GLuint) {
    OpenGL_Linux.glUseProgram(program)
}

@_transparent @usableFromInline internal func _glGetShaderiv(_ shader: GLuint, _ pname: GLenum, _ params: UnsafeMutablePointer<GLint>!) {
    OpenGL_Linux.glGetShaderiv(shader, pname, params)
}

@_transparent @usableFromInline internal func _glCompileShader(_ shader: GLuint) {
    OpenGL_Linux.glCompileShader(shader)
}

@_transparent @usableFromInline internal func _glShaderSource(_ shader: GLuint, _ count: GLsizei, _ string: UnsafePointer<UnsafePointer<GLchar>?>?, _ length: UnsafeMutablePointer<GLint>!) {
    OpenGL_Linux.glShaderSource(shader, count, string, length)
}

@_transparent @usableFromInline internal func _glUniformMatrix3fv(_ location: GLint, _ count: GLsizei, _ transpose: GLboolean, _ value: UnsafePointer<GLfloat>!) {
    OpenGL_Linux.glUniformMatrix3fv(location, count, transpose, value)
}

@_transparent @usableFromInline internal func _glUniformMatrix4fv(_ location: GLint, _ count: GLsizei, _ transpose: GLboolean, _ value: UnsafePointer<GLfloat>!) {
    OpenGL_Linux.glUniformMatrix4fv(location, count, transpose, value)
}

@_transparent @usableFromInline internal func _glEnableVertexAttribArray(_ name: GLuint) {
    OpenGL_Linux.glEnableVertexAttribArray(name)
}

@_transparent @usableFromInline internal func _glVertexAttribDivisor(_ index: GLuint, divisor: GLuint) {
    OpenGL_Linux.glVertexAttribDivisor(index, divisor)
}

@_transparent @usableFromInline internal func _glBindBuffer(_ target: GLenum, _ buffer: GLuint) {
    OpenGL_Linux.glBindBuffer(target, buffer)
}

@_transparent @usableFromInline internal func _glBufferData(_ target: GLenum, _ size: GLsizeiptr, _ data: UnsafeRawPointer!, _ usage: GLenum) {
    OpenGL_Linux.glBufferData(target, size, data, usage)
}

@_transparent @usableFromInline internal func _glTexParameteri(_ target: GLenum, _ pname: GLenum, _ param: GLint) {
    OpenGL_Linux.glTexParameteri(target, pname, param)
}

@_transparent @usableFromInline internal func _glGetIntegerv(_ pname: GLenum, _ data: UnsafeMutablePointer<GLint>!) {
    OpenGL_Linux.glGetIntegerv(pname, data)
}

@_transparent @usableFromInline internal func _glBindTexture(_ target: GLenum, _ texture: GLuint) {
    OpenGL_Linux.glBindTexture(target, texture)
}

@_transparent @usableFromInline internal func _glGenTextures(_ count: GLsizei, _ textures: UnsafeMutablePointer<GLuint>!) {
    OpenGL_Linux.glGenTextures(count, textures)
}

@_transparent @usableFromInline internal func _glDeleteTextures(_ count: GLsizei, _ textures: UnsafeMutablePointer<GLuint>!) {
    OpenGL_Linux.glDeleteTextures(count, textures)
}

@_transparent @usableFromInline internal func _glActiveTexture(_ texture: GLenum) {
    OpenGL_Linux.glActiveTexture(texture)
}

@_transparent @usableFromInline internal func _glPixelStorei(_ pname: GLenum, _ param: GLint) {
    OpenGL_Linux.glPixelStorei(pname, param)
}

@_transparent @usableFromInline internal func _glTexImage2D(_ target: GLenum, _ level: GLint, _ internalFormat: GLint, _ width: GLsizei, _ height: GLsizei, _ border: GLint, _ format: GLenum, _ type: GLenum, _ pixels: UnsafeRawPointer!) {
    OpenGL_Linux.glTexImage2D(target, level, internalFormat, width, height, border, format, type, pixels)
}

@_transparent @usableFromInline internal func _glDisableVertexAttribArray(_ index: GLuint) {
    OpenGL_Linux.glDisableVertexAttribArray(index)
}

@_transparent @usableFromInline internal func _glVertexAttribPointer(_ index: GLuint, _ size: GLint, _ type: GLenum, _ normalized: GLboolean, _ stride: GLsizei, _ pointer: UnsafeMutableRawPointer!) {
    OpenGL_Linux.glVertexAttribPointer(index, size, type, normalized, stride, pointer)
}

@_transparent @usableFromInline internal func _glGetError() -> GLenum {
    return OpenGL_Linux.glGetError()
}

@_transparent @usableFromInline internal func _glEnable(_ capability: GLenum) {
    OpenGL_Linux.glEnable(capability)
}

@_transparent @usableFromInline internal func _glDisable(_ capability: GLenum) {
    OpenGL_Linux.glDisable(capability)
}

@_transparent @usableFromInline internal func _glGenBuffers(_ count: GLint, _ buffers: UnsafeMutablePointer<GLuint>!) {
    OpenGL_Linux.glGenBuffers(count, buffers)
}

@_transparent @usableFromInline internal func _glDeleteBuffers(_ count: GLint, _ buffers: UnsafePointer<GLuint>!) {
    OpenGL_Linux.glDeleteBuffers(count, buffers)
}

@_transparent @usableFromInline internal func _glClearColor(_ red: GLfloat, _ green: GLfloat, _ blue: GLfloat, _ alpha: GLfloat) {
    OpenGL_Linux.glClearColor(red, green, blue, alpha)
}

@_transparent @usableFromInline internal func _glClearDepth(_ value: GLfloat) {
    OpenGL_Linux.glClearDepthf(value)
}

@_transparent @usableFromInline internal func _glClear(_ mask: GLbitfield) {
    OpenGL_Linux.glClear(mask)
}

@_transparent @usableFromInline internal func _glGenVertexArrays(_ count: GLint, _ arrays: UnsafeMutablePointer<GLuint>!) {
    OpenGL_Linux.glGenVertexArrays(count, arrays)
}

@_transparent @usableFromInline internal func _glBindVertexArray(_ array: GLuint) {
    OpenGL_Linux.glBindVertexArray(array)
}

@_transparent @usableFromInline internal func _glDeleteVertexArrays(_ count: GLint, _ arrays: UnsafePointer<GLuint>!) {
    OpenGL_Linux.glDeleteVertexArrays(count, arrays)
}

@_transparent @usableFromInline internal func _glViewport(_ x: GLint, _ y: GLint, _ width: GLsizei, _ height: GLsizei) {
    OpenGL_Linux.glViewport(x, y, width, height)
}

@_transparent @usableFromInline internal func _glScissor(_ x: GLint, _ y: GLint, _ width: GLsizei, _ height: GLsizei) {
    OpenGL_Linux.glScissor(x, y, width, height)
}

@_transparent @usableFromInline internal func _glGetString(_ name: GLenum) -> UnsafePointer<GLubyte>? {
    return OpenGL_Linux.glGetString(name)
}

@_transparent @usableFromInline internal func _glDrawElements(_ mode: GLenum, _ count: GLsizei, _ type: GLenum, _ indices: UnsafeRawPointer!) {
    OpenGL_Linux.glDrawElements(mode, count, type, indices)
}

@_transparent @usableFromInline internal func _glDrawElementsInstanced(_ mode: GLenum, _ count: GLsizei, _ type: GLenum, _ indices: UnsafeRawPointer!, _ instanceCount: GLsizei) {
    OpenGL_Linux.glDrawElementsInstanced(mode, count, type, indices, instanceCount)
}

@_transparent @usableFromInline internal func _glGetUniformBlockIndex(_ program: GLuint, _ uniformBlockName: UnsafePointer<GLchar>!) -> GLuint {
    return OpenGL_Linux.glGetUniformBlockIndex(program, uniformBlockName)
}

@_transparent @usableFromInline internal func _glGetUniformLocation(_ program: GLuint, _ name: UnsafePointer<GLchar>!) -> GLint {
    return OpenGL_Linux.glGetUniformLocation(program, name)
}

@_transparent @usableFromInline internal func _glCreateShader(_ type: GLenum) -> GLuint {
    return OpenGL_Linux.glCreateShader(type)
}

@_transparent @usableFromInline internal func _glGetProgramInfoLog(_ program: GLuint, _ maxLength: GLsizei, _ length: UnsafeMutablePointer<GLsizei>!, _ infoLog: UnsafeMutablePointer<GLchar>!) {
    OpenGL_Linux.glGetProgramInfoLog(program, maxLength, length, infoLog)
}

@_transparent @usableFromInline internal func _glLinkProgram(_ program: GLuint) {
    OpenGL_Linux.glLinkProgram(program)
}

@_transparent @usableFromInline internal func _glValidateProgram(_ program: GLuint) {
    OpenGL_Linux.glValidateProgram(program)
}

@_transparent @usableFromInline internal func _glDeleteShader(_ shader: GLuint) {
    OpenGL_Linux.glDeleteShader(shader)
}

@_transparent @usableFromInline internal func _glDepthFunc(_ function: GLenum) {
    OpenGL_Linux.glDepthFunc(function)
}

@_transparent @usableFromInline internal func _glDepthMask(_ enabled: GLboolean) {
    OpenGL_Linux.glDepthMask(enabled)
}

@_transparent @usableFromInline internal func _glFramebufferTexture2D(_ target: GLenum, _ attachment: GLenum, _ textarget: GLenum, _ texture: GLuint, _ level: GLint) {
    OpenGL_Linux.glFramebufferTexture2D(target, attachment, textarget, texture, level)
}

@_transparent @usableFromInline internal func _glDrawBuffers(_ count: GLsizei, _ buffers: UnsafePointer<GLenum>!) {
    OpenGL_Linux.glDrawBuffers(count, buffers)
}

@_transparent @usableFromInline internal func _glDrawArrays(_ mode: GLenum, _ first: GLint, _ count: GLsizei) {
    OpenGL_Linux.glDrawArrays(mode, first, count)
}

@_transparent @usableFromInline internal func _glBlendEquationSeparate(_ modeRGB: GLenum, _ modeAlpha: GLenum) {
    OpenGL_Linux.glBlendEquationSeparate(modeRGB, modeAlpha)
}

@_transparent @usableFromInline internal func _glBlendEquation(_ mode: GLenum) {
    OpenGL_Linux.glBlendEquation(mode)
}

@_transparent @usableFromInline internal func _glBlendFunc(_ sfactor: GLenum, _ dfactor: GLenum) {
    OpenGL_Linux.glBlendFunc(sfactor, dfactor)
}

@_transparent @usableFromInline internal func _glBlendFuncSeparate(_ sfactorRGB: GLenum, _ dfactorRGB: GLenum, sfactorAlpha: GLenum, dfactorAlpha: GLenum) {
    OpenGL_Linux.glBlendFuncSeparate(sfactorRGB, dfactorRGB, sfactorAlpha, dfactorAlpha)
}

@_transparent @usableFromInline internal func _glReadBuffer(_ mode: GLenum) {
    OpenGL_Linux.glReadBuffer(mode)
}

@_transparent @usableFromInline internal func _glReadPixels(_ x: GLint, _ y: GLint, _ width: GLsizei, _ height: GLsizei, _ format: GLenum, _ type: GLenum, _ pixels: UnsafeMutableRawPointer!) {
    OpenGL_Linux.glReadPixels(x, y, width, height, format, type, pixels)
}

@_transparent @usableFromInline internal func _glFlush() {
    OpenGL_Linux.glFlush()
}

#endif
