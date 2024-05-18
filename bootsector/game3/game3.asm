; GAME 3 - Fly Escape
; by Krzysztof Krystian Jankowski ^ P1X
;

[bits 16]                                   ; 16-bit mode          
[org 0x7c00]                                ; Boot sector
cpu pentium                                 ; Minimum CPU is Pentium

; =========================================== MEMORY ===========================

VGA_MEMORY_ADR equ 0xA000
TIMER equ 0x046C                            ; BIOS timer
VGA_BUFFER equ 0xFA00                       ; DoubleDBUFFER_MEMORY_ADR  

; =========================================== MAGIC NUMBERS ====================

SCREEN_WIDTH equ 320                        ; 320x200 pixels
SCREEN_HEIGHT equ 200
SCREEN_CENTER equ SCREEN_WIDTH*SCREEN_HEIGHT/2+SCREEN_WIDTH/2

SPRITE_SIZE equ 8                           ; 8 pixels per sprite line
SPRITE_LINES equ 7                          ; 7 lines per sprite  
MAX_ENTITIES equ 64                          ; Maximum number of enemies           
ENEMIES_PER_LEVEL equ 4                     ; Number of enemies per level

COLOR_BG equ 20                                 
COLOR_SPIDER equ 0
COLOR_FLOWER equ 10
COLOR_FLY equ 77

SPRITE_FLY equ 0                            ; Fly sprite ID (position in memory)
SPRITE_SPIDER equ 14                        ; Spider sprite ID
SPRITE_FLOWER equ 28                        ; Flower sprite ID

; =========================================== RESERVE MEMORY ===================

section .bss
    DBUFFER_MEMORY_ADR   resb VGA_BUFFER    ; Doublebuffer
    LIFE resb 1                             ; Number of lifes, 1 byte
    LEVEL resw 2                            ; Current level, 2 bytes
    SPRITE resw 2                           ; Current sprite, 2 bytes
    COLOR resb 2                            ; Current color, 1 byte
    PLAYER resb 5                           ; Player data, 5 bytes of:
                                            ;       sprite ID, 1 byte
                                            ;       color, 1 byte
                                            ;       rotation, 1 byte
                                            ;       position, 2 bytes
    ENTITIES resb MAX_ENTITIES*5            ; 5 bytes per entitie
    
   

; =========================================== IMPLEMENTATION ===================

section .text
    global _start

; =========================================== BOOTSTRAP ========================

_start:
    xor ax,ax                               ; Init segments (0)
    mov ds, ax
    mov ax, VGA_MEMORY_ADR                  ; Set VGA memory
    mov es, ax                              ; as target
    mov ax, 13h                             ; Init VGA 320x200x256
    int 10h                                 ; Video BIOS interrupt
    
; =========================================== DOUBLE BUFFER INITIALIZATION =====

    mov ax,DBUFFER_MEMORY_ADR               ; Set doublebuffer memory
    mov es, ax                              ; as target

; =========================================== GAME INITIALIZATION / RESET ======

restart_game:
    mov byte [LIFE], 3                      ; Starting lifes
    mov word [LEVEL], 0                     ; Starting level
    mov byte [PLAYER+1], COLOR_FLY          ; Color
   
    mov si, ENTITIES                        ; Set memory position to entites
    mov cx, MAX_ENTITIES                     ; Number of enemies
    .clear_entites:
        mov byte [si], 0                    ; Clear sprite ID
        add si, 5                           ; Move to next memory position
    loop .clear_entites

; =========================================== LEVEL INITIALIZATION / NEXT LEVEL

next_level:
    mov word [PLAYER+3], SCREEN_CENTER      ; Set player initial position
    inc word [LEVEL]                        ; 0 -> 1st level
    mov si, ENTITIES                        ; Set memory position to entites
    mov ax, ENEMIES_PER_LEVEL               ; Number of enemies per level
    mov bx, [LEVEL]                         ; Current level number
    mul bx                                  ; Multiply enemies by level number
    mov cx, ax                              ; Store the result in cx
    .next_entitie:
        mov word [SI], (COLOR_SPIDER << 8) | SPRITE_SPIDER  
                                            ; Set sprite ID and color
        rdtsc                               ; Get random number
        and al, 7                           ; Clip rotation
        mov byte [si+2], al                 ; Set direction
        rdtsc                               ; Make it more random
        and ax, VGA_BUFFER                  ; Clip screen size
        mov word [si+3], ax                 ; Set position
    add si, 5                               ; Move to next memory position
    loop .next_entitie                      ; Repeat for all enemies

    mov cx, [LEVEL]                         ; One more flower per level
    .spawn_flowers:
        mov word [si], (COLOR_FLOWER << 8) | SPRITE_FLOWER
                                            ; Set sprite ID and color
        rdtsc                               ; Get random number
        and ax, VGA_BUFFER                  ; Clip screen size
        mov word [si+3], ax                 ; Set position
    add si, 5                               ; Move to next memory position
    loop .spawn_flowers


; =========================================== MAIN GAME LOOP ===================

game_loop:

; =========================================== DRAW BACKGROUND ==================

draw_bg:
    xor di,di                               ; Clear DI                     
    xor bx,bx                               ; Clear BX
    mov ax, 0x0808                          ; Set color to 8
    add byte bl, [LEVEL]                    ; Get current level number
    mul bx                                  ; Multiply by level number
    add ax, 0x8080                          ; Add 8 to the color for each pixel
    mov dx, 8                               ; We have 8 bars
    .draw_bars:
        mov cx, 320*25                      ; 320x25 pixels
        rep stosb                           ; Write to the doublebuffer
        inc al                              ; Increment color index for next bar
        dec dx                              ; Decrement bar counter
        jnz .draw_bars                      ; Repeat for all bars


; =========================================== DRAW ENTITIES ====================

draw_entities:
    mov word cx, MAX_ENTITIES                ; Number of enemies to check
    mov si, ENTITIES                        ; Start index for positions
    .next:
        push cx                             ; Save counter
        push si                             ; Save position
        xor ax,ax                           ; Clear AX
        mov byte al, [si]                   ; Sprite frame
        cmp al, 0                           ; Check if it's not empty
        je .done                            ; Kill loop if empty    
        mov word [SPRITE], ax               ; Set sprite frame
        rdtsc                               ; Get random number
        and al, 1                           ; Last bit
        jnz .ok                             ; If 1, add frame
        add word [SPRITE], 7                ; Move to the second sprite frame
        .ok:
        mov byte al, [si+1]                 ; Get color
        mov byte [COLOR], al                ; Set color
        mov di, [SI+3]                      ; Get position
        .move_player_and_enemies:
            cmp byte [SPRITE], SPRITE_SPIDER; Check if it's a spider
            ja .draw_entitie                ; Do not move if not a spider
            .move_entitie_forward:
                movzx si, [si+2]            ; Direction            
                shl si, 1                   ; Shift left
                add di, [MLT + si]          ; Movement Lookup Table
                cmp di, VGA_BUFFER          ; Check if out of bounds
                jb .draw_entitie            ; No clip below
                and di, VGA_BUFFER          ; Clip screen size 
        .draw_entitie:
            push di                         ; Save position
            mov byte BL, [COLOR]            ; Set color
            mov si, sprites                 ; Set sprites data position
            add word si, [SPRITE]           ; Shift to the current sprite
            call draw_sprite                ; Draw the sprite
            pop di                          ; Restore position
        pop si
        mov word [si+3], di                 ; Save new position

        .random_rotate:
            rdtsc                           ; Randomize rotation
            and ax, 42                      ; Wait 42 cycles
            jg .skip
            rdtsc                           ; Get random number
            and byte al, 7                  ; Clip rotation
            mov byte [si+2], al             ; Set direction
            .skip:
        add si, 5                           ; Move to the next entitie data
        pop cx
        loop .next
        .done:


; =========================================== COLLISION CHECKING ===============

check_collisions:
    mov di, [PLAYER+3]                      ; Player position
    mov cx, SPRITE_LINES                    ; Number of rows to check
    .check_row:     
        push cx                             ; Save row counter
        mov cx, 8                           ; Number of columns to check
        mov si, di                          ; Current position
        .check_column:      
            push cx                         ; Save column counter
            mov al, [es:si]                 ; Get pixel color
            cmp al, COLOR_SPIDER            ; Check if it matches spider color
            je .collision_spider            ; Jump if collision with spider
            cmp al, COLOR_FLOWER            ; Check if it matches flower color
            je .collision_flower            ; Jump if collision with flower
            add si, 1                       ; Move to the next column
            pop cx                          ; Restore column counter
        loop .check_column      
        add di, 320                         ; Move to the next row
        pop cx                              ; Restore row counter
    loop .check_row
    jmp .collision_done                     ; No collision

    .collision_spider:
        mov word [PLAYER+3], SCREEN_CENTER  ; Reset player position
        dec byte [LIFE]                     ; Decrease life
        jz restart_game                     ; Restart game if no lifes left
        jmp .collision_done                 ; Continue if lifes left
        
    .collision_flower:
        jmp next_level                      ; Advance to the next level

    .collision_done:

; =========================================== PLAYER MOVEMENT ==================

handle_player:
    mov di, [PLAYER+3]                      ; Position
    mov byte bl, [PLAYER+1]                 ; Color
    mov byte al, [PLAYER+2]                 ; Rotation
    movzx si,al                             ; Set SI to rotation
    shl si, 1                               ; Shift left
    add di, [MLT + si]                      ; Movement Lookup Table
    add di, [MLT + si]                      ; Second time for faster movement
    mov word [PLAYER+3], DI                 ; Save new position
    mov si, sprites+SPRITE_FLY              ; Sprite
    rdtsc                                   ; Get random number
    and al, 1                               ; Last bit  
    jnz .ok                                 ; If 1, add frame
    add si, 7                               ; Move to the second srite frame
    .ok:
    call draw_sprite                        ; Draw player sprite


; =========================================== KEYBOARD INPUT ===================


handle_keyboard:
    mov ax, 0x0100                            ; Check if a key has been pressed
    int 0x16                                ; Get the key press
    jz .no_move                             ; No press
    xor ax, ax                              ; Clear AX
    int 0x16                                ; Get the key press code
    .rotate_player:
        mov byte bl, [PLAYER+2]             ; Get current rotation 0-7
        inc bl                              ; Move rotation clockvise
        and bl, 7                           ; Limit 0..7
        mov byte [PLAYER+2], bl             ; Save back
    .no_move:

; =========================================== VGA BLIT =========================

vga_blit:
    push es
    push ds

    mov ax, VGA_MEMORY_ADR                   ; Set VGA memory
    mov es, ax                               ; as target
    mov ax,DBUFFER_MEMORY_ADR                ; Set doublebuffer memory
    mov ds, ax                               ; as source
    mov cx, 0x3E80                           ; Quarter of 320x200 pixels
    xor si, si                               ; Clear SI
    xor di, di                               ; Clear DI
    rep movsd                                ; Push double words (4x pixels)

    pop ds
    pop es


; =========================================== DELAY CYCLE ======================

delay_timer:
    mov ax, [TIMER]                         ; Get current timer value
    inc ax                                  ; Increment it by 1 cycle (42ms)
    .wait:
        cmp [TIMER], ax                     ; Compare with the current timer value
        jl .wait                            ; Loop until equal

jmp game_loop

; =========================================== DRAWING SPRITE PROCEDURE =========


draw_sprite:
    mov dx, SPRITE_LINES                    ; Number of lines in the sprite
    .draw_row:
        push dx                             ; Save DX
        xor ax,ax                           ; Clear AX  
        mov al, [si]                        ; Get sprite row data
        mov cx, 8                           ; 8 bits per row
        .draw_pixel:
            shl al, 1                       ; Shift left
            jnc .skip_pixel                 ; If carry flag is 0, skip
            mov [es:di], bl                 ; Set the pixel
        .skip_pixel:
            inc di                          ; Move to the next pixel position
            loop .draw_pixel                ; Repeat for all 8 pixels in the row
        pop dx                              ; Restore DX
        inc si
    add di, 312                             ; Move to the next line
    dec dx                                  ; Decrement row count
    jnz .draw_row                           ; Draw the next row
    ret


; =========================================== DATA =============================

MLT dw -320,-319,1,321,320,319,-1,-321      ; Movement Lookup Table
sprites:
db 0x60, 0x96, 0x49, 0x32, 0x5C, 0x7D, 0x1E ; Fly sprite frame 0
db 0x00, 0x00, 0x1E, 0x72, 0x5C, 0x7D, 0x1E ; Frame 1
db 0x06, 0x77, 0xAF, 0xFE, 0x2A, 0x49, 0x49 ; Spider sprite frame 0
db 0x06, 0x77, 0xAF, 0xFE, 0x2B, 0xD4, 0x14 ; Frame 1
db 0x1C, 0x36, 0x1C, 0x48, 0x3F, 0x08, 0x08 ; Flower sprite frame 0
db 0x38, 0x6C, 0x38, 0x09, 0x7E, 0x08, 0x08 ; Frame 1

; =========================================== BOOTSECTOR =======================

times 507 - ($ - $$) db 0                   ; Pad remaining bytes
db 'P1X'                                    ; P1X signature 3b
dw 0xAA55                                   ; Boot signature    