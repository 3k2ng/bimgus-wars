; main game loop

; ram location
KEY_CURRENT = $c5
JIFFY_CLOCK = $a2 ; the only byte that matters

CHARACTER_RAM = $1c00
SCREEN_RAM = $1e00
COLOR_RAM = $9600

; key code
KEY_SPACE = $20
KEY_UP_DOWN = $1f
KEY_LEFT_RIGHT = $17
KEY_ENTER = $0f

; screen code
SCREEN_EMPTY = 0
SCREEN_WALL = 1
SCREEN_CRACK = 2
SCREEN_BUSH = 3
SCREEN_TANK_UP = 4
SCREEN_BULLET_UP = 16
SCREEN_TANK_ROTATING_UP = 28
SCREEN_AMMO = 32

; color code
COLOR_BLACK = 0
COLOR_WHITE = 1
COLOR_RED = 2
COLOR_CYAN = 3
COLOR_PURPLE = 4
COLOR_GREEN = 5
COLOR_BLUE = 6
COLOR_YELLOW = 7

; rotation code
ROTATION_UP = 0
ROTATION_LEFT = 1
ROTATION_DOWN = 2
ROTATION_RIGHT = 3

; state mask
STATE_ROTATION = %11
STATE_MOVING = %100
STATE_ROTATING = %1000
STATE_SHOOTING = %10000

; offsets
OFFSET_IB_LOWER = 4
OFFSET_IB_UPPER = 8

; constants
SCREEN_WIDTH = 22
GAME_OFFSET = 69 ; offset from start of screen ram to start of game
AMMO_OFFSET = 421 ; offset from start of screen ram to where u should draw the ammo
GAME_WIDTH = 16
GAME_HEIGHT = 16

; zero page variables
; zp
PTR_TEMP = $fd
TEMP = $ff

; zp
PTR_SCREEN = $00 ; 2 bytes
PTR_COLOR = $02 ; 2 bytes
SCREEN_CURRENT = $04 ; 1 byte
COLOR_CURRENT = $05 ; 1 byte

ODD_FRAME = $0f ; 1 byte

; used for draw and stuff
STATE = $10 ; 1 byte
POSITION = $11 ; 1 byte
ROTATION = $12 ; 1 byte
FRONT = $13 ; 1 byte
NEIGHBOR_UP = $18 ; 1 byte
NEIGHBOR_LEFT = $19 ; 1 byte
NEIGHBOR_DOWN = $1a ; 1 byte
NEIGHBOR_RIGHT = $1b ; 1 byte

; used for storing which level the player is currently on
CURRENT_LEVEL = $26

; used to load and store tank info
TANK_INDEX = $5f ; 1 byte
TANK_STATE = $50 ; 1 byte
TANK_POSITION = $51 ; 1 byte
BULLET_POSITION = $52 ; 1 byte
TANK_FRONT = $53 ; 1 byte
BULLET_FRONT = $54 ; 1 byte
BULLET_BEHIND = $55 ; 1 byte
TANK_DETAIL = $56 ; 1 byte

; for nested loop
OTHER_TANK_INDEX = $5e ; 1 byte
OTHER_TANK_STATE = $58 ; 1 byte
OTHER_TANK_POSITION = $59 ; 1 byte
OTHER_BULLET_POSITION = $5a ; 1 byte

TARGET = $60 ; 1 byte
IN_LOS = $61 ; 1 byte

ENEMY_LEFT = $70 ; 1 byte

        seg.u local_level_data_zone
        org $1d10
; local variables
KEY_LAST
        ds.b 1
JIFFY_BIT_LAST
        ds.b 1
SHOOTING_BIT_LAST
        ds.b 1
; current level data
level_state
tile_data
        ds.b 64
tank_state ; %e-csmrRR
PLAYER_STATE
        ds.b 1
ENEMY_STATE
        ds.b 8
tank_position
PLAYER_POSITION
        ds.b 1 ; $yyxx
ENEMY_POSITION
        ds.b 8
PLAYER_AMMO
        ds.b 1
ENEMY_DETAIL
        ds.b 8 ;
; end of level data
bullet_position
PLAYER_BULLET
        ds.b 1
ENEMY_BULLET
        ds.b 8
        seg

        subroutine
main_game
        lda #<game_char_set
        sta ini
        lda #>game_char_set
        sta ini+1
        jsr full_decomp

        lda #$ff
        sta CURRENT_LEVEL

.next_level
        inc CURRENT_LEVEL
        lda CURRENT_LEVEL
        asl 
        tax
        lda level_data_table,X
        sta game_level_block_begin
        lda level_data_table+1,X
        sta game_level_block_begin+1

.load_level
        jsr clear_screen

        lda CURRENT_LEVEL
        cmp #NUM_LEVELS
        bne .continue_load
        rts
.continue_load
        lda #<game_level_block
        sta ini
        lda #>game_level_block
        sta ini+1
        jsr full_decomp

        lda #1
        sta ODD_FRAME

        jsr draw_tile
        lda #$40
        sta KEY_CURRENT
        ;sta KEY_LAST
        jmp .update_start

.mg_loop
        lda PLAYER_STATE
        and #STATE_SHOOTING
        beq .not_shooting
        lda JIFFY_CLOCK
        and #%100
        cmp JIFFY_BIT_LAST
        sta JIFFY_BIT_LAST
        bne .update_start
        jmp .skip_update
.not_shooting


        lda KEY_CURRENT
        cmp KEY_LAST
        sta KEY_LAST
        bne .update_start
        jmp .skip_update

.update_start

        ldx KEY_CURRENT
        cpx #KEY_ENTER
        bne .not_cheat_key_enter
        jmp .next_level
.not_cheat_key_enter

        inc ODD_FRAME
        lda ODD_FRAME
        and #1
        sta ODD_FRAME

        jsr reset_sfx_bitmask

        lda #$ff
        sta OTHER_TANK_INDEX
        lda #0
        sta TANK_INDEX
        jsr load_tank
        lda TANK_STATE
        bmi .load_level ; game_over

        lda #0
        sta ENEMY_LEFT
        lda #8
        sta TANK_INDEX
.move_loop
        jsr load_tank
        lda TANK_STATE
        bmi .skip_move_tank
        inc ENEMY_LEFT
        jsr move_tank
        jsr store_tank
.skip_move_tank
        dec TANK_INDEX
        bpl .move_loop

        dec ENEMY_LEFT
        bne .no_win
        jmp .next_level ; you win
.no_win

        lda PLAYER_STATE
        and #STATE_SHOOTING
        bne .no_lose ; player not shooting
        lda PLAYER_AMMO
        bne .no_lose
        jmp .load_level ; out of ammo
.no_lose

        lda #8
        sta TANK_INDEX
.collide_tank_loop
        jsr load_tank
        lda TANK_STATE
        bmi .skip_collide_tank ; tank not exist
        and #STATE_SHOOTING
        beq .skip_collide_tank ; not shooting
        jsr collide_tank
.skip_collide_tank
        dec TANK_INDEX
        bpl .collide_tank_loop

        lda #8
        sta TANK_INDEX
.collide_bullet_loop
        jsr load_tank
        lda TANK_STATE
        bmi .skip_collide_bullet ; tank not exist
        and #STATE_SHOOTING
        beq .skip_collide_bullet ; not shooting
        jsr collide_bullet
.skip_collide_bullet
        dec TANK_INDEX
        bpl .collide_bullet_loop

        lda #8
        sta TANK_INDEX
.draw_loop
        jsr load_tank
        lda TANK_STATE
        bmi .skip_draw_tank
        jsr draw_tank
.skip_draw_tank
        dec TANK_INDEX
        bpl .draw_loop

        lda #<SCREEN_RAM+<AMMO_OFFSET
        sta PTR_SCREEN
        lda #>SCREEN_RAM+>AMMO_OFFSET
        sta PTR_SCREEN+1
        lda #<COLOR_RAM+<AMMO_OFFSET
        sta PTR_COLOR
        lda #>COLOR_RAM+>AMMO_OFFSET
        sta PTR_COLOR+1
        ldy #16-1
.clean_ammo_area_loop
        lda #SCREEN_EMPTY
        sta SCREEN_CURRENT
        lda #COLOR_YELLOW
        sta COLOR_CURRENT
        jsr draw_screen
        dey
        bpl .clean_ammo_area_loop
        ldy PLAYER_AMMO
        dey
.draw_ammo_loop
        lda #SCREEN_AMMO
        sta SCREEN_CURRENT
        lda #COLOR_YELLOW
        sta COLOR_CURRENT
        jsr draw_screen
        dey
        bpl .draw_ammo_loop

.skip_update
        jmp .mg_loop

sprite_data
        incbin "./data/sprite_data.zx02"
sprite_data_end

        include "./zx02_level_data.s"

        jmp .load_level ; you win


        subroutine
move_tank

        lda TANK_STATE
        and #STATE_SHOOTING
        beq .not_shooting
        jmp .shooting
.not_shooting
        lda TANK_STATE
        and #STATE_ROTATING
        beq .not_rotating
        jmp .rotating
.not_rotating
        lda TANK_STATE
        and #STATE_MOVING
        beq .not_moving
        jmp .moving
.not_moving

        ldx TANK_INDEX
        bne .not_player
.read_key
        ldx KEY_CURRENT
        lda TANK_STATE
        cpx #KEY_UP_DOWN
        bne .not_up_down
        jsr player_movement
        ora #STATE_MOVING
.not_up_down
        cpx #KEY_LEFT_RIGHT
        bne .not_left_right
        jsr player_movement
        ora #STATE_ROTATING
.not_left_right
        cpx #KEY_SPACE
        bne .not_space
        jsr sfx_bullet
        ora #STATE_SHOOTING|STATE_MOVING
.not_space
        sta TANK_STATE
        jmp .check_front
.not_player

        lda ODD_FRAME
        beq .skip_odd_frame
        jsr check_los

        ldx TANK_DETAIL
        bne .not_basic_shoot
        lda TANK_STATE
        ora #STATE_SHOOTING|STATE_MOVING
        sta TANK_STATE
        jmp .check_front
.not_basic_shoot

        dex
        bne .not_basic_detect
        lda IN_LOS
        beq .not_in_los_0
        lda TANK_STATE
        ora #STATE_SHOOTING|STATE_MOVING
        sta TANK_STATE
.not_in_los_0
        jmp .check_front
.not_basic_detect

        dex
        bne .not_rotate_detect
        lda IN_LOS
        beq .not_in_los_1
        lda TANK_STATE
        ora #STATE_SHOOTING|STATE_MOVING
        sta TANK_STATE
        jmp .check_front
.not_in_los_1
        lda TANK_STATE
        ora #STATE_ROTATING
        sta TANK_STATE
        jmp .check_front
.not_rotate_detect

        dex
        bne .not_move_detect
        lda TANK_FRONT
        sta POSITION
        jsr read_target
        lda TARGET
        bne .have_to_rotate
        lda IN_LOS
        beq .not_in_los_2
        lda TANK_STATE
        ora #STATE_SHOOTING|STATE_MOVING
        sta TANK_STATE
        jmp .check_front
.not_in_los_2
        lda TANK_STATE
        ora #STATE_MOVING
        sta TANK_STATE
        jmp .check_front
.have_to_rotate
        lda TANK_STATE
        ora #STATE_ROTATING
        sta TANK_STATE
        jmp .check_front
.not_move_detect

.skip_odd_frame

.check_front
        lda TANK_FRONT
        sta POSITION
        jsr read_target

        lda TARGET
        beq .not_blocked
        cmp #SCREEN_WALL
        bne .not_wall
        lda TANK_STATE
        and #$ff^(STATE_MOVING|STATE_SHOOTING)
        sta TANK_STATE
.not_wall
        lda TANK_STATE
        and #$ff^STATE_MOVING
        sta TANK_STATE
.not_blocked

        lda TANK_STATE
        and #STATE_SHOOTING
        beq .skip_shooting

        lda TANK_POSITION
        sta BULLET_POSITION

.skip_shooting

        jmp .finish_moving

.moving
        lda TANK_POSITION
        sta POSITION
        jsr position2screen
        ldy #0
        lda #SCREEN_EMPTY
        sta SCREEN_CURRENT
        jsr draw_screen

        lda TANK_FRONT
        sta TANK_POSITION
        lda TANK_STATE
        and #STATE_ROTATION
        sta TANK_STATE
        jmp .finish_moving

.rotating
        inc TANK_STATE
        lda TANK_STATE
        and #STATE_ROTATION
        sta TANK_STATE
        jmp .finish_moving

.shooting
        lda TANK_STATE
        and #STATE_MOVING
        bne .bullet_moving

        lda BULLET_FRONT
        sta POSITION
        jsr read_target
        lda TARGET
        cmp #SCREEN_CRACK
        bne .no_crack
        jsr empty_position
        lda TANK_STATE
        and #$ff^STATE_SHOOTING
        sta TANK_STATE
        lda BULLET_POSITION
        sta POSITION
        jsr empty_position
        jmp .finish_moving
.no_crack
        lda TARGET
        cmp #SCREEN_WALL
        bne .no_wall
        lda TANK_STATE
        and #$ff^STATE_SHOOTING
        sta TANK_STATE
        lda BULLET_POSITION
        sta POSITION
        jsr empty_position
        jmp .finish_moving
.no_wall
        lda TANK_STATE
        ora #STATE_MOVING
        sta TANK_STATE
        jmp .finish_moving

.bullet_moving
        lda BULLET_POSITION
        sta POSITION
        jsr empty_position

        lda BULLET_FRONT
        sta BULLET_POSITION
        lda TANK_STATE
        and #STATE_ROTATION|STATE_SHOOTING
        sta TANK_STATE
        jmp .finish_moving
.finish_moving
        lda PLAYER_STATE
        and #STATE_SHOOTING
        cmp SHOOTING_BIT_LAST
        sta SHOOTING_BIT_LAST
        beq .player_not_just_shot
        lda SHOOTING_BIT_LAST
        beq .player_not_just_shot
        dec PLAYER_AMMO
.player_not_just_shot
        rts


        subroutine
collide_tank
        lda #8
        sta OTHER_TANK_INDEX
.inner_collision_loop
        jsr load_tank
        lda OTHER_TANK_INDEX
        cmp TANK_INDEX
        beq .skip_current_tank ; same tank
        lda OTHER_TANK_STATE
        bmi .skip_current_tank ; tank not exist
        lda OTHER_TANK_POSITION
        cmp BULLET_POSITION
        bne .not_collide_tank ; tank does not collide
        lda OTHER_TANK_STATE
        and #STATE_SHOOTING
        beq .shot_tank_not_shooting
        lda OTHER_BULLET_POSITION
        sta POSITION
        jsr empty_position
.shot_tank_not_shooting
        lda #$ff
        sta OTHER_TANK_STATE
        lda OTHER_TANK_POSITION
        sta POSITION
        jsr empty_position
        lda TANK_STATE
        and #STATE_ROTATION
        sta TANK_STATE
        jsr playerExplosion
.not_collide_tank
        jsr store_tank
.skip_current_tank
        dec OTHER_TANK_INDEX
        bpl .inner_collision_loop
        rts


        subroutine
collide_bullet
        lda #8
        sta OTHER_TANK_INDEX
.inner_collision_loop
        jsr load_tank
        lda OTHER_TANK_INDEX
        cmp TANK_INDEX
        beq .skip_current_tank ; same tank
        lda OTHER_TANK_STATE
        bmi .skip_current_tank ; tank not exist
        and #STATE_SHOOTING
        beq .skip_current_tank ; tank not shooting
        lda OTHER_BULLET_POSITION
        cmp BULLET_POSITION
        beq .collide_bullet ; bullet does not collide
        cmp BULLET_BEHIND
        beq .collide_bullet ; bullet does not collide
        jmp .skip_current_tank
.collide_bullet
        lda OTHER_TANK_STATE
        and #STATE_ROTATION
        sta OTHER_TANK_STATE
        lda TANK_STATE
        and #STATE_ROTATION
        sta TANK_STATE
        lda OTHER_BULLET_POSITION
        sta POSITION
        jsr empty_position
        lda BULLET_POSITION
        sta POSITION
        jsr empty_position
        jsr store_tank
.skip_current_tank
        dec OTHER_TANK_INDEX
        bpl .inner_collision_loop
        rts


        subroutine
draw_tank

        lda #SCREEN_BULLET_UP
        sta SCREEN_CURRENT

        ldx TANK_INDEX
        bne .not_drawing_player
        lda #COLOR_GREEN
        sta COLOR_CURRENT
        jmp .drawing_drawing
.not_drawing_player
        lda #COLOR_RED
        sta COLOR_CURRENT

.drawing_drawing
        lda TANK_STATE
        and #STATE_SHOOTING
        beq .skip_drawing_bullet
        lda TANK_STATE
        and #$ff^STATE_SHOOTING
        sta STATE
        lda BULLET_POSITION
        sta POSITION
        lda BULLET_FRONT
        sta FRONT
        jsr draw_entity
.skip_drawing_bullet

        lda #SCREEN_TANK_UP
        sta SCREEN_CURRENT
        lda TANK_STATE
        sta STATE
        lda TANK_POSITION
        sta POSITION
        lda TANK_FRONT
        sta FRONT
        jsr draw_entity
.finish_drawing
        rts


; zp
TARGET_POSITION = TEMP

        subroutine
check_los

        lda #0
        sta IN_LOS ;
        lda TANK_STATE
        and #STATE_ROTATION
        tax
        bne .not_up

        lda PLAYER_POSITION
        and #$f
        sta TARGET_POSITION
        lda TANK_POSITION
        and #$f
        cmp TARGET_POSITION
        bne .not_target_up

        lda PLAYER_POSITION
        and #$f0
        sta TARGET_POSITION
        lda TANK_POSITION
        and #$f0
        cmp TARGET_POSITION
        bmi .not_target_up
        inc IN_LOS
.not_target_up
        jmp .done_check
.not_up
        dex
        bne .not_left

        lda PLAYER_POSITION
        and #$f0
        sta TARGET_POSITION
        lda TANK_POSITION
        and #$f0
        cmp TARGET_POSITION
        bne .not_target_left

        lda PLAYER_POSITION
        and #$f
        sta TARGET_POSITION
        lda TANK_POSITION
        and #$f
        cmp TARGET_POSITION
        bmi .not_target_left
        inc IN_LOS
.not_target_left
        jmp .done_check
.not_left
        dex
        bne .not_down

        lda PLAYER_POSITION
        and #$f
        sta TARGET_POSITION
        lda TANK_POSITION
        and #$f
        cmp TARGET_POSITION
        bne .not_target_down

        lda PLAYER_POSITION
        and #$f0
        sta TARGET_POSITION
        lda TANK_POSITION
        and #$f0
        cmp TARGET_POSITION
        bpl .not_target_down
        inc IN_LOS
.not_target_down
        jmp .done_check
.not_down
        dex
        bne .not_right

        lda PLAYER_POSITION
        and #$f0
        sta TARGET_POSITION
        lda TANK_POSITION
        and #$f0
        cmp TARGET_POSITION
        bne .not_target_right

        lda PLAYER_POSITION
        and #$f
        sta TARGET_POSITION
        lda TANK_POSITION
        and #$f
        cmp TARGET_POSITION
        bpl .not_target_right
        inc IN_LOS
.not_target_right
        jmp .done_check
.not_right
.done_check
        rts


        subroutine
load_tank

        ldx TANK_INDEX
        lda tank_state,x
        sta TANK_STATE
        lda tank_position,x
        sta TANK_POSITION
        lda bullet_position,x
        sta BULLET_POSITION

        lda TANK_STATE
        and #STATE_ROTATION
        sta ROTATION

        lda TANK_POSITION
        sta POSITION
        jsr neighbor
        ldx ROTATION
        lda NEIGHBOR_UP,x
        sta TANK_FRONT

        lda BULLET_POSITION
        sta POSITION
        jsr neighbor
        ldx ROTATION
        lda NEIGHBOR_UP,x
        sta BULLET_FRONT

        inx
        inx
        txa
        and #3
        tax
        lda NEIGHBOR_UP,x
        sta BULLET_BEHIND

        ; TODO: add ammo and details loading
        ldx TANK_INDEX
        beq .not_loading_player
        dex
        lda ENEMY_DETAIL,x
        sta TANK_DETAIL
.not_loading_player

        ldx OTHER_TANK_INDEX
        bmi .skip_other_tank
        lda tank_state,x
        sta OTHER_TANK_STATE
        lda tank_position,x
        sta OTHER_TANK_POSITION
        lda bullet_position,x
        sta OTHER_BULLET_POSITION
.skip_other_tank
        rts

        subroutine
store_tank

        ldx TANK_INDEX
        lda TANK_STATE
        sta tank_state,x
        lda TANK_POSITION
        sta tank_position,x
        lda BULLET_POSITION
        sta bullet_position,x

        ldx OTHER_TANK_INDEX
        bmi .skip_other_tank
        lda OTHER_TANK_STATE
        sta tank_state,x
        lda OTHER_TANK_POSITION
        sta tank_position,x
        lda OTHER_BULLET_POSITION
        sta bullet_position,x
.skip_other_tank
        rts


; draw_entity
        subroutine
draw_entity
        clc
        lda SCREEN_CURRENT
        adc ROTATION
        sta SCREEN_CURRENT
        clc
        lda STATE
        and #STATE_SHOOTING
        bne .normal
        lda STATE
        and #STATE_MOVING|STATE_ROTATING
        beq .normal
        and #STATE_MOVING
        beq .rotating
.moving
        ldy #0
        lda SCREEN_CURRENT
        adc #OFFSET_IB_LOWER
        sta SCREEN_CURRENT
        jsr position2screen
        jsr draw_screen
        jsr neighbor
        lda FRONT
        sta POSITION
        clc
        lda SCREEN_CURRENT
        adc #OFFSET_IB_UPPER-OFFSET_IB_LOWER
        sta SCREEN_CURRENT
        jmp .draw
.rotating
        lda SCREEN_CURRENT
        adc #24
        sta SCREEN_CURRENT
.normal
        ; do nothing
.draw
        ldy #0
        jsr position2screen
        jmp draw_screen


        subroutine
read_target
        ; position loaded
        jsr position2screen
        ldy #0
        lda (PTR_SCREEN),y
        sta TARGET
        rts


        subroutine
empty_position
        jsr position2screen
        ldy #0
        lda #SCREEN_EMPTY
        sta SCREEN_CURRENT
        jmp draw_screen


; neighbor
        subroutine
neighbor

        clc
        lda POSITION
        adc #$10
        sta NEIGHBOR_DOWN
        clc
        sbc #$1f
        sta NEIGHBOR_UP
        lda POSITION
        and #$f0
        sta NEIGHBOR_LEFT
        sta NEIGHBOR_RIGHT
        lda POSITION
        and #$f
        tax ; left_x
        dex
        tay ; right_x
        iny
        clc
        txa
        and #$f
        adc NEIGHBOR_LEFT
        sta NEIGHBOR_LEFT
        clc
        tya
        and #$f
        adc NEIGHBOR_RIGHT
        sta NEIGHBOR_RIGHT
        rts


; zp
PTR_TILE = PTR_TEMP
LEVEL_BYTE = TEMP

; draw_tile
; -x-
        subroutine
draw_tile

        lda #COLOR_WHITE
        sta COLOR_CURRENT
        lda #<tile_data
        sta PTR_TILE
        lda #>tile_data
        sta PTR_TILE+1
        lda #$00
        sta POSITION

.byte
        jsr position2screen
        ldy #0
        lda (PTR_TILE),y
        sta LEVEL_BYTE

        ldy #3
.tile
        lda LEVEL_BYTE
        and #3
        sta SCREEN_CURRENT
        jsr draw_screen
        lda LEVEL_BYTE
        lsr
        lsr
        sta LEVEL_BYTE
        dey
        bpl .tile

        inc PTR_TILE
        bne .0
        inc PTR_TILE+1
.0

        clc
        lda POSITION
        adc #4
        sta POSITION
        bne .byte

        rts


; clear_screen
; -x-
        subroutine
clear_screen

        ldy #0
        lda #SCREEN_EMPTY
        sta SCREEN_CURRENT
        lda #COLOR_BLACK
        sta COLOR_CURRENT

        lda #<SCREEN_RAM
        sta PTR_SCREEN
        lda #>SCREEN_RAM
        sta PTR_SCREEN+1
        lda #<COLOR_RAM
        sta PTR_COLOR
        lda #>COLOR_RAM
        sta PTR_COLOR+1
.loop
        jsr draw_screen
        inc PTR_SCREEN
        bne .0
        inc PTR_SCREEN+1
.0
        inc PTR_COLOR
        bne .1
        inc PTR_COLOR+1
.1
        lda PTR_SCREEN+1
        cmp #>SCREEN_RAM+2
        bne .loop
        rts


; draw_screen
; -xY
        subroutine
draw_screen

        lda SCREEN_CURRENT
        sta (PTR_SCREEN),y
        lda COLOR_CURRENT
        sta (PTR_COLOR),y
        rts


; position2screen
; --y
        subroutine
position2screen

        clc
        lda POSITION
        and #$f
        adc #<SCREEN_RAM+<GAME_OFFSET
        sta PTR_SCREEN
        lda #>SCREEN_RAM+>GAME_OFFSET
        adc #0
        sta PTR_SCREEN+1

        clc
        lda POSITION
        and #$f
        adc #<COLOR_RAM+<GAME_OFFSET
        sta PTR_COLOR
        lda #>COLOR_RAM+>GAME_OFFSET
        adc #0
        sta PTR_COLOR+1

        lda POSITION
        lsr
        lsr
        lsr
        lsr
        beq .no_y
        tax
.y

        clc
        lda PTR_SCREEN
        adc #SCREEN_WIDTH
        sta PTR_SCREEN
        lda PTR_SCREEN+1
        adc #0
        sta PTR_SCREEN+1

        clc
        lda PTR_COLOR
        adc #SCREEN_WIDTH
        sta PTR_COLOR
        lda PTR_COLOR+1
        adc #0
        sta PTR_COLOR+1

        dex
        bne .y
.no_y
        rts
