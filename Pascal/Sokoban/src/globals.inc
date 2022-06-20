//-----------------------------------------------------------------------------

const

  loopWait    = round(1000/50);         //PAL=50, NTSC=60 frames per second
  intervalT1  = 100;
  intervalT2  = 0;
  tileSize    = 64;                     //64 originally (32 acceptable)
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

  bgs           : array [0..3] of PChar = (
    'gfx/bg_desk.jpg',
    'gfx/bg_suburbia.jpg',
    'gfx/bg_island.jpg',
    'gfx/bg_waterfalls.jpg'
  );

//-----------------------------------------------------------------------------

  gSets         : array [0..23] of PChar = (
    'levels/Intro.txt',
    'levels/Sokoban.txt',
    'levels/Sokoban Jr. 1.txt',
    'levels/Sokoban Jr. 2.txt',
    'levels/Deluxe.txt',
    'levels/Sokogen 990602.txt',
    'levels/Xsokoban.txt',
    'levels/David Holland 1.txt',
    'levels/David Holland 2.txt',
    'levels/Howard''s 1st set.txt',
    'levels/Howard''s 2nd set.txt',
    'levels/Howard''s 3rd set.txt',
    'levels/Howard''s 4th set.txt',
    'levels/Sasquatch.txt',
    'levels/Mas Sasquatch.txt',
    'levels/Sasquatch III.txt',
    'levels/Sasquatch IV.txt',
    'levels/Still more levels.txt',
    'levels/Nabokosmos.txt',
    'levels/Microcosmos.txt',
    'levels/Microban.txt',
    'levels/Simple sokoban.txt',
    'levels/Dimitri and Yorick.txt',
    'levels/Yoshio Automatic.txt'
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
  sdlTimer2Id       : TSDL_TimerID;
  sdlTimer1CallBack : TSDL_TimerCallback;
  sdlTimer2CallBack : TSDL_TimerCallback;
  scannedDir        : byte = 0;
  paramT2           : boolean = false;

//-------------------------------------

  isEsc             : boolean = false;
  animFrame         : byte = 0;
  bgCounter         : byte = 0;
  msxCounter        : byte = 0;
  direction         : byte;
  ix, iy            : byte;
  decks, crates     : byte;
  lvSizeX, lvSizeY  : byte;
  playerX, playerY  : byte;
  centerX, centerY  : word;
  i                 : word;
  y, offset         : byte;
  lv                : byte;
  gSet              : byte = 0;
  maxLv             : byte;
  isWall            : boolean = false;
  nextMsx           : boolean = false;

//-------------------------------------

  levels  : array [0..maxSet] of string;
  arena   : array [0..windowSizeY, 0..windowSizeX] of char;

//-----------------------------------------------------------------------------

const
  maxMsx = 14;                          //zero indexed

var
  playlist : array [0..maxMsx] of byte;

  music    : array [0..maxMsx] of PChar = (
    'msx/la blue girl.xm',
    'msx/heal my peel.s3m',
    'msx/afro superfly.xm',
    'msx/in bed.s3m',
    'msx/evening in the city.xm',
    'msx/happyness without limit.it',
    'msx/a rose of gold.xm',
    'msx/intermission.xm',
    'msx/over reacted.xm',
    'msx/roundheeled.xm',
    'msx/mooserun.xm',
    'msx/true.xm',
    'msx/discodel.xm',
    'msx/the norm.xm',
    'msx/placebo.xm'
  );

  musicDur : array [0..maxMsx] of dword = (
    (1000 * 60 * 3) + (1000 *  9) + (10 * 16), // 3:09.16
    (1000 * 60 * 4) + (1000 * 45) + (10 * 32), // 4:45.32
    (1000 * 60 * 3) + (1000 * 16) + (10 * 59), // 3:16.59
    (1000 * 60 * 4) + (1000 * 12) + (10 * 80), // 4:14.86
    (1000 * 60 * 3) + (1000 * 31) + (10 * 75), // 3:31.75
    (1000 * 60 * 3) + (1000 * 54) + (10 * 82), // 3:54.82
    (1000 * 60 * 3) + (1000 * 47) + (10 * 88), // 3:47.88
    (1000 * 60 * 3) + (1000 *  8) + (10 * 16), // 3:08.16
    (1000 * 60 * 4) + (1000 * 18) + (10 * 65), // 4:18.65
    (1000 * 60 * 3) + (1000 *  4) + (10 * 43), // 3:04.43
    (1000 * 60 * 2) + (1000 * 59) + (10 * 80), // 2:59.80
    (1000 * 60 * 3) + (1000 * 38) + (10 * 81), // 3:38.81
    (1000 * 60 * 3) + (1000 * 37) + (10 * 10), // 3:37.10
    (1000 * 60 * 3) + (1000 * 17) + (10 * 59), // 3:17.59
    (1000 * 60 * 3) + (1000 * 26) + (10 * 42)  // 3:26.42
  );

//-----------------------------------------------------------------------------
