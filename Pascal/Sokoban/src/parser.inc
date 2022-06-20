//-------------------------------------
// arena size 30x18 (1920x1200)       |
// tile  size 64x64                   |
//-------------------------------------
// ~        grass                     |
// space    ground                    |
// #        block                     |
// $        crate                     |
// .        deck                      |
// *        crate on deck             |
// @        player                    |
// !        player on deck            |
//-------------------------------------


//-----------------------------------------------------------------------------


procedure putGrass(xx, yy : shortint);
begin
    if arena[yy][xx] = '#' then exit;
    if (xx < 0) or (xx >= offset) or (yy < 0) or (yy >= y) then exit;

    arena[yy][xx] := '~';

    if arena[yy][xx+1] = ' ' then putGrass(xx+1,yy);
    if arena[yy][xx-1] = ' ' then putGrass(xx-1,yy);
    if arena[yy+1][xx] = ' ' then putGrass(xx,yy+1);
    if arena[yy-1][xx] = ' ' then putGrass(xx,yy-1);
end;

//-------------------------------------

procedure parseLv(fname: string);
var
  tfIn   : TextFile;
  s      : string;
  i      : byte;
  sLevel : string;
begin
  i := 0; y := 0;

  AssignFile(tfIn, fname);

  try
    reset(tfIn);

    repeat
      readln(tfIn, s);
    until (s = '---') or eof(tfIn);

    while not eof(tfIn) do begin

      offset := 0;

      for iy := 0 to windowSizeY do
        for ix := 0 to windowSizeX do
            arena[iy][ix] := ' ';

      repeat
        readln(tfIn, s);

        if (s <> '') and (s[1] <> ';') and (s <> '---') and (ord(s[1]) <> 39) then begin
          if offset < length(s) then offset := length(s);
          s := StringReplace(s, '+', '!', []);
          for ix := 0 to length(s) - 1 do arena[y][ix] := s[ix + 1];
          inc(y);
        end;
      until (s = '---') or eof(tfIn);

      for ix := 0 to offset-1 do putGrass(ix, 0);
      for ix := 0 to offset-1 do putGrass(ix, y-1);
      for iy := 0 to y-1 do putGrass(0, iy);
      for iy := 0 to y-1 do putGrass(offset-1, iy);

      sLevel := '';

      AppendStr(sLevel, char(offset));
      for iy := 0 to y-1 do
        for ix := 0 to offset-1 do AppendStr(sLevel, arena[iy][ix]);

      levels[i] := sLevel;

      inc(i); y := 0;

    end;

    lv := 0; maxLv := i-1;

    CloseFile(tfIn);
  except
    on E: EInOutError do
      writeln('File', fname,'handling error occurred. Details: ', E.Message);
  end;
end;

//-----------------------------------------------------------------------------