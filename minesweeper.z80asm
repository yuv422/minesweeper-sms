;mine sweeper

.memorymap
defaultslot 0
slotsize $4000
slot 0 $0000
slotsize $4000
slot 1 $4000
slotsize $4000
slot 2 $8000 ; psgmod vibrato tables
slotsize $2000
slot 3 $c000 ; memory
.endme

;.memorymap
;defaultslot 0
;slotsize $2000
;slot 0 $0000
;slotsize $2000
;slot 1 $8000
;slotsize $4000
;slot 2 $8000 ; psgmod vibrato tables
;slotsize $2000
;slot 3 $c000 ; memory
;.endme

.rombankmap
bankstotal 4
banksize $4000
banks 1
banksize $4000
banks 1
banksize $4000
banks 1
banksize $4000
banks 1
.endro

.sdsctag 1.1, "Mine Sweeper","A simple mine sweeper game","Eric Fry"

.define VDPStatusPort $bf
.define VDPDataPort $be

.define floodFillFlag          %10000000
.define tileMask               %00001111
.define statusMask             %01110000
.define statusSetMask          %10001111

.define coveredTileStatus      %00000000
.define flaggedTileStatus      %00010000
.define questionMarkTileStatus %00100000
.define uncoveredTileStatus    %00110000

.define tileStartOffset 2
 
.define emptyTile 0
.define bombTile 9
.define hitBombTile $a
.define flaggedBombTile $e
.define questionMarkTile 1 
.define blankCoveredTile $33 
/*
.define pauseFlag $c000
.define vblankFlag $c001
; 400 bytes for a 20x20 game board
; each byte has the following structure 0nnnyyyy
; nnnn is one of the following
; 0 covered tile
; 1 flagged tile
; 2 question marked tile
; 3 uncovered tile
; 4 uncovered bomb!
; 
; yyyy is one of the following
; 0 empty tile
; 1 1 adjacent bomb
; 2 2 adjacent bombs
; 3 3 adjacent bombs
; 4 4 adjacent bombs
; 5 5 adjacent bombs
; 6 6 adjacent bombs
; 7 7 adjacent bombs
; 8 8 adjacent bombs
; 9 bomb tile

.define board $c002
.define boardEnd $c192
.define boardW $c193
.define boardH $c194
.define cursorX $c195
.define cursorY $c196
.define randSeed $c197 ;word
.define randValue $c199 ;word
.define numBombs $c19b
.define lastInputState $c19c
.define boardOffsetX $c19d
.define boardOffsetY $c19e
*/

.ramsection "RAM" slot 3
psgdata dsb $180
pauseFlag db 
vblankFlag db 
; 400 bytes for a 20x20 game board
; each byte has the following structure innnyyyy
; i is the floodfill flag. If set this tile has already been searched by the floodfill routine.
; nnn is one of the following
; 0 covered tile
; 1 flagged tile
; 2 question marked tile
; 3 uncovered tile
; 4 uncovered bomb!
; 
; yyyy is one of the following
; 0 empty tile
; 1 1 adjacent bomb
; 2 2 adjacent bombs
; 3 3 adjacent bombs
; 4 4 adjacent bombs
; 5 5 adjacent bombs
; 6 6 adjacent bombs
; 7 7 adjacent bombs
; 8 8 adjacent bombs
; 9 bomb tile

board dsb 20*20 
boardW db
boardH db
totalNumTiles dw ; boardW * boardH
cursorX db
cursorY db
randSeed dw
randValue dw
numBombs db
numTilesLeftToUncover dw ; number of tiles left to uncover to win the game in bcd format.
lastInputState db
boardOffsetX db
boardOffsetY db 
boardTileDisplayOffset dw ; (2*32+2)*2 + $3800
isPalTv db ; set to 1 for PAL, 0 for NTSC
frameRate db ; either 50 for PAL or 60 for NTSC
frameCounter db
elapsedTime dsb 3 ; bcd in seconds
moveCounter dw ; number of moves in bcd format.
gameFlags dw ; 
floodFillRows dsb 20
gameMode db ; 0 small board, 1 medium board and 2 large board.
faceUpdateCounter db ; used for blink animation
.ends

.define FLAG_MUSIC_PLAYING     1
.define FLAG_UPDATE_TILES_LEFT 2
.define FLAG_RETURN_TO_TITLE_SCREEN 4
.define FLAG_GAME_OVER 8

.define PSGMOD_START_ADDRESS $c000
.bank 0 slot 0

.org $0000
.section "boot" force
	di
	im 1
	jp main
.ends

;Interrupt handler
.org $38
push af
in a, (VDPStatusPort) ; acknowledge interrupt
ld a, 1
ld (vblankFlag), a
pop af
ei
reti

;Pause button NMI
.org $66
	push af
	ld a, (pauseFlag)
	xor 1 
	ld (pauseFlag), a
	cp 1
	jp z, +
	call PSGMOD_Start
	jp ++
+:
	call PSGMOD_Pause
++:
	pop af
retn

.bank 0 slot 0
.section "all" force
main:
	ld sp, $dff0
	ld b, 0
	ld c, 0
	ld (randSeed), bc

	xor a
	;ld a, :SampleMusic
	;ld ($ffff), a
	;ld ($ffff), a
	;inc a
	;ld ($fffe), a
	ld (gameFlags), a
	ld (gameFlags+1), a

	call DetectTVType
	ld (isPalTv), a
	ld b, 60 ; ntsc tv type
	or a
	jp z, +
	ld b, 50 ; pal tv type
+:
	ld a, b
	ld (frameRate), a

;Setup initial VDP register values
	ld hl, VdpInitData
	ld c, VDPStatusPort
	ld b, VdpInitDataEnd-VdpInitData
	otir

	call ClearVRAM
	ld a, 0
	ld (pauseFlag), a
	ld (vblankFlag), a

	ld hl, PsgModCallback
	call PSGMOD_SetCallbackFunction

	ld   a, :SampleMusic
	ld   hl, SampleMusic
	call PSGMOD_LoadModule
	ld a, (gameFlags)
	or FLAG_MUSIC_PLAYING
	or FLAG_UPDATE_TILES_LEFT
	ld (gameFlags), a
 
;-------

	ld hl,TitlePal
	ld b,(TitlePalEnd-TitlePal)
	call LoadPalette

	ld hl,TitleTileData              ; Location of tile data
	ld bc,TitleTileDataEnd-TitleTileData  ; Counter for number of bytes to write
	call LoadTiles

	ld hl,TitleTilemap
	ld bc,TitleTilemapEnd-TitleTilemap; Counter for number of bytes to write
	call LoadTilemap

;-------

	call ScreenOn

	ei

;titleloop
-:
	call WaitVblank
	ld bc, (randSeed)
	inc bc
	ld (randSeed), bc
	; any keypress on controller 1 or pause will start the game.
	in a, ($dc)
	xor $ff
	ld b, a
	ld a,(pauseFlag)
	or b
	jp z,-

	call SelectBoardSize

	call ScreenOff

	ld hl,PaletteData
	ld b,(PaletteDataEnd-PaletteData)
	call LoadPalette

	ld hl,GameTileData              ; Location of tile data
	ld bc,GameTileDataEnd-GameTileData  ; Counter for number of bytes to write
	call LoadTiles

	ld a, (gameMode)

	cp 0
	jp nz, +
		call LoadSmallGameBoard
		jp ++
+:
	cp 1
	jp nz, +
		call LoadMediumGameBoard
		jp ++
+:
	call LoadLargeGameBoard
++:

	xor a
	ld (faceUpdateCounter), a
	ld (pauseFlag), a
	call PSGMOD_Start
	ld a, (frameRate)
	ld (frameCounter), a
	ld hl, 0
	ld (elapsedTime), hl

	ld a, $ff
	ld (lastInputState), a

	call InitRand
	ld a, (gameMode) ; board size
	call InitBoard
;	call WaitVblank
	call DisplayTilesLeftDigits
	call InitCursor
	call InitFaceSprites

	call ScreenOn

gameloop:
	call WaitVblank
	ld a, (frameCounter)
	dec a
	or a 
	jp nz,+
	ld a, (gameFlags)
	and FLAG_GAME_OVER
	jp nz, ++
	; increment bcd elapsedTime var.
	ld hl, elapsedTime
	ld a, 1
	ld b, 0
	add a, (hl)
	daa
	ld (hl), a 
	ld c, a
	ld de, $3ab8
	call DisplayDigits
	inc hl
	ld a, b
	adc a, (hl)
	daa
	ld (hl), a 
	ld c, a
	ld de, $3ab4
	call DisplayDigits
	inc hl
	ld a, b
	adc a, (hl)
	daa
	ld (hl), a 
++:
	;FIXME update display here.
	ld a, (frameRate)
+:
	ld (frameCounter), a

	ld a, (gameFlags)
	and FLAG_RETURN_TO_TITLE_SCREEN
	jp nz, main ; restart game.

	call UpdateFace

	call ReadInput
	call PSGMOD_Play
	jp gameloop

WaitVblank:
	push af
	-:
	ld a, (vblankFlag)
	cp 1
	jp z, +
	halt
	jp -
	+:
	xor a
	ld (vblankFlag), a
	pop af
	ret

PauseMusic:
	push af
	ld a, 1
	ld (pauseFlag), a
	call PSGMOD_Pause
	pop af
ret

WaitForKeyPress:
	push af
-:
	call WaitVblank
	call PSGMOD_Play
	; any keypress on controller 1 
	in a, ($dc)
	xor $ff
	or a
	jp z,-
	pop af
	ret

WaitForAllKeysUp:
	push af
-:
	call WaitVblank
	call PSGMOD_Play
	; any keypress on controller 1 
	in a, ($dc)
	xor $ff
	or a
	jp nz,-
	pop af
	ret

;; Write zero to 16KB of VRAM
ClearVRAM:
	push af
	push bc
	ld a,$00
	out (VDPStatusPort),a
	ld a,$40
	out (VDPStatusPort),a
	; 2. Output 16KB of zeroes
	ld bc, $4000    ; Counter for 16KB of VRAM
	-:
		ld a,$00    ; Value to write
		out (VDPDataPort),a ; Output to VRAM address, which is auto-incremented after each write
		dec bc
		ld a,b
		or c
		jp nz,-

	pop bc
	pop af
	ret

;;Set palette
;hl palette address
;b palette size
;trashes bc
LoadPalette:
	push af
	push hl
	ld a,$00
	out (VDPStatusPort),a
	ld a,$c0
	out (VDPStatusPort),a
	; 2. Output colour data
	ld c,VDPDataPort
	otir
	pop hl
	pop af
	ret

SelectBoardSize:
	push af
	push bc
	push hl
	push de

	call ScreenOff
debughere:
;clear 13 tiles. The '>press start<' text.
	ld b, 13
	ld hl, $3c42
	ld de, 0
	call TileMapSetToTile

	ld b, 13
	ld hl, $3b86
	ld de, SelectBoardTextTilemap
	call TileMapSetTiles

	ld b, 7 
	ld hl, $3c04
	ld de, SmallTextTilemap
	call TileMapSetTiles

	ld b, 6 
	ld hl, $3c86
	ld de, MediumTextTilemap
	call TileMapSetTiles

	ld b, 5 
	ld hl, $3d06
	ld de, LargeTextTilemap
	call TileMapSetTiles

	ld a, 0
	ld (gameMode), a ; small

	call ScreenOn

	call WaitForAllKeysUp 

	call WaitForKeyPress

-:

	; any keypress on controller 1 
	in a, ($dc)
	ld b, a
	and %00000010 ;down
	jp nz,+
	call SelectBoardDown
	jp ++
+:
	ld a, b
	and %00000001 ; up
	jp nz,+
	call SelectBoardUp
	jp ++
+:
	ld a, b
	and %00010000 ; a button
	jp nz,++
	call WaitForAllKeysUp
	jp +++
++:
jp -

+++:
	pop de
	pop hl
	pop bc
	pop af
ret

;trashes af
SelectBoardDown:
	ld a, (gameMode)
	cp 2
	jp z, +

	inc a
	ld (gameMode), a
	call SelectBoardClearArrows
+:
	call WaitForAllKeysUp
ret

;trashes af
SelectBoardUp:
	ld a, (gameMode)
	cp 0
	jp z, +

	dec a
	ld (gameMode), a
	call SelectBoardClearArrows
+:
	call WaitForAllKeysUp
ret

SelectBoardClearArrows:
push hl
push bc
; clear existing arrows
ld bc, $0000
ld hl, $3c04
call WaitVblank
call TileMapSetTile
ld hl, $3c10
call TileMapSetTile

ld hl, $3c84
call TileMapSetTile
ld hl, $3c92
call TileMapSetTile

ld hl, $3d04
call TileMapSetTile
ld hl, $3d10
call TileMapSetTile

; set new arrows

	call WaitVblank
	ld a, (gameMode)

	cp 0
	jp nz, +
		ld bc, $006A
		ld hl, $3c04
		call TileMapSetTile
		ld bc, $026A
		ld hl, $3c10
		call TileMapSetTile
		jp ++
+:
	cp 1
	jp nz, +
		ld bc, $006A
		ld hl, $3c84
		call TileMapSetTile
		ld bc, $026A
		ld hl, $3c92
		call TileMapSetTile
		jp ++
+:
	ld bc, $006A
	ld hl, $3d04
	call TileMapSetTile
	ld bc, $026A
	ld hl, $3d10
	call TileMapSetTile

++:


pop bc
pop hl
ret


;hl tilemap start offset
;b  number of tiles
;de start of tile data to copy
TileMapSetTiles:
	push af
	push bc
	push de 

	ld a,l
	out (VDPStatusPort),a
	ld a,h
	or $40
	out (VDPStatusPort),a
	; 2. Output tilemap data
	sla b ; b = b * 2 as tilemap entries are words.
	-:
		ld a, (de)
		out (VDPDataPort),a
		inc de
		xor a
		dec b
		or b
	jp nz,-

	pop de 
	pop bc
	pop af
ret

;hl tilemap start offset
;b  number of tiles
;de tile data  
TileMapSetToTile:
	push af
	push bc

	ld a,l
	out (VDPStatusPort),a
	ld a,h
	or $40
	out (VDPStatusPort),a
	; 2. Output tilemap data
	-:
		ld a, e
		out (VDPDataPort),a
		ld a, d
		out (VDPDataPort),a
		xor a
		dec b
		or b
	jp nz,-

	pop bc
	pop af
ret

;hl tilemap start offset
;bc tile data 
TileMapSetTile:
	push af

	ld a,l
	out (VDPStatusPort),a
	ld a,h
	or $40
	out (VDPStatusPort),a
	ld a, c
	out (VDPDataPort),a
	ld a, b
	out (VDPDataPort),a

	pop af
ret

;trashes af, hl and bc
LoadSmallGameBoard:
	ld a, ($FFFF)
	push af
	ld   a, :BoardTilemapSml
	ld   ($FFFF), a

	ld hl,BoardTilemapSml
	ld bc,BoardTilemapSmlEnd-BoardTilemapSml; Counter for number of bytes to write
	call LoadTilemap

	pop af
	ld ($FFFF), a
ret

;trashes af, hl and bc
LoadMediumGameBoard:
	ld a, ($FFFF)
	push af
	ld   a, :BoardTilemapMed
	ld   ($FFFF), a

	ld hl,BoardTilemapMed
	ld bc,BoardTilemapMedEnd-BoardTilemapMed; Counter for number of bytes to write
	call LoadTilemap

	pop af
	ld ($FFFF), a
ret

;trashes af, hl and bc
LoadLargeGameBoard:
	ld a, ($FFFF)
	push af
	ld   a, :BoardTilemapLrg
	ld   ($FFFF), a

	ld hl,BoardTilemapLrg
	ld bc,BoardTilemapLrgEnd-BoardTilemapLrg; Counter for number of bytes to write
	call LoadTilemap

	pop af
	ld ($FFFF), a
ret

InitCursor:
	push af
	xor a
	ld (cursorX), a
	ld (cursorY), a

	ld a, $81
	out (VDPStatusPort),a
	ld a, $40|$3f
	out (VDPStatusPort),a
	ld a, $f; tile num
	out (VDPDataPort), a

	call UpdateCursorSpriteX
	call UpdateCursorSpriteY

	pop af
	ret

HideCursor:
	push af

	ld a, $81
	out (VDPStatusPort),a
	ld a, $40|$3f
	out (VDPStatusPort),a
	ld a, $0; tile num
	out (VDPDataPort), a

	pop af
	ret

InitFaceSprites:
	push af

; left eye
	ld a, $83
	out (VDPStatusPort),a
	ld a, $40|$3f
	out (VDPStatusPort),a
	ld a, $6d; tile num
	out (VDPDataPort), a

	ld a, $82
	out (VDPStatusPort),a
	ld a, $7f
	out (VDPStatusPort),a
	ld a, 206 
	out (VDPDataPort), a 

	ld a, 1 
	out (VDPStatusPort),a
	ld a, $7f
	out (VDPStatusPort),a
	ld a, 27 
	out (VDPDataPort), a 

; right eye
	ld a, $85
	out (VDPStatusPort),a
	ld a, $40|$3f
	out (VDPStatusPort),a
	ld a, $6d; tile num
	out (VDPDataPort), a

	ld a, $84
	out (VDPStatusPort),a
	ld a, $7f
	out (VDPStatusPort),a
	ld a, 219 
	out (VDPDataPort), a 

	ld a, 2 
	out (VDPStatusPort),a
	ld a, $7f
	out (VDPStatusPort),a
	ld a, 27 
	out (VDPDataPort), a 


; mouth
	ld a, $87
	out (VDPStatusPort),a
	ld a, $40|$3f
	out (VDPStatusPort),a
	ld a, $71; tile num
	out (VDPDataPort), a

	ld a, $86
	out (VDPStatusPort),a
	ld a, $7f
	out (VDPStatusPort),a
	ld a, 212 
	out (VDPDataPort), a 

	ld a, 3 
	out (VDPStatusPort),a
	ld a, $7f
	out (VDPStatusPort),a
	ld a, 39 
	out (VDPDataPort), a 

	pop af

	ret

DeathFace:
	push af

; left eye
	ld a, $83
	out (VDPStatusPort),a
	ld a, $40|$3f
	out (VDPStatusPort),a
	ld a, $73; tile num
	out (VDPDataPort), a

	ld a, $82 ; return to straight pos X
	out (VDPStatusPort),a
	ld a, $7f
	out (VDPStatusPort),a
	ld a, 206 
	out (VDPDataPort), a 

; right eye
	ld a, $85
	out (VDPStatusPort),a
	ld a, $40|$3f
	out (VDPStatusPort),a
	ld a, $73; tile num
	out (VDPDataPort), a

	ld a, $84 ; return to straight pos X
	out (VDPStatusPort),a
	ld a, $7f
	out (VDPStatusPort),a
	ld a, 219 
	out (VDPDataPort), a 

; mouth
	ld a, $87
	out (VDPStatusPort),a
	ld a, $40|$3f
	out (VDPStatusPort),a
	ld a, $72; tile num
	out (VDPDataPort), a

	ld a, $86 ; return to straight pos X
	out (VDPStatusPort),a
	ld a, $7f
	out (VDPStatusPort),a
	ld a, 212 
	out (VDPDataPort), a 


	pop af
	ret

UpdateFace:
	push af
	ld a, (faceUpdateCounter)
	cp 0
	jp z, +
		push hl
		push bc
		ld hl, faceBlinkAnim
		ld b, 0
		ld c, a
		add hl, bc
		ld b, (hl)

		dec a
		ld (faceUpdateCounter), a

		; left eye
		ld a, $83
		out (VDPStatusPort),a
		ld a, $40|$3f
		out (VDPStatusPort),a
		ld a, b
		out (VDPDataPort), a

		; right eye
		ld a, $85
		out (VDPStatusPort),a
		ld a, $40|$3f
		out (VDPStatusPort),a
		ld a, b
		out (VDPDataPort), a

		pop bc 
		pop hl
		pop af
		ret
+:
	; update face here.
	call GetRandomNumber
	and %11111
	jp nz, +++
	call GetRandomNumber
	and %11
	; update face here.
	cp 0
	jp nz, +
		;look left
		ld a, $82
		out (VDPStatusPort),a
		ld a, $7f
		out (VDPStatusPort),a
		ld a, 202 
		out (VDPDataPort), a 

		ld a, $84
		out (VDPStatusPort),a
		ld a, $7f
		out (VDPStatusPort),a
		ld a, 215 
		out (VDPDataPort), a 

		ld a, $86
		out (VDPStatusPort),a
		ld a, $7f
		out (VDPStatusPort),a
		ld a, 210 
		out (VDPDataPort), a 

		jp ++
+:
	cp 1
	jp nz, +
; look straight 
		ld a, $82
		out (VDPStatusPort),a
		ld a, $7f
		out (VDPStatusPort),a
		ld a, 206 
		out (VDPDataPort), a 

		ld a, $84
		out (VDPStatusPort),a
		ld a, $7f
		out (VDPStatusPort),a
		ld a, 219 
		out (VDPDataPort), a 

		ld a, $86
		out (VDPStatusPort),a
		ld a, $7f
		out (VDPStatusPort),a
		ld a, 212 
		out (VDPDataPort), a 

		jp ++
+:
	cp 2
	jp nz, +
; look right 
		ld a, $82
		out (VDPStatusPort),a
		ld a, $7f
		out (VDPStatusPort),a
		ld a, 210 
		out (VDPDataPort), a 

		ld a, $84
		out (VDPStatusPort),a
		ld a, $7f
		out (VDPStatusPort),a
		ld a, 223 
		out (VDPDataPort), a

		ld a, $86
		out (VDPStatusPort),a
		ld a, $7f
		out (VDPStatusPort),a
		ld a, 214 
		out (VDPDataPort), a 

		jp ++
+:
; blink
	ld a, 25
	ld (faceUpdateCounter), a
++:

+++:
	pop af
ret

ReadInput:
	push af
	push bc
	in a, ($dc)
	ld b, a
	and %00001000 
	jp nz,+
	ld a, (lastInputState)
	and %00001000 ; right button
	jp z,+ ; button still pressed so ignore.
	call MoveCursorRight
+:
	ld a, b
	and %00000100 
	jp nz,+
	ld a, (lastInputState)
	and %00000100 ; left button
	jp z,+ ; button still pressed so ignore.
	call MoveCursorLeft
+:
	ld a, b
	and %00000010 
	jp nz,+
	ld a, (lastInputState)
	and %00000010 ; down button
	jp z,+ ; button still pressed so ignore.
	call MoveCursorDown
+:
	ld a, b
	and %00000001 
	jp nz,+
	ld a, (lastInputState)
	and %00000001 ; up button
	jp z,+ ; button still pressed so ignore.
	call MoveCursorUp
+:
	ld a, b
	and %00010000 
	jp nz,+
	ld a, (lastInputState)
	and %00010000 ; a button
	jp z,+ ; button still pressed so ignore.
	call UncoverBoardAtCursor
+:
	ld a, b
	and %00100000 
	jp nz,+
	ld a, (lastInputState)
	and %00100000 ; b button
	jp z,+ ; button still pressed so ignore.
	call MarkBoardAtCursor

+:
	ld a, b
	ld (lastInputState), a
	pop bc
	pop af
	ret

MoveCursorRight:
	push af
	push hl
	ld a, (boardW)
	ld h, a
	ld a, (cursorX)
	inc a
	cp h
	jp z,+
	ld (cursorX), a
	call UpdateCursorSpriteX
+:
	pop hl
	pop af
	ret

MoveCursorLeft:
	push af
	ld a, (cursorX)
	cp 0
	jp z,+
	dec a ; only update if cursorX > 0
	ld (cursorX), a
	call UpdateCursorSpriteX
+:
	pop af
	ret

MoveCursorDown:
	push af
	push hl
	ld a, (boardH)
	ld h, a
	ld a, (cursorY)
	inc a
	cp h
	jp z,+
	ld (cursorY), a ; only update if cursorY < boardH - 1 
	call UpdateCursorSpriteY
+:
	pop hl
	pop af
	ret

MoveCursorUp:
	push af
	ld a, (cursorY)
	cp 0
	jp z, +
	dec a
	ld (cursorY), a
	call UpdateCursorSpriteY
+:
	pop af
	ret

UpdateCursorSpriteX:
	push af
	push hl
	ld a, $80
	out (VDPStatusPort),a
	ld a, $7f
	out (VDPStatusPort),a

	ld a, (cursorX)
	ld h, a
	sla h
	sla h
	sla h
	ld a, (boardOffsetX)
	add a, h

	out (VDPDataPort), a ; a = cursorX * 8 + boardOffsetX
	pop hl
	pop af
	ret

UpdateCursorSpriteY:
	push af
	push hl
	xor a
	out (VDPStatusPort),a
	ld a, $7f
	out (VDPStatusPort),a

	ld a, (cursorY)
	ld h, a
	sla h
	sla h
	sla h
	ld a, (boardOffsetY)
	add a, h

	out (VDPDataPort), a ; a = cursorY * 8 + boardOffsetY
	pop hl
	pop af
	ret

UncoverBoardAtCursor:
	push af
	push hl
	push bc
	call GetBoardIndexAtCursor
	push hl
	ld bc, board
	add hl, bc
	ld a, (hl)
	and statusSetMask
	or uncoveredTileStatus
	ld (hl), a
	and tileMask
	cp bombTile
	jp nz,+
	call HitBomb
	jp ++
+:
	cp emptyTile
	jp nz, +
	;empty tile. mark the current row to be scanned and call the floodfill logic.
	ld hl, floodFillRows
	ld b, 0
	ld a, (cursorY)
	ld c, a
	add hl, bc
	ld (hl), 1
	call UncoverEmptyTilesWithFloodFill
+: 
	call DecTilesLeftCounter ; if we didn't uncover a bomb then decrement the remaining uncovered tile count.
	call CheckForWin
++:
	pop hl
	call DisplayBoardTile
	call DisplayTilesLeftDigits
	pop bc
	pop hl
	pop af
	ret

DecTilesLeftCounter:
	push hl
	push af
	ld hl, numTilesLeftToUncover
	ld a, (hl)
	dec a
	daa
	ld (hl), a
	inc hl
	ld a, (hl)
	sbc a, 0
	daa
	ld (hl), a
	ld a, (gameFlags) ; set update flag
	or FLAG_UPDATE_TILES_LEFT
	ld (gameFlags), a
	pop af
	pop hl
	ret

DisplayTilesLeftDigits:
	push af
	push bc
	push de
	ld a, (numTilesLeftToUncover)
	ld c, a
	ld de, $3bf8
	call DisplayDigits
	ld a, (numTilesLeftToUncover+1)
	ld c, a
	ld de, $3bf4
	call DisplayDigits
	ld a, (gameFlags) ; unset update flag
	xor FLAG_UPDATE_TILES_LEFT
	ld (gameFlags), a
	pop de
	pop bc
	pop af
	ret

CheckForWin:
	push hl
	push af
	ld hl, (numTilesLeftToUncover)
	ld a, h
	or l
	jp nz, +
	; The game has been won. no tiles are left to be uncovered
	;FIXME do something here.
	call WaitVblank
	call DisplayTilesLeftDigits
	call HideCursor
	call DisplayAllTiles
	ld a, (gameFlags)
	or FLAG_RETURN_TO_TITLE_SCREEN
	or FLAG_GAME_OVER
	ld (gameFlags), a

	call WaitForKeyPress
	call PauseMusic
+:
	pop af
	pop hl
	ret

HitBomb:
	push af
	ld a, hitBombTile
	or uncoveredTileStatus
	ld (hl), a

	ld a, (gameFlags)
	or FLAG_GAME_OVER
	ld (gameFlags), a

	call PauseMusic
	call HideCursor
	call DeathFace
	call DisplayAllTiles

	call WaitForKeyPress

	ld a, (gameFlags)
	or FLAG_RETURN_TO_TITLE_SCREEN
	ld (gameFlags), a

	pop af
	ret

MarkBoardAtCursor:
	push af
	push hl
	push bc
	call GetBoardIndexAtCursor
	push hl ; board index
	ld bc, board
	add hl, bc
	ld a, (hl)
	and statusMask 
	cp uncoveredTileStatus 
	jp m,+ 
	jp ++ ; if status >= uncoveredTileStatus then return as tile is already unconvered.
	+:
	cp flaggedTileStatus
	jp nz, +
		ld a, (hl)
		and tileMask
		or questionMarkTileStatus
		ld (hl), a
		jp ++
	+:
	cp questionMarkTileStatus 
	jp nz, +
		ld a, (hl)
		and tileMask
		or coveredTileStatus
		ld (hl), a
		jp ++
	+:
	cp coveredTileStatus 
	jp nz, ++
		ld a, (hl)
		and tileMask
		or flaggedTileStatus
		ld (hl), a
++:
	pop hl
	call DisplayBoardTile
	pop bc
	pop hl
	pop af
	ret

;returns the index of the current cursor position in hl
GetBoardIndexAtCursor:
	push af
	push de
	ld a, (cursorY)
	ld h, a
	ld a, (boardW)
	ld e, a
	call mul
	ld d, 0
	ld a, (cursorX)
	ld e, a
	add hl, de
	pop de
	pop af
	ret

;;Initialise the game board
;;reg a=board size index
InitBoard:
	push bc
	push hl
	push af
	push de
	ld h, a
	ld a, boardInitDataSize
	ld e, a
	call mul
	ld de, BoardInitData
	add hl, de

	ld a, (hl)
	ld (boardW), a
	inc hl
	ld a, (hl)
	ld (boardH), a
	inc hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld (totalNumTiles), de ; boardW * boardH
	inc hl
	
	ld a, (hl)
	ld (numBombs), a
	inc hl
	ld a, (hl)
	ld (boardOffsetX), a
	inc hl
	ld a, (hl)
	ld (boardOffsetY), a
	inc hl

	ld c, (hl)
	inc hl
	ld b, (hl)
	ld (boardTileDisplayOffset), bc

	;zero game board
	ld bc, (totalNumTiles)
	ld hl, board
-:
	ld (hl), 0
	dec bc
	inc hl
	ld a, b
	or c
	jp nz, -
	;;place bombs on the board
	ld a, (numBombs)
	ld d, a
-:

  -: ; get a random number between 0 and $18f FIXME need to handle non 20*20 game boards.
	call GetRandomNumber
	and 1
	ld b, a
	call GetRandomNumber
	ld c, a
	ld a, b
	or a
	jp z,+
	ld a, c
	cp $8f
	jp c,+
	jp -
	+:

	ld hl, (totalNumTiles)
	dec hl
	and a ; clear carry flag
	sbc hl, bc
	jp c, + ; if(totalNumTiles-1<bc) continue; 
	ld hl, board
	add hl, bc
	ld a, (hl) ;check to make sure there isn't a bomb on this tile already.
	cp 0
	jp nz,+
	ld (hl), bombTile 
	;pop bc
	dec d
+:
	ld a, d
	or a
	jp nz,-

;setup adjacent bomb counts
	ld bc, (totalNumTiles) 
	ld hl, board
-:
	dec bc
	push hl
	add hl, bc
	ld a, (hl)
	pop hl
	cp bombTile
	jp z,+
	call SetupAdjBombCounters
+:
	ld a, b
	or c
	jp nz, -

;numTilesLeftToUncover = totalNumTiles - numBombs
	ld hl, (totalNumTiles)
	xor a
	ld b, a
	ld a, (numBombs)
	ld c, a
	sbc hl, bc
	call Bin2Bcd
	ld (numTilesLeftToUncover), hl

;clear floodfill row scan data
	ld a, (boardH)
	ld hl, floodFillRows
	call ClearRAM

	pop de
	pop af
	pop hl
	pop bc
	ret

; zeros out A bytes of ram starting at HL
; A = number of bytes to clear
; HL = start address
; trashes af, hl 
ClearRAM:
-:
	ld (hl), 0
	inc hl
	dec a
	jp nz,-
ret

;bc = boardIndex.
;hl = board
;trashed, a
SetupAdjBombCounters:
	push de 
	push hl
	ld a, 0
	call CheckForBombNW
	add a, d 
	call CheckForBombN
	add a, d 
	call CheckForBombNE
	add a, d 
	call CheckForBombE
	add a, d 
	call CheckForBombSE
	add a, d 
	call CheckForBombS
	add a, d 
	call CheckForBombSW
	add a, d 
	call CheckForBombW
	add a, d 

	add hl, bc
	ld (hl), a
	pop hl
	pop de
	ret

;returns 1 in d if a bomb is found. otherwise returns 0 in d.
CheckForBombNW:
	push af 
	push hl

	push bc
	push bc
	pop hl
	ld d, 0
	ld a, (boardW)
	ld c, a
	call div
	pop bc ;index
	or a
	jp z,+ ; return if in first column. index % boardW == 0
	ld a, h
	or l
	jp z,+ ; return if in first row. index / boardW == 0
	
	;check for bomb tile here.
	ld hl, board
	add hl, bc
	xor a
	ld d, a
	ld a, (boardW)
	inc a
	ld e, a 
	sbc hl, de

	ld d, (hl) ; check for bomb
	
+:
	ld a, d
	ld d, 0
	cp bombTile
	jp nz,+
	ld d, 1
+:
	pop hl
	pop af 
	ret

;returns 1 in d if a bomb is found. otherwise returns 0 in d.
CheckForBombN:
	push af 
	push hl

	push bc
	push bc
	pop hl
	ld d, 0
	ld a, (boardW)
	ld c, a
	call div
	pop bc ;index
	ld a, h
	or l
	jp z,+ ; return if in first row. index / boardW == 0
	
	;check for bomb tile here.
	ld hl, board
	add hl, bc
	xor a
	ld d, a
	ld a, (boardW)
	ld e, a 
	sbc hl, de

	ld d, (hl) ; check for bomb
	
+:
	ld a, d
	ld d, 0
	cp bombTile
	jp nz,+
	ld d, 1
+:
	pop hl
	pop af 
	ret

;returns 1 in d if a bomb is found. otherwise returns 0 in d.
CheckForBombNE:
	push af 
	push hl

	push bc
	push bc
	pop hl
	ld d, 0
	ld a, (boardW)
	ld c, a
	call div
	pop bc ;index
	ld e, a
	ld a, (boardW)
	dec a
	cp e 
	jp z,+ ; return if in last column. index % boardW == 0
	ld a, h
	or l
	jp z,+ ; return if in first row. index / boardW == 0
	
	;check for bomb tile here.
	ld hl, board
	add hl, bc
	xor a
	ld d, a
	ld a, (boardW)
	dec a
	ld e, a 
	sbc hl, de

	ld d, (hl) ; check for bomb
	
+:
	ld a, d
	ld d, 0
	cp bombTile
	jp nz,+
	ld d, 1
+:
	pop hl
	pop af 
	ret

;returns 1 in d if a bomb is found. otherwise returns 0 in d.
CheckForBombE:
	push af 
	push hl

	push bc
	push bc
	pop hl
	ld d, 0
	ld a, (boardW)
	ld c, a
	call div
	pop bc ;index
	ld e, a
	ld a, (boardW)
	dec a
	cp e 
	jp z,+ ; return if in last column. index % boardW == 0
	
	;check for bomb tile here.
	ld hl, board
	add hl, bc
	inc hl

	ld d, (hl) ; check for bomb
	
+:
	ld a, d
	ld d, 0
	cp bombTile
	jp nz,+
	ld d, 1
+:
	pop hl
	pop af 
	ret

;returns 1 in d if a bomb is found. otherwise returns 0 in d.
CheckForBombSE:
	push af 
	push hl

	push bc
	push bc
	pop hl
	ld d, 0
	ld a, (boardW)
	ld c, a
	call div
	pop bc ;index
	ld e, a
	ld a, (boardW)
	dec a
	cp e 
	jp z,+ ; return if in last column. index % boardW == 0
	ld a, (boardH)
	dec a
	ld e, l
	cp l
	jp z,+ ; return if in last row. index / boardW == boardH - 1 
	
	;check for bomb tile here.
	ld hl, board
	add hl, bc
	xor a
	ld d, a
	ld a, (boardW)
	inc a
	ld e, a 
	add hl, de

	ld d, (hl) ; check for bomb
	
+:
	ld a, d
	ld d, 0
	cp bombTile
	jp nz,+
	ld d, 1
+:
	pop hl
	pop af 
	ret


;returns 1 in d if a bomb is found. otherwise returns 0 in d.
CheckForBombS:
	push af 
	push hl

	push bc
	push bc
	pop hl
	ld d, 0
	ld a, (boardW)
	ld c, a
	call div
	pop bc ;index
	ld a, (boardH)
	dec a
	ld e, l
	cp l
	jp z,+ ; return if in last row. index / boardW == boardH - 1
	
	;check for bomb tile here.
	ld hl, board
	add hl, bc
	xor a
	ld d, a
	ld a, (boardW)
	ld e, a 
	add hl, de

	ld d, (hl) ; check for bomb
	
+:
	ld a, d
	ld d, 0
	cp bombTile
	jp nz,+
	ld d, 1
+:
	pop hl
	pop af 
	ret

;returns 1 in d if a bomb is found. otherwise returns 0 in d.
CheckForBombSW:
	push af 
	push hl

	push bc
	push bc
	pop hl
	ld d, 0
	ld a, (boardW)
	ld c, a
	call div
	pop bc ;index
	or a
	jp z,+ ; return if in first column. index % boardW == 0
	ld a, (boardH)
	dec a
	ld e, l
	cp l
	jp z,+ ; return if in last row. index / boardW == boardH - 1
	
	;check for bomb tile here.
	ld hl, board
	add hl, bc
	xor a
	ld d, a
	ld a, (boardW)
	dec a
	ld e, a 
	add hl, de

	ld d, (hl) ; check for bomb
	
+:
	ld a, d
	ld d, 0
	cp bombTile
	jp nz,+
	ld d, 1
+:
	pop hl
	pop af 
	ret

;returns 1 in d if a bomb is found. otherwise returns 0 in d.
CheckForBombW:
	push af 
	push hl

	push bc
	push bc
	pop hl
	ld d, 0
	ld a, (boardW)
	ld c, a
	call div
	pop bc ;index
	or a
	jp z,+ ; return if in first column. index % boardW == 0

	;check for bomb tile here.
	ld hl, board
	add hl, bc
	dec hl

	ld d, (hl) ; check for bomb
	
+:
	ld a, d
	ld d, 0
	cp bombTile
	jp nz,+
	ld d, 1
+:
	pop hl
	pop af 
	ret

InitRand:
	push bc
	ld bc, (randSeed)
	ld (randValue), bc
	pop bc
	ret
/*
RandValue:
; bc = randValue = randValue ^ $beef 
	push hl
	push af
	ld hl, (randValue)
	ld a, $be
	xor h
	rra
	ld b, a
	ld a, $ef
	xor l
	rla
	ld c, a
	inc bc
	ld (randValue), bc
	pop af
	pop hl
	ret
*/
GetRandomNumber:
; Uses a 16-bit RAM variable called RandomNumberGeneratorWord
; Returns an 8-bit pseudo-random number in a
    push hl
        ld hl,(randValue)
        ld a,h         ; get high byte
        rrca           ; rotate right by 2
        rrca
        xor h          ; xor with original
        rrca           ; rotate right by 1
        xor l          ; xor with low byte
        rrca           ; rotate right by 4
        rrca
        rrca
        rrca
        xor l          ; xor again
        rra            ; rotate right by 1 through carry
        adc hl,hl      ; add RandomNumberGeneratorWord to itself
        jr nz,+
        ld hl,$733c    ; if last xor resulted in zero then re-seed random number generator
+:      ld a,r         ; r = refresh register = semi-random number
        xor l          ; xor with l which is fairly random
        ld (randValue),hl
    pop hl
    ret                ; return random number in a

DisplayAllTiles:
	push hl
	push bc
	push af
	ld bc, (totalNumTiles) 
-:
	ld hl, 0
	add hl, bc 
	dec hl
	call BoardSetUncoveredStatus
	call DisplayBoardTile

	dec bc
	ld a,b
	or c
	jp nz,-

	pop af
	pop bc
	pop hl
	ret

BoardSetUncoveredStatus:
; hl = board index
	push af
	push hl
	push bc
	ld bc, board
	add hl, bc
	ld a, (hl)
	and tileMask
	or uncoveredTileStatus
	ld (hl), a
	pop bc
	pop hl
	pop af 
	ret

DisplayBoardTile:
; hl = boardIndex
	push af
	push de
	push bc
	push hl
	ld a, (boardW)
	ld c, a
	call div

	push af ; boardIndex % boardW
	ld e, 32*2 ; screen width 
	ld a, l
	ld h, a
	call mul ; hl = (boardIndex / boardW) * 32
	pop af 
	sla a ; a * 2
	ld c, a
	ld a, 0
	ld b, a
	add hl, bc ; hl += boardIndex % boardW
	ld bc, (boardTileDisplayOffset) ;(2*32+2)*2 + $3800 
	add hl, bc ; board start offset.

	call WaitVblank

	ld a, l
	out (VDPStatusPort),a
	ld a, h
	or $40
	out (VDPStatusPort),a
	pop bc ; boardIndex
	ld hl,board
	add hl, bc

	ld a, (hl)    ; Get data byte
	and statusMask
	cp uncoveredTileStatus
	jp nz,+
		ld a, (hl)
		and tileMask
		add a, tileStartOffset ; 2 = tile start offset.
		jp ++
	+:
	cp flaggedTileStatus
	jp nz,+
		ld a, flaggedBombTile 
		jp ++
	+:
	cp questionMarkTileStatus
	jp nz,+
		ld a, questionMarkTile 
		jp ++
	+:
		ld a, blankCoveredTile 
	++:
	out (VDPDataPort),a
	xor a
	out (VDPDataPort),a

	call PSGMOD_Play

	pop bc
	pop de
	pop af
	ret

;digit in c, tilemap location in de
;trashes a,de,hl
DisplayDigits:
	push af
	push hl
	push bc
	push de
	ld a, e
	out (VDPStatusPort),a
	ld a, d
	or $40
	out (VDPStatusPort),a
	ld a, c
	and $f0 
	rrca ; only rotate 3 because we want c * 2
	rrca
	rrca
;	rrca
	ld b, a
	ld d, 0 
;	rlc a ;a = a * 2
	ld e, a
	ld hl, NumberTilemapTop
	add hl, de
	ld a, (hl)
	out (VDPDataPort),a
	inc hl
	ld a, (hl) 
	out (VDPDataPort),a
	ld a, c
	and $0f 
;	ld d, 0 
	rlc a ;a = a * 2
	ld c, a
	ld e, a
	ld hl, NumberTilemapTop
	add hl, de
	ld a, (hl)
	out (VDPDataPort),a
	inc hl
	ld a, (hl) 
	out (VDPDataPort),a

	pop hl
	ld e, 32*2
	add hl, de
	ld a, l
	out (VDPStatusPort),a
	ld a, h
	or $40
	out (VDPStatusPort),a
	ld a, b

	ld e, a
	ld hl, NumberTilemapBottom
	add hl, de
	ld a, (hl)
	out (VDPDataPort),a
	inc hl
	ld a, (hl) 
	out (VDPDataPort),a

	ld e, c
	ld hl, NumberTilemapBottom
	add hl, de
	ld a, (hl)
	out (VDPDataPort),a
	inc hl
	ld a, (hl) 
	out (VDPDataPort),a

	pop bc
	pop hl
	pop af
ret

;returns number of rows processed in A
UncoverEmptyTilesWithFloodFill:
	push af
-:
	call FFScanRows ; loop until no more rows are scanned.
	or a
	jp nz,-
	pop af
ret

; returns a number > 0 in A if rows were scanned.
FFScanRows:
	push bc
	push hl
	ld b, 0 ;
	ld a, (boardH)
	ld c, a
	ld hl, floodFillRows
	add hl, bc
-:
	dec hl
	ld a, (hl)
	ld (hl), 0 ; reset row scan flag
	or a
	call nz, FFScanRow
	add a, b
	ld b, a
	dec c
	jp nz,-

	ld a, b
	pop hl
	pop bc
ret

;row to scan in C
FFScanRow:
	push af
	push bc
	push de
	push hl
	dec c
	ld b, 0
	ld a, (boardW)
	ld h, a
	ld e, c
	call mul ; hl = boardW * rownumber
	ld de, board
	add hl, de
	
-:
	ld a, (hl)
	and floodFillFlag
	jp nz,+ ;floodfill flag set so we continue with next tile
		;flood fill flag not set so we'll try to scan this tile
		ld a, (hl)
		and tileMask
		cp emptyTile
		jp nz,+ ; we're looking for empty tiles
			ld a, (hl)
			and statusMask
			cp uncoveredTileStatus
			jp nz,+ ; tile not uncovered so we continue with next tile.
				; we've got an uncovered tile. Lets scan it.

				;FIXME scan here.
				call FFScanNorth
				call FFScanNorthEast
				call FFScanEast
				call FFScanSouth
				call FFScanSouthEast
				call FFScanSouthWest
				call FFScanWest
				call FFScanNorthWest

				ld a, (hl)
				or floodFillFlag
				ld (hl), a ; set the floodfillflag to show that we've scanned this tile.
+:
	inc hl
	inc b
	ld a, (boardW)
	cp b
	jp nz, -

	pop hl
	pop de
	pop bc
	pop af
ret

;B = x
;C = y
;HL = address of the tile in board memory
FFScanEast:
	push af
	push hl
	push bc 
	ld a, (boardW)
	dec a
	cp b
	jp z,+
	inc b
	call FFGetBoardIndex
	call FFScanTile 
+:
	pop bc 
	pop hl
	pop af
ret

;B = x
;C = y
;HL = address of the tile in board memory
FFScanSouth:
	push af
	push hl
	push bc
	ld a, (boardH)
	dec a
	cp c
	jp z,++
	inc c
	call FFGetBoardIndex
	call FFScanTile
	++:
	pop bc
	pop hl
	pop af
ret

;B = x
;C = y
;HL = address of the tile in board memory
FFScanSouthEast:
	push af
	push hl
	push bc
	ld a, (boardH)
	dec a
	cp c
	jp z,++
	inc c
	ld a, (boardW)
	dec a
	cp b
	jp z,++
	inc b
	call FFGetBoardIndex
	call FFScanTile
	++:
	pop bc
	pop hl
	pop af
ret

;B = x
;C = y
;HL = address of the tile in board memory
FFScanSouthWest:
	push af
	push hl
	push bc
	ld a, (boardH)
	dec a
	cp c
	jp z,++
	inc c
	ld a, b
	cp 0
	jp z,++
	dec b
	call FFGetBoardIndex
	call FFScanTile
	++:
	pop bc
	pop hl
	pop af
ret

;B = x
;C = y
;HL = address of the tile in board memory
FFScanWest:
	push af
	push hl
	push bc
	ld a, b
	cp 0
	jp z,++
	dec b
	call FFGetBoardIndex
	call FFScanTile
	++:
	pop bc
	pop hl
	pop af
ret

;B = x
;C = y
;HL = address of the tile in board memory
FFScanNorthWest:
	push af
	push hl
	push bc
	ld a, c
	cp 0
	jp z,++
	dec c
	ld a, b
	cp 0
	jp z,++
	dec b
	call FFGetBoardIndex
	call FFScanTile
	++:
	pop bc
	pop hl
	pop af
ret

;B = x
;C = y
;HL = address of the tile in board memory
FFScanNorth:
	push af
	push hl
	push bc
	ld a, c
	cp 0
	jp z,++
	dec c
	call FFGetBoardIndex
	call FFScanTile
	++:
	pop bc
	pop hl
	pop af
ret

;B = x
;C = y
;HL = address of the tile in board memory
FFScanNorthEast:
	push af
	push hl
	push bc
	ld a, c
	cp 0
	jp z,++
	dec c
	ld a, (boardW)
	dec a
	cp b
	jp z,++
	inc b
	call FFGetBoardIndex
	call FFScanTile
	++:
	pop bc
	pop hl
	pop af
ret

;returns the board index in hl
; B = x
; C = y
FFGetBoardIndex:
	push af
	push de
	ld h, c
	ld a, (boardW)
	ld e, a
	call mul
	ld d, 0
	ld e, b
	add hl, de
	pop de
	pop af
	ret

; HL = tileIndex
FFScanTile:
	push de
	push hl
	ld de, board
	add hl, de
	ld a, (hl)
	and statusMask 
	cp uncoveredTileStatus
	jp z,++ ; skip tile if it's already uncovered.
		ld a, (hl)
		and statusSetMask 
		or uncoveredTileStatus
		ld (hl), a
		and tileMask
		cp emptyTile
		jp nz, +
			call FFSetRowScanFlag
		+:
		call DecTilesLeftCounter
		pop hl ; board index
		call DisplayBoardTile
		call DisplayTilesLeftDigits
		jp +++
++:
	pop hl
+++:
	pop de
	ret

FFSetRowScanFlag:
	push hl
	push bc
	ld hl, floodFillRows
	ld b, 0
	add hl, bc
	ld (hl), 1
	pop bc
	pop hl
ret

PsgModCallback:
	ret

;.bank 0
;.section "division_code" free
;16/8 division
;http://wikiti.brandonw.net/index.php?title=Z80_Routines:Math:Division
;The following routine divides hl by c and places the quotient in hl and the remainder in a
div:
    push   bc

    xor    a
    ld     b,16

-:  add    hl,hl
    rla
    cp     c
    jp     c,+
    sub    c
    inc    l

+:  djnz   -

    pop    bc

    ret
;.ends

;hl = h * e
mul:
    push   bc
    push   de

    ld     l,0
    ld     d,l

    ld     b,8

-:  add    hl,hl
    jp     nc,+
    add    hl,de
+:  djnz   -

    pop    de
    pop    bc
    ret

;;--------------------------------------------------
;; Binary to BCD conversion
;;
;; Converts a 16-bit unsigned integer into a 6-digit
;; BCD number. 1181 Tcycles
;;
;; input: HL = unsigned integer to convert
;; output: C:HL = 6-digit BCD number
;; destroys: A,F,B,C,D,E,H,L
;;--------------------------------------------------
Bin2Bcd:
	ld bc, 16*256+0 ; handle 16 bits, one bit per iteration
	ld de, 0
-:
	add hl, hl
	ld a, e
	adc a, a
	daa
	ld e, a
	ld a, d
	adc a, a
	daa
	ld d, a
	ld a, c
	adc a, a
	daa
	ld c, a
	djnz - 
	ex de, hl
ret


DetectTVType:
; Returns a=0 for NTSC, a=1 for PAL
; uses a, hl, de
    di             ; disable interrupts
    ld a,%01100000 ; set VDP such that the screen is on
    out ($bf),a    ; with VBlank interrupts enabled
    ld a,$81
    out ($bf),a
    ld hl,$0000    ; init counter
-:  in a,($bf)     ; get VDP status
    or a           ; inspect
    jp p,-         ; loop until frame interrupt flag is set
-:  in a,($bf)     ; do the same again, in case we were unlucky and came in just
    or a           ;   before the start of the VBlank with the flag already set
    jp p,-
    ; the VDP must now be at the start of the VBlank
-:  inc hl         ; (6 cycles) increment counter until interrupt flag comes on again
    in a,($bf)     ; (11 cycles)
    or a           ; (4 cycles)
    jp p,-         ; (10 cycles)
    xor a          ; reset carry flag, also set a=0
    ld de,2048     ; see if hl is more or less than 2048
    sbc hl,de
    ret c          ; if less, return a=0
    ld a,1
    ret            ; if more or equal, return a=1


;==============================================================
; Load tiles (font)
;==============================================================
; 1. Set VRAM write address to tile index 0
; by outputting $4000 ORed with $0000
; hl tile data
; bc tile data length
; trashes af
LoadTiles:
	ld a,$00
	out (VDPStatusPort),a
	ld a,$40
	out (VDPStatusPort),a
	; 2. Output tile data
-:
	; Output data byte then three zeroes, because our tile data is 1 bit
	; and must be increased to 4 bit
	ld a,(hl)        ; Get data byte
	out (VDPDataPort),a
	inc hl           ; Add one to hl so it points to the next data byte
	dec bc
	ld a,b
	or c
	jp nz,-
ret

;==============================================================
; Write text to name table
;==============================================================
; 1. Set VRAM write address to name table index 0
; by outputting $4000 ORed with $3800+0
; hl tile data
; bc tile data length
; trashes af
LoadTilemap:
ld a,$00
out (VDPStatusPort),a
ld a,$38|$40
out (VDPStatusPort),a
; 2. Output tilemap data
-:
ld a,(hl)    ; Get data byte
out (VDPDataPort),a
inc hl       ; Point to next letter
dec bc
ld a,b
or c
jp nz,-
ret

;trashes af
ScreenOn:
	; Turn screen on
	ld a,%11100000
	;      |||| |`- Zoomed sprites -> 16x16 pixels
	;      |||| `-- Doubled sprites -> 2 tiles per sprite, 8x16
	;      |||`---- 30 row/240 line mode
	;      ||`----- 28 row/224 line mode
	;      |`------ VBlank interrupts
	;      `------- Enable display
	out (VDPStatusPort),a
	ld a,$81 ;reg 1
	out (VDPStatusPort),a
ret

;trashes af
ScreenOff:
	; Turn screen on
	ld a,%10100000
	;      |||| |`- Zoomed sprites -> 16x16 pixels
	;      |||| `-- Doubled sprites -> 2 tiles per sprite, 8x16
	;      |||`---- 30 row/240 line mode
	;      ||`----- 28 row/224 line mode
	;      |`------ VBlank interrupts
	;      `------- Enable display
	out (VDPStatusPort),a
	ld a,$81 ;reg 1
	out (VDPStatusPort),a
ret

.define PSGMOD_SUPPORT_GG_STEREO 0
.DEFINE PSGMOD_PSG_PORT $7F
.include "psgmod/psgmod.inc"
.include "psgmod/psgmod.asm"
.ends

.BANK 0 SLOT 0
.section "data" force 
PaletteData:
;.db $00,$3f
.include "pal.inc"
PaletteDataEnd:


VdpInitData:
.db $04,$80
.db $84,$81
.db $ff,$82
.db $ff,$85
.db %11111011,$86 ; sprites come from the first 256 tiles.
.db $10,$87 ; overscan/background colour.
.db $00,$88
.db $00,$89
.db $ff,$8a
VdpInitDataEnd:

NumberTilemapTop:
;.dw $004B $004C $004D $004D $044B $024D $024D $004E $004F $004F
.dw $0065 $0066 $0067 $0067 $0465 $0267 $0267 $0068 $0069 $0069
NumberTilemapBottom:
.dw $006A $006B $006C $026C $006B $026C $006A $006B $006A $006B
;.dw $0050 $0051 $0052 $0252 $0051 $0252 $0050 $0051 $0050 $0051
;----=-=-=-=-=-=-=-----

SelectBoardTextTilemap:
.dw $0058 $0059 $005A $0059 $005B $005C $0000 $005D $005E $005F $0060 $0061 $0062
SmallTextTilemap:
.dw $006A $006B $006C $006D $006E $006E $026A
MediumTextTilemap:
.dw $006C $0074 $0078 $0079 $007A $006C
LargeTextTilemap:
.dw $006E $006D $0073 $0082 $0074

GameTileData:
.include "base_tiles.inc"
;.include "background_tiles.inc"
.include "background_smallboard4_tiles.inc"
.include "numbers_tiles.inc"
.include "face_tiles.inc"
GameTileDataEnd:


TitleTileData:
.include "title4_tiles.inc"
TitleTileDataEnd:

TitleTilemap:
.include "title2_tilemap.inc"
TitleTilemapEnd:

TitlePal:
.db $00 $3F $15 $17 $2F
TitlePalEnd:

.define boardInitDataSize 9

BoardInitData:
.db 8;20
.db 9;20
.dw 8 * 9
.db 10
.db 16 + 6 * 8
.db 15 + 6 * 8
.dw (8*32+8)*2 + $3800
;
.db 14;20
.db 14;20
.dw 14 * 14
.db 20
.db 16 + 3 * 8
.db 15 + 3 * 8
.dw (5*32+5)*2 + $3800
;
.db 20
.db 20
.dw 20 * 20
.db 40
.db 16
.db 15 
.dw (2*32+2)*2 + $3800

faceBlinkAnim:
;.db 0, $6d, $73, $73, $73, $73, $73, $73, $73, $73, $73, $73, $73, $73, $73, $73, $73, $73, $73, $73, $73, $73, $73, $73, $73, $73
.db 0 
.db $6d, $6e, $6e, $6e, $6e, $6f, $6f, $6f, $6f, $6f, $6f, $70
.db $70
.db $70, $6f, $6f, $6f, $6f, $6e, $6e, $6e, $6e, $6e, $6e, $6d

.ends


.BANK 1 SLOT 2
.ORG $0000
SampleMusic:
;.incbin "music/01-system_of_a_master.epsgmod";
;.incbin "music/cdb_nointro.epsgmod";
.incbin "music/minesweeper_new_version.epsgmod";


.BANK 2 SLOT 2
.ORG $0000
PSGMOD_VIBRATO_TABLES:
.incbin "psgmod/psgmod.vib"


.BANK 3 SLOT 2
.org $0000
.section "tilemaps" force
BoardTilemapSml:
;.include "background_tilemap.inc"
.include "background_smallboard4_tilemap.inc"
BoardTilemapSmlEnd:

BoardTilemapMed:
;.include "background_tilemap.inc"
.include "background_mediumboard4_tilemap.inc"
BoardTilemapMedEnd:

BoardTilemapLrg:
;.include "background_tilemap.inc"
.include "background_largeboard4_tilemap.inc"
BoardTilemapLrgEnd:

.ends
