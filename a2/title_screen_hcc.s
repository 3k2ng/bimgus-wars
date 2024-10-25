; title_screen.s
;
; displaying the title screen
; game name: BIMGUS WARS
; team name: UR MOM
; year: 2024
; title picture: 1 green tank facing 3 red tank

	processor 6502

CHARACTER_RAM = $1c00

SCREEN_RAM = $1e00
; screen_ram split into 2 bytes
SCRB0 = $00
SCRB1 = $1e

COLOR_RAM = $9600
; color_ram split into 2 bytes
CORB0 = $00
CORB1 = $96

; zero page variable position
; decoding subroutine
; decoded data location (moving)
DECODED_DATA_LOC = $00 ; 2 bytes
; encoded data location (moving)
ENCODED_DATA_LOC = $02 ; 2 bytes
; where to read when reading buffer data (moving)
BACKREAD_DATA_LOC = $04 ; 2 bytes
; location on backread data
BACKREAD_INDEX = $06 ; 1 byte
; count down for back reading data
BACKREAD_COUNT = $07 ; 1 byte

	org $1001

; BASIC stub 
        dc.w nextstmt
        dc.w 10
        dc.b $9e, [start]d, 0
nextstmt
        dc.w 0

; main
start
; set character location to character ram
        lda #$ff
        sta $9005

; set screen and border color
        lda #$0b
        sta $900f

; copy custom character to character ram
        ldx #0
ccr_loop
        lda uncompressed_char_set,x
        sta CHARACTER_RAM,x
        inx
        cpx TITLE_CHAR_SET_SIZE
        bne ccr_loop

        lda #SCRB0
        sta DECODED_DATA_LOC
        lda #SCRB1
        sta DECODED_DATA_LOC+1
        lda hmap_loc
        sta ENCODED_DATA_LOC
        lda hmap_loc+1
        sta ENCODED_DATA_LOC+1
        jsr hcc_decode

        lda #CORB0
        sta DECODED_DATA_LOC
        lda #CORB1
        sta DECODED_DATA_LOC+1
        lda hcm_loc
        sta ENCODED_DATA_LOC
        lda hcm_loc+1
        sta ENCODED_DATA_LOC+1
        jsr hcc_decode

inf_loop
        jmp inf_loop

; decoding subroutine
hcc_decode
decode_loop
        ldy #00
        lda (ENCODED_DATA_LOC),y
        cmp #$7f
        beq decode_done
        cmp #$7e
        beq backread_start

        sta (DECODED_DATA_LOC),y

        clc
        lda ENCODED_DATA_LOC
        adc #01
        sta ENCODED_DATA_LOC
        lda ENCODED_DATA_LOC+1
        adc #00
        sta ENCODED_DATA_LOC+1

        clc
        lda DECODED_DATA_LOC
        adc #01
        sta DECODED_DATA_LOC
        lda DECODED_DATA_LOC+1
        adc #00
        sta DECODED_DATA_LOC+1

        jmp decode_loop
decode_done
        jmp decode_exit

backread_start
        lda DECODED_DATA_LOC
        sta BACKREAD_DATA_LOC
        lda DECODED_DATA_LOC+1
        sta BACKREAD_DATA_LOC+1
        ldy #01
        lda (ENCODED_DATA_LOC),y
        sta BACKREAD_INDEX
        ldy #02
        lda (ENCODED_DATA_LOC),y
        sta BACKREAD_COUNT
        clc
        lda ENCODED_DATA_LOC
        adc #03
        sta ENCODED_DATA_LOC
        lda ENCODED_DATA_LOC+1
        adc #00
        sta ENCODED_DATA_LOC+1

        clc
        lda BACKREAD_DATA_LOC
        adc #01
        sta BACKREAD_DATA_LOC
        lda BACKREAD_DATA_LOC+1
        adc #00
        sta BACKREAD_DATA_LOC+1

        clc
        lda BACKREAD_DATA_LOC
        sbc BACKREAD_INDEX
        sta BACKREAD_DATA_LOC
        lda BACKREAD_DATA_LOC+1
        sbc #00
        sta BACKREAD_DATA_LOC+1

backread_loop
        lda BACKREAD_COUNT
        cmp #00
        beq backread_exit

        ldy #00
        lda (BACKREAD_DATA_LOC),y
        sta (DECODED_DATA_LOC),y

        clc
        lda BACKREAD_DATA_LOC
        adc #01
        sta BACKREAD_DATA_LOC
        lda BACKREAD_DATA_LOC+1
        adc #00
        sta BACKREAD_DATA_LOC+1

        clc
        lda DECODED_DATA_LOC
        adc #01
        sta DECODED_DATA_LOC
        lda DECODED_DATA_LOC+1
        adc #00
        sta DECODED_DATA_LOC+1

        dec BACKREAD_COUNT

        jmp backread_loop

backread_exit
        jmp decode_loop

decode_exit
        rts

        include "./data/hcc_data.s"
