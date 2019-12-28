; trans (offset: ax) to (row: ah, col: al)
trXY PROC uses bx dx
	xor dx, dx
	mov bx, WORD PTR w
	div bx
	shl ax, 8
	mov al, dl
	ret
trXY ENDP

; trans (row: ah, col: al) to (offset: ax)
trN PROC uses bx dx
	movzx dx, al
	shr ax, 8
	mov bl, BYTE PTR w
	mul bl
	add ax, dx
	ret
trN ENDP

; set dl valid flag accroding to (row: ah, col: al) as 4-bit flags [udlr]
getNeighborValidFlag PROC uses eax
	; clear dl
	xor dl, dl

	; dl |= 1000b if row > 0
	cmp ah, 0
	ja nu
		or dl, 1000b
	nu:
	; dl |= 0100b if row < h-1
	inc ah
	cmp ah, BYTE PTR h
	jb nd
		or dl, 0100b
	nd:
	; dl |= 0010b if col > 0
	cmp al, 0
	ja nl
		or dl, 0010b
	nl:
	; dl |= 0001b if col < w-1
	inc al
	cmp al, BYTE PTR w
	jb nr
		or dl, 0001b
	nr:

	ret
getNeighborValidFlag ENDP

; increase mine number of a tile around (offset: ax), valid flag dl must be set properly
incNumber PROC uses ebx
	; ebx start from top-left tile
	sub ebx, w
	dec ebx

	test dl, 1010b
	jnz _1
		inc byte ptr [ebx]
	_1:
	inc ebx

	test dl, 1000b
	jnz _2
		inc byte ptr [ebx]
	_2:
	inc ebx

	test dl, 1001b
	jnz _3
		inc byte ptr [ebx]
	_3:
	sub ebx, 2
	add ebx, DWORD PTR w

	test dl, 0010b
	jnz _4
		inc byte ptr [ebx]
	_4:
	inc ebx

	_5:
	inc ebx

	test dl, 0001b
	jnz _6
		inc byte ptr [ebx]
	_6:
	sub ebx, 2
	add ebx, DWORD PTR w

	test dl, 0110b
	jnz _7
		inc byte ptr [ebx]
	_7:
	inc ebx

	test dl, 0100b
	jnz _8
		inc byte ptr [ebx]
	_8:
	inc ebx

	test dl, 0101b
	jnz _9
		inc byte ptr [ebx]
	_9:

	ret
incNumber ENDP
