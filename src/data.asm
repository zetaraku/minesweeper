.data

	closed	EQU 00b
	opened	EQU 01b
	flagged	EQU 10b

	titleMsg1 BYTE	"|\ /| | |\  | |^^^  (^^ \  \ /  / |^^^ |^^^ |^^\ |^^^ |^^\  |", 0
	titleMsg2 BYTE	"| V | | | \ | |---   \   \  X  /  |--- |--- |--/ |--- |--/  |", 0
	titleMsg3 BYTE	"|   | | |  \| |___ \__)   \/ \/   |___ |___ |    |___ |  \  . @ MASM", 0
	titleMsg4 BYTE	"A game made of livers and sleeplessness. We present to you at 4 A.M. !", 0

	widthMsg			BYTE "Width: ", 0
	heightMsg			BYTE "Height: ", 0
	minesMsg			BYTE "Mine density: ", 0

	gameStatusMsg1		BYTE "Remaining Mines: ", 0
	gameStatusMsg2		BYTE "Tiles to Open: ", 0

	gameStartMsg		BYTE "GAME START!!!", 0
	gameOverMsg			BYTE "Game over!", 0
	gameWinMsg			BYTE "WTF! You Win?", 0
	playtimeMsg			BYTE "Play Time: ", 0

	exitOrRestartMsg	BYTE "Press [R] to Restart, or Press [Esc] to Exit", 0
	startMsg			BYTE "Use [^] [v] [<] [>] to adjust settings, then Press [ENTER] to Start!", 0

	max_w = 78
	max_h = 22
	max_fsize = max_w * max_h

	; variable

	w DWORD 20
	h DWORD 20
	fsize DWORD ?

	minesPercent DWORD 15
	minesCount DWORD ?

	nowX BYTE 0
	nowY BYTE 0

	selectedSetting BYTE 0

.data?

	flagsCount DWORD ?	; 0
	openCount DWORD ?	; 0

	field		BYTE max_fsize dup (?)	; 0
	tileState	BYTE max_fsize dup (?)	; 0
	tmpm		WORD max_fsize dup (?)

	processStack	WORD max_fsize dup (?)
	processStackCount		DWORD ?		; 0

	numOpenStack	WORD 8 dup (?)
	numStackCount	DWORD ?		; 0
	nFlagCounter	BYTE ?

	gameStarted BYTE ?	; 0
	gameover BYTE ?		; 0

	startTime DWORD ?
	timeDelta DWORD ?
