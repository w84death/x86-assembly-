; GAME10 - Mysteries of the Forgotten Isles
; 2048b VERSION, x86 BIOS, P1X BOOTLOADER in boot.asm
;
; Description:
; Logic 2D game in VGA graphics, w PC Speaker sound.
; 
;
; Size category: 2048 bytes / 2KB
; Bootloader: 512 bytes
; Author: Krzysztof Krystian Jankowski
; Web: smol.p1x.in/assembly/#forgotten-isles
; License: MIT

org 0x100
use16

jmp start

; =========================================== COLOR PALETTES ===================
; Set of four colors per palette. 0x00 is transparency; use 0x10 for black.

PaletteSets:
db 0x00, 0x34, 0x17, 0x1b   ; 0x0 Grays
db 0x00, 0x06, 0x27, 0x43   ; 0x1 Indie top
db 0x00, 0x7f, 0x13, 0x15   ; 0x2 Indie bottom
db 0x35, 0x34, 0x19, 0x1a   ; 0x3 Bridge
db 0x00, 0x06, 0x42, 0x43   ; 0x4 Chest
db 0x00, 0x46, 0x5a, 0x5c   ; 0x5 Terrain 1 - shore
db 0x47, 0x46, 0x45, 0x54   ; 0x6 Terrain 2 - in  land
db 0x00, 0x06, 0x77, 0x2e   ; 0x7 Palm
db 0x00, 0x27, 0x2a, 0x2b   ; 0x8 Snake
db 0x00, 0x2b, 0x2c, 0x5b   ; 0x9 Gold Coin
db 0x00, 0x15, 0x19, 0x1a   ; 0xa Rock

; =========================================== BRUSH REFERENCES =================
; Brush data offset table
; Data: offset to brush data, Y shift

BrushRefs:
dw IndieTopBrush, -320*6
dw PalmBrush, -320*10
dw SnakeBrush, -320*2
dw RockBrush, 0
dw SkullBrush, 0
dw BridgeBrush, 0
dw ChestBrush, 0
dw Gold2Brush, 320
dw GoldBrush, 320
dw IndieTop2Brush, -320*5

; =========================================== BRUSHES DATA =====================
; Set of 8xY brushes for entities
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

IndieTop2Brush:
db 0x7, 0x1
dw 0001000101000100b
dw 0011010101011100b
dw 0011001111111100b
dw 0011000011110000b
dw 0000111010000000b
dw 0000001010100000b
dw 0000001111110000b
dw 0000000101010000b

IndieBottomBrush:
db 0x4, 0x2
dw 0000000101010000b
dw 0000000100010000b
dw 0000001000100000b
dw 0000001000100000b

SnakeBrush:
db 0x8, 0x8
dw 0000000011011101b
dw 0000001111111111b
dw 0000001110001011b
dw 0000001010110001b
dw 0011000010101100b
dw 0000100001101000b
dw 0000010001010100b
dw 0000110101010000b

ChestBrush:
db 0x8, 0x4
dw 0011111111111100b
dw 1111101010101111b
dw 1110101010101011b
dw 1110101010101011b
dw 0111111111111101b
dw 0101010101010101b
dw 0101011111010101b
dw 0001010101010100b

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
db 0x8, 0x3             ; Non movable - bridge spot
dw 0101000001010000b
dw 0000000000000000b
dw 0000010101010000b
dw 0101000000000101b
dw 0101000000000101b
dw 0000010101010000b
dw 0000000000000000b
dw 0000010100000101b

RockBrush:
db 0x8, 0xa
dw 0000111111110000b
dw 0011111110101100b
dw 1111101111111111b
dw 1110111110101111b
dw 1011111010111001b
dw 0111111011111101b
dw 0101111110110101b
dw 0001010101010100b

GoldBrush:
db 0x6, 0x9
dw 0000111111110000b
dw 0011101111101100b
dw 1110111010111011b
dw 1010111010101010b
dw 0001101110100100b
dw 0000010101010000b

Gold2Brush:
db 0x6, 0x9
dw 0000001100000000b
dw 0000001100000000b
dw 0000001000000000b
dw 0000001000000000b
dw 0000000100000000b
dw 0000000100000000b

SlotBrush:
db 0x7, 0xa
dw 1001010000010110b
dw 0100000000000001b
dw 0000000000000000b
dw 0000000000000000b
dw 0000000000000000b
dw 0100000000000001b
dw 1001010000010110b

ArrowBrush:
db 0x7, 0x1
dw 0000001110000000b
dw 0000001110000000b
dw 0000001110000000b
dw 0011111110100100b
dw 0010111110100100b
dw 0000101110010000b
dw 0000001001000000b

SkullBrush:
db 0x7, 0x0a
dw 0000010101010000b
dw 0001010101010100b
dw 0001110111010100b
dw 0001010101010100b
dw 0100010101010001b
dw 0001010101010100b
dw 0100000101000001b

; =========================================== TERRAIN TILES DATA ===============
; 8x8 tiles for terrain
; Data: number of lines, palettDefaulte id, lines (8 pixels) of palette color id

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

db 0x8, 0x5          ; 0x4 Shore corner filler inside
dw 1010111101010101b
dw 1011110101010101b
dw 1111010101010101b
dw 1101010101010101b
dw 0101010101010101b
dw 0101010101010101b
dw 0101010101010101b
dw 0101010101010101b

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

db 0x8, 0x0           ; 0x8 Bridge Movable
dw 0001010000000000b
dw 0000000000010100b
dw 0000111111100000b
dw 0011111110101000b
dw 1111101010101011b
dw 0111101010111101b
dw 0001010101010100b
dw 0000000000000000b

; =========================================== META-TILES DECLARATION ===========
; 4x4 meta-tiles for level
; Data: 4x4 tiles id

MetaTiles:
db 00000000b, 00000000b, 00000000b, 00000000b
db 00000010b, 00000010b, 00000101b, 00000101b
db 00000001b, 00000101b, 00000001b, 00000101b
db 00000011b, 00000010b, 00000001b, 00110110b
db 00000101b, 00000110b, 00010110b, 00000101b
db 00000110b, 00000111b, 00000111b, 00000111b
db 00000100b, 00110101b, 00100101b, 00000111b
db 00000100b, 00100110b, 00010111b, 00110100b
db 00001000b, 00001000b, 00001000b, 00001000b
db 00000100b, 00010100b, 00000110b, 00000111b
db 00000100b, 00000111b, 00100100b, 00010111b

; =========================================== LEVEL DATA =======================
; 16x8 level data
; Data: 4x4 meta-tiles id
; Nibble is meta-tile id, 2 bits ar nibbles XY mirroring, 1 bit movable

LevelData:
db 01000011b, 01000001b, 01010011b, 00000000b
db 00000000b, 01000011b, 01000001b, 01010011b
db 00000000b, 00000000b, 00000000b, 00000000b
db 01001000b, 01001000b, 01000011b, 01010011b
db 01000010b, 01100101b, 01010010b, 01001000b
db 01000011b, 01000110b, 01110110b, 01110011b
db 01001000b, 01000011b, 01010011b, 00000000b
db 00000000b, 01000011b, 01000111b, 01110011b
db 01100011b, 01100001b, 01110011b, 00000000b
db 01100011b, 01101001b, 01110011b, 00000000b
db 00000000b, 01100011b, 01010111b, 01010011b
db 00000000b, 01100011b, 01110011b, 01001000b
db 00000000b, 00000000b, 00000000b, 00000000b
db 01000011b, 01001001b, 01010011b, 01000011b
db 01010011b, 00000000b, 01100011b, 01010111b
db 01010011b, 00000000b, 01001000b, 00000000b
db 01000011b, 01010011b, 01001000b, 00000000b
db 01100011b, 01100110b, 01011010b, 01100001b
db 01110011b, 00000000b, 00000000b, 01100011b
db 01010111b, 01010011b, 01000011b, 01010011b
db 01000010b, 01010110b, 01010011b, 00000000b
db 00000000b, 01100011b, 01110011b, 00000000b
db 00000000b, 01000011b, 01010011b, 01001000b
db 01000010b, 01010110b, 01000110b, 01010010b
db 01100011b, 01100001b, 01010111b, 01000001b
db 01010011b, 00000000b, 00000000b, 01000011b
db 01000001b, 01000110b, 01010010b, 00000000b
db 01100011b, 01100001b, 01100110b, 01010010b
db 01001000b, 01001000b, 01100011b, 01100001b
db 01110011b, 01001000b, 01001000b, 01100011b
db 01100001b, 01100001b, 01110011b, 00000000b
db 00000000b, 01001000b, 01100011b, 01110011b

EntityData:
db 1, 1
dw 0x0301
db 2, 28
dw 0x0103
dw 0x020a
dw 0x030a
dw 0x040a
dw 0x0509
dw 0x050d
dw 0x051a
dw 0x051b
dw 0x060a
dw 0x060c
dw 0x070d
dw 0x080e
dw 0x081a
dw 0x0910
dw 0x0916
dw 0x091a
dw 0x0a0d
dw 0x0a14
dw 0x0a15
dw 0x0a1b
dw 0x0b0c
dw 0x0c01
dw 0x0c0f
dw 0x0d02
dw 0x0d08
dw 0x0d0e
dw 0x0e06
dw 0x0f07
db 3, 5
dw 0x000c
dw 0x081e
dw 0x0c04
dw 0x0e07
dw 0x0e11
db 4, 8
dw 0x021b
dw 0x031a
dw 0x031e
dw 0x0404
dw 0x060b
dw 0x0616
dw 0x090e
dw 0x0c1e
db 6, 16
dw 0x0207
dw 0x0210
dw 0x0211
dw 0x0307
dw 0x0310
dw 0x061c
dw 0x061d
dw 0x071c
dw 0x071d
dw 0x0b16
dw 0x0b17
dw 0x0e0a
dw 0x0e0b
dw 0x0e0d
dw 0x0f0a
dw 0x0f0d
db 7, 1
dw 0x0300
db 8, 5
dw 0x0104
dw 0x010b
dw 0x0710
dw 0x0a01
dw 0x0d12
db 0x0 ; End of entities

; =========================================== MEMORY ADDRESSES =================

_ENTITIES_ equ 0x1000         ; 5 bytes per entity, 64 entites cap, 320 bytes
_PLAYER_ENTITY_ID_ equ 0x1800 ; 2 bytes
_REQUEST_POSITION_ equ 0x1802 ; 2 bytes
_HOLDING_ID_ equ 0x1804       ; 1 byte
_SCORE_ equ 0x1805            ; 1 byte
_SCORE_TARGET_ equ 0x1806     ; 1 byte
_GAME_TICK_ equ 0x1807        ; 2 bytes
_GAME_STATE_ equ 0x1809       ; 1 byte

_LAST_TICK_ equ 0x180a

_DBUFFER_MEMORY_ equ 0x2000   ; 64k bytes
_VGA_MEMORY_ equ 0xA000       ; 64k bytes
_TICK_ equ 1Ah                ; BIOS tick

_ID_ equ 0      ; 1 byte
_POS_ equ 1     ; 2 bytes - word
_MIRROR_ equ 3  ; 1 byte
_STATE_ equ 4   ; 1 bytes

; =========================================== MAGIC NUMBERS ====================

ENTITY_SIZE  equ 8
MAX_ENTITIES equ 64
LEVEL_START_POSITION equ 320*68+32
COLOR_SKY equ 0x3b3b
COLOR_WATER equ 0x3535

ID_PLAYER equ 0
ID_PALM equ 1
ID_SNAKE equ 2
ID_ROCK equ 3
ID_SKULL equ 4
ID_BRIDGE equ 5
ID_CHEST equ 6
ID_GOLD equ 7

STATE_DEACTIVATED equ 0
STATE_FOLLOW equ 2
STATE_STATIC equ 4
STATE_EXPLORING equ 8
STATE_INTERACTIVE equ 16

GSTATE_INTRO equ 0
GSTATE_GAME equ 2
GSTATE_END equ 4
GSTATE_WIN equ 8

BEEP_BITE equ 250
BEEP_PICK equ 15
BEEP_PUT equ 90

; =========================================== INITIALIZATION ===================

start:
    mov ax,0x13                             ; Init VGA 320x200x256
    int 0x10                                ; Video BIOS interrupt

    push _DBUFFER_MEMORY_                 ; Set doublebuffer memory
    pop es                                  ; as target

  ; set_keyboard_rate:
  ; xor ax, ax
  ; xor bx, bx
  ; mov ah, 03h         ; BIOS function to set typematic rate and delay
  ; mov bl, 1Fh         ; BL = 31 (0x1F) for maximum repeat rate (30 Hz)
  ; int 16h

restart_game:

mov byte [_GAME_STATE_], GSTATE_GAME
mov byte [_SCORE_], 0x0
mov byte [_HOLDING_ID_], 0x0

; =========================================== SPAWN ENTITIES ==================
; Expects: entities array from level data
; Returns: entities in memory array

spawn_entities:
  mov si, EntityData
  mov di, _ENTITIES_

  .next_entitie:
    mov bl, [si]
    cmp bl, 0x0
    jz .done
    
    dec bl             ; Conv level id to game id

    inc si
    mov al, [si]
    inc si
    mov cl, al

    cmp bl, ID_GOLD
    jnz .not_gold
    mov [_SCORE_TARGET_], cl
    .not_gold:
    .next_in_group:
      mov byte [di], bl           ; Save sprite id
      mov ax, [si]          ; Get position
      mov [di+_POS_], ax          ; Save position
      mov byte [di+_MIRROR_], 0x0 ;  Save mirror (none)
      mov byte [di+_STATE_], STATE_STATIC ; Save basic state
      
      cmp bl, ID_SNAKE
      jnz .skip_snake
        mov byte [di+_STATE_], STATE_EXPLORING ; Save basic state
      .skip_snake:

      cmp bl, ID_PALM
      jnz .skip_palm
        xor al, ah
        and al, 0x01
        mov byte [di+_MIRROR_], al ; Save basic state
      .skip_palm: 

      cmp bl, ID_BRIDGE
      jz .set_interactive
      cmp bl, ID_GOLD
      jz .set_interactive
      cmp bl, ID_ROCK
      jz .set_interactive
      cmp bl, ID_CHEST
      jz .set_interactive
      jmp .skip_interactive
      .set_interactive:
        mov byte [di+_STATE_], STATE_INTERACTIVE
      .skip_interactive:
      
      add si, 0x02                  ; Move to the next entity in code
      add di, ENTITY_SIZE           ; Move to the next entity in memory
    loop .next_in_group
  jmp .next_entitie
  .done:

mov word [_PLAYER_ENTITY_ID_], _ENTITIES_ ; Set player entity id to first entity

; =========================================== GAME LOGIC =======================

game_loop:
  xor di, di
  xor si, si

; =========================================== DRAW BACKGROUND ==================

draw_bg:
  mov ax, COLOR_SKY               ; Set starting sky color
  mov dl, 0xa                  ; 10 bars to draw
  .draw_sky:
    mov cx, 320*3           ; 3 pixels high
    rep stosw               ; Write to the doublebuffer
    inc ax                  ; Increment color index for next bar
    xchg al, ah             ; Swap colors
    dec dl
    jnz .draw_sky

draw_ocean:
  mov ax, COLOR_WATER
  mov cx, 320*70              ; 70 lines of ocean
  rep stosw

test byte [_GAME_STATE_], GSTATE_GAME
jz skip_game_state_game

; =========================================== DRAWING LEVEL ====================

draw_level:
  mov si, LevelData
  mov di, LEVEL_START_POSITION
  xor cx, cx
  .next_meta_tile:
    push cx
    push si

    mov byte al, [si]     ; Read level cell
    mov bl, al            ; Make a copy
    shr bl, 0x4           ; Remove first nible
    and bl, 0x3           ; Read XY mirroring - BL

    and ax, 0xf           ; Read first nibble - AX
    jnz .not_empty
      add di, 16
      jmp .skip_meta_tile
    .not_empty:

    mov si, MetaTiles
    shl ax, 0x2           ; ID*4 Move to position; 4 bytes per tile
    add si, ax            ; Meta-tile address

    mov     dx, 0x0123       ; Default order: 0, 1, 2, 3
    .check_y:
      test    bl, 2
      jz      .check_x
      xchg    dh, dl           ; Swap top and bottom rows (Order: 2, 3, 0, 1)
    .check_x:
      test    bl, 1
      jz      .push_tiles
      ror     dh, 4            ; Swap nibbles in dh (tiles in positions 0 and 1)
      ror     dl, 4            ; Swap nibbles in dl (tiles in positions 2 and 3)

    .push_tiles:
        mov     cx, 4            ; 4 tiles to push
    .next_tile_push:
        push    dx               ; Push the tile ID
        ror     dx, 4            ; Rotate dx to get the next tile ID in place
        loop    .next_tile_push

    mov cx, 0x4           ; 2x2 tiles
    .next_tile:
      pop dx              ; Get tile order
      and dx, 0x7
      push si
      add si, dx
      mov byte al, [si]   ; Read meta-tile with order
      pop si
      mov bh, al
      shr bh, 4            ; Extract the upper 4 bits
      and bh, 3            ; Mask to get the mirror flags (both X and Y)

      xor bh, bl          ; invert original tile mirror by meta-tile mirror
      mov dl, bh          ; set final mirror for tile

      and ax, 0xf         ; First nibble
      dec ax              ; We do not have tile 0, shifting values
     imul ax, 18          ; Move to position

      push si
      mov si, TerrainTiles
      add si, ax
      call draw_sprite
      pop si

      add di, 8

      cmp cx, 0x3
      jnz .skip_set_new_line
        add di, 320*8-16  ; Word wrap
      .skip_set_new_line:

    loop .next_tile
    sub di, 320*8
    .skip_meta_tile:

    pop si
    inc si
    pop cx
    inc cx
    test cx, 0xf
    jnz .no_new_line
      add di, 320*16-(16*16)  ; Move to the next display line
    .no_new_line:

    cmp cx, 0x80           ; 128 = 16*8
  jl .next_meta_tile


; =========================================== KEYBOARD INPUT ==================

check_keyboard:
  mov ah, 01h         ; BIOS keyboard status function
  int 16h             ; Call BIOS interrupt
  jz .no_key_press           ; Jump if Zero Flag is set (no key pressed)

  mov si, [_PLAYER_ENTITY_ID_]
  mov cx, [si+_POS_]   ; Load player position into CX (Y in CH, X in CL)

  mov ah, 00h         ; BIOS keyboard read function
  int 16h             ; Call BIOS interrupt

  .check_spacebar:
  cmp ah, 39h         ; Compare scan code with spacebar
  jne .check_up
    mov byte [_HOLDING_ID_], 0x0
    jmp .no_key_press

  .check_up:
  cmp ah, 48h         ; Compare scan code with up arrow
  jne .check_down
    cmp ch, 0x0
    jz .invalid_move
    dec ch
    jmp .check_move

  .check_down:
  cmp ah, 50h         ; Compare scan code with down arrow
  jne .check_left
    inc ch
    jmp .check_move

  .check_left:
  cmp ah, 4Bh         ; Compare scan code with left arrow
  jne .check_right
    ; cmp cl, 0x0
    ; jz .invalid_move
    dec cl
    mov byte [si+_MIRROR_], 0x1
    jmp .check_move

  .check_right:
  cmp ah, 4Dh         ; Compare scan code with right arrow
  jne .no_key_press
    inc cl
    mov byte [si+_MIRROR_], 0x0
    ;jmp .check_move

  .check_move:
    call check_friends
    jz .no_move
    call check_water_tile
    jz .no_move
    call check_bounds
   jz .no_move

    .move:
    mov word [si+_POS_], cx      
    .no_move:
    mov word [_REQUEST_POSITION_], cx

  .no_key_press:
  .invalid_move:


; =========================================== AI ENITIES ===============

ai_entities:
  mov si, _ENTITIES_
  mov cl, MAX_ENTITIES
  .next_entity:
    push cx

    cmp byte [si+_STATE_], STATE_EXPLORING
    jnz .skip_explore
      mov ax, [_GAME_TICK_]
      add ax, cx
      test ax, 0x4
      jz .skip_explore

      .explore:
        mov cx, [si+_POS_]
        call random_move
          mov byte [si+_MIRROR_], 0x0
          cmp byte cl, [si+_POS_]
          jg .skip_mirror_x
          mov byte [si+_MIRROR_], 0x1
          .skip_mirror_x:

        call check_bounds
        jz .can_not_move

        call check_friends
        jz .can_not_move

        call check_water_tile
        jz .can_not_move
        .move_to_new_pos:
          mov word [si+_POS_], cx
        .can_not_move:
        .check_if_player:
          cmp cx, [_REQUEST_POSITION_]
          jnz .no_bite
            cmp byte [_HOLDING_ID_], 0x0
            jnz .continue_game
              mov bl, BEEP_BITE
              call beep
              mov byte [_GAME_STATE_], GSTATE_END
            .continue_game:
            jz .no_bite
              mov byte [_HOLDING_ID_], 0x00
              jmp .skip_item
          .no_bite:
    .skip_explore:

    cmp byte [si+_STATE_], STATE_INTERACTIVE
    jnz .skip_item
      mov cx, [si+_POS_]
      cmp cx, [_REQUEST_POSITION_]
      jnz .skip_item
        
      cmp byte [si+_ID_], ID_BRIDGE
      jz .check_bridge
      cmp byte [si+_ID_], ID_CHEST
      jnz .skip_check_interactions
      
      .check_interactions:
        cmp byte [_HOLDING_ID_], ID_GOLD
        jnz .skip_item
        inc byte [_SCORE_]
        jmp .clear_item
      .check_bridge:
        cmp byte [_HOLDING_ID_], ID_ROCK
        jnz .skip_item
        mov byte [si+_STATE_], STATE_DEACTIVATED
      .clear_item:          
          mov byte [_HOLDING_ID_], 0xff
          jmp .skip_item
      .skip_check_interactions:

      cmp byte [_HOLDING_ID_], 0x0  ; Check if player is holding something
      jnz .skip_item
      .pick_item:
        mov byte [si+_STATE_], STATE_FOLLOW
        mov word [_REQUEST_POSITION_], 0x0
        mov byte cl, [si+_ID_]
        mov byte [_HOLDING_ID_], cl  
        mov bl, BEEP_PICK  
        call beep
    .skip_item:

    .put_item_back:
    cmp byte [si+_STATE_], STATE_FOLLOW
    jnz .no_follow
      
      cmp byte [_HOLDING_ID_], 0x0 
      jnz .check_kill
        mov byte [si+_STATE_], STATE_INTERACTIVE
        mov word [_REQUEST_POSITION_], 0x0
        jmp .beep
      .check_kill:
      cmp byte [_HOLDING_ID_], 0xff
      jnz .skip_kill
        mov byte [si+_STATE_], STATE_DEACTIVATED
        inc byte [_HOLDING_ID_] ;, 0x0
      .beep:
      mov bl, BEEP_PUT
      call beep
    .skip_kill:
    .no_follow: 
    
    add si, ENTITY_SIZE
    pop cx
    dec cx
  jnz .next_entity

; =========================================== SORT ENITIES ===============
; Sort entities by Y position
; Expects: entities array
; Returns: sorted entities array

sort_entities:
  mov cl, MAX_ENTITIES-1  ; We'll do n-1 passes
  .outer_loop:
    push cx
    mov si, _ENTITIES_

    .inner_loop:
      push cx
      mov bx, [si+_POS_]  ; Get Y of current entity
      mov dx, [si+ENTITY_SIZE+_POS_]  ; Get Y of next entity

      cmp bh, dh      ; Compare Y values
      jl .no_swap

        mov di, si
        add di, ENTITY_SIZE

        mov ax, [_PLAYER_ENTITY_ID_]
        cmp ax, si
        jne .check_next_entity
          mov [_PLAYER_ENTITY_ID_], di
          jmp .swap_entities
        .check_next_entity:
        cmp ax, di
        jne .swap_entities
          mov [_PLAYER_ENTITY_ID_], si
        .swap_entities:

        mov cx, ENTITY_SIZE
        .swap_loop:
          mov al, [si]
          xchg al, [di]
          mov [si], al
          inc si
          inc di
          loop .swap_loop
        sub si, ENTITY_SIZE

      .no_swap:
      add si, ENTITY_SIZE
      pop cx
      loop .inner_loop

    pop cx
    loop .outer_loop

; =========================================== DRAW ENITIES ===============

draw_entities:
  mov si, _ENTITIES_
  mov cl, MAX_ENTITIES
  .next:
    push cx
    push si

    cmp byte [si+_STATE_], STATE_DEACTIVATED
    jz .skip_entity

    mov cx, [si+_POS_]
    call conv_pos2mem       ; Convert position to memory
    
    cmp byte [si+_STATE_], STATE_FOLLOW
    jnz .skip_follow
      push si
      mov si, [_PLAYER_ENTITY_ID_]
      mov cx, [si+_POS_]   ; Load player position into CX (Y in CH, X in CL)
      pop si
      mov word [si+_POS_], cx ; Save new position
      call conv_pos2mem       ; Convert position to memory
      sub di, 320*12          ; Move above player
    .skip_follow:

    mov byte al, [si]       ; Get brush id in AL
    mov ah, al              ; Save a copy in AH

    cmp ah, ID_PLAYER
    jnz .skip_player_check
      cmp byte [_HOLDING_ID_], 0x0
      jz .skip_player_check
      mov al, 0x9
    .skip_player_check:

    shl al, 0x2
    mov bx, BrushRefs       ; Get brush reference table
    add bl, al              ; Shift to ref (id*2 bytes)
    mov dx, [bx]            ; Get brush data address
    push dx                 ; Save address for SI

    add al, 0x2               ; offest is at next byte (+2)
    movzx bx, al              ; Get address to BX
    add di, [BrushRefs + bx]  ; Get shift and apply to destination position
    mov dl, [si+_MIRROR_]     ; Get brush mirror flag
    
    pop si                  ; Get address
    call draw_sprite

    cmp ah, ID_PLAYER
    jnz .skip_player_draw
      mov si, IndieBottomBrush
      add di, 320*7
      call draw_sprite
    .skip_player_draw:

    cmp ah, ID_GOLD
    jnz .skip_gold_draw
      mov ax, [_GAME_TICK_]
      add ax, cx
      and ax, 0x4
      cmp ax, 0x2
      jl .skip_gold_draw
      xor dl, dl ; no mirror
      mov si, GoldBrush
      call draw_sprite
    .skip_gold_draw:

    cmp ah, ID_CHEST
    jnz .skip_chest
      cmp byte [_HOLDING_ID_], ID_GOLD
      jnz .skip_chest
        mov si, ArrowBrush
        sub di, 320*6
        mov ax, [_GAME_TICK_]
        and ax, 0x1
        imul ax, 320*2
        add di, ax
        call draw_sprite
    .skip_chest:

    .skip_entity:
    pop si
    add si, ENTITY_SIZE
    pop cx
    dec cx
  jg .next


; =========================================== DRAW UI ==========================

draw_score:
  mov di, 320*8+32
  mov al, [_SCORE_TARGET_]
  mov ah, [_SCORE_]
  cmp al, ah
  jg .continue_game
    mov byte [_GAME_STATE_], GSTATE_END+GSTATE_WIN
  .continue_game:
  xor cl, cl
  .draw_spot:
      mov si, SlotBrush
      call draw_sprite
      cmp cl, ah
      jge .skip_gold_draw
        mov si, GoldBrush
        call draw_sprite 
      .skip_gold_draw:
    add di, 0xa
    inc cl
    cmp al, cl
  jnz .draw_spot

skip_game_state_game:

test byte [_GAME_STATE_], GSTATE_END
jz skip_game_state_end
  mov di, 320*100+154
  mov si, SkullBrush
  test byte [_GAME_STATE_], GSTATE_WIN
  jz .draw_icon
  mov si, GoldBrush
  .draw_icon:
  call draw_sprite
skip_game_state_end:

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


; =========================================== GAME TICK ========================

wait_for_tick:
    xor ax, ax          ; Function 00h: Read system timer counter
    int _TICK_          ; Returns tick count in CX:DX
    mov bx, dx          ; Store the current tick count
.wait_loop:
    int _TICK_          ; Read the tick count again
    cmp dx, bx
    je .wait_loop       ; Loop until the tick count changes

inc word [_GAME_TICK_]  ; Increment game tick
 
; =========================================== BEEP STOP ========================

  in al, 0x61    ; Read the PIC chip
  and al, 0x0FC  ; Clear bit 0 to disable the speaker
  out 0x61, al   ; Write the updated value back to the PIC chip

; =========================================== ESC OR LOOP ======================

  in al,0x60                  ; Read keyboard
  dec al                      ; Decrement AL (esc is 1, after decrement is 0)
  jnz game_loop               ; If not zero, loop again

; =========================================== TERMINATE PROGRAM ================

  exit:
    ret                       ; Return to BIOS

; =========================================== BEEP PC SPEAKER ==================
; Set the speaker frequency
; Expects: BX - frequency value
; Return: -

beep:
  ; xor bh, bh
  ; shl bx, 6
  mov al, 0xB6  ; Command to set the speaker frequency
  out 0x43, al   ; Write the command to the PIT chip
  mov ah, bl    ; Frequency value 
  out 0x42, al   ; Write the low byte of the frequency value
  mov al, ah
  out 0x42, al   ; Write the high byte of the frequency value
  in al, 0x61    ; Read the PIC chip
  or al, 0x03    ; Set bit 0 to enable the speaker
  out 0x61, al   ; Write the updated value back to the PIC chip
ret

; =========================================== CNVERT XY TO MEM =================
; Expects: CX - position YY/XX
; Return: DI memory position

conv_pos2mem:
  mov di, LEVEL_START_POSITION
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
  in ax, 0x40       ; Read the timer
  xor ax, 0xb00b    ; XOR with magic number
  mov bx, ax        ; Save a copy
  and ax, 0x2       ; Check if we should move X
  dec ax            ; Convert 2 to 1 and 0 to -1 = -1, 0, 1

  test bx, 0x1      ; Check if we should move Y
  jz .move_x        ; Jump if not
  add ch, al        ; Move Y
ret 
  .move_x:
  add cl, al        ; Move X
  .done:
ret

; =========================================== CHECK BOUNDS =====================
; Expects: CX - Position YY/XX (CH: Y coordinate, CL: X coordinate)
; Returns: AX - Zero if hit bound, 1 if no bounds at this location

check_bounds:
  xor ax, ax             ; Assume bound hit (AX = 0)
  cmp ch, 0x0f
  ja .return
  cmp cl, 0x1f
  ja .return
  inc ax                 ; No bound hit (AX = 1)
.return:
  test ax, 1             ; Set flags based on AX
  ret

; =========================================== CHECK FRIEDS =====================
; Expects: CX - Position YY/XX
; Return: AX - Zero if hit entity, 1 if clear

check_friends:
  push si
  push cx
  xor bx, bx
  mov ax, cx

  mov cl, MAX_ENTITIES
  mov si, _ENTITIES_
  .next_entity:
    cmp byte [si+_STATE_], STATE_FOLLOW
    jle .skip_this_entity
    cmp word [si+_POS_], ax
    jnz .skip_this_entity
      inc bx
    .skip_this_entity:
    add si, ENTITY_SIZE
  loop .next_entity

  .done:
  pop cx
  pop si
  cmp bx, 0x1
ret

; =========================================== CHECK WATER TILE ================
; Expects: CX - Player position (CH: Y 0-15, CL: X 0-31)
; Returns: AL - 0 if water (0xF), 1 otherwise

check_water_tile:
  mov ax, cx      ; Copy position to AX
  shr ah, 1       ; Y / 2
  shr al, 1       ; X / 2 to convert to tile position
  movzx bx, ah
  shl bx, 4       ; Multily by 16 tiles wide
  add bl, al      ; Y / 2 * 16 + X / 2
  add bx, LevelData
  mov al, [bx]    ; Read tile
  test al, 0x40   ; Check if movable (7th bit set)
ret

; =========================================== DRAW SPRITE PROCEDURE ============
; Expects:
; DI - positon (linear)
; DL - settings: 0 normal, 1 mirrored x, 2 mirrored y, 3 mirrored x&y
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

  test dl, 0x1              ; Check x mirror
  jz .no_x_mirror
    add di, 0x7             ; Move point to the last right pixel
  .no_x_mirror:

  test dl, 0x2              ; Check
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

          rol ax, 2
          mov bx, ax
          and bx, 0x3
          
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

; ========================================== SAFETY CHECK ====================== 

; times 0x7FD - ($ - $$) db 0x0   ; Pad to 2048 bytes

; =========================================== THE END ==========================
; Thanks for reading the source code!
; Visit http://smol.p1x.in for more.

Logo:
db "P1X"    ; Use HEX viewer to see P1X at the end of binary