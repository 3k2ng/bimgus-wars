; main game loop

; ram location
CURRENT_KEY = $c5
JIFFY_CLOCK = $a2 ; the only byte that matters

; CHARACTER_RAM = $1c00
; SCREEN_RAM = $1e00
SCREEN_RAM_END = $2000
; COLOR_RAM = $9600
COLOR_RAM_END = $9800

; keycode
SPACE_KEY_CODE = $20
UP_DOWN_KEY_CODE = $1f
LEFT_RIGHT_KEY_CODE = $17
F1_KEY_CODE = $0f

; screen code
SPACE_SCREEN_CODE = $00
WALL_SCREEN_CODE = $01
CRACK_SCREEN_CODE = $02
BUSH_SCREEN_CODE = $03
TANK_UP_SCREEN_CODE = $04
BULLET_SCREEN_CODE = $18

; color code
BLACK_COLOR_CODE = 0
WHITE_COLOR_CODE = 1
RED_COLOR_CODE = 2
GREEN_COLOR_CODE = 5

; rotation code
ROTATION_CODE_UP = 0
ROTATION_CODE_LEFT = 1
ROTATION_CODE_DOWN = 2
ROTATION_CODE_RIGHT = 3

; state bits
STATE_BIT_MOVING = 1
STATE_BIT_ROTATION = 2

; offsets
DATA_OFFSET_X = 0
DATA_OFFSET_Y = 1
DATA_OFFSET_ROTATION = 2

SCREEN_CODE_OFFSET_TANK_ROTATING = 3

; constants
SCREEN_ROW_SIZE = 22
GAME_SCREEN_OFFSET = 69
GAME_SIZE_WIDTH = 16
GAME_SIZE_HEIGHT = 16
ROTATION_COUNT = 4
MAX_ENEMY_TANK_COUNT = 8
TANK_DATA_SIZE = 3
MAX_SHOT_COUNT = 8

; zero page variables
LEVEL_DATA_PTR = $00 ; 2 bytes
SCREEN_RAM_PTR = $02 ; 2 bytes
COLOR_RAM_PTR = $04 ; 2 bytes
TANK_DATA_PTR = $06 ; 2 bytes
TANK_SCREEN_CODE = $08 ; 1 bytes
TANK_COLOR_CODE = $09 ; 1 bytes
TANK_STATE = $0a ; 1 bytes
DURATION_TEMP = $0b ; 1 byte

; local variables
LAST_KEY
        ds.b 1
ENEMY_TANK_INDEX
        ds.b 1
all_tank_data ; since player_tank_data and enemy_tank_data are right next to each other, we can load them both with a loop
player_tank_data ; 3 bytes for tank_x, tank_y, tank_rotation
        ds.b 3
enemy_tank_data
        ds.b 3*8
player_shot_data ; there are max 8 shots, and shots data can be [0, 3)
        ds.b 8
all_tank_state
player_tank_state
        ds.b 1
enemy_tank_state
        ds.b 1*8

; main_game_loop
        subroutine
main_game_loop
        lda #<level_data
        sta LEVEL_DATA_PTR
        lda #>level_data
        sta LEVEL_DATA_PTR+1

        ldx #sprite_data_end-sprite_data
.load_sprite_loop
        lda sprite_data-1,x
        sta CHARACTER_RAM-1,x
        dex
        bne .load_sprite_loop

        lda #<SCREEN_RAM
        sta SCREEN_RAM_PTR
        lda #>SCREEN_RAM
        sta SCREEN_RAM_PTR+1
        lda #<COLOR_RAM
        sta COLOR_RAM_PTR
        lda #>COLOR_RAM
        sta COLOR_RAM_PTR+1
.clear_screen_loop
        ldy #0
        lda #SPACE_SCREEN_CODE
        sta (SCREEN_RAM_PTR),y
        lda #BLACK_COLOR_CODE
        sta (COLOR_RAM_PTR),y
        inc SCREEN_RAM_PTR
        bne .mgsc0
        inc SCREEN_RAM_PTR+1
.mgsc0
        inc COLOR_RAM_PTR
        bne .mgsc1
        inc COLOR_RAM_PTR+1
.mgsc1
        lda SCREEN_RAM_PTR+1
        cmp #>SCREEN_RAM_END
        bne .clear_screen_loop

.mgl_start
        ldy #0
        lda (LEVEL_DATA_PTR),y
        bpl .load_level ; if level exist
        rts
        
.load_level
        lda #<SCREEN_RAM+GAME_SCREEN_OFFSET
        sta SCREEN_RAM_PTR
        lda #>SCREEN_RAM
        sta SCREEN_RAM_PTR+1
        lda #<COLOR_RAM+GAME_SCREEN_OFFSET
        sta COLOR_RAM_PTR
        lda #>COLOR_RAM
        sta COLOR_RAM_PTR+1
        ldx #GAME_SIZE_HEIGHT-1
.lv_x_loop
        ldy #GAME_SIZE_WIDTH-1
.lv_y_loop
        lda (LEVEL_DATA_PTR),y
        sta (SCREEN_RAM_PTR),y
        beq .skip_color
        lda #WHITE_COLOR_CODE
        sta (COLOR_RAM_PTR),y
.skip_color
        dey
        bpl .lv_y_loop

        clc
        lda LEVEL_DATA_PTR
        adc #GAME_SIZE_WIDTH
        sta LEVEL_DATA_PTR
        lda LEVEL_DATA_PTR+1
        adc #0
        sta LEVEL_DATA_PTR+1

        clc
        lda SCREEN_RAM_PTR
        adc #SCREEN_ROW_SIZE
        sta SCREEN_RAM_PTR
        lda SCREEN_RAM_PTR+1
        adc #0
        sta SCREEN_RAM_PTR+1

        clc
        lda COLOR_RAM_PTR
        adc #SCREEN_ROW_SIZE
        sta COLOR_RAM_PTR
        lda COLOR_RAM_PTR+1
        adc #0
        sta COLOR_RAM_PTR+1

        dex
        bpl .lv_x_loop

; load player tank data
        ldy #(MAX_ENEMY_TANK_COUNT+1)*TANK_DATA_SIZE+MAX_SHOT_COUNT-1
.load_tank_loop
        lda (LEVEL_DATA_PTR),y
        sta all_tank_data,y
        dey
        bpl .load_tank_loop

; finally increment the level data pointer to point to the start of the next level
        clc
        lda LEVEL_DATA_PTR
        adc #(MAX_ENEMY_TANK_COUNT+1)*TANK_DATA_SIZE+MAX_SHOT_COUNT
        sta LEVEL_DATA_PTR
        lda LEVEL_DATA_PTR+1
        adc #0
        sta LEVEL_DATA_PTR+1

; draw the bullets
        ldy #7
.draw_bullets_loop
        clc
        lda player_shot_data,y
        beq .no_bullet
        adc #BULLET_SCREEN_CODE
.no_bullet
        sta (SCREEN_RAM_PTR),y
        sbc #BULLET_SCREEN_CODE
        adc #GREEN_COLOR_CODE-1
        sta (COLOR_RAM_PTR),y
        dey
        bpl .draw_bullets_loop

        ldy #MAX_ENEMY_TANK_COUNT+1-1
.load_state_loop
        lda #0
        sta all_tank_state,y
        dey
        bpl .load_state_loop

        jsr play_game_theme
        
        jmp .draw_update

.mgl_loop
; update key
        lda CURRENT_KEY
        cmp LAST_KEY
        sta LAST_KEY
        beq .skip_drawing

        lda #<player_tank_data
        sta TANK_DATA_PTR
        lda #>player_tank_data
        sta TANK_DATA_PTR+1
        lda player_tank_state
        sta TANK_STATE
        jsr get_tank_head
        lda #<tank_head_data
        sta TANK_DATA_PTR
        lda #>tank_head_data
        sta TANK_DATA_PTR+1
        jsr tank_data_to_ram

        lda player_tank_state
        beq .check_key
        lsr
        sta player_tank_state
        beq .on_move
        lsr
        sta player_tank_state
        beq .on_rotate

.check_key
        lda CURRENT_KEY
        tax
        lda player_tank_state
        cpx #UP_DOWN_KEY_CODE
        bne .not_up_down
        ora #STATE_BIT_MOVING
.not_up_down
        cpx #LEFT_RIGHT_KEY_CODE
        bne .not_left_right
        ora #STATE_BIT_ROTATION
.not_left_right
        ; cheat code 'f1' - load next level
        cpx #F1_KEY_CODE
        bne .not_f1
        jmp .mgl_start
        ; jmp .break_loop
.not_f1
        cpx #SPACE_KEY_CODE
        bne .not_anything
        ;;; shoot i guess
        jsr sfx_bullet
.not_anything
        sta player_tank_state

        ldy #0
        lda (SCREEN_RAM_PTR),y
        beq .not_blocked
        lda player_tank_state
        and #STATE_BIT_ROTATION
        sta player_tank_state
.not_blocked

        jmp .draw_update

.skip_drawing
        jmp .finish_update

.on_rotate
        inc player_tank_data+DATA_OFFSET_ROTATION
        lda player_tank_data+DATA_OFFSET_ROTATION
        and #ROTATION_COUNT-1
        sta player_tank_data+DATA_OFFSET_ROTATION
        jmp .draw_update

.on_move
        lda #<player_tank_data
        sta TANK_DATA_PTR
        lda #>player_tank_data
        sta TANK_DATA_PTR+1
        lda player_tank_state
        sta TANK_STATE
        jsr tank_data_to_ram
        ldy #0
        lda #SPACE_SCREEN_CODE
        sta (SCREEN_RAM_PTR),y
        lda #BLACK_COLOR_CODE
        sta (COLOR_RAM_PTR),y
        lda player_tank_data+DATA_OFFSET_ROTATION
        ; ROTATION_CODE_UP == 0
        beq .move_up
        cmp #ROTATION_CODE_LEFT
        beq .move_left
        cmp #ROTATION_CODE_DOWN
        beq .move_down
        cmp #ROTATION_CODE_RIGHT
        beq .move_right

.move_up
        dec player_tank_data+DATA_OFFSET_Y
        jmp .clamp_location
.move_left
        dec player_tank_data+DATA_OFFSET_X
        jmp .clamp_location
.move_down
        inc player_tank_data+DATA_OFFSET_Y
        jmp .clamp_location
.move_right
        inc player_tank_data+DATA_OFFSET_X
        jmp .clamp_location

.clamp_location
        lda player_tank_data
        and #GAME_SIZE_WIDTH-1 ; %= 16
        sta player_tank_data
        lda player_tank_data+1
        and #GAME_SIZE_HEIGHT-1 ; %= 16
        sta player_tank_data+1

.draw_update
        ; draw player tank
        lda #<player_tank_data
        sta TANK_DATA_PTR
        lda #>player_tank_data
        sta TANK_DATA_PTR+1
        lda #GREEN_COLOR_CODE
        sta TANK_COLOR_CODE
        lda player_tank_state
        sta TANK_STATE
        jsr draw_tank_sr

        ; draw enemy tanks
        lda #RED_COLOR_CODE
        sta TANK_COLOR_CODE
        lda #0
        sta ENEMY_TANK_INDEX
.draw_enemy_loop
        clc
        lda TANK_DATA_PTR
        adc #TANK_DATA_SIZE
        sta TANK_DATA_PTR
        lda TANK_DATA_PTR+1
        adc #0
        sta TANK_DATA_PTR+1

        ldy ENEMY_TANK_INDEX
        lda enemy_tank_data,y
        bmi .skip_current_enemy_draw

        lda enemy_tank_state,y
        sta TANK_STATE
        jsr draw_tank_sr
.skip_current_enemy_draw
        inc ENEMY_TANK_INDEX
        lda ENEMY_TANK_INDEX
        cmp #MAX_ENEMY_TANK_COUNT
        bne .draw_enemy_loop

.finish_update
        jsr update_game_theme
        jmp .mgl_loop

; draw_tank_sr
        subroutine
draw_tank_sr
        jsr tank_data_to_ram
        ldy #DATA_OFFSET_ROTATION
        lda (TANK_DATA_PTR),y ; y = 2 -> tank_rotation
        asl
        asl
        clc
        adc #TANK_UP_SCREEN_CODE
        sta TANK_SCREEN_CODE
        lda TANK_STATE
        beq .normal
        lsr
        beq .moving
        ; else .rotating

.rotating
        clc
        lda TANK_SCREEN_CODE
        adc #SCREEN_CODE_OFFSET_TANK_ROTATING
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
        jsr get_tank_head

        lda #<tank_head_data
        sta TANK_DATA_PTR
        lda #>tank_head_data
        sta TANK_DATA_PTR+1
        jsr tank_data_to_ram

.normal
        ldy #0
        lda TANK_SCREEN_CODE
        sta (SCREEN_RAM_PTR),y
        lda TANK_COLOR_CODE
        sta (COLOR_RAM_PTR),y
        rts

; tank_data_to_ram
; get tank data at TANK_DATA_PTR (tank_x, tank_y) and calculate corresponding SCREEN_RAM and COLOR_RAM location
        subroutine
tank_data_to_ram
        clc
        ldy #0
        lda (TANK_DATA_PTR),y ; y = 0 -> tank_x
        adc #<SCREEN_RAM+GAME_SCREEN_OFFSET
        sta SCREEN_RAM_PTR
        lda #>SCREEN_RAM
        adc #0
        sta SCREEN_RAM_PTR+1
        clc
        lda (TANK_DATA_PTR),y ; y = 0 -> tank_x
        adc #<COLOR_RAM+GAME_SCREEN_OFFSET
        sta COLOR_RAM_PTR
        lda #>COLOR_RAM
        adc #0
        sta COLOR_RAM_PTR+1
        iny
        lda (TANK_DATA_PTR),y ; y = 1 -> tank_y
        beq .skip_y_loop ; if tank_y == 0
        tax

.y_loop
        clc
        lda SCREEN_RAM_PTR
        adc #SCREEN_ROW_SIZE
        sta SCREEN_RAM_PTR
        lda SCREEN_RAM_PTR+1
        adc #0
        sta SCREEN_RAM_PTR+1
        clc
        lda COLOR_RAM_PTR
        adc #SCREEN_ROW_SIZE
        sta COLOR_RAM_PTR
        lda COLOR_RAM_PTR+1
        adc #0
        sta COLOR_RAM_PTR+1
        dex
        bne .y_loop
.skip_y_loop
        rts

; get_tank_head
; read tank data from TANK_DATA_PTR (tank_x, tank_y, and tank_rot) and calculate the tile in front of the tank
        subroutine
tank_head_data
TANK_HEAD_X
        ds.b 1
TANK_HEAD_Y
        ds.b 1
get_tank_head
        ldy #0
        lda (TANK_DATA_PTR),y ; y = 0 -> tank_x
        sta TANK_HEAD_X
        iny
        lda (TANK_DATA_PTR),y ; y = 1 -> tank_y
        sta TANK_HEAD_Y
        iny
        lda (TANK_DATA_PTR),y ; y = 2 -> tank_rot
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
        and #GAME_SIZE_WIDTH-1 ; %=16
        sta TANK_HEAD_X
        lda TANK_HEAD_Y
        and #GAME_SIZE_HEIGHT-1 ; %=16
        sta TANK_HEAD_Y
        rts

sprite_data
        include "./data/sprite_data.s"
sprite_data_end

level_data
        include "./data/level_data.s"
level_data_end

        include "./sound_effects.s"
        include "./game_theme.s"
