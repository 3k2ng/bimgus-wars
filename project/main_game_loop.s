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
SPACE_KEY_CODE = $20
UP_DOWN_KEY_CODE = $1f
LEFT_RIGHT_KEY_CODE = $17

; screen code
SPACE_SCREEN_CODE = $e0

; color code
BLACK_COLOR_CODE = 0
WHITE_COLOR_CODE = 1
RED_COLOR_CODE = 2
GREEN_COLOR_CODE = 5

; constants
ROW_SIZE = 22
GAME_SCREEN_OFFSET = 69

; zero page variables
SCREEN_RAM_PTR = $00 ; 2 bytes
COLOR_RAM_PTR = $02 ; 2 bytes
GAME_LOC_PTR = $04 ; 2 bytes for game_loc_to_ram
TANK_SCREEN_CODE = $06 ; 1 bytes for draw_tank_sr
TANK_COLOR_CODE = $07 ; 1 bytes for draw_tank_sr

; local variables
LAST_KEY
        ds.b 1
PLAYER_LOCATION_X
        ds.b 1 ; [0, 16)
PLAYER_LOCATION_Y
        ds.b 1 ; [0, 16)
PLAYER_ROTATION
        ds.b 1 ; [0, 4)
PLAYER_STATE_BITS
        ds.b 1 ; %0000 00rm

main_game_loop
mgl_start

        ldx #sprite_data_end-sprite_data
load_sprite_loop
        lda sprite_data-1,x
        sta CHARACTER_RAM-1,x
        dex
        bne load_sprite_loop

        lda #<SCREEN_RAM
        sta SCREEN_RAM_PTR
        lda #>SCREEN_RAM
        sta SCREEN_RAM_PTR+1
        lda #<COLOR_RAM
        sta COLOR_RAM_PTR
        lda #>COLOR_RAM
        sta COLOR_RAM_PTR+1
clear_screen_loop
        ldy #0
        lda #SPACE_SCREEN_CODE
        sta (SCREEN_RAM_PTR),y
        lda #BLACK_COLOR_CODE
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

        lda PLAYER_STATE_BITS
        beq check_key
        lsr
        sta PLAYER_STATE_BITS
        beq on_move
        lsr
        sta PLAYER_STATE_BITS
        beq on_rotate

check_key
        lda CURRENT_KEY
        tax
        lda PLAYER_STATE_BITS
        cpx #UP_DOWN_KEY_CODE
        bne not_up_down
        ora #1 ; begin moving forward
not_up_down
        cpx #LEFT_RIGHT_KEY_CODE
        bne not_left_right
        ora #2 ; begin rotating
not_left_right
        cpx #SPACE_KEY_CODE
        bne not_anything
        ;;; shoot i guess
        rts
not_anything
        sta PLAYER_STATE_BITS
        jmp draw_update

skip_drawing
        jmp finish_update

on_move
        lda #<PLAYER_LOCATION_X
        sta GAME_LOC_PTR
        lda #>PLAYER_LOCATION_X
        sta GAME_LOC_PTR+1
        jsr game_loc_to_ram
        ldy #0
        lda #SPACE_SCREEN_CODE
        sta (SCREEN_RAM_PTR),y
        lda #BLACK_COLOR_CODE
        sta (COLOR_RAM_PTR),y
        lda PLAYER_ROTATION
        cmp #0
        beq move_up
        cmp #1
        beq move_left
        cmp #2
        beq move_down
        cmp #3
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
        and #15 ; x_pos %= 16
        sta PLAYER_LOCATION_X
        lda PLAYER_LOCATION_Y
        and #15 ; y_pos %= 16
        sta PLAYER_LOCATION_Y
        jmp draw_update

on_rotate
        inc PLAYER_ROTATION
        lda PLAYER_ROTATION
        and #3
        sta PLAYER_ROTATION

draw_update
        lda #<PLAYER_LOCATION_X
        sta GAME_LOC_PTR
        lda #>PLAYER_LOCATION_X
        sta GAME_LOC_PTR+1
        lda #GREEN_COLOR_CODE
        sta TANK_COLOR_CODE
        jsr draw_tank_sr

finish_update
        jmp mgl_loop

break_loop
        rts

        subroutine
TANK_HEAD_X
        ds.b 1
TANK_HEAD_Y
        ds.b 1
draw_tank_sr
        jsr game_loc_to_ram
        ldy #2
        lda (GAME_LOC_PTR),y ; y = 2 -> game_loc_rotation
        asl
        asl
        sta TANK_SCREEN_CODE
        ldy #3
        lda (GAME_LOC_PTR),y ; y = 3 -> game_loc_state_bits
        beq .normal
        lsr
        beq .moving
        ; else .rotating
.rotating
        clc
        lda TANK_SCREEN_CODE
        adc #3
        sta TANK_SCREEN_CODE
        jmp .normal
.moving
        ldy #0
        inc TANK_SCREEN_CODE
        lda TANK_SCREEN_CODE
        sta (SCREEN_RAM_PTR),y
        lda TANK_COLOR_CODE
        sta (COLOR_RAM_PTR),y
        inc TANK_SCREEN_CODE
        lda (GAME_LOC_PTR),y ; y = 0 -> game_loc_x
        sta TANK_HEAD_X
        iny
        lda (GAME_LOC_PTR),y ; y = 1 -> game_loc_y
        sta TANK_HEAD_Y
        iny
        lda (GAME_LOC_PTR),y ; y = 2 -> game_loc_rotation
        tax
        beq .up
        dex
        beq .left
        dex
        beq .down
.right
        inc TANK_HEAD_X
        jmp .clamp_loc
.up
        dec TANK_HEAD_Y
        jmp .clamp_loc
.left
        dec TANK_HEAD_X
        jmp .clamp_loc
.down
        inc TANK_HEAD_Y
        jmp .clamp_loc
.clamp_loc
        lda TANK_HEAD_X
        and #15
        sta TANK_HEAD_X
        lda TANK_HEAD_Y
        and #15
        sta TANK_HEAD_Y

        lda #<TANK_HEAD_X
        sta GAME_LOC_PTR
        lda #>TANK_HEAD_X
        sta GAME_LOC_PTR+1
        jsr game_loc_to_ram
.normal
        ldy #0
        lda TANK_SCREEN_CODE
        sta (SCREEN_RAM_PTR),y
        lda TANK_COLOR_CODE
        sta (COLOR_RAM_PTR),y
        rts

        subroutine
game_loc_to_ram
        clc
        ldy #0
        lda (GAME_LOC_PTR),y ; y = 0 -> game_loc_x
        adc #<SCREEN_RAM
        adc #GAME_SCREEN_OFFSET
        sta SCREEN_RAM_PTR
        lda #>SCREEN_RAM
        adc #0
        sta SCREEN_RAM_PTR+1
        clc
        lda (GAME_LOC_PTR),y ; y = 0 -> game_loc_x
        adc #<COLOR_RAM
        adc #GAME_SCREEN_OFFSET
        sta COLOR_RAM_PTR
        lda #>COLOR_RAM
        adc #0
        sta COLOR_RAM_PTR+1
        iny
        lda (GAME_LOC_PTR),y ; y = 1 -> game_loc_y
        beq .skip_y_loop ; if game_loc_y == 0
        tax
.y_loop
        clc
        lda SCREEN_RAM_PTR
        adc #22
        sta SCREEN_RAM_PTR
        lda SCREEN_RAM_PTR+1
        adc #0
        sta SCREEN_RAM_PTR+1
        clc
        lda COLOR_RAM_PTR
        adc #22
        sta COLOR_RAM_PTR
        lda COLOR_RAM_PTR+1
        adc #0
        sta COLOR_RAM_PTR+1
        dex
        bne .y_loop
.skip_y_loop
        rts

sprite_data
        include "./data/sprite_data.s"
sprite_data_end

        ; include "./game_theme.s"