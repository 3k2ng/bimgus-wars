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

        lda character_ram_args
        sta DATA_DST_LOC
        lda character_ram_args+1
        sta DATA_DST_LOC+1
        lda character_ram_args+2
        sta DATA_SRC_LOC
        lda character_ram_args+3
        sta DATA_SRC_LOC+1
        lda character_ram_args+4
        sta SRC_END_LOC
        lda character_ram_args+5
        sta SRC_END_LOC+1
        jsr copy_data
 
        lda screen_ram_args
        sta DATA_DST_LOC
        lda screen_ram_args+1
        sta DATA_DST_LOC+1
        lda screen_ram_args+2
        sta DATA_SRC_LOC
        lda screen_ram_args+3
        sta DATA_SRC_LOC+1
        lda screen_ram_args+4
        sta SRC_END_LOC
        lda screen_ram_args+5
        sta SRC_END_LOC+1
        jsr copy_data

        lda color_ram_args
        sta DATA_DST_LOC
        lda color_ram_args+1
        sta DATA_DST_LOC+1
        lda color_ram_args+2
        sta DATA_SRC_LOC
        lda color_ram_args+3
        sta DATA_SRC_LOC+1
        lda color_ram_args+4
        sta SRC_END_LOC
        lda color_ram_args+5
        sta SRC_END_LOC+1
        jsr copy_data

inf_loop
        jmp inf_loop

; copy subroutine, just need to copy the argument location to subroutine input location
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

character_ram_args
        dc.w CHARACTER_RAM, uncompressed_char_set, uncompressed_char_set_end
screen_ram_args
        dc.w SCREEN_RAM, uncompressed_char_map, uncompressed_char_map_end
color_ram_args
        dc.w COLOR_RAM, uncompressed_color_map, uncompressed_color_map_end

        include "./data/uncompressed_data.s"
