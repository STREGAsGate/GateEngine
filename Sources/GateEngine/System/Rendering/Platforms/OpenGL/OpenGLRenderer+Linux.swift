/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(Linux)
import LinuxSupport

internal extension OpenGLRenderer {
    func setup() {
        let glxContext = X11Window.sharedContext
        glXMakeCurrent(X11Window.xDisplay, 0, glxContext)
        glFlush()
    }
}
#endif
