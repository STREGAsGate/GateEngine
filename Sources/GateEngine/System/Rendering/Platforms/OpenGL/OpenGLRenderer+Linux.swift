/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(Linux)
import LinuxSupport

extension OpenGLRenderer {
    func setup() {
        let glxContext = X11Window.sharedContext
        glXMakeCurrent(X11Window.xDisplay, 0, glxContext)
        glFlush()
    }
}
#endif
