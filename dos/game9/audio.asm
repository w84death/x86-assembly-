org 0x100
use16


start:


game_loop:

        mov al, 0B6h  ; Command to set the speaker frequency
    out 43h, al   ; Write the command to the PIT chip
    mov ax, 2715  ; Frequency value for 440 Hz
    out 42h, al   ; Write the low byte of the frequency value
    mov al, ah
    out 42h, al   ; Write the high byte of the frequency value

    ; Enable the speaker
    in al, 61h    ; Read the PIC chip
    or al, 03h    ; Set bit 0 to enable the speaker
    out 61h, al   ; Write the updated value back to the PIC chip



delay:
    push es
    push 0x0040
    pop es
    mov bx, [es:0x006C]  ; Load the current tick count into BX
wait_for_tick:
    mov ax, [es:0x006C]  ; Load the current tick count
    sub ax, bx           ; Calculate elapsed ticks
    jz wait_for_tick     ; If not enough time has passed, keep waiting
    pop es

    in al, 61h    ; Read the PIC chip
    and al, 0FCh  ; Clear bit 0 to disable the speaker
    out 61h, al   ; Write the updated value back to the PIC chip


; =========================================== ESC OR LOOP =====================

    in al,0x60                           ; Read keyboard
    dec al
    jnz game_loop

; =========================================== TERMINATE PROGRAM ================
exit:
    mov ax, 0x0003
    int 0x10
    ret
