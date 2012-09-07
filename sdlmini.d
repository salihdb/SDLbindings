/*
 * SDL - Simple DirectMedia Layer
 * Copyright (C) 1997-2009 Sam Lantinga
 * 
 * SDL - D Bindings
 * Copyright (C) 2011-2012 www.ddili.org
 * 
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or (at
 * your option) any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received copy of the GNU Lesser General Public License along
 * with this library; if not, write to the Free Software Foundation, Inc.:
 * 51 Franklin St, Fifth Floor,
 * Boston, MA  02110-1301  USA
 *
 * Sam Lantinga
 * slouken@libsdl.org
 */
module sdlmini;

public import std.math, std.random;

alias SDL_UpperBlit SDL_BlitSurface;

/********************************************************* Some SDL Functions */
extern(C) { 
  int SDL_UpperBlit(SDL_Surface *src, SDL_Rect *srcrect,
                    SDL_Surface *dst, SDL_Rect *dstrect);
  int SDL_SetColorKey(SDL_Surface *surface, uint flag, uint key);
  int SDL_SetAlpha(SDL_Surface* surface, uint flags, ubyte alpha);
  int SDL_FillRect (SDL_Surface *dst, SDL_Rect *dstrect, uint color);
  int SDL_Flip(SDL_Surface *screen);
  int SDL_Init(uint flags);
  int SDL_PollEvent(SDL_Event *event);

  SDL_Surface *SDL_SetVideoMode(int width, int height, int bpp, uint flags);
  SDL_Surface *SDL_DisplayFormat(SDL_Surface *surface);
  SDL_Surface *SDL_DisplayFormatAlpha(SDL_Surface *surface);
  SDL_Surface *SDL_CreateRGBSurface(uint flags, int width, int height, int depth,
                                    uint Rmask, uint Gmask, uint Bmask, uint Amask);
  void SDL_Quit();
  void SDL_Delay(uint ms);
  void SDL_FreeSurface(SDL_Surface *surface);
  void SDL_UpdateRect(SDL_Surface *screen, int x, int y, uint w, uint h);
  void SDL_WM_SetCaption(const char *title, const char *icon);
}
  enum uint SDL_INIT_EVERYTHING  = 0x0000FFFF;
  enum uint SDL_SWSURFACE  = 0x00000000;  /* Surface is in system memory */
  enum uint SDL_HWSURFACE  = 0x00000001;  /* Surface is in video memory */
  enum uint SDL_DOUBLEBUF  = 0x40000000;  /* Set up double-buffered video mode */
  enum uint SDL_FULLSCREEN = 0x80000000;  /* Surface is a full screen display */
  enum uint SDLK_ESCAPE    = 27; 
  enum : ubyte {
    SDL_KEYDOWN = 2,            /* Keys pressed */
    SDL_KEYUP                   /* Keys released */
  }
/*************************************************** Keyboard event structure */

  union SDL_Event {
    ubyte type;
    SDL_KeyboardEvent key;
    SDL_SysWMEvent syswm;
  }
  struct SDL_KeyboardEvent {
    ubyte type;                /* SDL_KEYDOWN or SDL_KEYUP */
    ubyte which;               /* The keyboard device index */
    ubyte state;               /* SDL_PRESSED or SDL_RELEASED */
    SDL_keysym keysym;
  }

  struct SDL_keysym {
    ubyte scancode;         /* hardware specific scancode */
    uint sym;               /* SDL virtual keysym */
    uint mod;               /* current key modifiers */
    ushort unicode;         /* translated character */
  }

  struct SDL_SysWMEvent {
    ubyte type;
    SDL_SysWMmsg *msg;
  }

extern(C) struct SDL_SysWMmsg;  // İlginçtir, yine de extern(C) şart değil!

/********************************************************** Surface structure */

  struct SDL_Rect {
    short x, y;
    ushort w, h;
  } 

  struct SDL_Color {
    ubyte r, g, b, unused;
  }

  struct SDL_Palette {
    int       ncolors;
    SDL_Color *colors;
  } 

  struct SDL_PixelFormat {
    SDL_Palette *palette;
    ubyte  BitsPerPixel, BytesPerPixel;
    ubyte  Rloss,  Gloss,  Bloss, Aloss;
    ubyte  Rshift, Gshift, Bshift, Ashift;
    uint   Rmask, Gmask, Bmask, Amask;
    uint   colorkey;
    ubyte  alpha;
  } 

  struct SDL_Surface {
    uint flags;                /* Read-only */
    SDL_PixelFormat *format;   /* Read-only */
    int w, h;                  /* Read-only */
    ushort pitch;              /* Read-only */
    void *pixels;              /* Read-write */
    int offset;                /* Private */
    void *hwdata;              /* Private */
    SDL_Rect clip_rect;        /* Read-only */
    uint unused1;              /* for binary compatibility */
    uint locked;               /* Private */
    void *map;                 /* Private */
    uint format_version;       /* Private */
    int refcount;              /* Read-mostly */
  }
/******************************************************************************\
/************************* HAYATI KOLAYLAŞTIRAN SINIF *************************\
/******************************************************************************\
*/
class draw {
  int w, h;
  SDL_Surface* scr;

  this (int width, int height, string name, clr color=clr.white) {
    w = width;
    h = height;
    scr = SDL_SetVideoMode(w, h, 0, SDL_HWSURFACE);
    SDL_WM_SetCaption(cast(char*)name, cast(const char*)name);
    if(color != clr.black) setBackground(color);
    //SDL_Flip(scr); // iyi olmuyor, sanki! **** GEREKİRSE AÇ ****
  }

/******************** Zemin Boyar ********************/
  
  void setBackground(clr color) {
    SDL_FillRect(scr, &scr.clip_rect, color);
  }

/******************** Benek Boyar ********************/  

  void setPixel(int x, int y, int c = int.max) {
    uint *pixel = cast(uint*)scr.pixels + y * scr.pitch/4 + x;
         *pixel = c; /* pixel demek
                      * benek demektir,
                      * benek demek
                      * renkli görmektir...:)*/
  }

/******************** Çizgi Çizer ********************/

  void line(int x0, int y0, int x1, int y1, int c = int.max) {
    int dx =  abs(x1 - x0), sx = x0 < x1 ? 1 : -1;
    int dy = -abs(y1 - y0), sy = y0 < y1 ? 1 : -1;
    int err = dx + dy, e2;
  
    while(1) {
      setPixel(x0, y0, c);
      if(x0 == x1 && y0 == y1) break;
      e2 = 2 * err;
      if (e2 >= dy) { err += dy; x0 += sx; }
      if (e2 <= dx) { err += dx; y0 += sy; }
    }
  }

/******************* Çokgen Çizer *******************/

  void polygon(double x, double y, double r, int sides, int c=int.max, int a=0) {
    double edge = PI*2 / sides; 
    int x0, y0;
    for(int i = 0; i <= sides; i++) {
      double a1 = cos(edge*i) * r;
      double a2 = sin(edge*i) * r;
      int x1 = cast(int)(a == 270 ? x + a2 : a == 180 ? x + a1 : a == 90 ? x - a2 : x - a1);
      int y1 = cast(int)(a == 270 ? y + a1 : a == 180 ? y + a2 : a == 90 ? y - a1 : y - a2);
      if(i) line(x0, y0, x1, y1, c);
      x0 = x1; y0 = y1;
    }
  }

/******************** Yay Çizer ********************/

  void curve(int x0, int y0, int x1, int y1, int x2, int y2, int c = int.max) {                            
    int sx = x2-x1, sy = y2-y1;
    long xx = x0-x1, yy = y0-y1, xy;            /* relative values for checks */
    double dx, dy, err, cur = xx*sy-yy*sx;                       /* curvature */
    // assert(xx*sx <= 0 && yy*sy <= 0);  /* sign of gradient must not change */
    if (sx*cast(long)sx+sy*cast(long)sy > xx*xx+yy*yy)
    {                                               /* begin with longer part */ 
      x2 = x0; x0 = sx+x1; y2 = y0; y0 = sy+y1; cur = -cur;     /* swap P0 P2 */
    }  
    if (cur != 0) {                                       /* no straight line */
      xx += sx; xx *= sx = x0 < x2 ? 1 : -1;              /* x step direction */
      yy += sy; yy *= sy = y0 < y2 ? 1 : -1;              /* y step direction */
      xy = 2*xx*yy; xx *= xx; yy *= yy;             /* differences 2nd degree */
      if (cur*sx*sy < 0) {                              /* negated curvature? */
        xx = -xx; yy = -yy; xy = -xy; cur = -cur;
      }
      dx = 4.0*sy*cur*(x1-x0)+xx-xy;                /* differences 1st degree */
      dy = 4.0*sx*cur*(y0-y1)+yy-xy;
      xx += xx; yy += yy; err = dx+dy+xy;                   /* error 1st step */    
      do {                              
        setPixel(x0, y0, c);                                    /* plot curve */
        if (x0 == x2 && y0 == y2) return;     /* last pixel -> curve finished */
        y1 = 2*err < dx;                     /* save value for test of y step */
        if (2*err > dy) { x0 += sx; dx -= xy; err += dy += yy; }    /* x step */
        if (    y1    ) { y0 += sy; dy -= xy; err += dx += xx; }    /* y step */
      } while (dy < 0 && dx > 0);      /* gradient negates -> algorithm fails */
    }
    // line(x0,y0, x2,y2);                      /* plot remaining part to end */
  }/*  ^--- BU SORUNLU, KAPAYIP ZIT YÖNEYLERLE 2 KERE ÇAĞIRMAK MANTIKLI. FIXME*/

/************** İçi Dolu Çember Çizer **************/  

  void yuvarlak(int x, int y, int r, int c = int.max) {
    int len, ofs;
    for(int i = 0; i < 2 * r; i++) {
      len = cast(int)sqrt(cast(float)(r ^^ 2 - (r - i) ^^ 2));
      ofs = (y + i) * (scr.pitch / 4) + r - len + x;
      len*=2;
      for(int j = 0; j < len; j++) {
        (cast(uint*) scr.pixels)[ofs + j] = c;
      }
    }
  }
  
//************************* HAYATI KOLAYLAŞTIRAN İŞLEV *************************

  bool keyEvent(int type) {
    SDL_Flip(scr); // iyi oluyor, gibi! **** GEREKİRSE KAPAT ****
  
    bool STOP;
    SDL_Event event;

    if(!type) { // 0 seçilmiş ise durdurma döngüsüne atla
      STOP = true;
      goto SON;
    }
    
    SDL_PollEvent(&event);
    if(event.type           == SDL_KEYDOWN &&
       event.key.keysym.sym == SDLK_ESCAPE) {
       STOP = true;
       if(type != 2) return false;
    }
    
    while(STOP) {
        SDL_Delay(99); // İşlemci kullanımını düşürmek için!
        SDL_PollEvent(&event);
        if(event.type == SDL_KEYUP) break; // ESC bırakıldıysa devam...
    }
    
    SON:  
    while(STOP) {
        SDL_Delay(99); // İşlemci kullanımını düşürmek için!
        SDL_PollEvent(&event);
        if(event.type           == SDL_KEYDOWN &&
           event.key.keysym.sym == SDLK_ESCAPE) return false;
    }   // v--- TUŞA BASILMADIYSA DEVAM / 2. ESC'de ---^
    return true;
  }
}

enum clr : uint {
  white  = 0xFFFFFF,
  red    = 0xFF0000,
  yellow = 0xFFFF00,
  green  = 0x00FF00,
  cyan   = 0x00FFFF,
  blue   = 0x0000FF,
  black  = 0x000000
}
/* Date of Test : 7 September 2012
 * DMD Versions : 2.0.59 and 2.0.60
 * Compile Arg. : dmd sdlmini -L-lSDL -debug
 */
debug {
  void main() {
    int x, y, s, i;
    uint[] colors; with(clr) {
           colors = [ black, blue, cyan, green, yellow, red, white ];
    }
    SDL_Init(SDL_INIT_EVERYTHING);
    
    with( new draw(640, 480, "Working...") ) {
      assert(scr != null);
      do {
        foreach(c; colors) {
          i++;
          x = uniform(64, w-64);
          y = uniform(64, h-64);
          s = uniform(3, 6);
          foreach(r; 0..64) polygon(x, y, r, s, c);
        }
        if(i > 33) {
          setBackground(clr.black);
          i = 0;
        }
      } while(keyEvent(2));
    }
    SDL_Quit();
  }
}
//v1.1
