
// Window & Rendering
#include "X11.h"

// X11 Non-variadic wrapper
XIC XCreateIC_Ext(XIM im, Window window) {
    return XCreateIC(im, 
                     XNInputStyle, XIMPreeditNothing | XIMStatusNothing,
                     XNClientWindow, window,
                     XNFocusWindow,  window,
                     NULL);
}

// Macros
int DisplayWidth_Ext(Display *dpy, int scr) {
    return ScreenOfDisplay(dpy,scr)->width;
}
int DisplayWidthMM_Ext(Display *dpy, int scr) {
    return ScreenOfDisplay(dpy,scr)->mwidth;
}