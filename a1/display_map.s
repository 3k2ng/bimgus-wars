; display_map.s
;
; load a map assembly file and try to display it
; map tiles use custom character set

	processor 6502

CHARACTER_RAM = $1c00

HALF_SCREEN = $fd
SCREEN_RAM_UPPER = $1e00
SCREEN_RAM_LOWER = $1efd
COLOR_RAM_UPPER = $9600
COLOR_RAM_LOWER = $96fd

SPACE_SCREEN_CODE = $e0
WHITE_COLOR_CODE = 1
RED_COLOR_CODE = 2
GREEN_COLOR_CODE = 5
BLUE_COLOR_CODE = 6

SCREEN_WIDTH = 22
MAP_WIDTH = 16
MAP_HEIGHT = 16

; zero page variable position
SCREEN_RAM_VAR = $00
MAP_DATA_VAR = $02
X_VAR = $03
Y_VAR = $04

	org $1001

; BASIC stub 
        dc.w nextstmt
        dc.w 10
        dc.b $9e, [start]d, 0
nextstmt
        dc.w 0

; main
start

; clear screen
        lda #SPACE_SCREEN_CODE
        ldx #0
csr_screen_ul
        sta SCREEN_RAM_UPPER,X
        inx
        cpx #HALF_SCREEN
        bne csr_screen_ul

        lda #SPACE_SCREEN_CODE
        ldx #0
csr_screen_ll
        sta SCREEN_RAM_LOWER,X
        inx
        cpx #HALF_SCREEN
        bne csr_screen_ll

; fill screen with color BLUE
        lda #WHITE_COLOR_CODE
        ldx #0
csr_color_ul
        sta COLOR_RAM_UPPER,X
        inx
        cpx #HALF_SCREEN
        bne csr_color_ul

        lda #WHITE_COLOR_CODE
        ldx #0
csr_color_ll
        sta COLOR_RAM_LOWER,X
        inx
        cpx #HALF_SCREEN
        bne csr_color_ll

; set character location to character ram
        lda #$ff
        sta $9005

; set screen and border color
        lda #$0b
        sta $900f

; copy custom character to character ram
        ldx #0
ccr_loop
        lda wall_char,X
        sta CHARACTER_RAM,X
        inx
        cpx #8*4
        bne ccr_loop

; copy map data to screen ram
        ; initiate screen ram address and map data offset on the zero page
        lda #$45
        sta SCREEN_RAM_VAR
        lda #$1e
        sta SCREEN_RAM_VAR+1
        lda #$00
        sta MAP_DATA_VAR

        ; initiate y
        lda #0
        sta Y_VAR
y_loop
        ; initiate x
        lda #0
        sta X_VAR
x_loop
        ; load map data at (x, y)
        ldy MAP_DATA_VAR
        lda map_data,y
        iny
        sty MAP_DATA_VAR
        ; put map data on screen
        ldy X_VAR
        sta (SCREEN_RAM_VAR),y
        iny
        sty X_VAR
        ; check if x hit map width
        cpy #MAP_WIDTH
        bne x_loop

        ; increment SCREEN_RAM_VAR everytime we increment y
        clc
        lda SCREEN_RAM_VAR
        adc #SCREEN_WIDTH
        sta SCREEN_RAM_VAR
        lda SCREEN_RAM_VAR+1
        adc #0
        sta SCREEN_RAM_VAR+1
        ldx Y_VAR
        inx
        stx Y_VAR
        ; check if y hit map height
        cpx #MAP_HEIGHT
        bne y_loop
 
inf_loop
        jmp inf_loop

wall_char
        include "./chars/wall.s"

map_data
        include "./maps/test.s"
