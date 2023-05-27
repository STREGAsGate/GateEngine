/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(GLEW) && os(Linux)

import GLEW

@_transparent @usableFromInline internal var GL_VENDOR: Int32 {return GLEW.GL_VENDOR}
@_transparent @usableFromInline internal var GL_RENDERER: Int32 {return GLEW.GL_RENDERER}
@_transparent @usableFromInline internal var GL_VERSION: Int32 {return GLEW.GL_VERSION}
@_transparent @usableFromInline internal var GL_SHADING_LANGUAGE_VERSION: Int32 {return GLEW.GL_SHADING_LANGUAGE_VERSION}

@_transparent @usableFromInline internal var GL_MAX_TEXTURE_SIZE: Int32 {return GLEW.GL_MAX_TEXTURE_SIZE}
@_transparent @usableFromInline internal var GL_MAX_TEXTURE_IMAGE_UNITS: Int32 {return GLEW.GL_MAX_TEXTURE_IMAGE_UNITS}
@_transparent @usableFromInline internal var GL_DRAW_FRAMEBUFFER_BINDING: Int32 {return GLEW.GL_DRAW_FRAMEBUFFER_BINDING}

@_transparent @usableFromInline internal var GL_TRUE: Int32 {return GLEW.GL_TRUE}
@_transparent @usableFromInline internal var GL_FALSE: Int32 {return GLEW.GL_FALSE}

@_transparent @usableFromInline internal var GL_INT: Int32 {return GLEW.GL_INT}
@_transparent @usableFromInline internal var GL_UNSIGNED_INT: Int32 {return GLEW.GL_UNSIGNED_INT}
@_transparent @usableFromInline internal var GL_UNSIGNED_BYTE: Int32 {return GLEW.GL_UNSIGNED_BYTE}
@_transparent @usableFromInline internal var GL_UNSIGNED_SHORT: Int32 {return GLEW.GL_UNSIGNED_SHORT}
@_transparent @usableFromInline internal var GL_FLOAT: Int32 {return GLEW.GL_FLOAT}

@_transparent @usableFromInline internal var GL_TRIANGLES: Int32 {return GLEW.GL_TRIANGLES}
@_transparent @usableFromInline internal var GL_TRIANGLE_STRIP: Int32 {return GLEW.GL_TRIANGLE_STRIP}
@_transparent @usableFromInline internal var GL_POINTS: Int32 {return GLEW.GL_POINTS}
@_transparent @usableFromInline internal var GL_LINES: Int32 {return GLEW.GL_LINES}
@_transparent @usableFromInline internal var GL_LINE_STRIP: Int32 {return GLEW.GL_LINE_STRIP}

@_transparent @usableFromInline internal var GL_NO_ERROR: Int32 {return GLEW.GL_NO_ERROR}
@_transparent @usableFromInline internal var GL_INVALID_ENUM: Int32 {return GLEW.GL_INVALID_ENUM}
@_transparent @usableFromInline internal var GL_INVALID_VALUE: Int32 {return GLEW.GL_INVALID_VALUE}
@_transparent @usableFromInline internal var GL_INVALID_OPERATION: Int32 {return GLEW.GL_INVALID_OPERATION}
@_transparent @usableFromInline internal var GL_OUT_OF_MEMORY: Int32 {return GLEW.GL_OUT_OF_MEMORY}
@_transparent @usableFromInline internal var GL_INVALID_FRAMEBUFFER_OPERATION: Int32 {return GLEW.GL_INVALID_FRAMEBUFFER_OPERATION}
@_transparent @usableFromInline internal var GL_INVALID_INDEX: UInt32 {return GLEW.GL_INVALID_INDEX}

@_transparent @usableFromInline internal var GL_FRAMEBUFFER_COMPLETE: Int32 {return GLEW.GL_FRAMEBUFFER_COMPLETE}
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT: Int32 {return GLEW.GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT}
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT: Int32 {return GLEW.GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT}
#if os(Linux) || os(Windows)
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER: Int32 {return GLEW.GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER}
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER: Int32 {return GLEW.GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER}
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS: Int32 {return GLEW.GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS}
#endif
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_UNSUPPORTED: Int32 {return GLEW.GL_FRAMEBUFFER_UNSUPPORTED}
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE: Int32 {return GLEW.GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE}
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_UNDEFINED: Int32 {return GLEW.GL_FRAMEBUFFER_UNDEFINED}

@_transparent @usableFromInline internal var GL_FRAMEBUFFER: Int32 {return GLEW.GL_FRAMEBUFFER}
@_transparent @usableFromInline internal var GL_DRAW_FRAMEBUFFER: Int32 {return GLEW.GL_DRAW_FRAMEBUFFER}
@_transparent @usableFromInline internal var GL_READ_FRAMEBUFFER: Int32 {return GLEW.GL_READ_FRAMEBUFFER}

@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT0: Int32 {return GLEW.GL_COLOR_ATTACHMENT0}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT1: Int32 {return GLEW.GL_COLOR_ATTACHMENT1}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT2: Int32 {return GLEW.GL_COLOR_ATTACHMENT2}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT3: Int32 {return GLEW.GL_COLOR_ATTACHMENT3}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT4: Int32 {return GLEW.GL_COLOR_ATTACHMENT4}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT5: Int32 {return GLEW.GL_COLOR_ATTACHMENT5}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT6: Int32 {return GLEW.GL_COLOR_ATTACHMENT6}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT7: Int32 {return GLEW.GL_COLOR_ATTACHMENT7}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT8: Int32 {return GLEW.GL_COLOR_ATTACHMENT8}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT9: Int32 {return GLEW.GL_COLOR_ATTACHMENT9}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT10: Int32 {return GLEW.GL_COLOR_ATTACHMENT10}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT11: Int32 {return GLEW.GL_COLOR_ATTACHMENT11}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT12: Int32 {return GLEW.GL_COLOR_ATTACHMENT12}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT13: Int32 {return GLEW.GL_COLOR_ATTACHMENT13}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT14: Int32 {return GLEW.GL_COLOR_ATTACHMENT14}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT15: Int32 {return GLEW.GL_COLOR_ATTACHMENT15}
@_transparent @usableFromInline internal var GL_DEPTH_ATTACHMENT: Int32 {return GLEW.GL_DEPTH_ATTACHMENT}
@_transparent @usableFromInline internal var GL_STENCIL_ATTACHMENT: Int32 {return GLEW.GL_STENCIL_ATTACHMENT}

@_transparent @usableFromInline internal var GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE: Int32 {return GLEW.GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE}
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME: Int32 {return GLEW.GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME}

@_transparent @usableFromInline internal var GL_DEPTH_TEST: Int32 {return GLEW.GL_DEPTH_TEST}
@_transparent @usableFromInline internal var GL_CULL_FACE: Int32 {return GLEW.GL_CULL_FACE}
@_transparent @usableFromInline internal var GL_BLEND: Int32 {return GLEW.GL_BLEND}

@_transparent @usableFromInline internal var GL_STATIC_DRAW: Int32 {return GLEW.GL_STATIC_DRAW}
@_transparent @usableFromInline internal var GL_DYNAMIC_DRAW: Int32 {return GLEW.GL_DYNAMIC_DRAW}

@_transparent @usableFromInline internal var GL_ARRAY_BUFFER: Int32 {return GLEW.GL_ARRAY_BUFFER}
@_transparent @usableFromInline internal var GL_ELEMENT_ARRAY_BUFFER: Int32 {return GLEW.GL_ELEMENT_ARRAY_BUFFER}

@_transparent @usableFromInline internal var GL_COMPILE_STATUS: Int32 {return GLEW.GL_COMPILE_STATUS}
@_transparent @usableFromInline internal var GL_INFO_LOG_LENGTH: Int32 {return GLEW.GL_INFO_LOG_LENGTH}
@_transparent @usableFromInline internal var GL_LINK_STATUS: Int32 {return GLEW.GL_LINK_STATUS}

@_transparent @usableFromInline internal var GL_VERTEX_SHADER: Int32 {return GLEW.GL_VERTEX_SHADER}
@_transparent @usableFromInline internal var GL_FRAGMENT_SHADER: Int32 {return GLEW.GL_FRAGMENT_SHADER}
#if os(Linux) || os(Windows)
@_transparent @usableFromInline internal var GL_GEOMETRY_SHADER: Int32 {return GLEW.GL_GEOMETRY_SHADER}
#endif
@_transparent @usableFromInline internal var GL_TEXTURE_COMPARE_FUNC: Int32 {return GLEW.GL_TEXTURE_COMPARE_FUNC}

@_transparent @usableFromInline internal var GL_NEAREST: Int32 {return GLEW.GL_NEAREST}
@_transparent @usableFromInline internal var GL_LINEAR: Int32 {return GLEW.GL_LINEAR}
@_transparent @usableFromInline internal var GL_NEAREST_MIPMAP_NEAREST: Int32 {return GLEW.GL_NEAREST_MIPMAP_NEAREST}
@_transparent @usableFromInline internal var GL_LINEAR_MIPMAP_NEAREST: Int32 {return GLEW.GL_LINEAR_MIPMAP_NEAREST}
@_transparent @usableFromInline internal var GL_NEAREST_MIPMAP_LINEAR: Int32 {return GLEW.GL_NEAREST_MIPMAP_LINEAR}
@_transparent @usableFromInline internal var GL_LINEAR_MIPMAP_LINEAR: Int32 {return GLEW.GL_LINEAR_MIPMAP_LINEAR}
@_transparent @usableFromInline internal var GL_TEXTURE_MAG_FILTER: Int32 {return GLEW.GL_TEXTURE_MAG_FILTER}
@_transparent @usableFromInline internal var GL_TEXTURE_MIN_FILTER: Int32 {return GLEW.GL_TEXTURE_MIN_FILTER}
@_transparent @usableFromInline internal var GL_TEXTURE_WRAP_S: Int32 {return GLEW.GL_TEXTURE_WRAP_S}
@_transparent @usableFromInline internal var GL_TEXTURE_WRAP_T: Int32 {return GLEW.GL_TEXTURE_WRAP_T}
@_transparent @usableFromInline internal var GL_CLAMP_TO_EDGE: Int32 {return GLEW.GL_CLAMP_TO_EDGE}
@_transparent @usableFromInline internal var GL_REPEAT: Int32 {return GLEW.GL_REPEAT}

@_transparent @usableFromInline internal var GL_NEVER: Int32 {return GLEW.GL_NEVER}
@_transparent @usableFromInline internal var GL_LESS: Int32 {return GLEW.GL_LESS}
@_transparent @usableFromInline internal var GL_EQUAL: Int32 {return GLEW.GL_EQUAL}
@_transparent @usableFromInline internal var GL_LEQUAL: Int32 {return GLEW.GL_EQUAL}
@_transparent @usableFromInline internal var GL_GREATER: Int32 {return GLEW.GL_GREATER}
@_transparent @usableFromInline internal var GL_NOTEQUAL: Int32 {return GLEW.GL_NOTEQUAL}
@_transparent @usableFromInline internal var GL_GEQUAL: Int32 {return GLEW.GL_GEQUAL}
@_transparent @usableFromInline internal var GL_ALWAYS: Int32 {return GLEW.GL_ALWAYS}

@_transparent @usableFromInline internal var GL_TEXTURE_2D: Int32 {return GLEW.GL_TEXTURE_2D}
@_transparent @usableFromInline internal var GL_RENDERBUFFER: Int32 {return GLEW.GL_RENDERBUFFER}
@_transparent @usableFromInline internal var GL_DEPTH_COMPONENT: Int32 {return GLEW.GL_DEPTH_COMPONENT}

@_transparent @usableFromInline internal var GL_PACK_ALIGNMENT: Int32 {return GLEW.GL_PACK_ALIGNMENT}
@_transparent @usableFromInline internal var GL_UNPACK_ALIGNMENT: Int32 {return GLEW.GL_UNPACK_ALIGNMENT}

@_transparent @usableFromInline internal var GL_COLOR_BUFFER_BIT: Int32 {return GLEW.GL_COLOR_BUFFER_BIT}
@_transparent @usableFromInline internal var GL_DEPTH_BUFFER_BIT: Int32 {return GLEW.GL_DEPTH_BUFFER_BIT}
@_transparent @usableFromInline internal var GL_STENCIL_BUFFER_BIT: Int32 {return GLEW.GL_STENCIL_BUFFER_BIT}

@_transparent @usableFromInline internal var GL_TEXTURE0: Int32 {return GLEW.GL_TEXTURE0}
@_transparent @usableFromInline internal var GL_TEXTURE1: Int32 {return GLEW.GL_TEXTURE1}
@_transparent @usableFromInline internal var GL_TEXTURE2: Int32 {return GLEW.GL_TEXTURE2}
@_transparent @usableFromInline internal var GL_TEXTURE3: Int32 {return GLEW.GL_TEXTURE3}
@_transparent @usableFromInline internal var GL_TEXTURE4: Int32 {return GLEW.GL_TEXTURE4}
@_transparent @usableFromInline internal var GL_TEXTURE5: Int32 {return GLEW.GL_TEXTURE5}
@_transparent @usableFromInline internal var GL_TEXTURE6: Int32 {return GLEW.GL_TEXTURE6}
@_transparent @usableFromInline internal var GL_TEXTURE7: Int32 {return GLEW.GL_TEXTURE7}
@_transparent @usableFromInline internal var GL_TEXTURE8: Int32 {return GLEW.GL_TEXTURE8}
@_transparent @usableFromInline internal var GL_TEXTURE9: Int32 {return GLEW.GL_TEXTURE9}
@_transparent @usableFromInline internal var GL_TEXTURE10: Int32 {return GLEW.GL_TEXTURE10}
@_transparent @usableFromInline internal var GL_TEXTURE11: Int32 {return GLEW.GL_TEXTURE11}
@_transparent @usableFromInline internal var GL_TEXTURE12: Int32 {return GLEW.GL_TEXTURE12}
@_transparent @usableFromInline internal var GL_TEXTURE13: Int32 {return GLEW.GL_TEXTURE13}
@_transparent @usableFromInline internal var GL_TEXTURE14: Int32 {return GLEW.GL_TEXTURE14}
@_transparent @usableFromInline internal var GL_TEXTURE15: Int32 {return GLEW.GL_TEXTURE15}
@_transparent @usableFromInline internal var GL_TEXTURE16: Int32 {return GLEW.GL_TEXTURE16}
@_transparent @usableFromInline internal var GL_TEXTURE17: Int32 {return GLEW.GL_TEXTURE17}
@_transparent @usableFromInline internal var GL_TEXTURE18: Int32 {return GLEW.GL_TEXTURE18}
@_transparent @usableFromInline internal var GL_TEXTURE19: Int32 {return GLEW.GL_TEXTURE19}
@_transparent @usableFromInline internal var GL_TEXTURE20: Int32 {return GLEW.GL_TEXTURE20}
@_transparent @usableFromInline internal var GL_TEXTURE21: Int32 {return GLEW.GL_TEXTURE21}
@_transparent @usableFromInline internal var GL_TEXTURE22: Int32 {return GLEW.GL_TEXTURE22}
@_transparent @usableFromInline internal var GL_TEXTURE23: Int32 {return GLEW.GL_TEXTURE23}
@_transparent @usableFromInline internal var GL_TEXTURE24: Int32 {return GLEW.GL_TEXTURE24}
@_transparent @usableFromInline internal var GL_TEXTURE25: Int32 {return GLEW.GL_TEXTURE25}
@_transparent @usableFromInline internal var GL_TEXTURE26: Int32 {return GLEW.GL_TEXTURE26}
@_transparent @usableFromInline internal var GL_TEXTURE27: Int32 {return GLEW.GL_TEXTURE27}
@_transparent @usableFromInline internal var GL_TEXTURE28: Int32 {return GLEW.GL_TEXTURE28}
@_transparent @usableFromInline internal var GL_TEXTURE29: Int32 {return GLEW.GL_TEXTURE29}
@_transparent @usableFromInline internal var GL_TEXTURE30: Int32 {return GLEW.GL_TEXTURE30}
@_transparent @usableFromInline internal var GL_TEXTURE31: Int32 {return GLEW.GL_TEXTURE31}

@_transparent @usableFromInline internal var GL_RED: Int32 {return GLEW.GL_RED}
@_transparent @usableFromInline internal var GL_RGB: Int32 {return GLEW.GL_RGB}
@_transparent @usableFromInline internal var GL_RGBA: Int32 {return GLEW.GL_RGBA}
#if os(Linux) || os(Windows)
@_transparent @usableFromInline internal var GL_SRGB_ALPHA: Int32 {return GLEW.GL_SRGB_ALPHA}
#else
@_transparent @usableFromInline internal var GL_SRGB_ALPHA: Int32 {return GLEW.GL_SRGB8_ALPHA8}
#endif
@_transparent @usableFromInline internal var GL_DEPTH_COMPONENT32F: Int32 {return GLEW.GL_DEPTH_COMPONENT32F}

public typealias GLbitfield = GLEW.GLbitfield
public typealias GLenum = GLEW.GLenum
public typealias GLuint = GLEW.GLuint
public typealias GLint = GLEW.GLint
public typealias GLsizei = GLEW.GLsizei
public typealias GLsizeiptr = GLEW.GLsizeiptr
public typealias GLboolean = GLEW.GLboolean
public typealias GLbyte = GLEW.GLbyte
public typealias GLubyte = GLEW.GLubyte
public typealias GLchar = GLEW.GLchar
public typealias GLfloat = GLEW.GLfloat
#if os(Linux) || os(Windows)
public typealias GLdouble = GLEW.GLdouble
#endif

@_transparent @usableFromInline internal var GL_MIN: Int32 {return GLEW.GL_MIN}
@_transparent @usableFromInline internal var GL_MAX: Int32 {return GLEW.GL_MAX}
@_transparent @usableFromInline internal var GL_FUNC_ADD: Int32 {return GLEW.GL_FUNC_ADD}
@_transparent @usableFromInline internal var GL_FUNC_SUBTRACT: Int32 {return GLEW.GL_FUNC_SUBTRACT}
@_transparent @usableFromInline internal var GL_FUNC_REVERSE_SUBTRACT: Int32 {return GLEW.GL_FUNC_REVERSE_SUBTRACT}

@_transparent @usableFromInline internal var GL_ZERO: Int32 {return GLEW.GL_ZERO}
@_transparent @usableFromInline internal var GL_ONE: Int32 {return GLEW.GL_ONE}
@_transparent @usableFromInline internal var GL_SRC_COLOR: Int32 {return GLEW.GL_SRC_COLOR}
@_transparent @usableFromInline internal var GL_ONE_MINUS_SRC_COLOR: Int32 {return GLEW.GL_ONE_MINUS_SRC_COLOR}
@_transparent @usableFromInline internal var GL_DST_COLOR: Int32 {return GLEW.GL_DST_COLOR}
@_transparent @usableFromInline internal var GL_ONE_MINUS_DST_COLOR: Int32 {return GLEW.GL_ONE_MINUS_DST_COLOR}
@_transparent @usableFromInline internal var GL_SRC_ALPHA: Int32 {return GLEW.GL_SRC_ALPHA}
@_transparent @usableFromInline internal var GL_ONE_MINUS_SRC_ALPHA: Int32 {return GLEW.GL_ONE_MINUS_SRC_ALPHA}
@_transparent @usableFromInline internal var GL_DST_ALPHA: Int32 {return GLEW.GL_DST_ALPHA}
@_transparent @usableFromInline internal var GL_ONE_MINUS_DST_ALPHA: Int32 {return GLEW.GL_ONE_MINUS_DST_ALPHA}
@_transparent @usableFromInline internal var GL_CONSTANT_COLOR: Int32 {return GLEW.GL_CONSTANT_COLOR}
@_transparent @usableFromInline internal var GL_ONE_MINUS_CONSTANT_COLOR: Int32 {return GLEW.GL_ONE_MINUS_CONSTANT_COLOR}
@_transparent @usableFromInline internal var GL_CONSTANT_ALPHA: Int32 {return GLEW.GL_CONSTANT_ALPHA}
@_transparent @usableFromInline internal var GL_ONE_MINUS_CONSTANT_ALPHA: Int32 {return GLEW.GL_ONE_MINUS_CONSTANT_ALPHA}
@_transparent @usableFromInline internal var GL_SRC_ALPHA_SATURATE: Int32 {return GLEW.GL_SRC_ALPHA_SATURATE}

@_transparent @usableFromInline internal var GL_FRONT: Int32 {return GLEW.GL_FRONT}
@_transparent @usableFromInline internal var GL_BACK: Int32 {return GLEW.GL_BACK}

@_transparent @usableFromInline internal var GL_CW: Int32 {return GLEW.GL_CW}
@_transparent @usableFromInline internal var GL_CCW: Int32 {return GLEW.GL_CCW}

@_transparent @usableFromInline internal var GL_DEPTH: Int32 {return GLEW.GL_DEPTH}

public func glewInit() {
    if GLEW.glewInit() != GLEW.GLEW_OK {
        fatalError("Failed to initialize glew.")
    }
}

@_transparent @usableFromInline internal func _glFrontFacing(_ mode: GLenum) {
    GLEW.glFrontFace(mode)
}

//framebuffer
@_transparent @usableFromInline internal func _glCheckFramebufferStatus(_ target: GLenum) -> GLenum {
    return GLEW.__glewCheckFramebufferStatus(target)
}

@_transparent @usableFromInline internal func _glGenFramebuffers(_ count: GLsizei, _ framebuffers: UnsafeMutablePointer<GLuint>!) {
    GLEW.__glewGenFramebuffers(count, framebuffers)
}

@_transparent @usableFromInline internal func _glBindFramebuffer(_ target: GLenum, _ framebuffer: GLuint) {
    GLEW.__glewBindFramebuffer(UInt32(target), framebuffer)
}

@_transparent @usableFromInline internal func _glDeleteFramebuffers(_ count: GLint,_ buffers: UnsafePointer<UInt32>?) {
    GLEW.__glewDeleteFramebuffers(count, buffers)
}

@_transparent @usableFromInline internal func _glGetFramebufferAttachmentParameteriv(_ target: GLenum, _ attachment: GLenum, _ pname: GLenum, _ params: UnsafeMutablePointer<GLint>!) {
    GLEW.__glewGetFramebufferAttachmentParameteriv(target, attachment, pname, params)
}

//shader

@_transparent @usableFromInline internal func _glGetShaderInfoLog(_ shader: GLuint, _ maxLength: GLsizei, _ length: UnsafeMutablePointer<GLsizei>?, _ infoLog: UnsafeMutablePointer<GLchar>?) {
    GLEW.__glewGetShaderInfoLog(shader, maxLength, length, infoLog)
}

//glUniform

@_transparent @usableFromInline internal func _glUniform1i(_ location: GLint, _ v1: GLint) {
    GLEW.__glewUniform1i(location, v1)
}

@_transparent @usableFromInline internal func _glUniform2i(_ location: GLint, _ v1: GLint, _ v2: GLint) {
    GLEW.__glewUniform2i(location, v1, v2)
}

@_transparent @usableFromInline internal func _glUniform3i(_ location: GLint, _ v1: GLint, _ v2: GLint, _ v3: GLint) {
    GLEW.__glewUniform3i(location, v1, v2, v3)
}

@_transparent @usableFromInline internal func _glUniform4i(_ location: GLint, _ v1: GLint, _ v2: GLint, _ v3: GLint, _ v4: GLint) {
    GLEW.__glewUniform4i(location, v1, v2, v3, v4)
}

@_transparent @usableFromInline internal func _glUniform1ui(_ location: GLint, _ v1: GLuint) {
    GLEW.__glewUniform1ui(location, v1)
}

@_transparent @usableFromInline internal func _glUniform2ui(_ location: GLint, _ v1: GLuint, _ v2: GLuint) {
    GLEW.__glewUniform2ui(location, v1, v2)
}

@_transparent @usableFromInline internal func _glUniform3ui(_ location: GLint, _ v1: GLuint, _ v2: GLuint, _ v3: GLuint) {
    GLEW.__glewUniform3ui(location, v1, v2, v3)
}

@_transparent @usableFromInline internal func _glUniform4ui(_ location: GLint, _ v1: GLuint, _ v2: GLuint, _ v3: GLuint, _ v4: GLuint) {
    GLEW.__glewUniform4ui(location, v1, v2, v3, v4)
}

@_transparent @usableFromInline internal func _glUniform1f(_ location: GLint, _ v1: GLfloat) {
    GLEW.__glewUniform1f(location, v1)
}

@_transparent @usableFromInline internal func _glUniform2f(_ location: GLint, _ v1: GLfloat, _ v2: GLfloat) {
    GLEW.__glewUniform2f(location, v1, v2)
}

@_transparent @usableFromInline internal func _glUniform3f(_ location: GLint, _ v1: GLfloat, _ v2: GLfloat, _ v3: GLfloat) {
    GLEW.__glewUniform3f(location, v1, v2, v3)
}

@_transparent @usableFromInline internal func _glUniform4f(_ location: GLint, _ v1: GLfloat, _ v2: GLfloat, _ v3: GLfloat, _ v4: GLfloat) {
    GLEW.__glewUniform4f(location, v1, v2, v3, v4)
}

@_transparent @usableFromInline internal func _glGetProgramiv(_ program: GLuint, _ pname: GLenum, _ params:  UnsafeMutablePointer<GLint>?) {
    GLEW.__glewGetProgramiv(program, pname, params)
}

@_transparent @usableFromInline internal func _glGetAttribLocation(_ program: GLuint, _ name: UnsafePointer<GLchar>!) -> GLint {
    return GLEW.__glewGetAttribLocation(program, name)
}

@_transparent @usableFromInline internal func _glAttachShader(_ program: GLuint, _ shader: GLuint) {
    GLEW.__glewAttachShader(program, shader)
}

@_transparent @usableFromInline internal func _glCreateProgram() -> GLuint {
    return GLEW.__glewCreateProgram()
}

@_transparent @usableFromInline internal func _glGenerateMipmap(_ target: GLenum) {
    GLEW.__glewGenerateMipmap(target)
}

@_transparent @usableFromInline internal func _glDeleteProgram(_ program: GLuint) {
    GLEW.__glewDeleteProgram(program)
}

@_transparent @usableFromInline internal func _glUseProgram(_ program: GLuint) {
    GLEW.__glewUseProgram(program)
}

@_transparent @usableFromInline internal func _glGetShaderiv(_ shader: GLuint, _ pname: GLenum, _ params: UnsafeMutablePointer<GLint>!) {
    GLEW.__glewGetShaderiv(shader, pname, params)
}

@_transparent @usableFromInline internal func _glCompileShader(_ shader: GLuint) {
    GLEW.__glewCompileShader(shader)
}

@_transparent @usableFromInline internal func _glShaderSource(_ shader: GLuint, _ count: GLsizei, _ string: UnsafePointer<UnsafePointer<GLchar>?>?, _ length: UnsafeMutablePointer<GLint>!) {
    GLEW.__glewShaderSource(shader, count, string, length)
}

@_transparent @usableFromInline internal func _glUniformMatrix3fv(_ location: GLint, _ count: GLsizei, _ transpose: GLboolean, _ value: UnsafePointer<GLfloat>!) {
    GLEW.__glewUniformMatrix3fv(location, count, transpose, value)
}

@_transparent @usableFromInline internal func _glUniformMatrix4fv(_ location: GLint, _ count: GLsizei, _ transpose: GLboolean, _ value: UnsafePointer<GLfloat>!) {
    GLEW.__glewUniformMatrix4fv(location, count, transpose, value)
}

@_transparent @usableFromInline internal func _glEnableVertexAttribArray(_ name: GLuint) {
    GLEW.__glewEnableVertexAttribArray(name)
}

@_transparent @usableFromInline internal func _glBindBuffer(_ target: GLenum, _ buffer: GLuint) {
    GLEW.__glewBindBuffer(target, buffer)
}

@_transparent @usableFromInline internal func _glBufferData(_ target: GLenum, _ size: GLsizeiptr, _ data: UnsafeRawPointer!, _ usage: GLenum) {
    GLEW.__glewBufferData(target, size, data, usage)
}

@_transparent @usableFromInline internal func _glTexParameteri(_ target: GLenum, _ pname: GLenum, _ param: GLint) {
    GLEW.__glewTexParameteri(target, pname, param)
}

@_transparent @usableFromInline internal func _glGetIntegerv(_ pname: GLenum, _ data: UnsafeMutablePointer<GLint>!) {
    GLEW.__glewGetIntegerv(pname, data)
}

@_transparent @usableFromInline internal func _glBindTexture(_ target: GLenum, _ texture: GLuint) {
    GLEW.__glewBindTexture(target, texture)
}

@_transparent @usableFromInline internal func _glGenTextures(_ count: GLsizei, _ textures: UnsafeMutablePointer<GLuint>!) {
    GLEW.__glewGenTextures(count, textures)
}

@_transparent @usableFromInline internal func _glDeleteTextures(_ count: GLsizei, _ textures: UnsafeMutablePointer<GLuint>!) {
    GLEW.__glewDeleteTextures(count, textures)
}

@_transparent @usableFromInline internal func _glActiveTexture(_ texture: GLenum) {
    GLEW.__glewActiveTexture(texture)
}

@_transparent @usableFromInline internal func _glPixelStorei(_ pname: GLenum, _ param: GLint) {
    GLEW.__glewPixelStorei(pname, param)
}

@_transparent @usableFromInline internal func _glTexImage2D(_ target: GLenum, _ level: GLint, _ internalFormat: GLint, _ width: GLsizei, _ height: GLsizei, _ border: GLint, _ format: GLenum, _ type: GLenum, _ pixels: UnsafeRawPointer!) {
    GLEW.__glewTexImage2D(target, level, internalFormat, width, height, border, format, type, pixels)
}

@_transparent @usableFromInline internal func _glDisableVertexAttribArray(_ index: GLuint) {
    GLEW.__glewDisableVertexAttribArray(index)
}

@_transparent @usableFromInline internal func _glVertexAttribPointer(_ index: GLuint, _ size: GLint, _ type: GLenum, _ normalized: GLboolean, _ stride: GLsizei, _ pointer: UnsafeMutableRawPointer!) {
    GLEW.__glewVertexAttribPointer(index, size, type, normalized, stride, pointer)
}

@_transparent @usableFromInline internal func _glGetError() -> GLenum {
    return GLEW.__glewGetError()
}

@_transparent @usableFromInline internal func _glEnable(_ capability: GLenum) {
    GLEW.__glewEnable(capability)
}

@_transparent @usableFromInline internal func _glDisable(_ capability: GLenum) {
    GLEW.__glewDisable(capability)
}

@_transparent @usableFromInline internal func _glGenBuffers(_ count: GLint, _ buffers: UnsafeMutablePointer<GLuint>!) {
    GLEW.__glewGenBuffers(count, buffers)
}

@_transparent @usableFromInline internal func _glDeleteBuffers(_ count: GLint, _ buffers: UnsafePointer<GLuint>!) {
    GLEW.__glewDeleteBuffers(count, buffers)
}

@_transparent @usableFromInline internal func _glClearColor(_ red: GLfloat, _ green: GLfloat, _ blue: GLfloat, _ alpha: GLfloat) {
    GLEW.__glewClearColor(red, green, blue, alpha)
}

@_transparent @usableFromInline internal func _glClear(_ mask: GLbitfield) {
    GLEW.__glewClear(mask)
}

@_transparent @usableFromInline internal func _glGenVertexArrays(_ count: GLint, _ arrays: UnsafeMutablePointer<GLuint>!) {
    GLEW.__glewGenVertexArrays(count, arrays)
}

@_transparent @usableFromInline internal func _glBindVertexArray(_ array: GLuint) {
    GLEW.__glewBindVertexArray(array)
}

@_transparent @usableFromInline internal func _glDeleteVertexArrays(_ count: GLint, _ arrays: UnsafePointer<GLuint>!) {
    GLEW.__glewDeleteVertexArrays(count, arrays)
}

@_transparent @usableFromInline internal func _glViewport(_ x: GLint, _ y: GLint, _ width: GLsizei, _ height: GLsizei) {
    GLEW.__glewViewport(x, y, width, height)
}

@_transparent @usableFromInline internal func _glGetString(_ name: GLenum) -> UnsafePointer<GLubyte>? {
    return GLEW.__glewGetString(name)
}

@_transparent @usableFromInline internal func _glDrawElements(_ mode: GLenum, _ count: GLsizei, _ type: GLenum, _ indices: UnsafeRawPointer!) {
    GLEW.__glewDrawElements(mode, count, type, indices)
}

@_transparent @usableFromInline internal func _glGetUniformBlockIndex(_ program: GLuint, _ uniformBlockName: UnsafePointer<GLchar>!) -> GLuint {
    return GLEW.__glewGetUniformBlockIndex(program, uniformBlockName)
}

@_transparent @usableFromInline internal func _glGetUniformLocation(_ program: GLuint, _ name: UnsafePointer<GLchar>!) -> GLint {
    return GLEW.__glewGetUniformLocation(program, name)
}

@_transparent @usableFromInline internal func _glCreateShader(_ type: GLenum) -> GLuint {
    return GLEW.__glewCreateShader(type)
}

@_transparent @usableFromInline internal func _glGetProgramInfoLog(_ program: GLuint, _ maxLength: GLsizei, _ length: UnsafeMutablePointer<GLsizei>!, _ infoLog: UnsafeMutablePointer<GLchar>!) {
    GLEW.__glewGetProgramInfoLog(program, maxLength, length, infoLog)
}

@_transparent @usableFromInline internal func _glLinkProgram(_ program: GLuint) {
    GLEW.__glewLinkProgram(program)
}

@_transparent @usableFromInline internal func _glDeleteShader(_ shader: GLuint) {
    GLEW.__glewDeleteShader(shader)
}

@_transparent @usableFromInline internal func _glDepthFunc(_ function: GLenum) {
    GLEW.__glewDepthFunc(function)
}

@_transparent @usableFromInline internal func _glDepthMask(_ enabled: GLboolean) {
    GLEW.glDepthMask(enabled)
}

@_transparent @usableFromInline internal func _glFramebufferTexture2D(_ target: GLenum, _ attachment: GLenum, _ textarget: GLenum, _ texture: GLuint, _ level: GLint) {
    GLEW.__glewFramebufferTexture2D(target, attachment, textarget, texture, level)
}

@_transparent @usableFromInline internal func _glDrawBuffers(_ count: GLsizei, _ buffers: UnsafePointer<GLenum>!) {
    GLEW.__glewDrawBuffers(count, buffers)
}

@_transparent @usableFromInline internal func _glDrawArrays(_ mode: GLenum, _ first: GLint, _ count: GLsizei) {
    GLEW.__glewDrawArrays(mode, first, count)
}

@_transparent @usableFromInline internal func _glBlendEquationSeparate(_ modeRGB: GLenum, _ modeAlpha: GLenum) {
    GLEW.__glewBlendEquationSeparate(modeRGB, modeAlpha)
}

@_transparent @usableFromInline internal func _glBlendEquation(_ mode: GLenum) {
    GLEW.__glewBlendEquation(mode)
}

@_transparent @usableFromInline internal func _glBlendFunc(_ sfactor: GLenum, _ dfactor: GLenum) {
    GLEW.__glewBlendFunc(sfactor, dfactor)
}

@_transparent @usableFromInline internal func _glReadBuffer(_ mode: GLenum) {
    GLEW.__glewReadBuffer(mode)
}

@_transparent @usableFromInline internal func _glReadPixels(_ x: GLint, _ y: GLint, _ width: GLsizei, _ height: GLsizei, _ format: GLenum, _ type: GLenum, _ pixels: UnsafeMutableRawPointer!) {
    GLEW.__glewReadPixels(x, y, width, height, format, type, pixels)
}

@_transparent @usableFromInline internal func _glFlush() {
    GLEW.__glewFlush()
}

#endif
