SDLK_ESCAPE        : isEsc := true;
SDLK_PAGEDOWN      : nextLv;
SDLK_PAGEUP        : backLv;
SDLK_END           : nextSet;
SDLK_HOME          : backSet;
SDLK_SPACE         : resetArena;
SDLK_RIGHT, SDLK_d : scannedDir := SDL_SCANCODE_RIGHT;
SDLK_LEFT,  SDLK_a : scannedDir := SDL_SCANCODE_LEFT;
SDLK_UP,    SDLK_w : scannedDir := SDL_SCANCODE_UP;
SDLK_DOWN,  SDLK_s : scannedDir := SDL_SCANCODE_DOWN;
SDLK_r             : redrawArena;
SDLK_n             : nextWall;

SDLK_b             : begin
  isWall := not isWall;
  redrawArena;
end;


