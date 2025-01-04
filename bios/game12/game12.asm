; GAME12 - 2D Game Engine for DOS
;
; Created by Krzysztof Krystian Jankowski
; MIT License
; 01/2025
;

org 0x100
use16

_BASE_ equ 0x2000
_GAME_TICK_ equ _BASE_ + 0x00       ; 2 bytes
_GAME_STATE_ equ _BASE_ + 0x02      ; 1 byte
_SCORE_ equ _BASE_ + 0x03           ; 1 byte
_CUR_X_  equ _BASE_ + 0x04          ; 2 bytes
_CUR_Y_  equ _BASE_ + 0x06          ; 2 bytes
_CUR_TEST_X_  equ _BASE_ + 0x08       ; 2 bytes
_CUR_TEST_Y_  equ _BASE_ + 0x0A       ; 2 bytes
_VECTOR_COLOR_ equ _BASE_ + 0x0C    ; 1 byte
_TOOL_ equ _BASE_ + 0x0D            ; 1 byte

_SPRITES_ equ 0x3000
_LEVEL_ equ 0x4000

; =========================================== GAME STATES ======================

STATE_INTRO equ 0
STATE_MENU equ 2
STATE_PREPARE equ 4
STATE_GAME equ 8
STATE_OVER equ 16
; ...
STATE_QUIT equ 255

KB_ESC equ 0x01
KB_UP equ 0x48
KB_DOWN equ 0x50
KB_LEFT equ 0x4B
KB_RIGHT equ 0x4D
KB_ENTER equ 0x1C
KB_SPACE equ 0x39

TOOLS equ 9

GRID_H_LINES equ 11
GRID_V_LINES equ 20
COLOR_BACKGROUND equ 0xDE
COLOR_GRID equ 0xDD
COLOR_TEXT equ 0x4E
COLOR_CURSOR equ 0x1F
COLOR_CURSOR_ERR equ 0x6F
COLOR_CURSOR_OK equ 0x49
COLOR_GRADIENT_START equ 0x1414
COLOR_GRADIENT_END equ 0x1010
COLOR_METAL equ 0xA3
COLOR_STEEL equ 0x67
COLOR_WOOD equ 0xD3

; =========================================== INITIALIZATION ===================

mov ax, 0x13        ; Init 320x200, 256 colors mode
int 0x10            ; Video BIOS interrupt
mov ax, 0xA000
mov es, ax
xor di, di          ; Set DI to 0

mov ax, 0x9000
mov ss, ax
mov sp, 0xFFFF

mov byte [_GAME_TICK_], 0
mov byte [_GAME_STATE_], STATE_INTRO
call prepare_intro

; =========================================== GAME LOOP ========================

main_loop:

; =========================================== KEYBOARD INPUT ===================

check_keyboard:
   mov ah, 01h         ; BIOS keyboard status function
   int 16h             ; Call BIOS interrupt
   jz .done             ; Jump if Zero Flag is set (no key pressed)

   mov ah, 00h         ; BIOS keyboard read function
   int 16h             ; Call BIOS interrupt

   cmp ah, KB_ESC
   je .process_esc
   cmp ah, KB_ENTER
   je .process_enter

   cmp byte [_GAME_STATE_], STATE_GAME
   jnz .done
   cmp ah, KB_SPACE
   je .process_space
   cmp ah, KB_UP
   je .pressed_up
   cmp ah, KB_DOWN
   je .pressed_down
   cmp ah, KB_LEFT
   je .pressed_left
   cmp ah, KB_RIGHT
   je .pressed_right
   
   jmp .done

   .process_esc:
      cmp byte [_GAME_STATE_], STATE_GAME
      jz .go_intro
      mov byte [_GAME_STATE_], STATE_QUIT
      jmp .done
   .process_enter:
      cmp byte [_GAME_STATE_], STATE_INTRO
      jz .go_game
      cmp byte [_GAME_STATE_], STATE_GAME
      jz .go_game_enter
      jmp .done
   .process_space:
      cmp byte [_GAME_STATE_], STATE_GAME
      jz .go_game_space
      jmp .done
   .go_intro:
      mov byte [_GAME_STATE_], STATE_INTRO
      mov word [_GAME_TICK_], 0x0
      call prepare_intro
      jmp .done
   .go_game:
      mov byte [_GAME_STATE_], STATE_GAME
      mov word [_GAME_TICK_], 0x0
      call prepare_game
      jmp .done
   .go_game_enter:
      call change_tool
      jmp .done
   .go_game_space:
      call get_cursor_pos
      call stamp_tile
      mov cl, COLOR_CURSOR_OK
      call draw_cursor
      jmp .done
   .pressed_up:
      dec word [_CUR_TEST_Y_]
      jmp .done_processed
   .pressed_down:
      inc word [_CUR_TEST_Y_]
      jmp .done_processed
   .pressed_left:
      dec word [_CUR_TEST_X_]
      jmp .done_processed
   .pressed_right:
      inc word [_CUR_TEST_X_]
      jmp .done_processed
   .done_processed:
      call move_cursor
   .done:

; =========================================== GAME STATES ======================

cmp byte [_GAME_STATE_], STATE_QUIT
je exit

cmp byte [_GAME_STATE_], STATE_INTRO
je draw_intro

cmp byte [_GAME_STATE_], STATE_GAME
je draw_game

jmp wait_for_tick

draw_intro:
      mov ax, [_GAME_TICK_]
   test ax, 0x10
   jnz .done

   mov al, [_VECTOR_COLOR_]
   cmp al, 0x1f
   jge .done
   inc al

   mov byte [_VECTOR_COLOR_], al
   call draw_vector
   .done:
   jmp wait_for_tick

draw_game:
   jmp wait_for_tick

; =========================================== GAME TICK ========================

wait_for_tick:
   xor ax, ax           ; Function 00h: Read system timer counter
   int 0x1a             ; Returns tick count in CX:DX
   mov bx, dx           ; Store the current tick count
   .wait_loop:
      int 0x1a          ; Read the tick count again
      cmp dx, bx
      je .wait_loop     ; Loop until the tick count changes

inc word [_GAME_TICK_]  ; Increment game tick

; =========================================== ESC OR LOOP ======================

jmp main_loop

; =========================================== EXIT TO DOS ======================

exit:
   mov ax, 0x4c00      ; Exit to DOS
   int 0x21            ; Call DOS
   ret                 ; Return to DOS
















; =========================================== PROCEDURES =======================

prepare_intro:
   xor di, di
   mov ax, COLOR_GRADIENT_START             ; Set starting color
   mov dl, 0x10               ; 10 bars to draw
   .draw_gradient:
      mov cx, 320*4          ; Each bar 10 pixels high
      rep stosw               ; Write to the VGA memory
      cmp dl, 0x09
      jg .draw_top
      jl .draw_bottom
      mov ax, COLOR_GRADIENT_END
      mov cx, 320*36
      rep stosw
      .draw_bottom:
      inc ax
      jmp .cont
      .draw_top:
      dec ax                  ; Increment color index for next bar
      .cont:
      xchg al, ah             ; Swap colors
      dec dl
      jnz .draw_gradient

   mov byte [_VECTOR_COLOR_], COLOR_TEXT
   mov bp, 320*165+85
   mov si, PressEnterVector
   call draw_vector

   mov byte [_VECTOR_COLOR_], 0x10
   mov bp, 320*80+150
   mov si, P1XVector
   call draw_vector
ret

prepare_game:
   xor di, di
   mov al, COLOR_BACKGROUND
   mov ah, al
   mov cx, 320*200/2
   rep stosw

   call draw_grid
   mov byte [_TOOL_], 0
   call draw_tools

   mov word [_CUR_X_], 9
   mov word [_CUR_Y_], 5
   mov word [_CUR_TEST_X_], 9
   mov word [_CUR_TEST_Y_], 5
   mov byte [_SCORE_], 0

   mov cl, COLOR_CURSOR
   call draw_cursor
ret

draw_grid:
   pusha
   mov di, 320*8+8
   push di    
   mov al, COLOR_GRID
   mov ah, al
   .draw_horizontal_lines:
      mov cx, GRID_H_LINES
      .h_line_loop:
         push cx
         mov cx, 320/2-8
         rep stosw
         pop cx
         add di, 320*15+16
      loop .h_line_loop
   .draw_vertical_lines:
      pop di
      mov cx, GRID_V_LINES
      .v_line_loop:
         push cx
         mov cx, 160
         .draw_v:
            stosw
            add di, 318
         loop .draw_v
         pop cx
         add di, 320*45-48
      loop .v_line_loop
   popa
ret

draw_tools:
   mov dl, [_TOOL_]
   mov bp, 320*177+16
   mov byte [_TOOL_], 0
   mov cx, TOOLS
   .tools_loop:
      push cx
      call stamp_tile
      inc byte [_TOOL_]
      add bp, 24
      pop cx
   loop .tools_loop
   mov byte [_TOOL_], dl
   call update_tools_selector
ret

get_cursor_pos:
   mov ax, [_CUR_Y_]
   shl ax, 4
   imul ax, 320
   mov bx, [_CUR_X_]
   shl bx, 4
   add ax, bx
   add ax, 320*8+8
   mov bp, ax
ret

stamp_tile:
   push bp

   cmp byte [_TOOL_], 0
   je .stamp_track_h
   cmp byte [_TOOL_], 1
   je .stamp_track_v
   cmp byte [_TOOL_], 2
   je .stamp_x
   cmp byte [_TOOL_], 3
   je .stamp_track_3
   cmp byte [_TOOL_], 4
   je .stamp_track_6
   cmp byte [_TOOL_], 5
   je .stamp_track_9
   cmp byte [_TOOL_], 6
   je .stamp_track_12
   cmp byte [_TOOL_], 7
   je .stamp_locomotive_h
   cmp byte [_TOOL_], 8
   je .stamp_locomotive_v
   jmp .done

   .stamp_track_h: 
   mov byte [_VECTOR_COLOR_], COLOR_METAL
   mov si, RailroadTracksHRailVector
   jmp .done

   .stamp_track_v: 
   mov byte [_VECTOR_COLOR_], COLOR_METAL
   mov si, RailroadTracksVRailVector
   jmp .done

   .stamp_x:
   mov byte [_VECTOR_COLOR_], COLOR_METAL
   mov si, XVector
   jmp .done

   .stamp_track_3:
   mov byte [_VECTOR_COLOR_], COLOR_METAL
   mov si, RailroadTracksTurn3Vector
   jmp .done

   .stamp_track_6:
   mov byte [_VECTOR_COLOR_], COLOR_METAL
   mov si, RailroadTracksTurn6Vector
   jmp .done

   .stamp_track_9:
   mov byte [_VECTOR_COLOR_], COLOR_METAL
   mov si, RailroadTracksTurn9Vector
   jmp .done

   .stamp_track_12:
   mov byte [_VECTOR_COLOR_], COLOR_METAL
   mov si, RailroadTracksTurn12Vector
   jmp .done

   .stamp_locomotive_h:
   mov byte [_VECTOR_COLOR_], COLOR_STEEL
   mov si, LocomotiveHVector
   jmp .done

   .stamp_locomotive_v:
   mov byte [_VECTOR_COLOR_], COLOR_STEEL
   mov si, LocomotiveVVector
   jmp .done

   .done:
   call draw_vector

   pop bp
ret

move_cursor:
   mov cl, COLOR_GRID
   call draw_cursor
   mov cl, COLOR_CURSOR
   mov ax, [_CUR_TEST_X_]
   cmp ax, 0
   jl .err
   cmp ax, GRID_V_LINES-2
   jg .err
   mov [_CUR_X_], ax

   mov ax, [_CUR_TEST_Y_]
   cmp ax, 0
   jl .err
   cmp ax, GRID_H_LINES-2
   jg .err
   mov [_CUR_Y_], ax
   jmp .done
   .err:
      mov cl, COLOR_CURSOR_ERR
      mov ax, [_CUR_X_]
      mov [_CUR_TEST_X_], ax
      mov ax, [_CUR_Y_]
      mov [_CUR_TEST_Y_], ax
   .done:
   call draw_cursor
ret

draw_cursor:
   mov ax, [_CUR_Y_]
   shl ax, 4
   imul ax, 320
   mov bx, [_CUR_X_]
   shl bx, 4
   add ax, bx
   add ax, 320*8+8
   mov bp, ax   
   mov byte [_VECTOR_COLOR_], cl
   mov si, CursorVector
   call draw_vector
ret

change_tool:
   mov dl, [_TOOL_]
   inc dl
   cmp dl, TOOLS
   jl .ok
      xor dl, dl
   .ok:
   mov byte [_TOOL_], dl
   call update_tools_selector
ret

update_tools_selector:
   mov di, 320*195+16
   mov cx, 180
   mov ax, COLOR_BACKGROUND
   mov ah, al
   rep stosw

   mov di, 320*195+16
   xor bx, bx
   mov bl, dl
   imul bx, 24
   add di, bx
   mov cx, 8
   mov ax, 0x1f1f
   rep stosw
ret

; =========================================== DRAW VECTOR ======================

draw_vector:   
  pusha 
  .read_group:
    xor cx, cx
    mov cl, [si]
    cmp cl, 0x0
    jz .done

    inc si

    .read_line:
    push cx

    xor ax, ax
    mov al, [si]
    add ax, bp
    
    xor bx, bx
    mov bl, [si+2]
    add bx, bp          ; Move to position
    mov dl, [si+1]
    mov dh, [si+3]        
    mov cl, [_VECTOR_COLOR_]
    mov ch, cl
    call draw_line

    add si, 2
    pop cx
    loop .read_line
    add si, 2
    jmp .read_group
  .done:
  popa
ret

; =========================================== DRAWING LINE ====================
; X0 - AX, Y0 - DL
; X1 - BX, Y1 - DH
; COLOR - CL
; Spektre @ https://stackoverflow.com/questions/71390507/line-drawing-algorithm-in-assembly#71391899
draw_line:
  pusha       
    push ax
    mov si,bx
    sub si,ax
    sub ah,ah
    mov al,dl
    mov bx,ax
    mov al,dh
    sub ax,bx
    mov di,ax
    mov ax,320
    sub dh,dh
    mul dx
    pop bx
    add ax,bx
    mov bp,ax
    mov ax,1
    mov bx,320
    cmp si,32768
    jb  .r0
    neg si
    neg ax
 .r0:    cmp di,32768
    jb  .r1
    neg di
    neg bx
 .r1:    cmp si,di
    ja  .r2
    xchg    ax,bx
    xchg    si,di
 .r2:    mov [.ct],si
 .l0:    mov byte [es:bp], cl
    add bp,ax
    sub dx,di
    jnc .r3
    add dx,si
    add bp,bx
 .r3:    dec word [.ct]
    jnz .l0
    popa
    ret
 .ct:    dw  0


; =========================================== DATA =============================

CursorVector:
db 4
db 0, 0, 16, 0, 16, 16, 0, 16, 0, 0
db 0

P1XVector:
db 4
db 2, 35, 2, 3, 10, 3, 10, 20, 2, 20
db 1
db 11, 4, 14, 4
db 1
db 14, 35, 14, 2
db 3
db 18, 35, 18, 19, 24, 11, 24, 2
db 3
db 24, 35, 24, 19, 18, 11, 18, 2
db 0

PressEnterVector:
db 6
db 3, 16, 15, 4, 20, 4, 21, 6, 18, 9, 15, 10, 10, 10
db 5
db 17, 16, 26, 4, 31, 4, 32, 7, 28, 10, 23, 10
db 1
db 27, 10, 28, 16
db 3
db 46, 4, 39, 4, 32, 15, 40, 16
db 1
db 37, 8, 43, 9
db 7
db 58, 4, 53, 4, 49, 8, 51, 10, 55, 10, 55, 14, 51, 16, 45, 15
db 7
db 70, 4, 64, 4, 62, 7, 64, 9, 68, 11, 68, 15, 63, 17, 59, 15
db 3
db 88, 4, 81, 4, 80, 16, 88, 16
db 1
db 82, 9, 87, 9
db 3
db 93, 16, 93, 4, 102, 15, 102, 4
db 1
db 106, 4, 115, 4
db 1
db 111, 4, 114, 17
db 3
db 126, 4, 119, 4, 122, 16, 130, 16
db 1
db 121, 9, 128, 9
db 5
db 136, 16, 130, 3, 135, 4, 137, 5, 139, 10, 134, 10
db 1
db 138, 10, 146, 16
db 0


XVector:
db 1
db 0, 0, 16, 16
db 1
db 16, 0, 0, 16
db 0

RailroadTracksHRailVector:
db 1
db 0, 6, 16, 6
db 1
db 0, 10, 16, 10
db 0

RailroadTracksVRailVector:
db 1
db 6, 0, 6, 16
db 1
db 10, 0, 10, 16
db 0

RailroadTracksTurn3Vector:
db 1
db 0, 5, 10, 16
db 1
db 0, 9, 6, 16
db 0

RailroadTracksTurn6Vector:
db 1
db 6, 16, 16, 5
db 1
db 10, 16, 16, 9
db 0

RailroadTracksTurn9Vector:
db 1
db 0, 5, 6, 0
db 1
db 0, 9, 10, 0
db 0

RailroadTracksTurn12Vector:
db 1
db 6, 0, 16, 9
db 1
db 10, 0, 16, 5
db 0

LocomotiveHVector:
db 4
db 1, 4, 15, 4, 15, 12, 1, 12, 1, 4
db 1
db 3, 7, 14, 7
db 1
db 3, 9, 14, 9
db 0

LocomotiveVVector:
db 4
db 4, 1, 4, 15, 12, 15, 12, 1, 4, 1
db 1
db 7, 3, 7, 14
db 1
db 9, 3, 9, 14
db 0