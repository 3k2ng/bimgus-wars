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

	processor 6502

ZP=$80

offset  equ ZP+0
ZX0_src equ ZP+2
ZX0_dst equ ZP+4
bitr    equ ZP+6
pntr    equ ZP+7

	org $1001

        ; Initial values for offset, source, destination and bitr
zx0_ini_block
;       dc.b $00, $00, <comp_data, >comp_data, <out_addr, >out_addr, $80
        dc.b $00, $00, $69,        $f9,        $ce,       $cf,       $80 ;JCH

;--------------------------------------------------
; Decompress ZX0 data (6502 optimized format)

full_decomp
        ; Get initialization block
        ldy #7

copy_init
        lda zx0_ini_block-1,Y
        sta offset-1,Y
        dey
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
