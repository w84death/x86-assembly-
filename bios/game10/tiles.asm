; GAME10 - Mysteries of the Forgotten Isles
; File name: tiles.asm
; Description: Tiles sprites data
; Size: 232 bytes
;
; Size category: 4096 bytes / 4KB
; Bootloader: 512 bytes
; Author: Krzysztof Krystian Jankowski
; Web: smol.p1x.in/assembly/forgotten-isles/
; License: MIT

; =========================================== TERRAIN TILES DATA ===============
; 8x8 tiles for terrain
; Data: number of lines, palettDefaulte id, lines (8 pixels) of palette color id

TerrainTiles:
db 0x8, 0x05          ; 0x1 Shore left bank
dw 0101011010111111b
dw 0001010110111111b
dw 0000010110101111b
dw 0000010110101111b
dw 0000010110101111b
dw 0000010110101111b
dw 0001010110111111b
dw 0101011010111111b

db 0x8, 0x05          ; 0x2 Shore top bank
dw 0100000000000001b
dw 0101000000000101b
dw 0101010101010101b
dw 1001010101010110b
dw 1010101010101010b
dw 1111101010101111b
dw 1111111111111111b
dw 1111111111111111b

db 0x8, 0x5          ; 0x3 Shore corner outside
dw 0000000001010101b
dw 0000010101010101b
dw 0001010101101001b
dw 0001011010101010b
dw 0101011010101010b
dw 0101101010101111b
dw 0101101010111111b
dw 0101011010111111b

db 0x8, 0x5          ; 0x4 Shore corner filler inside
dw 0101011010111111b
dw 0101011011111111b
dw 0101101011111111b
dw 1010101111111111b
dw 1011111111111111b
dw 1111111111111111b
dw 1111111111111111b
dw 1111111111111111b

db 0x8, 0x6          ; 0x5 Ground light
dw 1010101010101010b
dw 1010101010011010b
dw 1010011010111010b
dw 1010111010101010b
dw 1010101010101010b
dw 1010101001101010b
dw 1010101011101010b
dw 1010101010101010b

db 0x8, 0x6           ; 0x6 Ground medium
dw 1010101010101010b
dw 1010101010011010b
dw 1010011010011010b
dw 0110011010111010b
dw 0110111001101010b
dw 1101101001101010b
dw 1011101011100110b
dw 1010101010101110b

db 0x8, 0x6           ; 0x7 Ground dense
dw 1010101010101010b
dw 0110100110001010b
dw 0110101110011010b
dw 1110001010011010b
dw 1010011000111000b
dw 1010111001101001b
dw 1001101011101001b
dw 1011101010101011b

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
; free slot
; free slot
; free slot
; free slot
