// Window & Rendering
#include <GL/glx.h>
#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <X11/Xresource.h>

// Keyboard
#include <X11/XKBlib.h>

// Audio
#include <AL/al.h>
#include <AL/alc.h>

// Game Controllers
#include <sys/ioctl.h>
#include <linux/joystick.h>

/* This isn't defined in older Linux kernel headers */
#ifndef SYN_DROPPED
#define SYN_DROPPED 3
#endif
#ifndef BTN_DPAD_UP
#define BTN_DPAD_UP     0x220
#endif
#ifndef BTN_DPAD_DOWN
#define BTN_DPAD_DOWN   0x221
#endif
#ifndef BTN_DPAD_LEFT
#define BTN_DPAD_LEFT   0x222
#endif
#ifndef BTN_DPAD_RIGHT
#define BTN_DPAD_RIGHT  0x223
#endif
