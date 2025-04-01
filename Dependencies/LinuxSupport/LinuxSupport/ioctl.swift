import LinuxExtensions

@inlinable
public func ioctl(_ fd: Int32, _ request: Int32, _ ptr: UnsafeMutableRawPointer) -> Int32 {
    return ioctl_ptr(fd, request, ptr)
}

@inlinable
public func ioctl(_ fd: Int32, _ request: Int32, _ value: Int32) -> Int32 {
    return ioctl_value(fd, request, value)
}

@inlinable
public func EVIOCGBIT(_ ev: Int32, _ len: Int32) -> Int32 {
    return LinuxExtensions.EVIOCGBIT(ev, len)
}

@inlinable
public func EVIOCGABS(_ abs: Int32) -> Int32 {
    return LinuxExtensions.EVIOCGABS(abs)
}

@inlinable
public func EVIOCGKEY(_ len: Int32) -> Int32 {
    return LinuxExtensions.EVIOCGKEY(len)
}

@inlinable
public var EVIOCGID: Int32 {return LinuxExtensions.EVIOCGID()}
