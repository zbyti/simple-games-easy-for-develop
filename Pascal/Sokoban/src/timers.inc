//-----------------------------------------------------------------------------

function timer1(interval: UInt32; param: pointer): UInt32; cdecl;
begin
  direction := byte(param^);

  if direction <> 0 then begin
    animPlayer;
    updateArena;
    scannedDir := 0;
  end;

  timer1 := interval;
end;

//-------------------------------------

function timer2(interval: UInt32; param: pointer): UInt32; cdecl;
begin
  if msxCounter < maxMsx then inc(msxCounter) else msxCounter := 0;
  //writeln('music: ', music[msxCounter]);
  nextMsx := true;

  timer2 := musicDur[playlist[msxCounter]];
end;

//-----------------------------------------------------------------------------