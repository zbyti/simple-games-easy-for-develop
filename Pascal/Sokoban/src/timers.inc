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

//-----------------------------------------------------------------------------
