//fpc -Mdelphi parse_levels.pas
program ReadFile;

uses
 Sysutils;

const
  C_FNAME = 'picoban.txt';

  S_WAL   = 224;  // ord('#'); wall
  S_GRA   = 192;  // ord('x'); grass
  S_PLA   = 160;  // ord('@'); player
  S_PLD   = 128;  // ord('+'); player on deck
  S_DEC   = 96;   // ord('.'); deck
  S_CRA   = 64;   // ord('$'); crate
  S_CRD   = 32;   // ord('*'); crate on deck
  S_FLO   = 0;    // ord(' '); floor

var
  tfIn         : TextFile;
  s            : string;
  l, i, q, z   : byte;
  c, t         : char;

  counter      : word = 0;

//-----------------------------------------------------------------------------

begin

  // Set the name of the file that will be read
  AssignFile(tfIn, C_FNAME);

  // Embed the file handling in a try/except block to handle errors gracefully
  try
    // Open the file for reading
    reset(tfIn);

    repeat
      readln(tfIn, s);

      l := length(s);
      i := 1;

      write('#8#8');

      repeat
        q := 0;
        c := s[i];
        repeat
          inc(i);
          t := s[i];
          inc(q);
        until t <> c;

        case c of
          '#': z := S_WAL or q;
          'x': z := S_GRA or q;
          '@': z := S_PLA or q;
          '+': z := S_PLD or q;
          '.': z := S_DEC or q;
          '$': z := S_CRA or q;
          '*': z := S_CRD or q;
          ' ': z := S_FLO or q;
        end;

        write('#',z);
        inc(counter);

      until i > l;

      writeln(',');

      //exit;

    until eof(tfIn);


    // Done so close the file
    CloseFile(tfIn);

    //WriteLn('bytes: ', counter);

  except
    on E: EInOutError do
     writeln('File handling error occurred. Details: ', E.Message);
  end;

end.
