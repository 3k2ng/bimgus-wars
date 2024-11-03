; main game loop

; ram location
JIFFY_CLOCK = $a2 ; the only byte that matters
CURRENT_KEY = $c5

CHARACTER_RAM = $1c00
SCREEN_RAM = $1e00
SCREEN_RAM_END = $2000
COLOR_RAM = $9600
COLOR_RAM_END = $9800

; keycode
UP_DOWN_KEY_CODE = $1f
LEFT_RIGHT_KEY_CODE = $17
SPACE_SCREEN_CODE = $e0

; constants
ROW_SIZE = 22
GAME_SCREEN_OFFSET = 69

; zero page variables
SCREEN_RAM_PTR = $00
COLOR_RAM_PTR = $02
; for draw_tank_sr
HEAD_X = $04

; local variables
LAST_KEY
        ds.b 1
PLAYER_LOCATION_X
        ds.b 1 ; [0, 32)
PLAYER_LOCATION_Y
        ds.b 1 ; [0, 32)
PLAYER_ROTATION
        ds.b 1 ; [0, 8)

main_game_loop
mgl_start

        ldx #0
load_sprite_loop
        lda sprite_data,x
        sta CHARACTER_RAM,x
        inx
        cpx sprite_data_end-sprite_data
        bne load_sprite_loop

        ldy #0
        lda #<SCREEN_RAM
        sta SCREEN_RAM_PTR
        lda #>SCREEN_RAM
        sta SCREEN_RAM_PTR+1
        lda #<COLOR_RAM
        sta COLOR_RAM_PTR
        lda #>COLOR_RAM
        sta COLOR_RAM_PTR+1
clear_screen_loop
        lda #$e0
        sta (SCREEN_RAM_PTR),y
        lda #1
        sta (COLOR_RAM_PTR),y
        inc SCREEN_RAM_PTR
        inc COLOR_RAM_PTR
        bne mgsc0
        inc SCREEN_RAM_PTR+1
        inc COLOR_RAM_PTR+1
        ldx SCREEN_RAM_PTR+1
        cpx #>SCREEN_RAM_END
        beq done_clear_screen
mgsc0
        jmp clear_screen_loop
done_clear_screen

        lda #0
        sta PLAYER_LOCATION_X
        sta PLAYER_LOCATION_Y
        sta PLAYER_ROTATION
        jmp draw_update

mgl_loop
; update key
        lda CURRENT_KEY
        cmp LAST_KEY
        sta LAST_KEY
        beq skip_drawing

        lda PLAYER_LOCATION_X
        and #1
        bne on_move
        lda PLAYER_LOCATION_Y
        and #1
        bne on_move
        lda PLAYER_ROTATION
        and #1
        bne on_rotate
        jmp check_key

check_key
        lda CURRENT_KEY
        cmp #UP_DOWN_KEY_CODE
        beq on_move
        cmp #LEFT_RIGHT_KEY_CODE
        beq on_rotate

skip_drawing
        jmp finish_update

on_move
        lda PLAYER_ROTATION
        cmp #0
        beq move_up
        cmp #2
        beq move_left
        cmp #4
        beq move_down
        cmp #6
        beq move_right

move_up
        dec PLAYER_LOCATION_Y
        jmp clamp_location
move_left
        dec PLAYER_LOCATION_X
        jmp clamp_location
move_down
        inc PLAYER_LOCATION_Y
        jmp clamp_location
move_right
        inc PLAYER_LOCATION_X
        jmp clamp_location

clamp_location
        lda PLAYER_LOCATION_X
        and #31 ; x_pos %= 32
        sta PLAYER_LOCATION_X
        lda PLAYER_LOCATION_Y
        and #31 ; y_pos %= 32
        sta PLAYER_LOCATION_Y
        jmp draw_update

on_rotate
        inc PLAYER_ROTATION
        lda PLAYER_ROTATION
        and #7
        sta PLAYER_ROTATION

draw_update
        jsr draw_tank_sr

finish_update
        jmp mgl_loop

break_loop
        rts

        subroutine
draw_tank_sr
        lda PLAYER_LOCATION_X
        lsr
        clc
        adc #<SCREEN_RAM_PTR
        adc #GAME_SCREEN_OFFSET
        sta SCREEN_RAM_PTR
        lda #>SCREEN_RAM
        adc #0
        sta SCREEN_RAM_PTR+1
        lda PLAYER_LOCATION_Y
        lsr
        beq skip_y_loop
        tax
.y_loop
        clc
        lda SCREEN_RAM_PTR
        adc #22
        sta SCREEN_RAM_PTR
        lda SCREEN_RAM_PTR+1
        adc #0
        sta SCREEN_RAM_PTR+1
        dex
        bne .y_loop
skip_y_loop
        lda PLAYER_ROTATION
        lsr
        asl
        asl
        ldy #0
        sta (SCREEN_RAM_PTR),y
        lda PLAYER_ROTATION
        and #1
        bne mid_rotation
        lda PLAYER_LOCATION_X
        and #1
        bne moving_horizontal
        lda PLAYER_LOCATION_Y
        and #1
        bne moving_vertical
        rts
mid_rotation
        clc
        lda (SCREEN_RAM_PTR),y
        adc #3
        sta (SCREEN_RAM_PTR),y
        rts
moving_horizontal
        clc
        lda (SCREEN_RAM_PTR),y
        adc #1
        sta (SCREEN_RAM_PTR),y
        iny
        adc #1
        sta (SCREEN_RAM_PTR),y
        rts
moving_vertical
        clc
        lda (SCREEN_RAM_PTR),y
        adc #1
        sta (SCREEN_RAM_PTR),y
        ldy #22
        adc #1
        sta (SCREEN_RAM_PTR),y
        rts

sprite_data
        include "./data/sprite_data.s"
sprite_data_end
