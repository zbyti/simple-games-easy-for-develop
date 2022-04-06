MP=${HOME}/Programs/MadPascal/mp
MADS=${HOME}/Programs/mads/mads
BASE=${HOME}/Programs/MadPascal/base

all: clean build-vic20

vic20: clean build-vic20 start-vic20

build-vic20:
	$(MP) src/vic20.pas -t raw -code 1200 -o output/vic20.a65
	$(MADS) output/vic20.a65 -x -i:$(BASE) -o:output/vic20-core.bin
	cat res/snake.fnt output/vic20-core.bin > output/vic20.prg
	exomizer sfx 0x1200 -t 20 -n -o bin/snake-vic20-pal.prg output/vic20.prg

start-vic20:
	flatpak run --command=xvic net.sf.VICE -pal bin/snake-vic20-pal.prg

clean:
	rm -f output/* bin/*