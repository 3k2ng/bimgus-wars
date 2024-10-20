; tank_control.s
;
; use the control from read input to draw the tank
; no color yet

	processor 6502

CHARACTER_RAM = $1c00

HALF_SCREEN = $fd
SCREEN_RAM_UPPER = $1e00
SCREEN_RAM_LOWER = $1efd
COLOR_RAM_UPPER = $9600
COLOR_RAM_LOWER = $96fd

UP_DOWN_KEY_CODE = $1f
LEFT_RIGHT_KEY_CODE = $17

SPACE_SCREEN_CODE = $e0
WHITE_COLOR_CODE = 1

SCREEN_WIDTH = 22
MAP_WIDTH = 16
MAP_HEIGHT = 16

; zero page variable position
SCREEN_RAM_VAR = $00 ; variable for offsetting into screen ram
X_VAR = $02 ; x for keeping track of drawing cursor
Y_VAR = $03 ; y for keeping track of drawing cursor
LAST_KEY = $04 ; last key pressed
X_POS = $05 ; tank position x
Y_POS = $06 ; tank position y
ROT = $07 ; tank rotation
CURRENT_KEY = $c5 ; automatically updated current key held

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
        lda tank_char,X
        sta CHARACTER_RAM,X
        inx
        cpx #8*16
        bne ccr_loop

        ; initiate variables
        lda #$40 ; last key pressed is empty
        sta LAST_KEY
        lda #$08 ; start at the middle of the screen
        sta X_POS 
        sta Y_POS
        lda #$00 ; start facing up
        sta ROT

        jmp draw_update ; start with a draw

; inf_loop is the game loop
inf_loop
; check key
        lda CURRENT_KEY
        cmp LAST_KEY
        sta LAST_KEY
        beq skip_draw ; if no key changed, make no change

        cmp #UP_DOWN_KEY_CODE
        beq on_move

        cmp #LEFT_RIGHT_KEY_CODE
        beq on_rotate

skip_draw
        jmp finish_update ; key not accounted for

on_move
        lda ROT
        cmp #$0
        beq move_up
        cmp #$1
        beq move_left
        cmp #$2
        beq move_down
        cmp #$3
        beq move_right

move_up
        dec Y_POS
        lda Y_POS
        and #$0f ; y_pos %= 16
        sta Y_POS
        jmp draw_update

move_left
        dec X_POS
        lda X_POS
        and #$0f ; x_pos %= 16
        sta X_POS
        jmp draw_update

move_down
        inc Y_POS
        lda Y_POS
        and #$0f ; y_pos %= 16
        sta Y_POS
        jmp draw_update

move_right
        inc X_POS
        lda X_POS
        and #$0f ; x_pos %= 16
        sta X_POS
        jmp draw_update

on_rotate
        inc ROT
        lda ROT
        and #$03 ; rotation %= 4
        sta ROT

draw_update
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

; fill screen with color WHITE
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

        ; initiate screen ram pointer
        lda #$45
        sta SCREEN_RAM_VAR
        lda #$1e
        sta SCREEN_RAM_VAR+1

        ; initiate y
        lda #0
        sta Y_VAR
y_loop
        ; initiate x
        lda #0
        sta X_VAR
x_loop
        ; check if we're at the right position
        lda X_VAR
        cmp X_POS
        bne skip_tank
        lda Y_VAR
        cmp Y_POS
        bne skip_tank

        ; rotation also represent the correct char to draw
        lda ROT
        asl
        adc ROT
        ; put map data on screen
        ldy X_VAR
        sta (SCREEN_RAM_VAR),y
skip_tank
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

finish_update
        jmp inf_loop

tank_char
        include "./chars/tank.s"
