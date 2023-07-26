import LinuxExtensions

@_transparent
public func ioctl(_ fd: Int32, _ request: Int32, _ ptr: UnsafeMutableRawPointer) -> Int32 {
    return ioctl_ptr(fd, request, ptr)
}

@_transparent
public func ioctl(_ fd: Int32, _ request: Int32, _ value: Int32) -> Int32 {
    return ioctl_value(fd, request, value)
}

@_transparent
public func EVIOCGBIT(_ ev: Int32, _ len: Int32) -> Int32 {
    return LinuxExtensions.EVIOCGBIT(ev, len)
}

@_transparent
public func EVIOCGABS(_ abs: Int32) -> Int32 {
    return LinuxExtensions.EVIOCGABS(abs)
}

@_transparent
public func EVIOCGKEY(_ len: Int32) -> Int32 {
    return LinuxExtensions.EVIOCGKEY(len)
}

@_transparent
public var EVIOCGID: Int32 {return LinuxExtensions.EVIOCGID()}
