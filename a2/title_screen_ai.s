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

; decode data at hmap to screen ram
        lda #SCRB0
        sta DECODED_DATA_LOC
        lda #SCRB1
        sta DECODED_DATA_LOC+1
        lda hmap_loc
        sta ENCODED_DATA_LOC
        lda hmap_loc+1
        sta ENCODED_DATA_LOC+1
        jsr hcc_decode

; decode data at hcm to color ram
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
hcc_decode:
decode_loop:
    ldy #00
    lda (ENCODED_DATA_LOC),y     ; Load value to be repeated
    iny
    lda (ENCODED_DATA_LOC),y     ; Load run-length
    tax                         ; Store run-length in X register

repeat_loop:
    lda (ENCODED_DATA_LOC-1),y   ; Load the value again
    sta (DECODED_DATA_LOC),y     ; Store it in decoded location

    inc DECODED_DATA_LOC
    bne sc0
    inc DECODED_DATA_LOC+1
sc0:
    dex                         ; Decrement run-length counter
    bne repeat_loop             ; Repeat if X > 0

    inc ENCODED_DATA_LOC         ; Move to the next value
    bne sc1
    inc ENCODED_DATA_LOC+1
sc1:
    
    lda (ENCODED_DATA_LOC),y     ; Check for end of data marker ($7F)
    cmp #$7f
    beq decode_done

    jmp decode_loop             ; Continue decoding

decode_done:
    rts

backread_start
        clc
        lda DECODED_DATA_LOC
        adc #01
        iny ; y = 1
        sbc (ENCODED_DATA_LOC),y
        sta BACKREAD_DATA_LOC
        lda DECODED_DATA_LOC+1
        sbc #00
        sta BACKREAD_DATA_LOC+1

        iny ; y = 2
        lda (ENCODED_DATA_LOC),y
        tax

        ldy #00
backread_loop
        lda (BACKREAD_DATA_LOC),y ; y = 0
        sta (DECODED_DATA_LOC),y ; y = 0

        inc BACKREAD_DATA_LOC
        bne sc2
        inc BACKREAD_DATA_LOC+1
sc2

        inc DECODED_DATA_LOC
        bne sc3
        inc DECODED_DATA_LOC+1
sc3

        dex
        bne backread_loop ; if x == 0

backread_exit
        clc
        lda ENCODED_DATA_LOC
        adc #03
        sta ENCODED_DATA_LOC
        lda ENCODED_DATA_LOC+1
        adc #00
        sta ENCODED_DATA_LOC+1
        jmp decode_loop

decode_exit
        rts

        ;include "./data/hcc_data.s"
        include "./data/rle_data.s"
