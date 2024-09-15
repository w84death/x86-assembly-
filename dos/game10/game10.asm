; GAME10 - The X Project - Mysteries of the Forgotten Isles"
; DOS VERSION
;
; Description:
;   You are an intrepid explorer stranded on the Forgotten Isles, a chain of 
;   islands shrouded in myth. These islands were once home to an advanced 
;   civilization known for their ingenious engineering and mystical practices. 
;   Scattered across the islands are pressure plates that, when activated, 
;   reveal clues and alter the landscape by raising bridges or opening gates. 
;   However, these plates require a sustained weight to remain activated, 
;   necessitating the use of rocks to keep them pressed while you progress.
;
; Size category: <2KB
;
; Author: Krzysztof Krystian Jankowski
; Web: smol.p1x.in/assembly/#dinopix
; License: MIT

org 0x100
use16

; =========================================== MEMORY ADDRESSES =================
_VGA_MEMORY_ equ 0xA000
_DBUFFER_MEMORY_ equ 0x8000
_PLAYER_ENTITY_ID_ equ 0x7000
_REQUEST_POSITION_ equ 0x7002
_ENTITIES_ equ 0x7010

; =========================================== CONSTANTS ========================
BEEPER_ENABLED equ 0x01
BEEPER_FREQ equ 4800
LEVEL_START_POSITION equ 320*60
SPEED_EXPLORE equ 0x12c
COLOR_SKY equ 0x3b3b
COLOR_WATER equ 0x3636

; =========================================== INITIALIZATION ===================
start:
    mov ax,0x13                             ; Init VGA 320x200x256
    int 0x10                                ; Video BIOS interrupt

    push _DBUFFER_MEMORY_                 ; Set doublebuffer memory
    pop es                                  ; as target

set_keyboard_rate:
    xor ax, ax
    xor bx, bx
    mov ah, 03h         ; BIOS function to set typematic rate and delay
    mov bl, 1Fh         ; BL = 31 (0x1F) for maximum repeat rate (30 Hz)
    int 16h

restart_game:

; =========================================== GAME LOGIC =======================
game_loop:
  xor di, di
  xor si, si

; =========================================== DRAW BACKGROUND ==================
draw_bg:
  mov ax, COLOR_SKY               ; Set starting sky color
  mov cl, 0xa                  ; 10 bars to draw
  .draw_sky:
     push cx

     mov cx, 320*3           ; 3 pixels high
     rep stosw               ; Write to the doublebuffer
     inc ax                  ; Increment color index for next bar
     xchg al, ah             ; Swap colors

     pop cx                  ; Decrement bar counter
     loop .draw_sky

draw_ocean:
  xor dx, dx
  mov di, 320*60
  mov si, OceanBrush

  mov cx, 18
  .ll:
    push cx

    xor dx, dx
    mov ax, cx
    shr ax, 1
    adc dx, 0
    shl dx, 1

    mov cx, 40
    .l:
      call draw_sprite
      add di, 8

    loop .l
    add di, 320*7


    pop cx

  loop .ll

; anim_ocean:
;   add si, 2
;   mov cl, 8
;   .anim:
;     ror word [si], 2
;     add si, 2
;   loop .anim


draw_ship:
  mov cx, 0x040f
  call conv_pos2mem
  sub di, 8
  mov si, ShipEndBrush
  call draw_sprite
  add di, 16
  mov dx, 0x01
  call draw_sprite
  mov si, ShipMiddleBrush
  sub di, 8
  call draw_sprite

draw_player:
  call conv_pos2mem
  sub di, 320*6
  mov si, IndieTopBrush
  mov dl, 0x1
  call draw_sprite
  add di, 320*7
  mov si, IndieBottomBrush
  call draw_sprite

debug_test:
  xor dx, dx
  mov di, 320*116+120
  mov si, TerrainTiles
  mov cx, 8
  .lll:
    call draw_sprite
    add si, 0x12
    add di, 10
  loop .lll
  
  mov di, 320*106+130
  mov si, PalmBrush
  call draw_sprite

; =========================================== VGA BLIT PROCEDURE ===============

vga_blit:
    push es
    push ds

    push _VGA_MEMORY_                     ; Set VGA memory
    pop es                                  ; as target
    push _DBUFFER_MEMORY_                 ; Set doublebuffer memory
    pop ds                                  ; as source
    mov cx,0x7D00                           ; Half of 320x200 pixels
    xor si,si                               ; Clear SI
    xor di,di                               ; Clear DI
    rep movsw                               ; Push words (2x pixels)

    pop ds
    pop es

; =========================================== V-SYNC ======================

wait_for_vsync:
    mov dx, 03DAh
    .wait1:
        in al, dx
        and al, 08h
        jnz .wait1
    .wait2:
        in al, dx
        and al, 08h
        jz .wait2



; =========================================== GAME TICK=== =====================


inc word [GameTick]

; =========================================== ESC OR LOOP ======================

    in al,0x60                  ; Read keyboard
    dec al                      ; Decrement AL (esc is 1, after decrement is 0)
    jnz game_loop               ; If not zero, loop again

; =========================================== TERMINATE PROGRAM ================
  exit:
    mov ax, 0x0003             ; Return to text mode
    int 0x10                   ; Video BIOS interrupt
    ret                       ; Return to DOS

; =========================================== CNVERT XY TO MEM =================
; Expects: CX - position YY/XX
; Return: DI memory position
conv_pos2mem:
  mov di, LEVEL_START_POSITION
  add di, 320*8+32
  xor ax, ax               ; Clear AX
  mov al, ch               ; Move Y coordinate to AL
 imul ax, 320*8
  xor dh, dh               ; Clear DH
  mov dl, cl               ; Move X coordinate to DL
  shl dx, 3                ; DX = X * 8
  add ax, dx               ; AX = Y * 2560 + X * 8
  add di, ax               ; Move result to DI
ret


; =========================================== RANDOM MOVE  =====================
; Expects: CX - position YY/XX
; Return: CX - updated pos
random_move:
  rdtsc
  and ax, 0x13
  jz .skip_move

  test ax, 0x3
  jz .move_y
    dec cl
    test byte [si+4], 0x01
    jnz .skip_move
    add cl, 2
  ret

.move_y:
  dec ch
  test ax, 0x10
  jz .skip_move
  add ch, 2

.skip_move:
  ret


; =========================================== CHECK BOUNDS =====================
; Expects: CX - Position YY/XX
; Return: AX - Zero if hit bound, 1 if no bounds at this location
check_bounds:
  xor ax, ax                                ; Assume bound hit (AX = 0)
  cmp ch, 0x0f
  ja .return
  cmp cl, 0x20
  ja .return
  inc ax                                    ; No bound hit (AX = 1)
.return:
  cmp ax, 0x0
  ret


; =========================================== DRAW SPRITE PROCEDURE ============
; Expects:
; DI - positon (linear)
; DX - settings: 00 normal, 01 mirrored x, 10 mirrored y, 11 mirrored x&y
; Return: -
draw_sprite:
    pusha
    xor cx, cx
    mov byte cl, [si]       ; lines
    inc si

    xor ax, ax
    mov byte al, [si]       ; Palette
    inc si

    shl ax, 0x2              ; each set is 4x 1 byte
    mov bp, ax
    add bp, PaletteSets

    mov bl, dl              ; Check x mirror
    and bl, 0x1
    jz .no_x_mirror
      add di, 0x7             ; Move point to the last right pixel
    .no_x_mirror:

    mov bl, dl              ; Check
    and bl, 0x2
    jz .no_y_mirror
      add si, cx
      add si, cx              ; Move to the last position
      sub si, 0x2             ; Back one word
    .no_y_mirror:

    .plot_line:
        push cx           ; Save lines couter
        mov ax, [si]      ; Get sprite line
        xor bx, bx
        mov cl, 0x08      ; 8 pixels in line
        push si
        .draw_pixel:
            push cx

            mov cl, 0x2
            call get_bits_from_word

            mov si, bp      ; Palette Set
            add si, bx      ; Palette color
            mov byte bl, [si] ; Get color from the palette

            cmp bl, 0x0        ; transparency
            jz .skip_pixel
              mov byte [es:di], bl  ; Write pixel color
            .skip_pixel:     ; Or skip this pixel - alpha color

            inc di           ; Move destination to next pixel (+1)

            mov bl, dl
            and bl, 0x1
            jz .no_x_mirror2          ; Jump if not
              dec di           ; Remove previous shift (now it's 0)
              dec di           ; Move destination 1px left (-1)
            .no_x_mirror2:

            pop cx
            loop .draw_pixel

        pop si
        add si, 0x2               ; Move to the next sprite line data

        mov bl, dl
        and bl, 0x2
        jz .no_y_mirror2
          sub si, 0x4
        .no_y_mirror2:

        add di, 312          ; Move to next line in destination

        mov bl, dl
        and bl, 0x1
        jz .no_x_mirror3
          add di, 0x10           ; If mirrored adjust next line position
        .no_x_mirror3:

    pop cx                   ; Restore line counter
    loop .plot_line
    popa
  ret


; =========================================== CONVERT VALUE ===================
; Expects:
; AX - source
; CL - number of bits to convert
; Return: BX
get_bits_from_word:
    xor bx, bx          ; Clear BX
    .rotate_loop:
        rol ax, 1       ; Rotate left, moving leftmost bit to carry flag
        adc bx, 0       ; Add carry to BX (0 or 1)
        shl bx, 1       ; Shift BX left, making room for next bit
        loop .rotate_loop
    shr bx, 1           ; Adjust final result (undo last shift)
    ret


; =========================================== COLOR PALETTES ===================
; Set of four colors per palette. 0x00 is transparency; use 0x10 for black.

PaletteSets:
db 0x00, 0x13, 0x17, 0x1b   ; Grays
db 0x00, 0x06, 0x27, 0x43   ; Indie top
db 0x00, 0x7e, 0x13, 0x15   ; Indie bottom
db 0x7f, 0x7e, 0x7d, 0x7b   ; Ocean
db 0x00, 0xb7, 0xbb, 0x8c   ; Wood
db 0x00, 0x46, 0x5a, 0x5c   ; Terrain 1 - shore
db 0x47, 0x46, 0x45, 0x54   ; Terrain 2 - in  land
db 0x00, 0x06, 0x77, 0x2e   ; Palm

; =========================================== BRUSHES DATA =====================
; Set of 8x8 tiles for constructing meta-tiles
; Data: number of lines, palettDefaulte id, lines (8 pixels) of palette color id

IndieTopBrush:
db 0x7, 0x1
dw 0000000101010000b
dw 0000010101010100b
dw 0000001111110000b
dw 0000000011110000b
dw 0000001010000000b
dw 0000001010100000b
dw 0000001101010000b

IndieBottomBrush:
db 0x3, 0x2
dw 0000000101010000b
dw 0000000100010000b
dw 0000001000100000b

OceanBrush:
db 0x8, 0x3
dw 1111111111111111b
dw 1011111111111011b
dw 1110101110111110b
dw 0110111011100110b
dw 1001011001101001b
dw 0001100110010001b
dw 0100000100010100b
dw 0000010001000000b

ShipEndBrush:
db 0x7, 0x4
dw 0000101010101111b
dw 0000111111111010b
dw 0000101111111111b
dw 0000010101011011b
dw 0000000111111111b
dw 0000011010101010b
dw 0000000101010101b

ShipMiddleBrush:
db 0x7, 0x4
dw 1111101010111111b
dw 1111111111111111b
dw 1111111111111111b
dw 1111111111111111b
dw 1010111110101011b
dw 1010100110101010b
dw 0101010101010101b

PalmBrush:
db 0x10, 0x7
dw 0010100000101010b
dw 1011111010111110b
dw 1011101011101011b
dw 1010111110111011b
dw 1011111010111110b
dw 1011101010101110b
dw 1110111001101110b
dw 0011000101111011b
dw 0000000001000000b
dw 0000000001000000b
dw 0000000100001000b
dw 1011000100101100b
dw 1110110111101110b
dw 0010110101111011b
dw 1011101101101100b
dw 0011101011101100b

BridgeBrush:
db 0x8, 0x0
dw 0010101111101010b
dw 1011111010111111b
dw 1111101111111111b
dw 1111101011111111b
dw 1011111010101111b
dw 0110111111111010b
dw 0101101010101010b
dw 0001010101010101b


; TERRAIN TILES

TerrainTiles:
db 0x8, 0x05          ; 0x1 Shore left bank
dw 0010111101010101b
dw 0010111111010101b
dw 0010101111010101b
dw 0000101111010101b
dw 0000101111010101b
dw 0010101111010101b
dw 0010111101010101b
dw 0010111111010101b

db 0x8, 0x05          ; 0x2 Shore top bank
dw 0000000000000000b
dw 1010100000101010b
dw 1111101010101111b
dw 1111111111111111b
dw 0111111111111101b
dw 0101010101010101b
dw 0101010101010101b
dw 0101010101010101b

db 0x8, 0x5          ; 0x3 Shore corner outside
dw 0000101010101010b
dw 0010101111111110b
dw 1010111111111111b
dw 1011111111111111b
dw 1011111101010111b
dw 1011110101010101b
dw 1011110101010101b
dw 1011110101010101b

db 0x8, 0x6          ; 0x4 Shore corner filler inside
dw 1010111101010000b
dw 1011110000000000b
dw 1111000000010100b
dw 1100010100000001b
dw 0000000000000000b
dw 0001010000010000b
dw 0000000001000001b
dw 0001000000000100b

db 0x8, 0x6          ; 0x5 Ground light
dw 0110010101011001b
dw 1001011001010110b
dw 0101100101101001b
dw 0101010101010110b
dw 1001010110100101b
dw 0110100101010101b
dw 1001010110100110b
dw 0110010101011001b

db 0x8, 0x6           ; 0x6 Ground medium
dw 0110001001001001b
dw 1001010100100001b
dw 0100100101000110b
dw 0101010001101001b
dw 0101001000010101b
dw 1001010001100100b
dw 0101100101010110b
dw 0101010101010010b

db 0x8, 0x6           ; 0x7 Ground dense
dw 1011001001001001b
dw 1110110100110001b
dw 0011000101000111b
dw 0101101110101001b
dw 0101111011101101b
dw 1001001100111011b
dw 0111100101001100b
dw 1001011001010101b

db 0x8, 0x3           ; 0x8 Bridge disabled
dw 0000000000000000b
dw 0010101111101010b
dw 1011111010111111b
dw 1111101111111111b
dw 1111101011111111b
dw 1011111010101111b
dw 0110111111111010b
dw 0001101010101010b

; META TILES
MetaTiles:
db 00000000b, 00000000b, 00000000b, 00000000b
db 00000010b, 00000010b, 00000101b, 00000101b
db 00000001b, 00000101b, 00000001b, 00000101b
db 00000011b, 00000010b, 00000001b, 00000101b
db 00000101b, 00000101b, 00000101b, 00000101b
db 00001110b, 00000110b, 00000110b, 00000110b
db 00000110b, 00000110b, 00000111b, 00000110b
db 00000111b, 00000111b, 00001111b, 00000111b
db 00000100b, 00000101b, 00000101b, 00000101b
db 00000100b, 00000101b, 00000101b, 00001100b
db 00000000b, 00000000b, 00000000b, 00000000b
db 00000000b, 00000000b, 00000000b, 00000000b
db 00001000b, 00001100b, 00001000b, 00001100b
db 00000000b, 00000000b, 00000000b, 00000000b
db 00000000b, 00000000b, 00000000b, 00000000b
db 00000000b, 00000000b, 00000000b, 00000000b

LevelData:
db 00000000b, 00000000b, 00000000b, 00000000b
db 00000000b, 00000000b, 00000000b, 00000000b
db 00000000b, 00000000b, 00000011b, 00010011b
db 00000000b, 00000000b, 00000000b, 00000000b
db 00000000b, 00000000b, 00000000b, 00000011b
db 00000001b, 00000001b, 00000001b, 00000001b
db 00010011b, 00001100b, 00100011b, 00110011b
db 00000000b, 00000000b, 00000000b, 00000000b
db 00000000b, 00000000b, 00000011b, 00001000b
db 00010110b, 00000101b, 00000101b, 00000110b
db 00010010b, 00000000b, 00000000b, 00000000b
db 00000000b, 00000000b, 00000000b, 00000000b
db 00000000b, 00000011b, 00001000b, 00000110b
db 00000101b, 00000111b, 00000110b, 00000101b
db 00010010b, 00000000b, 00000000b, 00000011b
db 00000001b, 00000001b, 00010011b, 00000000b
db 00000011b, 00001000b, 00000111b, 00000101b
db 00000110b, 00000111b, 00000101b, 00110110b
db 00010010b, 00001100b, 00000011b, 00001000b
db 00000101b, 00111000b, 00110011b, 00000000b
db 00000010b, 00010110b, 00111000b, 00100001b
db 00100001b, 00100001b, 00100001b, 00100001b
db 00110011b, 00000000b, 00100011b, 00100001b
db 00100001b, 00110011b, 00000000b, 00000000b
db 00000010b, 00111000b, 00110011b, 00000000b
db 00000000b, 00001100b, 00000000b, 00000000b
db 00000000b, 00000000b, 00000000b, 00000000b
db 00001100b, 00000000b, 00000000b, 00000000b
db 00100011b, 00110011b, 00000000b, 00000000b
db 00000011b, 00000001b, 00010011b, 00000000b
db 00000000b, 00000000b, 00000000b, 00000000b
db 00001100b, 00000000b, 00000000b, 00000000b
db 00000000b, 00000000b, 00000000b, 00000011b
db 00001000b, 00000111b, 00011000b, 00010011b
db 00000000b, 00000000b, 00000011b, 00000001b
db 00000001b, 00010011b, 00000000b, 00000000b
db 00000000b, 00000000b, 00000000b, 00100011b
db 00101000b, 00100110b, 00111000b, 00110011b
db 00001100b, 00000011b, 00001000b, 00000110b
db 00111000b, 00110011b, 00000000b, 00000000b
db 00000000b, 00000000b, 00000000b, 00000000b
db 00100011b, 00100001b, 00110011b, 00000000b
db 00000000b, 00000010b, 00000101b, 00111000b
db 00110011b, 00000000b, 00000000b, 00000000b
db 00000000b, 00000000b, 00000000b, 00000000b
db 00000000b, 00000000b, 00000000b, 00000000b
db 00000000b, 00100011b, 00100001b, 00110011b

GameTick:
dw 0x0

Logo:
db "P1X"
; Thanks for reading the source code!
; Visit http://smol.p1x.in for more.