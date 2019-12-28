# BINPATH = /Program Files (x86)/Microsoft Visual Studio/2019/BuildTools/VC/Tools/MSVC/14.24.28314/bin/Hostx86/x86
BINPATH = /masm32/bin
ML = "$(BINPATH)/ml"
MLFLAGS = -W3 -Zi
LINK = "$(BINPATH)/link"
LIBDIR = -LIBPATH:"/c/Irvine" -LIBPATH:"/c/masm32/lib"
LIBS =  "Irvine32.lib" "kernel32.lib" "user32.lib" "gdi32.lib"

.PHONY: main prepare clean

main: dist/minesweeper.exe

prepare:
	@mkdir -p dist

dist/minesweeper.exe: dist/minesweeper.obj
	$(LINK) -SUBSYSTEM:CONSOLE $(LIBDIR) $(LIBS) -OUT:"dist/minesweeper.exe" dist/minesweeper.obj

dist/minesweeper.obj: src/minesweeper.asm src/board.asm src/data.asm src/disp.asm src/event.asm src/tasks.asm src/utils.asm
	$(ML) -c $(MLFLAGS) -I"/c/Irvine" -Fl"dist/minesweeper.lst" -Fo"dist/minesweeper.obj" src/minesweeper.asm

clean:
	@rm -f dist/*
