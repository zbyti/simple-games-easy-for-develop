{$r res/gfx.rc}

{$librarypath 'src/systems'}

uses sys_vic20;

const
  CRT_CHARS_ADR = ($a000 + $2000) - $200;
  CRT_TITLE_ADR = CRT_CHARS_ADR - SCREEN_SIZE;

const
  GAME_BLACK  = BLACK;
  GAME_WHITE  = WHITE;
  GAME_RED    = RED;
  GAME_CYAN   = CYAN;
  GAME_PURPLE = PURPLE;
  GAME_GREEN  = GREEN;
  GAME_BLUE   = BLUE;
  GAME_YELLOW = YELLOW;
  GAME_ORANGE = ORANGE;

  C_FRUIT      = 0;
  C_SPACE      = $20;

  C_WALL_H     = $1e;
  C_WALL_V     = $1f;

  C_HEAD_UP    = $27;
  C_HEAD_RIGHT = $26;
  C_HEAD_DOWN  = $28;
  C_HEAD_LEFT  = $29;

  C_TAIL_UP    = $22;
  C_TAIL_LEFT  = $23;
  C_TAIL_DOWN  = $24;
  C_TAIL_RIGHT = $25;

  C_BODY_V     = $2a;
  C_BODY_H     = $2b;

  C_BODY_SW    = $3b;
  C_BODY_SE    = $3c;
  C_BODY_NW    = $3d;
  C_BODY_NE    = $3e;

{$i 'src/game.inc'}
