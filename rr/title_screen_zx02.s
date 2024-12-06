; zx02 compression for title screen
; the original source is at https://github.com/dmsc/zx02/blob/main/6502/zx02-optim.asm
;
; displaying the title screen
; game name: BIMGUS WARS
; team name: UR MOM
; year: 2024
; title picture: 1 green tank facing 3 red tank

; De-compressor for ZX02 files
; ----------------------------
;
; Decompress ZX02 data (6502 optimized format), optimized for speed and size
;  138 bytes code, 58.0 cycles/byte in test file.
;
; Compress with:
;    zx02 input.bin output.zx0
;
; (c) 2022 DMSC
; Code under MIT license, see LICENSE file.

; Info pertaining to ZX02
ZP=$80

offset  equ ZP+0
ZX0_src equ ZP+2
ZX0_dst equ ZP+4
bitr    equ ZP+6
pntr    equ ZP+7
ini     equ ZP+9
index   equ ZP+11

; Info pertaining to writing to screen
CHARACTER_RAM = $1c00
; character_ram split into 2 bytes
CHRB0 = $00
CHRB1 = $1c

SCREEN_RAM = $1e00
; screen_ram split into 2 bytes
SCRB0 = $00
SCRB1 = $1e

COLOR_RAM = $9600
; color_ram split into 2 bytes
CORB0 = $00
CORB1 = $96

; Info pertaining to input reading
CHROUT = $ffd2

; CURRENT_KEY = $c5

; SPACE_KEY_CODE = $20
; UP_DOWN_KEY_CODE = $1f
; LEFT_RIGHT_KEY_CODE = $17

; main
decompress_all
        lda #3
        sta index
; Decompress the title screen
        ; char set
        lda #<ini_block
        sta ini
        lda #>ini_block
        sta ini+1
        clc
        jmp test7
        ; char map, color map, etc.
decomp_loop
        lda ini                 ; get the LSB of the ini pointer
        adc #7                  ; increment by 7
        sta ini                 ; store new pointer
        bcc test7               ; if the carry flag was set, we crossed a page
        inc ini+1               ; increment the MSB of the pointer
test7
        jsr full_decomp         ; call decompression subroutine
        dec index               ; move on to the next ini block
        bne decomp_loop         ; if 0, we are done
        ; all done!
        rts


        ; Initial values for offset, source, destination and bitr
        ; dc.b $00, $00, <comp_data, >comp_data, <out_addr, >out_addr, $80
ini_block
; char set
        dc.b $00, $00
        dc.w zx02_char_set, CHARACTER_RAM
        dc.b $80
; char map
        dc.b $00, $00
        dc.w zx02_char_map, SCREEN_RAM
        dc.b $80
; color map
        dc.b $00, $00
        dc.w zx02_color_map, COLOR_RAM
        dc.b $80
; game char set
game_char_set
        dc.b $00, $00
        dc.w sprite_data, CHARACTER_RAM
        dc.b $80
game_level_block
        dc.b $00, $00
game_level_block_begin
        dc.w level_1_data, level_state
        dc.b $80

;--------------------------------------------------
; Decompress ZX0 data (6502 optimized format)

full_decomp
        ; Get initialization block
        ldy #7

copy_init
        dey
        lda (ini),Y ; JCH
        sta offset,Y
        cpy #0
        bne copy_init

; Decode literal: Ccopy next N bytes from compressed file
;    Elias(length)  byte[1]  byte[2]  ...  byte[N]
decode_literal
        jsr   get_elias

cop0    lda   (ZX0_src),Y
        inc   ZX0_src
        bne   test4 ; JCH
        inc   ZX0_src+1
test4   sta   (ZX0_dst),Y ; JCH
        inc   ZX0_dst
        bne   test5 ; JCH
        inc   ZX0_dst+1
test5   dex ; JCH
        bne   cop0

        asl   bitr
        bcs   dzx0s_new_offset

; Copy from last offset (repeat N bytes from last offset)
;    Elias(length)
        jsr   get_elias
dzx0s_copy
        lda   ZX0_dst
        sbc   offset  ; C=0 from get_elias
        sta   pntr
        lda   ZX0_dst+1
        sbc   offset+1
        sta   pntr+1

cop1
        lda   (pntr),Y
        inc   pntr
        bne   test1 ; JCH
        inc   pntr+1
test1   sta   (ZX0_dst),Y ; JCH
        inc   ZX0_dst
        bne   test2 ; JCH
        inc   ZX0_dst+1
test2   dex ; JCH
        bne   cop1

        asl   bitr
        bcc   decode_literal

; Copy from new offset (repeat N bytes from new offset)
;    Elias(MSB(offset))  LSB(offset)  Elias(length-1)
dzx0s_new_offset
        ; Read elias code for high part of offset
        jsr   get_elias
        beq   exit  ; Read a 0, signals the end
        ; Decrease and divide by 2
        dex
        txa
        lsr ; JCH
        sta   offset+1

        ; Get low part of offset, a literal 7 bits
        lda   (ZX0_src),Y
        inc   ZX0_src
        bne   test3 ; JCH
        inc   ZX0_src+1
test3 ; JCH
        ; Divide by 2
        ror ; JCH
        sta   offset

        ; And get the copy length.
        ; Start elias reading with the bit already in carry:
        ldx   #1
        jsr   elias_skip1

        inx
        bcc   dzx0s_copy

; Read an elias-gamma interlaced code.
; ------------------------------------
get_elias
        ; Initialize return value to #1
        ldx   #1
        bne   elias_start

elias_get     ; Read next data bit to result
        asl   bitr
        rol
        tax

elias_start
        ; Get one bit
        asl   bitr
        bne   elias_skip1

        ; Read new bit from stream
        lda   (ZX0_src),Y
        inc   ZX0_src
        bne   test6 ; JCH
        inc   ZX0_src+1
test6   ;sec   ; not needed, C=1 guaranteed from last bit ; JCH
        rol ; JCH
        sta   bitr

elias_skip1
        txa
        bcs   elias_get
        ; Got ending bit, stop reading
exit
        rts

        include "zx02_data.s"