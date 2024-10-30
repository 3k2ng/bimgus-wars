; title_screen.s
;
; displaying the title screen
; game name: BIMGUS WARS
; team name: UR MOM
; year: 2024
; title picture: 1 green tank facing 3 red tanks

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
        jsr rle_decode  ; Call the RLE decoding routine

; decode data at hcm to color ram
        lda #CORB0
        sta DECODED_DATA_LOC
        lda #CORB1
        sta DECODED_DATA_LOC+1
        lda hcm_loc
        sta ENCODED_DATA_LOC
        lda hcm_loc+1
        sta ENCODED_DATA_LOC+1
        jsr rle_decode  ; Call the RLE decoding routine

inf_loop
        jmp inf_loop

; RLE decoding subroutine
rle_decode:
    ldy #0              ; Initialize index Y
decode_rle_loop:
    lda (ENCODED_DATA_LOC),y ; y = 0
    iny
    lda (ENCODED_DATA_LOC),y   ; Read count (second byte of the tuple)
    tay                       ; Store count in Y

rle_copy_loop:
    lda (ENCODED_DATA_LOC),y  ; Copy value to the decoded location
    sta (DECODED_DATA_LOC),y
    inc DECODED_DATA_LOC       ; Increment decoded data pointer
    bne rle_copy_next
    inc DECODED_DATA_LOC+1     ; Handle high byte overflow
rle_copy_next:
    dey                        ; Decrement count
    bne rle_copy_loop          ; If count not zero, keep copying

    iny                        ; Move to next RLE tuple
    iny
    inc ENCODED_DATA_LOC       ; Advance encoded data pointer
    bne decode_rle_loop        ; Continue until all data is decoded

rle_decode_done:
    rts                        ; Return from subroutine

; Original decoding subroutine (optional, if needed elsewhere)
hcc_decode:
decode_loop:
    ldy #00
    lda (ENCODED_DATA_LOC),y
    cmp #$7f
    beq decode_done
    cmp #$7e
    beq backread_start

    sta (DECODED_DATA_LOC),y

    inc ENCODED_DATA_LOC
    bne sc0
    inc ENCODED_DATA_LOC+1
sc0:

    inc DECODED_DATA_LOC
    bne sc1
    inc DECODED_DATA_LOC+1
sc1:

    jmp decode_loop
decode_done:
    jmp decode_exit

backread_start:
    clc
    lda DECODED_DATA_LOC
    adc #01
    iny
    sbc (ENCODED_DATA_LOC),y
    sta BACKREAD_DATA_LOC
    lda DECODED_DATA_LOC+1
    sbc #00
    sta BACKREAD_DATA_LOC+1

    iny
    lda (ENCODED_DATA_LOC),y
    tax

    ldy #00
backread_loop:
    lda (BACKREAD_DATA_LOC),y
    sta (DECODED_DATA_LOC),y

    inc BACKREAD_DATA_LOC
    bne sc2
    inc BACKREAD_DATA_LOC+1
sc2:

    inc DECODED_DATA_LOC
    bne sc3
    inc DECODED_DATA_LOC+1
sc3:

    dex
    bne backread_loop

backread_exit:
    clc
    lda ENCODED_DATA_LOC
    adc #03
    sta ENCODED_DATA_LOC
    lda ENCODED_DATA_LOC+1
    adc #00
    sta ENCODED_DATA_LOC+1
    jmp decode_loop

decode_exit:
    rts

    # include "./data/hcc_data.s"
    include "./data/rle_data.s"
