/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if targetEnvironment(macCatalyst) || os(Windows)

import Foundation

@_transparent @usableFromInline internal var GL_VENDOR: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_RENDERER: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_VERSION: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_SHADING_LANGUAGE_VERSION: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_MAX_TEXTURE_SIZE: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_MAX_TEXTURE_IMAGE_UNITS: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_DRAW_FRAMEBUFFER_BINDING: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_TRUE: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_FALSE: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_INT: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_UNSIGNED_INT: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_UNSIGNED_BYTE: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_UNSIGNED_SHORT: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_FLOAT: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_TRIANGLES: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TRIANGLE_STRIP: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_POINTS: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_LINES: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_LINES_ADJACENCY: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_NO_ERROR: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_INVALID_ENUM: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_INVALID_VALUE: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_INVALID_OPERATION: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_OUT_OF_MEMORY: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_INVALID_FRAMEBUFFER_OPERATION: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_INVALID_INDEX: UInt32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_FRAMEBUFFER_COMPLETE: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT: Int32 {fatalError("OpenGL Not Supported")}
#if os(macOS)
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS: Int32 {fatalError("OpenGL Not Supported")}
#endif
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_UNSUPPORTED: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_UNDEFINED: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_FRAMEBUFFER: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_DRAW_FRAMEBUFFER: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_READ_FRAMEBUFFER: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT0: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT1: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT2: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT3: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT4: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT5: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT6: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT7: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT8: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT9: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT10: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT11: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT12: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT13: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT14: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_COLOR_ATTACHMENT15: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_DEPTH_ATTACHMENT: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_STENCIL_ATTACHMENT: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_DEPTH_TEST: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_CULL_FACE: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_BLEND: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_STATIC_DRAW: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_DYNAMIC_DRAW: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_ARRAY_BUFFER: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_ELEMENT_ARRAY_BUFFER: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_COMPILE_STATUS: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_INFO_LOG_LENGTH: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_LINK_STATUS: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_VALIDATE_STATUS: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_VERTEX_SHADER: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_FRAGMENT_SHADER: Int32 {fatalError("OpenGL Not Supported")}
#if os(macOS)
@_transparent @usableFromInline internal var GL_GEOMETRY_SHADER: Int32 {fatalError("OpenGL Not Supported")}
#endif
@_transparent @usableFromInline internal var GL_TEXTURE_COMPARE_FUNC: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_NEAREST: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_LINEAR: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_NEAREST_MIPMAP_NEAREST: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_LINEAR_MIPMAP_NEAREST: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_NEAREST_MIPMAP_LINEAR: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_LINEAR_MIPMAP_LINEAR: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE_MAG_FILTER: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE_MIN_FILTER: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE_WRAP_S: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE_WRAP_T: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_CLAMP_TO_EDGE: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_REPEAT: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_NEVER: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_LESS: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_EQUAL: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_LEQUAL: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_GREATER: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_NOTEQUAL: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_GEQUAL: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_ALWAYS: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_TEXTURE_2D: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_RENDERBUFFER: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_DEPTH_COMPONENT: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_PACK_ALIGNMENT: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_UNPACK_ALIGNMENT: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_COLOR_BUFFER_BIT: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_DEPTH_BUFFER_BIT: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_STENCIL_BUFFER_BIT: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_TEXTURE0: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE1: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE2: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE3: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE4: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE5: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE6: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE7: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE8: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE9: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE10: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE11: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE12: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE13: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE14: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE15: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE16: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE17: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE18: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE19: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE20: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE21: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE22: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE23: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE24: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE25: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE26: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE27: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE28: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE29: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE30: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_TEXTURE31: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_RED: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_RGB: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_RGBA: Int32 {fatalError("OpenGL Not Supported")}
#if os(macOS)
@_transparent @usableFromInline internal var GL_SRGB_ALPHA: Int32 {fatalError("OpenGL Not Supported")}
#else
@_transparent @usableFromInline internal var GL_SRGB_ALPHA: Int32 {fatalError("OpenGL Not Supported")}
#endif
@_transparent @usableFromInline internal var GL_DEPTH_COMPONENT32F: Int32 {fatalError("OpenGL Not Supported")}

public typealias GLbitfield = UInt32
public typealias GLenum = UInt32
public typealias GLuint = UInt32
public typealias GLint = Int32
public typealias GLsizei = Int32
public typealias GLsizeiptr = Int
public typealias GLboolean = UInt8
public typealias GLbyte = Int8
public typealias GLubyte = UInt8
public typealias GLchar = Int8
public typealias GLfloat = Float
#if os(macOS)
public typealias GLdouble = Double
#endif

@_transparent @usableFromInline internal var GL_MIN: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_MAX: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_FUNC_ADD: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_FUNC_SUBTRACT: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_FUNC_REVERSE_SUBTRACT: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_ZERO: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_ONE: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_SRC_COLOR: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_ONE_MINUS_SRC_COLOR: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_DST_COLOR: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_ONE_MINUS_DST_COLOR: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_SRC_ALPHA: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_ONE_MINUS_SRC_ALPHA: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_DST_ALPHA: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_ONE_MINUS_DST_ALPHA: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_CONSTANT_COLOR: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_ONE_MINUS_CONSTANT_COLOR: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_CONSTANT_ALPHA: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_ONE_MINUS_CONSTANT_ALPHA: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_SRC_ALPHA_SATURATE: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_FRONT: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_BACK: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_CW: Int32 {fatalError("OpenGL Not Supported")}
@_transparent @usableFromInline internal var GL_CCW: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal var GL_DEPTH: Int32 {fatalError("OpenGL Not Supported")}

@_transparent @usableFromInline internal func _glFrontFacing(_ mode: GLenum) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glCullFace(_ mode: GLenum) {
    fatalError("OpenGL Not Supported")
}

//framebuffer
@_transparent @usableFromInline internal func _glCheckFramebufferStatus(_ target: GLenum) -> GLenum {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glGenFramebuffers(_ count: GLsizei, _ framebuffers: UnsafeMutablePointer<GLuint>!) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glBindFramebuffer(_ target: GLenum, _ framebuffer: GLuint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glDeleteFramebuffers(_ count: GLint,_ buffers: UnsafePointer<UInt32>?) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glGetFramebufferAttachmentParameteriv(_ target: GLenum, _ attachment: GLenum, _ pname: GLenum, _ params: UnsafeMutablePointer<GLint>!) {
    fatalError("OpenGL Not Supported")
}

//shader

@_transparent @usableFromInline internal func _glGetShaderInfoLog(_ shader: GLuint, _ maxLength: GLsizei, _ length: UnsafeMutablePointer<GLsizei>?, _ infoLog: UnsafeMutablePointer<GLchar>?) {
    fatalError("OpenGL Not Supported")
}

//glUniform

@_transparent @usableFromInline internal func _glUniform1i(_ location: GLint, _ v1: GLint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glUniform2i(_ location: GLint, _ v1: GLint, _ v2: GLint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glUniform3i(_ location: GLint, _ v1: GLint, _ v2: GLint, _ v3: GLint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glUniform4i(_ location: GLint, _ v1: GLint, _ v2: GLint, _ v3: GLint, _ v4: GLint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glUniform1ui(_ location: GLint, _ v1: GLuint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glUniform2ui(_ location: GLint, _ v1: GLuint, _ v2: GLuint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glUniform3ui(_ location: GLint, _ v1: GLuint, _ v2: GLuint, _ v3: GLuint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glUniform4ui(_ location: GLint, _ v1: GLuint, _ v2: GLuint, _ v3: GLuint, _ v4: GLuint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glUniform1f(_ location: GLint, _ v1: GLfloat) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glUniform2f(_ location: GLint, _ v1: GLfloat, _ v2: GLfloat) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glUniform3f(_ location: GLint, _ v1: GLfloat, _ v2: GLfloat, _ v3: GLfloat) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glUniform4f(_ location: GLint, _ v1: GLfloat, _ v2: GLfloat, _ v3: GLfloat, _ v4: GLfloat) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glGetProgramiv(_ program: GLuint, _ pname: GLenum, _ params:  UnsafeMutablePointer<GLint>?) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glGetAttribLocation(_ program: GLuint, _ name: UnsafePointer<GLchar>!) -> GLint {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glAttachShader(_ program: GLuint, _ shader: GLuint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glCreateProgram() -> GLuint {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glGenerateMipmap(_ target: GLenum) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glDeleteProgram(_ program: GLuint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glUseProgram(_ program: GLuint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glGetShaderiv(_ shader: GLuint, _ pname: GLenum, _ params: UnsafeMutablePointer<GLint>!) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glCompileShader(_ shader: GLuint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glShaderSource(_ shader: GLuint, _ count: GLsizei, _ string: UnsafePointer<UnsafePointer<GLchar>?>?, _ length: UnsafeMutablePointer<GLint>!) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glUniformMatrix3fv(_ location: GLint, _ count: GLsizei, _ transpose: GLboolean, _ value: UnsafePointer<GLfloat>!) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glUniformMatrix4fv(_ location: GLint, _ count: GLsizei, _ transpose: GLboolean, _ value: UnsafePointer<GLfloat>!) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glEnableVertexAttribArray(_ name: GLuint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glVertexAttribDivisor(_ index: GLuint, divisor: GLuint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glBindBuffer(_ target: GLenum, _ buffer: GLuint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glBufferData(_ target: GLenum, _ size: GLsizeiptr, _ data: UnsafeRawPointer!, _ usage: GLenum) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glTexParameteri(_ target: GLenum, _ pname: GLenum, _ param: GLint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glGetIntegerv(_ pname: GLenum, _ data: UnsafeMutablePointer<GLint>!) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glBindTexture(_ target: GLenum, _ texture: GLuint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glGenTextures(_ count: GLsizei, _ textures: UnsafeMutablePointer<GLuint>!) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glDeleteTextures(_ count: GLsizei, _ textures: UnsafeMutablePointer<GLuint>!) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glActiveTexture(_ texture: GLenum) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glPixelStorei(_ pname: GLenum, _ param: GLint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glTexImage2D(_ target: GLenum, _ level: GLint, _ internalFormat: GLint, _ width: GLsizei, _ height: GLsizei, _ border: GLint, _ format: GLenum, _ type: GLenum, _ pixels: UnsafeRawPointer!) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glDisableVertexAttribArray(_ index: GLuint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glVertexAttribPointer(_ index: GLuint, _ size: GLint, _ type: GLenum, _ normalized: GLboolean, _ stride: GLsizei, _ pointer: UnsafeMutableRawPointer!) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glGetError() -> GLenum {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glEnable(_ capability: GLenum) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glDisable(_ capability: GLenum) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glGenBuffers(_ count: GLint, _ buffers: UnsafeMutablePointer<GLuint>!) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glDeleteBuffers(_ count: GLint, _ buffers: UnsafePointer<GLuint>!) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glClearColor(_ red: GLfloat, _ green: GLfloat, _ blue: GLfloat, _ alpha: GLfloat) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glClear(_ mask: GLbitfield) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glGenVertexArrays(_ count: GLint, _ arrays: UnsafeMutablePointer<GLuint>!) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glBindVertexArray(_ array: GLuint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glDeleteVertexArrays(_ count: GLint, _ arrays: UnsafePointer<GLuint>!) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glViewport(_ x: GLint, _ y: GLint, _ width: GLsizei, _ height: GLsizei) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glGetString(_ name: GLenum) -> UnsafePointer<GLubyte>? {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glDrawElements(_ mode: GLenum, _ count: GLsizei, _ type: GLenum, _ indices: UnsafeRawPointer!) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glDrawElementsInstanced(_ mode: GLenum, _ count: GLsizei, _ type: GLenum, _ indices: UnsafeRawPointer!, _ instanceCount: GLsizei) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glGetUniformBlockIndex(_ program: GLuint, _ uniformBlockName: UnsafePointer<GLchar>!) -> GLuint {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glGetUniformLocation(_ program: GLuint, _ name: UnsafePointer<GLchar>!) -> GLint {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glCreateShader(_ type: GLenum) -> GLuint {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glGetProgramInfoLog(_ program: GLuint, _ maxLength: GLsizei, _ length: UnsafeMutablePointer<GLsizei>!, _ infoLog: UnsafeMutablePointer<GLchar>!) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glLinkProgram(_ program: GLuint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glValidateProgram(_ program: GLuint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glDeleteShader(_ shader: GLuint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glDepthFunc(_ function: GLenum) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glDepthMask(_ enabled: GLboolean) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glFramebufferTexture2D(_ target: GLenum, _ attachment: GLenum, _ textarget: GLenum, _ texture: GLuint, _ level: GLint) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glDrawBuffers(_ count: GLsizei, _ buffers: UnsafePointer<GLenum>!) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glDrawArrays(_ mode: GLenum, _ first: GLint, _ count: GLsizei) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glBlendEquationSeparate(_ modeRGB: GLenum, _ modeAlpha: GLenum) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glBlendEquation(_ mode: GLenum) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glBlendFunc(_ sfactor: GLenum, _ dfactor: GLenum) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glBlendFuncSeparate(_ sfactorRGB: GLenum, _ dfactorRGB: GLenum, sfactorAlpha: GLenum, dfactorAlpha: GLenum) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glReadBuffer(_ mode: GLenum) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glReadPixels(_ x: GLint, _ y: GLint, _ width: GLsizei, _ height: GLsizei, _ format: GLenum, _ type: GLenum, _ pixels: UnsafeMutableRawPointer!) {
    fatalError("OpenGL Not Supported")
}

@_transparent @usableFromInline internal func _glFlush() {
    fatalError("OpenGL Not Supported")
}

#endif
