#include "X11/Xlib.h"

// Non-variadic wrappers
XIC XCreateIC_Ext(XIM im, Window window);

// Macros
int DisplayWidth_Ext(Display *dpy, int scr);
int DisplayWidthMM_Ext(Display *dpy, int scr);