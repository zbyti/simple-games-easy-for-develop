{$r res/gfx.rc}
{$r res/music.rc}

{$librarypath 'lib'}

//------------------------------------------------------------------------------

uses atari, graph, joystick, mpt, soko_lv, soko_draw;

//------------------------------------------------------------------------------

const
  SETVBV    = $E45C;
  XITVBV    = $E462;

  BOARD_GFX  = $9c00;
  MPT_PLAYER = $a000;
  MPT_MODUL  = $a500;

  JOY_DELAY = 7;

  KEY_SPACE = $21;
  KEY_R     = $28;
  KEY_RIGHT = $87;
  KEY_LEFT  = $86;

var
  dir        : byte;
  isFire     : boolean;
  isOddFrame : boolean;
  tile       : byte;
  iLv        : byte = 100;

  moveTimer  : byte;

  msx        : TMPT;

//------------------------------------------------------------------------------

procedure setVbk(mode, msb, lsb: byte); assembler;
asm
  phr
  lda mode
  ldx msb
  ldy lsb
  jsr SETVBV
  plr
end;

procedure exitVbk; assembler; inline;
asm
  jmp XITVBV
end;

//------------------------------------------------------------------------------

procedure makeMove(joy: byte);
var
  updatePos           : boolean;
  pX, pY              : byte;
  step0, step1, step2 : PByte;
begin
  updatePos := false;
  pX := playerX; pY := playerY;
  step0 := @board[playerY][playerX];

  case joy of
    joy_right: begin
      step1 := step0 + 1;
      step2 := step1 + 1;
      inc(pX);
      gfx_pla^ := PLA_RIGHT;
    end;
    joy_left: begin
      step1 := step0 - 1;
      step2 := step1 - 1;
      dec(pX);
      gfx_pla^ := PLA_LEFT;
    end;
    joy_up: begin
      step1 := step0 - MAX_X;
      step2 := step1 - MAX_X;
      dec(pY);
      gfx_pla^ := PLA_UP;
    end;
    joy_down: begin
      step1 := step0 + MAX_X;
      step2 := step1 + MAX_X;
      inc(pY);
      gfx_pla^ := PLA_DOWN;
    end;
  end;

  if step1^ = S_FLO then
  begin
    step1^ := S_PLA; updatePos := true;
  end else

  if step1^ = S_DEC then
  begin
    step1^ := S_PLD; updatePos := true;
  end else

  if ((step1^ = S_CRA) or (step1^ = S_CRD)) and ((step2^ = S_FLO) or (step2^ = S_DEC)) then
  begin
    if step2^ = S_FLO then step2^ := S_CRA else step2^ := S_CRD;

    if (step1^ = S_CRA) and (step2^ = S_CRD) then dec(crates) else
    if (step1^ = S_CRD) and (step2^ = S_CRA) then inc(crates);

    if step1^ = S_CRA then step1^ := S_PLA else step1^ := S_PLD;

    updatePos := true;
  end;

  if updatePos then begin
    if step0^ = S_PLA then step0^ := S_FLO else step0^ := S_DEC;
    playerX := pX; playerY := pY;

    if isOddFrame then inc(gfx_pla^, 2);
    isOddFrame := not isOddFrame;

    drawBoard;

    moveTimer := JOY_DELAY;
  end;

end;

//------------------------------------------------------------------------------

procedure initLv;
begin
  isOddFrame := false;
  gfx_pla^ := PLA_DOWN;
  getLv(iLv);
  drawBoard;
end;

procedure nextLv;
begin
  if iLv < SET_SIZE then inc(iLv) else iLv := 0;
  drawGrass;
  initLv;
end;

procedure prevLv;
begin
  if iLv > 0 then dec(iLv) else iLv := SET_SIZE;
  drawGrass;
  initLv;
end;

procedure completeLv;
var
  i   : byte;
  tmp : word;
begin
  tmp := centered + (playerX shl 1) + (playerY shl 1) * SCR_ROW;
  for i := 7 downto 0  do begin
    if (i and 1) = 0 then putTile(tmp, PLA_WAVE) else putTile(tmp, PLA_WAVE + 2);
    pause(10);
  end;
  pause(25);

  nextLv;
end;

//------------------------------------------------------------------------------

procedure initScreen;
begin
  InitGraph(12+16);

  chbas := hi(BOARD_GFX);

  COLOR0 := 4;
  COLOR1 := 6;
  COLOR2 := 14;
  COLOR3 := 10;
  COLOR4 := $c0;
end;

//------------------------------------------------------------------------------

procedure VBLANKD;
begin
  if moveTimer > 0 then dec(moveTimer);
  msx.play;
  exitVbk;
end;

//------------------------------------------------------------------------------

begin
  pause;
  setVbk(7, hi(word(@VBLANKD)), lo(word(@VBLANKD)));

  msx.player := pointer(MPT_PLAYER);
  msx.modul  := pointer(MPT_MODUL);
  msx.init;

  initScreen;
  nextLv;

  repeat

    if crates = 0 then completeLv;

    if moveTimer = 0 then
      if
        (joy_1 = joy_up)   or
        (joy_1 = joy_down) or
        (joy_1 = joy_left) or
        (joy_1 = joy_right)
      then
        makeMove(joy_1);

    if ch <> 255 then begin
      case ch of
        KEY_SPACE : initLv;
        KEY_RIGHT : nextLv;
        KEY_LEFT  : prevLv;
      end;
      ch := 255;
    end;

    pause;
  until false;
end.

//------------------------------------------------------------------------------
