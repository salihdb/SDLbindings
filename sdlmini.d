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

public import std.conv, std.math, std.random;

alias SDL_UpperBlit SDL_BlitSurface;

/********************************************************* Some SDL Functions */
extern(C) { 
  int SDL_UpperBlit (SDL_Surface *src, SDL_Rect *srcrect,
                     SDL_Surface *dst, SDL_Rect *dstrect);
  int SDL_SetColorKey (SDL_Surface *surface, uint flag, uint key);
  int SDL_SetAlpha (SDL_Surface* surface, uint flags, ubyte alpha);
  int SDL_FillRect (SDL_Surface *dst, SDL_Rect *dstrect, uint color);
  int SDL_Flip (SDL_Surface *screen);
  int SDL_Init (uint flags);
  int SDL_PollEvent (SDL_Event *event);
  uint SDL_GetTicks ();
  
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
}
  enum uint SDL_INIT_EVERYTHING  = 0x0000FFFF;
  enum uint SDL_SWSURFACE  = 0x00000000;  /* Surface is in system memory      */
  enum uint SDL_HWSURFACE  = 0x00000001;  /* Surface is in video memory       */
  enum uint SDL_realBUF    = 0x40000000;  /* Set up real-buffered video mode  */
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
  static SDL_Surface* scr;

  this (int width, int height, string name, clr color=clr.white) {
    w = width;
    h = height;
    scr = SDL_SetVideoMode(w, h, 0, SDL_HWSURFACE);
    SDL_WM_SetCaption(cast(char*)name, cast(const char*)name);
    if(color != clr.black) setBackground(color);
    //SDL_Flip(scr); // iyi olmuyor, sanki! **** GEREKİRSE AÇ ****
  }

  ~this() { SDL_Quit(); }

public:

/******************** Zemin Boyar ********************/
  
  void setBackground (clr color) {
    SDL_FillRect(scr, &scr.clip_rect, color);
  }

/******************** Benek Boyar ********************/  

  void setPixel (int x, int y, clr c=clr.white) {
    uint * ptr = cast(uint *)scr.pixels;
    int offset = abs(y) * scr.w;// * (scr.pitch / 4);
    ptr[offset + abs(x) ] = c;/*
    uint *pixel = cast(uint *)scr.pixels + y * scr.pitch/4 + x;
         *pixel = c; /* pixel demek
                      * benek demektir,
                      * benek demek
                      * renkli görmektir...:)*/
  }

/**************** Benek Rengini Verir ****************/  

  uint getPixel (int x, int y, SDL_Surface *surface = this.scr) {
    uint *pixel = cast(uint *)surface.pixels;
    
    return pixel[ ( abs(y) * surface.w ) + abs(x) ];
  }

/**************** Renkleri Ters Çevirir ****************/ 

  void invertColor (int tersle=0, bool tersten_mi=false, clr neyle=clr.white) {
    int _x, _y;
    bool yaz;
    if(tersten_mi) { _x = w - 1; _y = h - 1; }
    for(int x; x < w; x++) {
      yaz = true;
      for(int y; y < h; y++) {
        clr benek = cast(clr)getPixel(_x-x, _y-y);
        if(!benek) yaz = false;
        else if(tersle == 1) yaz = true;
        if(tersle == 2) yaz = true;
        if(yaz) setPixel(_x-x, _y-y, tersle ? neyle ^ benek : neyle);
      }
    }
  }
  
/**************** Çizgi Rengiyle Boyar ****************/
 
  void fillPolygon (clr çizgiRengi, ) {
  
    /* Alttaki ilk satır uzun açıklamayı gerekli kılıyor:
     * Çizim yapılan renk ile (burada 'rengi' oluyor) her şeyi
     * XOR'larken çizim rengi ziyah zemin rengine dönüyor!
     */
    invertColor(2, false, çizgiRengi); // her şeyi "rengi" ile XOR'la
    invertColor(0, false, clr.blue);   // üstten siyah görene kadar beyaza boya
    invertColor(0, true, clr.blue);    // alttan siyah görene kadar beyaza boya
    invertColor(1, false, clr.blue);   // zemin rengi hariç her şeyi XOR'la
    invertColor(1, false, clr.blue);   // zemin rengi hariç her şeyi XOR'la
    /*
     * Üstteki son iki satır içinde, sanırım açıklama gerek...:)
     * İlk satırda zemin rengine dönen çizit, ikinci XOR'lamada
     * zemin rengi hariç işlem gördüğü ve işlem sonucu zemin rengi
     * ile aynı olduğu için kaynaşıyorlar. Üçüncü XOR'lamada ise
     * çizit içi istenen değere boyanmış oluyor...
     */
  }
  
/******************** Çizgi Çizer ********************/

  void line (int x0, int y0, int x1, int y1, clr c=clr.white) {
    int dx =  abs(x1 - x0), sx = x0 < x1 ? 1 : -1;
    int dy = -abs(y1 - y0), sy = y0 < y1 ? 1 : -1;
    int err = dx + dy, e2;
  
    while(true) {
      setPixel(x0, y0, c);
      if(x0 == x1 && y0 == y1) break;
      e2 = 2 * err;
      if (e2 >= dy) { err += dy; x0 += sx; }
      if (e2 <= dx) { err += dx; y0 += sy; }
    }
  }

/******************* Çokgen Çizer *******************/

  void polygon (real x, real y, real r, int sides, clr c=clr.white, int a=0) {
    real edge = PI*2 / sides; 
    int x0, y0;
    for(int i = 0; i <= sides; i++) {
      real a1 = cos(edge*i) * r;
      real a2 = sin(edge*i) * r;
      int x1 = cast(int)(a == 270 ?
                         x + a2 :
                           a == 180 ?
                           x + a1 :
                             a == 90 ?
                             x - a2 :
                               x - a1);
      int y1 = cast(int)(a == 270 ?
                         y + a1 :
                           a == 180 ?
                           y + a2 :
                             a == 90 ?
                             y - a1 :
                               y - a2);
      if(i) line(x0, y0, x1, y1, c);
      x0 = x1; y0 = y1;
    }
  }

/******************** Yay Çizer ********************/

  void curve (int x0, int y0, int x1, int y1, int x2, int y2, clr c=clr.white) {
    int sx = x2-x1, sy = y2-y1;
    long xx = x0-x1, yy = y0-y1, xy;            /* relative values for checks */
    real dx, dy, err, cur = xx*sy-yy*sx;                         /* curvature */
    // assert(xx*sx <= 0 && yy*sy <= 0);  /* sign of gradient must not change */
    if(sx*cast(long)sx+sy*cast(long)sy > xx*xx+yy*yy)
    {                                               /* begin with longer part */ 
      x2 = x0; x0 = sx+x1; y2 = y0; y0 = sy+y1; cur = -cur;     /* swap P0 P2 */
    }  
    if(cur != 0) {                                        /* no straight line */
      xx += sx; xx *= sx = x0 < x2 ? 1 : -1;              /* x step direction */
      yy += sy; yy *= sy = y0 < y2 ? 1 : -1;              /* y step direction */
      xy = 2*xx*yy; xx *= xx; yy *= yy;             /* differences 2nd degree */
      if(cur*sx*sy < 0) {                               /* negated curvature? */
        xx = -xx; yy = -yy; xy = -xy; cur = -cur;
      }
      dx = 4.0*sy*cur*(x1-x0)+xx-xy;                /* differences 1st degree */
      dy = 4.0*sx*cur*(y0-y1)+yy-xy;
      xx += xx; yy += yy; err = dx+dy+xy;                   /* error 1st step */    
      do {                              
        setPixel(x0, y0, c);                                    /* plot curve */
        if(x0 == x2 && y0 == y2) return;      /* last pixel -> curve finished */
        y1 = 2*err < dx;                     /* save value for test of y step */
        if(2*err > dy) { x0 += sx; dx -= xy; err += dy += yy; }     /* x step */
        if(    y1    ) { y0 += sy; dy -= xy; err += dx += xx; }     /* y step */
      } while (dy < 0 && dx > 0);      /* gradient negates -> algorithm fails */
    }
    // line(x0,y0, x2,y2);                      /* plot remaining part to end */
  }/*  ^--- BU SORUNLU, KAPAYIP ZIT YÖNEYLERLE 2 KERE ÇAĞIRMAK MANTIKLI. FIXME*/

/************** İçi Dolu Çember Çizer **************/  
    void circle(int x, int y, int r, clr c=clr.white, bool rOffset=false) {
      int len, ofs;
      for(int i = 0; i < 2 * r; i++) {
        len = cast(int)sqrt(cast(float)(r ^^ 2 - (r - i) ^^ 2));
        /* TODO */
        if(rOffset) ofs = (y - r + i) * (scr.pitch / 4) + x - len;
        ofs = (y + i) * (scr.pitch / 4) + r - len + x;
        /* TODO */
        for(int j = 0; j < len*2; j++) (cast(uint*) scr.pixels)[ofs + j] = c;
      }
    }

//************************* HAYATI KOLAYLAŞTIRAN İŞLEV *************************

  bool keyEvent (int type) {
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

  void dotPrnNum (T)(T number, clr color, int radius = 1, /*   >=1   */
                                          int dotLen = 2, /*   >0    */
                                          int chrLen = 0, /*   +/-   */
                                          int x = 0, int y = 0) {
    immutable dts = radius * dotLen;
    int x_chr = dts + x; int y_chr = dts + y;
    int x_tmp;
    
    char[] chr = to!string(number).dup;
    byte[] rakam;
    byte[][] rakamlar = [
      [  62, 127,  99,  99,  99,  99,  99,  99, 127,  62 ], // sıfır
      [  24,  28,  30,  24,  24,  24,  24,  24,  24, 126 ], // bir
      [  62, 127,  99,  96,  48,  24,  12,   6, 127, 127 ], // iki
      [  62, 127,  96,  96,  56, 120,  96,  99, 127,  62 ], // üç
      [  48,  56,  60,  54,  51, 127, 127,  48,  48,  48 ], // dört
      [ 127, 127,   3,   3, 127, 126,  96,  99, 127,  62 ], // beş
      [  62, 127,  99,   3,  63, 127,  99,  99, 127,  62 ], // altı
      [ 127, 127,  96,  48,  24,  12,  12,  12,  12,  12 ], // yedi
      [  62, 127,  99,  99,  62, 127,  99,  99, 127,  62 ], // sekiz
      [  62, 127,  99,  99, 127, 126,  96,  99, 127,  62 ], // dokuz
      [   0,   0,   0,  24,  24,   0,   0,  24,  24,   0 ], // :
      [   0,   0,   0,   0,   0,   0,   0,   0,  24,  24 ], // .
      [   0,   0,  96,  48,  24,  12,   6,   3,   0,   0 ], // /  
    ];

    foreach(c; chr) {
      if(c > 47 && c < 59) {
        int i = to!int(c) - 48; 
        rakam = rakamlar[i];
      } else if(c == 46) rakam = rakamlar[11];
      else if(c == 47) rakam = rakamlar[12];
      else continue;
      foreach(satır; rakam) {
        x_tmp = x_chr;
        foreach(bas; sütun(satır)) {
          if(bas) circle(x_chr, y_chr, radius, color);
          x_chr += dts;
        }
        x_chr = x_tmp;
        y_chr += dts;
      }
      x_chr += (10 * dts) + chrLen;
      y_chr = dts + y;
    }
  }
private:
     auto sütun (byte veri) {
      bool[8] sonuç;
      for(int i = 0; i < 8; i++) {
        sonuç[i] = 1 << i & veri ?
                   true :
                   false;
      }
      return sonuç;
    }
}

uint toRGB(int r, int g, int b) { return (r<<16) | (g<<8) | b; }

enum clr : uint {
  white  = 0xFFFFFF,
  Pantone186 = toRGB (227, 10, 23), //E3-0A-17
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
           colors = [ blue, cyan, green, yellow, red, white ];
    }
    int[] rotate = [ 90, 120, 180 ];
    SDL_Init(SDL_INIT_EVERYTHING);
    
    with( new draw(640, 480, "Working...", clr.black) ) {
      assert(scr != null);
      do {
        foreach(c; colors) {
          i++;
          x = uniform(64, w-64);
          y = uniform(64, h-64);
          s = uniform(3, 6);
          circle(x+30, y+30, 20, c);
          dotPrnNum!int(i, clr.Pantone186, 1, 2, 0, x+30, y+40);
          int rot = rotate[uniform(0, 2)];
          foreach(r; 0..64) {
            polygon(x, y, r, s, c, rot);
          }
        }
        if(i > 33) {
          setBackground(clr.black);
          i = 0;
        }
      } while(keyEvent(2));
    }
  }
}
//v1.2
