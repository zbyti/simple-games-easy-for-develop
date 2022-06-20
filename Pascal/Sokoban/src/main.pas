{$H+}

// fpc -Fu~/Projects/Pascal/SDL2/ main.pas
program SDL_RectanglesScaling;

// https://github.com/PascalGameDevelopment/SDL2-for-Pascal
uses sysutils, SDL2, SDL2_image, SDL2_mixer;

//-----------------------------------------------------------------------------

{$i globals.inc}
{$i parser.inc}

//-----------------------------------------------------------------------------

function timer1(interval: UInt32; param: pointer): UInt32; cdecl; forward;

//-------------------------------------

function initRect(x, y: word): TSDL_Rect;
begin
  initRect.x := x;
  initRect.y := y;
  initRect.w := tileSize;
  initRect.h := tileSize;
end;

//-------------------------------------

function readDirectory(d: string; c: PByte; isSorted: boolean): TFilesArray;
var
  info    : TSearchRec;
  a       : TStringArray;
  s       : string;
  counter : byte = 0;
begin
  counter := 0;

  if FindFirst (d + '*', faAnyFile, info) = 0 then begin

    repeat
      with info do
        begin
          if Name[1] <> '.' then begin
            if isSorted then begin
              s := name;
              a := s.split('_');
              readDirectory[StrToInt(a[0])] := d + name;
            end else
              readDirectory[counter] := d + name;
            inc(counter);
          end;
        end;
    until FindNext(info)<>0;

    FindClose(Info);


    c^ := counter - 1;
  end;

end;

//-----------------------------------------------------------------------------

procedure initSDL;
begin
  if SDL_Init(SDL_INIT_VIDEO or SDL_INIT_TIMER or SDL_INIT_AUDIO) < 0 then begin
    writeln('SDL could not initialize!');
    HALT;
  end;

  sdlTimer1CallBack := @timer1;
  sdlTimer1Id := SDL_AddTimer(intervalT1, sdlTimer1CallBack, @scannedDir);

  SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, 'linear');

  if SDL_CreateWindowAndRenderer
  (
    resX,
    resY,
    SDL_WINDOW_FULLSCREEN_DESKTOP,
    @sdlWindow,
    @sdlRenderer
  ) <> 0 then Halt;

  SDL_RenderSetLogicalSize(sdlRenderer, resX, resY);

  sdlTexture := IMG_LoadTexture(sdlRenderer, 'gfx/tilesheet.png');
  if sdlTexture = nil then HALT;

  sdlTextureBg := IMG_LoadTexture(sdlRenderer, PChar(bgs[bg]));
  if sdlTextureBg = nil then HALT;

  sdlSrcRect  := initRect(0, 0);
  sdlDestRect := initRect(0, 0);

  new(sdlEvent);

  if Mix_OpenAudio(MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT,
    MIX_DEFAULT_CHANNELS, 4096) < 0 then Exit;

  sdlMusic := Mix_LoadMUS(PChar(music[playlist[msx]]));
  if sdlMusic = nil then Exit;

  Mix_VolumeMusic(MIX_MAX_VOLUME);
end;

//-------------------------------------

procedure cleanupSDL;
begin
  dispose(sdlEvent);

  SDL_RemoveTimer(sdlTimer1Id);

  SDL_DestroyTexture(sdlTexture);
  SDL_DestroyTexture(sdlTextureBg);
  SDL_DestroyRenderer(sdlRenderer);
  SDL_DestroyWindow (sdlWindow);

  Mix_FreeMusic(sdlMusic);

  SDL_Quit;
end;

//-------------------------------------

procedure initTileset;
var
  tmp : word;
begin
  sdlPlayerRect := initRect(playerMapX, playerMapY);

  sdlBlockRect  := initRect(tileSize * (random(3) + 6), tileSize * 7);

  sdlCrateRect  := initRect(tileSize * (random(5) + 6), tileSize * (random(256) and 2));
  sdlDcrateRect := initRect(sdlCrateRect.x, tileSize * 1);
  sdlDeckRect   := initRect(tileSize * (random(2) + 10), tileSize * 7);
  sdlGroundRect := initRect(sdlDeckRect.x, tileSize * 6);

  //endless loop; TODO: add condition
  repeat
    tmp := tileSize * (random(2) + 10);
  until tmp <> sdlGroundRect.x;

  sdlGrassRect  := initRect(tmp, tileSize * 6);
end;

//-------------------------------------

procedure animPlayer;
begin
  if animFrame < 3 then inc(animFrame) else animFrame := 0;
  case direction of
    SDL_SCANCODE_RIGHT : begin
      sdlPlayerRect.x := animDownRight[animFrame];
      sdlPlayerRect.y := playerMapY + (2 * tileSize);
    end;
    SDL_SCANCODE_LEFT  : begin
      sdlPlayerRect.x := animUpLeft[animFrame];;
      sdlPlayerRect.y := playerMapY + (2 * tileSize);
    end;
    SDL_SCANCODE_UP    : begin
      sdlPlayerRect.x := animUpLeft[animFrame];
      sdlPlayerRect.y := playerMapY;
    end;
    SDL_SCANCODE_DOWN  : begin
      sdlPlayerRect.x := animDownRight[animFrame];
      sdlPlayerRect.y := playerMapY;
    end;
  end;
end;

//-------------------------------------

procedure drawArena;
var
  el: char;
begin
  sdlDestRect.x := centerX;
  sdlDestRect.y := centerY;

  for iy := 0 to lvSizeY do begin
    for ix := 0 to lvSizeX do begin
      el := arena[iy][ix];

      sdlSrcRect.x := 0; sdlSrcRect.y := 0;

      if el <> '~' then SDL_RenderCopy(sdlRenderer, sdlTexture, @sdlGroundRect, @sdlDestRect);
      case el of
        '#'      : sdlSrcRect := sdlBlockRect;
        '$'      : sdlSrcRect := sdlCrateRect;
        '.', '!' : sdlSrcRect := sdlDeckRect;
        '*'      : sdlSrcRect := sdlDcrateRect;
      end;

      SDL_RenderCopy(sdlRenderer, sdlTexture, @sdlSrcRect, @sdlDestRect);

      inc(sdlDestRect.x, tileSize);
    end;

    sdlDestRect.x := centerX;
    inc(sdlDestRect.y, tileSize);
  end;


  sdlDestRect.x:= (playerX * tileSize) + centerX;
  sdlDestRect.y:= (playerY * tileSize) + centerY;
  SDL_RenderCopy(sdlRenderer, sdlTexture, @sdlPlayerRect, @sdlDestRect);

  SDL_RenderPresent(sdlRenderer);
end;

//-------------------------------------

procedure updateArena;
var
  updatePos           : boolean = false;
  pX, pY              : byte;
  step0, step1, step2 : PChar;
begin
  step0 := @arena[playerY][playerX];

  pX := playerX; pY := playerY;

  case direction of
    SDL_SCANCODE_RIGHT:
    begin
      step1 := @arena[playerY][playerX + 1];
      step2 := @arena[playerY][playerX + 2];
      inc(px);
    end;
    SDL_SCANCODE_LEFT:
    begin
      step1 := @arena[playerY][playerX - 1];
      step2 := @arena[playerY][playerX - 2];
      dec(px);
    end;
    SDL_SCANCODE_UP:
    begin
      step1 := @arena[playerY - 1][playerX];
      step2 := @arena[playerY - 2][playerX];
      dec(pY);
    end;
    SDL_SCANCODE_DOWN:
    begin
      step1 := @arena[playerY + 1][playerX];
      step2 := @arena[playerY + 2][playerX];
      inc(pY);
    end;
  end;

  if step1^ = ' ' then
  begin
    step1^ := '@'; updatePos := true;
  end else

  if step1^ = '.' then
  begin
    step1^ := '!'; updatePos := true;
  end else

  if ((step1^ = '$') or (step1^ = '*')) and ((step2^ = ' ') or (step2^ = '.')) then
  begin
    if step2^ = ' ' then step2^ := '$' else step2^ := '*';

    if (step1^ = '$') and (step2^ = '*') then inc(crates) else
    if (step1^ = '*') and (step2^ = '$') then dec(crates);

    if step1^ = '$' then step1^ := '@' else step1^ := '!';

    updatePos := true;
  end;

  if updatePos then begin
    if step0^ = '@' then step0^ := ' ' else step0^ := '.';
    playerX := pX; playerY := pY;
  end;

  drawArena;
end;

//-------------------------------------

procedure resetArena;
begin
  decks := 0; crates := 0; iy := 0; ix := 0;
  direction := 0; animFrame := 0;

  sdlPlayerRect.x := playerMapX;
  sdlPlayerRect.y := playerMapY;

  for i := 2 to length(levels[lv]) do begin
    arena[iy][ix] := levels[lv][i];

    if (levels[lv][i] = '.') or ((levels[lv][i] = '*') or (levels[lv][i] = '!')) then inc(decks);
    if levels[lv][i] = '*' then inc(crates) else

    if (levels[lv][i] = '@') or (levels[lv][i] = '!') then begin
      playerX := ix;
      playerY := iy;
    end;

    inc(ix);

    if ((i - 1) mod ord(levels[lv][1])) = 0 then begin
      ix := 0;
      inc(iy);
    end;
  end;

  drawArena;
end;

//-------------------------------------

procedure fillBackground;
begin
  for iy := 0 to windowSizeY do begin
    sdlDestRect.y := tileSize * iy;

    for ix := 0 to windowSizeX do begin
      sdlDestRect.x := tileSize * ix;
      SDL_RenderCopy(sdlRenderer, sdlTexture, @sdlGrassRect, @sdlDestRect);
    end;

  end;
end;

//-------------------------------------

procedure setBackground;
begin
  if isWall then
    SDL_RenderCopy(sdlRenderer, sdlTextureBg, nil, nil)
  else
    fillBackground;
end;

//-------------------------------------

procedure redrawArena;
begin
  initTileset;
  setBackground;
  drawArena;
end;

//-------------------------------------

procedure nextWall;
begin
  if isWall then begin
    if bg < highBgs then inc(bg) else bg := 0;

    sdlTextureBg := IMG_LoadTexture(sdlRenderer, PChar(bgs[bg]));
    if sdlTextureBg = nil then HALT;

    setBackground;
    drawArena;
  end;
end;

//-------------------------------------

procedure setLevel;
begin
  initTileset; setBackground;

  lvSizeX := ord(levels[lv][1]) - 1;
  lvSizeY := ((length(levels[lv]) - 1) div ord(levels[lv][1])) - 1;

  centerX := tileSize * ((windowSizeX - lvSizeX) shr 1);
  centerY := tileSize * ((windowSizeY - lvSizeY) shr 1);

  //writeln('level: ', lv);

  resetArena;
end;

procedure nextLv;
begin
  if lv < maxLv then inc(lv) else lv := 0;
  setLevel;
end;

procedure backLv;
begin
  if lv > 0 then dec(lv) else lv := maxLv;
  setLevel;
end;

//-------------------------------------

procedure loadSet;
begin
  parseLv(gameSets[gs]);
  setLevel;
end;

procedure nextSet;
begin
  if gs < highGameSets then inc(gs) else gs := 0;
  loadSet;
end;

procedure backSet;
begin
  if gs > 0 then dec(gs) else gs := highGameSets;
  loadSet;
end;

//-------------------------------------

procedure eventsLoop;
begin
  while SDL_PollEvent(sdlEvent) = 1 do begin
    case sdlEvent^.type_ of
      SDL_KEYDOWN: begin
        case sdlEvent^.key.keysym.sym of
          {$i keydown.inc}
        end;
      end;
    end;
  end;
end;

//-------------------------------------

{
  Mix_PlayMusic(sdlMusic, 0)
  Mix_PauseMusic;
  Mix_ResumeMusic;
  Mix_RewindMusic;
  Mix_FadeInMusic(sdlMusic, 10, 3000);
  Mix_FadeOutMusic(3000);
}
procedure playMusic;
begin

  if Mix_PlayingMusic = 0 then begin
    sdlMusic := Mix_LoadMUS(PChar(music[playlist[msx]]));
    if sdlMusic = nil then Exit;
    Mix_PlayMusic(sdlMusic, 0);

    if msx < highMusic then inc(msx) else msx := 0;

    nextWall;
  end;
end;

//-------------------------------------

procedure shufflePlaylist;
var
  i, r, tmp: byte;
begin
  for i := 0 to highMusic do playlist[i] := i;

  for i := 0 to highMusic do begin
    r := random(highMusic + 1);
    tmp := playlist[i];
    playlist[i] := playlist[r];
    playlist[r] := tmp;
  end;
end;

//-------------------------------------

procedure initAssetsArrays;
begin
  music    := readDirectory('msx/', @highMusic, false);
  gameSets := readDirectory('lvs/', @highGameSets, true);
  bgs      := readDirectory('bgs/', @highBgs, false);

  shufflePlaylist;
end;


//-----------------------------------------------------------------------------

procedure mainLoop;
begin
  repeat

    eventsLoop;

    playMusic;

    if decks = crates then begin
      if lv < maxLv then begin
        inc(lv);
        setLevel;
      end else
        nextSet;
    end;

    SDL_Delay(loopWait);

  until isEsc;
end;

//-----------------------------------------------------------------------------

{$i timers.inc}

//-----------------------------------------------------------------------------

begin
  randomize;

  initAssetsArrays;
  initSDL;
  loadSet;

  mainLoop;

  cleanupSDL;
end.

//-----------------------------------------------------------------------------