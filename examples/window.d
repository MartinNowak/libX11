import std.exception, std.stdio;
import deimos.X11.Xlib;

import std.string;

enum SIZEX = 400;
enum SIZEY = 300;

void main()
{
    Display* dpy = enforce(XOpenDisplay(null), "ERROR: Could not open display");
    scope (exit) XCloseDisplay(dpy);

    auto scr = XDefaultScreen(dpy);
    auto rootwin = XRootWindow(dpy, scr);
    auto win = XCreateSimpleWindow(dpy, rootwin, 1, 1, SIZEX, SIZEY, 0,
                                   XBlackPixel(dpy, scr), XWhitePixel(dpy, scr));

    XStoreName(dpy, win, toStringz("hello"));
    XSelectInput(dpy, win, EventMask.ButtonPressMask | EventMask.StructureNotifyMask);
    XMapWindow(dpy, win);

    Atom[AtomT.max + 1] atoms;
    foreach(i, name; __traits(allMembers, AtomT))
        atoms[i] = XInternAtom(dpy, toStringz(name), Bool.False);
    enforce(XSetWMProtocols(dpy, win, atoms.ptr, cast(int)atoms.length) == 1);

    XEvent e;
    for (bool cont = true; cont; )
    {
        XNextEvent(dpy, &e);
        switch (e.type)
        {
        case EventType.ButtonPress:
            cont = false;
            break;

        case EventType.ClientMessage:
            if (e.xclient.message_type == atoms[AtomT.WM_PROTOCOLS] &&
                e.xclient.data.l[0] == atoms[AtomT.WM_DELETE_WINDOW])
                cont = false;
            break;

        default:
        }
    }
}

enum AtomT
{
    WM_PROTOCOLS,
    WM_DELETE_WINDOW,
    //WM_TAKE_FOCUS,
    _NET_WM_PING,
}
