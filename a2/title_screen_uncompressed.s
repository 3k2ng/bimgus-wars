; uncompressed title screen
;
; displaying the title screen
; game name: BIMGUS WARS
; team name: UR MOM
; year: 2024
; title picture: 1 green tank facing 3 red tank

	processor 6502

CHARACTER_RAM = $1c00
SCREEN_RAM = $1e00
COLOR_RAM = $9600

; zero page variable position
; decoding subroutine
; decoded data location (moving)
DATA_DST_LOC = $00 ; 2 bytes
; encoded data location (moving)
DATA_SRC_LOC = $02 ; 2 bytes
; back of encoded data chunk (moving)
SRC_END_LOC = $04 ; 2 bytes

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

; set up arguments on the zero page, and then call copy subroutine
        ; copy character data
        lda #<CHARACTER_RAM
        sta DATA_DST_LOC
        lda #>CHARACTER_RAM
        sta DATA_DST_LOC+1
        lda #<uncompressed_char_set
        sta DATA_SRC_LOC
        lda #>uncompressed_char_set
        sta DATA_SRC_LOC+1
        lda #<uncompressed_char_set_end
        sta SRC_END_LOC
        lda #>uncompressed_char_set_end
        sta SRC_END_LOC+1
        jsr copy_data
 
        ; copy screen data
        lda #<SCREEN_RAM
        sta DATA_DST_LOC
        lda #>SCREEN_RAM
        sta DATA_DST_LOC+1
        lda #<uncompressed_char_map
        sta DATA_SRC_LOC
        lda #>uncompressed_char_map
        sta DATA_SRC_LOC+1
        lda #<uncompressed_char_map_end
        sta SRC_END_LOC
        lda #>uncompressed_char_map_end
        sta SRC_END_LOC+1
        jsr copy_data

        ; copy color data
        lda #<COLOR_RAM
        sta DATA_DST_LOC
        lda #>COLOR_RAM
        sta DATA_DST_LOC+1
        lda #<uncompressed_color_map
        sta DATA_SRC_LOC
        lda #>uncompressed_color_map
        sta DATA_SRC_LOC+1
        lda #<uncompressed_color_map_end
        sta SRC_END_LOC
        lda #>uncompressed_color_map_end
        sta SRC_END_LOC+1
        jsr copy_data

inf_loop
        jmp inf_loop

; copy subroutine
copy_data
        ldy #00
copy_loop
        lda (DATA_SRC_LOC),y
        sta (DATA_DST_LOC),y
        inc DATA_SRC_LOC
        bne sc0
        inc DATA_SRC_LOC+1
sc0
        inc DATA_DST_LOC
        bne sc1
        inc DATA_DST_LOC+1
sc1
        lda DATA_SRC_LOC
        cmp SRC_END_LOC
        bne copy_loop
        lda DATA_SRC_LOC+1
        cmp SRC_END_LOC+1
        bne copy_loop
        rts

        include "./data/uncompressed_data.s"
