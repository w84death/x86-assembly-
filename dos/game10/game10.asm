; GAME10 - The X Project
; DOS VERSION
;
; Description:
;   New sprites, new   terrain rendering 32x24 with meta-tiles
;
; Size category: 2KB
;
; Author: Krzysztof Krystian Jankowski
; Web: smol.p1x.in/assembly/#dinopix
; License: MIT

org 0x100
use16

; =========================================== MEMORY ADDRESSES ===============
_VGA_MEMORY_ equ 0xA000
_DBUFFER_MEMORY_ equ 0x8000
_PLAYER_ENTITY_ID_ equ 0x7000
_REQUEST_POSITION_ equ 0x7002
_ENTITIES_ equ 0x7010

; =========================================== CONSTANTS =======================
BEEPER_ENABLED equ 0x01
BEEPER_FREQ equ 4800
LEVEL_START_POSITION equ 320*60
SPEED_EXPLORE equ 0x12c
COLOR_SKY equ 0x3b3b
COLOR_WATER equ 0x3636

; =========================================== INITIALIZATION ==================
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

.draw_bg:
  mov cx, 320*100
  mov si, PaletteSets
  xor di,di
  .l:
    mov byte bl, [si+2]
    mov bh, bl
    mov [es:di], bx
    add di, 0x2
  loop .l

;jmp skip_me

draw_player:
  xor dx, dx      ; no mirror
  mov cx, 0x0b10
  call conv_pos2mem
  mov si, IndieTopBrush
  call draw_sprite
  add di, 320*7
  mov si, IndieBottomBrush
  call draw_sprite
;skip_me:

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


; =========================================== ESC OR LOOP =====================

    in al,0x60                  ; Read keyboard
    dec al                      ; Decrement AL (esc is 1, after decrement is 0)
    jnz game_loop               ; If not zero, loop again

; =========================================== TERMINATE PROGRAM ================
  exit:
    mov ax, 0x0003             ; Return to text mode
    int 0x10                   ; Video BIOS interrupt
    ret                       ; Return to DOS

; =========================================== CNVERT XY TO MEM =====================
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

  imul ax, 0x3              ; each set is 3x 1 bytes
    mov bp, ax
    add bp, PaletteSets
    
    ; mov bx, dx              ; Check
    ; and bx, 0x1             ; mirror X?
    ; jz .no_x_mirror
    ;   add di, 0x7             ; Move point to the last right pixel
    ; .no_x_mirror:

    ; mov bx, dx              ; Check
    ; and bx, 0x2             ; mirror Y?
    ; jz .no_y_mirror
    ;   shl cx, 1               ; Lines*2
    ;   add si, cx              ; Move to the last position
    ;   sub si, 0x2             ; Back one word
    ; .no_y_mirror:

    .plot_line:
        push cx           ; Save lines couter
        mov ax, [si]      ; Get sprite line
        xor bx, bx
        mov cl, 0x08      ; 8 pixels in line
        .draw_pixel:
            push cx

            mov cl, 0x2
            call get_bits_from_word

            cmp bl, 0        ; transparency
            jz .skip_pixel
              push si
              mov si, bp      ; Palette Set
              add si, bx      ; Palette color
              mov byte bl, [si] ; Get color from the palette
              mov byte [es:di], bl  ; Write pixel color
              pop si
            .skip_pixel:     ; Or skip this pixel - alpha color
            inc di           ; Move destination to next pixel (+1)
            
            ; mov bx, dx
            ; and bx, 1
            ; jz .no_x_mirror2          ; Jump if not
            ; dec di           ; Remove previous shift (now it's 0)
            ; dec di           ; Move destination 1px left (-1)
            ; .no_x_mirror2:
            
            pop cx
            loop .draw_pixel

        add si, 0x2               ; Move to the next sprite line data

        ; mov bx, dx
        ; and bx, 2
        ; jz .no_y_mirror2
        ;   sub si, 4
        ; .no_y_mirror2:

        add di, 312          ; Move to next line in destination

        ; mov bx, dx
        ; and bx, 1
        ; jz .no_x_mirror3
        ;   add di, 0x10           ; If mirrored adjust next line position
        ; .no_x_mirror3:

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

; =========================================== BRUSHES DATA ======================
; Set of 8x8 tiles for constructing meta-tiles
; Data: number of lines, palette id, lines (8 pixels) of palette color id

PaletteSets:
db 0x0, 0x10, 0x18, 0x1f
db 0x0, 0x06, 0x27, 0x43
db 0x0, 0x7e, 0x13, 0x15

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
dw 0000001000100000b
dw 0000001011101100b

Logo:
db "P1X"
; Thanks for reading the source code!
; Visit http://smol.p1x.in for more.