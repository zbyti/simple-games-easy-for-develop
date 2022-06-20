//-----------------------------------------------------------------------------

const

  loopWait    = round(1000/50);             //PAL=50, NTSC=60 frames per second
  intervalT1  = 100;
  tileSize    = 64;                         //64 originally (32 acceptable)
  resX        = 1920;
  resY        = 1200;
  windowSizeX = round(resX / tileSize) - 1; //0 indexed def 29
  windowSizeY = round(resY / tileSize) - 1; //0 indexed def 17
  maxSet      = 199;

//-------------------------------------

  playerMapX = tileSize * 0;  playerMapY  = tileSize * 5;

  animUpLeft    : array [0..3] of Word = (
    (playerMapX + 0 + 3) * tileSize,
    (playerMapX + 1 + 3) * tileSize,
    (playerMapX + 0 + 3) * tileSize,
    (playerMapX + 2 + 3) * tileSize
  );
  animDownRight : array [0..3] of Word = (
    (playerMapX + 0) * tileSize,
    (playerMapX + 1) * tileSize,
    (playerMapX + 0) * tileSize,
    (playerMapX + 2) * tileSize
  );

//-----------------------------------------------------------------------------


var

  sdlWindow         : PSDL_Window;
  sdlRenderer       : PSDL_Renderer;
  sdlTexture        : PSDL_Texture;
  sdlTextureBg      : PSDL_Texture;

  sdlSrcRect,
  sdlDestRect,
  sdlPlayerRect,
  sdlGrassRect,
  sdlGroundRect,
  sdlBlockRect,
  sdlCrateRect,
  sdlDeckRect,
  sdlDcrateRect     : TSDL_Rect;

//-------------------------------------

  sdlMusic          : PMix_Music;

//-------------------------------------

  sdlEvent          : PSDL_Event;
  sdlTimer1Id       : TSDL_TimerID;
  sdlTimer1CallBack : TSDL_TimerCallback;
  scannedDir        : byte = 0;

//-------------------------------------

  isEsc             : boolean = false;
  animFrame         : byte = 0;
  direction         : byte;
  ix, iy            : byte;
  decks, crates     : byte;
  lvSizeX, lvSizeY  : byte;
  playerX, playerY  : byte;
  centerX, centerY  : word;
  i                 : word;
  y, offset         : byte;
  isWall            : boolean = false;

//-------------------------------------

  levels  : array [0..maxSet] of string;
  arena   : array [0..windowSizeY, 0..windowSizeX] of char;

//-----------------------------------------------------------------------------

const
  maxFiles = 255;                             //zero indexed

type
  TFilesArray = array [0..maxFiles] of string;

var
  lv           : byte;
  maxLv        : byte;
  msx          : byte = 0;
  highMusic    : byte;
  gs           : byte = 0;
  highGameSets : byte;
  bg           : byte = 0;
  highBgs      : byte;


  playlist   : array [0..maxFiles] of byte;
  music      : TFilesArray;
  gameSets   : TFilesArray;
  bgs        : TFilesArray;

//-----------------------------------------------------------------------------
