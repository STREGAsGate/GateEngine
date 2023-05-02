
// Window & Rendering
#include "Include/X11.h"

// X11 Non-variadic wrapper
XIC XCreateIC_Ext(XIM im, Window window) {
    return XCreateIC(im, 
                     XNInputStyle, XIMPreeditNothing | XIMStatusNothing,
                     XNClientWindow, window,
                     XNFocusWindow,  window,
                     NULL);
}
