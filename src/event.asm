onGameOver PROC USES eax ebx edx
	call GetMseconds
	sub eax, startTime
	mov timeDelta, eax

	mov dx, 0B10h
	call Gotoxy

	mSetColor lightRed
	mov edx, OFFSET gameOverMsg
	call WriteString

	mov dx, 0C10h
	call Gotoxy

	mSetColor yellow
	mov edx, OFFSET playtimeMsg
	call WriteString

	mov eax, timeDelta
	xor edx, edx
	mov ebx, 1000
	div ebx
	call WriteDec

	mov al, 's'
	call WriteChar

	mSetColor cyan
	mov dx, 0D10h
	call Gotoxy

	mov edx, OFFSET exitOrRestartMsg
	call WriteString

	ret
onGameOver ENDP

onFirstBlood PROC
	; unimplemented!
	ret
onFirstBlood ENDP
