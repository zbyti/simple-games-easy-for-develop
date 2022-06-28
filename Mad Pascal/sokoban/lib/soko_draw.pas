unit soko_draw;

//---------------------- INTERFACE ---------------------------------------------

interface

//----------------------

const

GFX_FLO    = 0;
GFX_GRA    = 2;
GFX_WAL    = 4;
GFX_CRD    = 6;
GFX_CRA    = GFX_CRD + 128;
GFX_DEC    = 8;


PLA_UP     = 22;
PLA_DOWN   = 18;
PLA_RIGHT  = 10;
PLA_LEFT   = 14;
PLA_WAVE   = 26;

//----------------------

var

gfx_pla : PByte;


//----------------------

procedure drawBoard;
procedure drawGrass;
procedure putTile(a: word; t: byte); register;

//---------------------- IMPLEMENTATION ----------------------------------------

implementation

//----------------------

uses atari, soko_lv;

//----------------------

procedure putTile(a: word; t: byte); register;
begin
  poke(a, t);
  poke(a +  1, t + 1);
  poke(a + SCR_ROW, t + $20);
  poke(a + SCR_ROW + 1, t + $21);
end;

//----------------------

procedure drawGrass;
var
  iX, iY   : byte;
  offset   : word;
begin
  offset := 0;
  for iY := 0 to (MAX_Y - 1) do begin
    for iX := 0 to (MAX_X - 1) do begin
      putTile(savmsc + offset + (iX shl 1), GFX_GRA);
    end;
    inc(offset, SCR_ROW * 2);
  end;
end;

//----------------------

procedure drawBoard;
var
  iX, iY   : byte;
  offset   : word;
  tile     : byte;
begin
  offset := 0;

  for iY := 0 to lvY do begin
    for iX := 0 to lvX do begin
      case ord(board[iY][iX]) of
        S_WAL : tile := GFX_WAL;
        S_FLO : tile := GFX_FLO;
        S_CRA : tile := GFX_CRA;
        S_CRD : tile := GFX_CRD;
        S_DEC : tile := GFX_DEC;
        S_GRA : tile := GFX_GRA;
        S_PLA : tile := gfx_pla^;
        S_PLD : tile := gfx_pla^;
      end;
      putTile(centered + offset + (iX shl 1), tile);
    end;
    inc(offset, SCR_ROW * 2);
  end;
end;

//---------------------- INITIALIZATION ----------------------------------------

initialization
end.
