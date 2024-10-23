; title_screen.s
;
; displaying the title screen
; game name: BIMGUS WARS
; team name: UR MOM
; year: 2024
; title picture: 1 green tank facing 3 red tank

	processor 6502

CHARACTER_RAM = $1c00

SCREEN_WIDTH = 22
SCREEN_HEIGHT = 23

        seg.u zp
        org $0
; zero page variable position
SCREEN_RAM_VAR
        ds.w 1
COLOR_RAM_VAR
        ds.w 1
MAP_DATA_VAR
        ds.w 1
CM_DATA_VAR
        ds.w 1
X_VAR
        ds.b 1
Y_VAR
        ds.b 1
        seg

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
        lda title_char,x
        sta CHARACTER_RAM,x
        inx
        cpx #0
        bne ccr_loop

; copy map data to screen ram
        ; initiate screen ram address and map data offset on the zero page
        lda #$00
        sta SCREEN_RAM_VAR
        lda #$1e
        sta SCREEN_RAM_VAR+1
        lda #$00
        sta COLOR_RAM_VAR
        lda #$96
        sta COLOR_RAM_VAR+1
        lda title_map_loc
        sta MAP_DATA_VAR
        lda title_map_loc+1
        sta MAP_DATA_VAR+1
        lda title_cm_loc
        sta CM_DATA_VAR
        lda title_cm_loc+1
        sta CM_DATA_VAR+1

        ; initiate y
        lda #0
        sta Y_VAR
y_loop
        ; initiate x
        lda #0
        sta X_VAR
x_loop
        ; load map data at (x, y)
        ; put map data on screen
        ldy X_VAR
        lda (MAP_DATA_VAR),y
        sta (SCREEN_RAM_VAR),y
        lda (CM_DATA_VAR),y
        sta (COLOR_RAM_VAR),y
        iny
        sty X_VAR
        ; check if x hit map width
        cpy #SCREEN_WIDTH
        bne x_loop

        ; increment SCREEN_RAM_VAR everytime we increment y
        clc
        lda MAP_DATA_VAR
        adc #SCREEN_WIDTH
        sta MAP_DATA_VAR
        lda MAP_DATA_VAR+1
        adc #0
        sta MAP_DATA_VAR+1

        clc
        lda SCREEN_RAM_VAR
        adc #SCREEN_WIDTH
        sta SCREEN_RAM_VAR
        lda SCREEN_RAM_VAR+1
        adc #0
        sta SCREEN_RAM_VAR+1

        clc
        lda CM_DATA_VAR
        adc #SCREEN_WIDTH
        sta CM_DATA_VAR
        lda CM_DATA_VAR+1
        adc #0
        sta CM_DATA_VAR+1

        clc
        lda COLOR_RAM_VAR
        adc #SCREEN_WIDTH
        sta COLOR_RAM_VAR
        lda COLOR_RAM_VAR+1
        adc #0
        sta COLOR_RAM_VAR+1

        ldx Y_VAR
        inx
        stx Y_VAR
        ; check if y hit map height
        cpx #SCREEN_HEIGHT
        bne y_loop
 
inf_loop
        jmp inf_loop

title_map_loc
        dc.w title_map

title_cm_loc
        dc.w title_cm

title_char
        include "./data/title_char_set.s"

title_map
        include "./data/title_char_map.s"

title_cm
        include "./data/title_color_map.s"
