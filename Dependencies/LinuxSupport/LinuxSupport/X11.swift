import LinuxExtensions

@inlinable
public func XCreateIC(_ im: XIM, _ window: Window) -> XIC {
    return XCreateIC_Ext(im, window)
}
