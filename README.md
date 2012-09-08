SDL - Simple DirectMedia Layer
Copyright (C) 1997-2009 Sam Lantinga
 
SDL - D Bindings
Copyright (C) 2011-2012 www.ddili.org
 
This library is free software; you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2.1 of the License, or (at
your option) any later version.

This library is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
details.

You should have received copy of the GNU Lesser General Public License along
with this library; if not, write to the Free Software Foundation, Inc.:
51 Franklin St, Fifth Floor,
Boston, MA  02110-1301  USA

Sam Lantinga
slouken@libsdl.org

Date of Test : 7 September 2012
DMD Versions : 2.0.59 and 2.0.60
Compile Arg. : dmd sdlmini -L-lSDL -debug
Lib. version : v1.1

* extern(C)
int SDL_UpperBlit (SDL_Surface *src, SDL_Rect *srcrect,
                   SDL_Surface *dst, SDL_Rect *dstrect);
int SDL_SetColorKey (SDL_Surface *surface, uint flag, uint key);
int SDL_SetAlpha (SDL_Surface* surface, uint flags, ubyte alpha);
int SDL_FillRect (SDL_Surface *dst, SDL_Rect *dstrect, uint color);
int SDL_Flip (SDL_Surface *screen);
int SDL_Init (uint flags);
int SDL_PollEvent (SDL_Event *event);

SDL_Surface *SDL_SetVideoMode (int width, int height, int bpp, uint flags);
SDL_Surface *SDL_DisplayFormat (SDL_Surface *surface);
SDL_Surface *SDL_DisplayFormatAlpha (SDL_Surface *surface);
SDL_Surface *SDL_CreateRGBSurface (uint flags, int width, int height, int depth,
                                   uint Rmask, uint Gmask, uint Bmask, uint Amask);
void SDL_Quit ();
void SDL_Delay (uint ms);
void SDL_FreeSurface (SDL_Surface *surface);
void SDL_UpdateRect (SDL_Surface *screen, int x, int y, uint w, uint h);
void SDL_WM_SetCaption (const char *title, const char *icon);

* class draw (int width, int height, string name, clr color=clr.white):
  void setBackground (clr color);
  void setPixel (int x, int y, int c=clr.white);
  void line (int x0, int y0, int x1, int y1, int c=clr.white);
  void polygon (double x, double y, double r, int sides, int c=clr.white, int a=0);
  void curve (int x0, int y0, int x1, int y1, int x2, int y2, int c=clr.white);
  void yuvarlak (int x, int y, int r, int c=clr.white);
  bool keyEvent (int type);

* union SDL_Event:
  struct SDL_KeyboardEvent;
  struct SDL_keysym;
  struct SDL_SysWMEvent
