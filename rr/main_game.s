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

; screen code
SCREEN_EMPTY = 0
SCREEN_WALL = 1
SCREEN_CRACK = 2
SCREEN_BUSH = 3
SCREEN_TANK_UP = 4
SCREEN_BULLET_UP = 16
SCREEN_TANK_ROTATING_UP = 28

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
STATE_CATAPULT = %100000

; offsets
OFFSET_IB_LOWER = 4
OFFSET_IB_UPPER = 8

; constants
SCREEN_WIDTH = 22
GAME_OFFSET = 69 ; offset from start of screen ram to start of game
GAME_WIDTH = 16
GAME_HEIGHT = 16

; zero page variables
; zp
PTR_TEMP = $fd
TEMP = $ff

; zp
PTR_SCREEN = $00 ; 2 bytes
PTR_COLOR = $02 ; 2 bytes
SCREEN_CURRENT = $04
COLOR_CURRENT = $05

STATE = $10 ; 1 byte
POSITION = $11 ; 1 byte
NEIGHBOR_UP = $12 ; 1 byte
NEIGHBOR_LEFT = $13 ; 1 byte
NEIGHBOR_DOWN = $14 ; 1 byte
NEIGHBOR_RIGHT = $15 ; 1 byte

TANK_INDEX = $50 ; 1 byte

; local variables
KEY_LAST
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
        ds.b 2
ENEMY_DETAIL
        ds.b 8 ; %----TTAA
; end of level data
bullet_position
PLAYER_BULLET
        ds.b 1
ENEMY_BULLET
        ds.b 8

        subroutine
main_game
        lda #<sprite_data
        sta PTR_COPY_SRC
        lda #>sprite_data
        sta PTR_COPY_SRC+1
        lda #<sprite_data_end
        sta PTR_COPY_SRC_END
        lda #>sprite_data_end
        sta PTR_COPY_SRC_END+1
        lda #<CHARACTER_RAM
        sta PTR_COPY_DST
        lda #>CHARACTER_RAM
        sta PTR_COPY_DST+1
        jsr copy

        jsr clear_screen

        lda #<level_data
        sta PTR_COPY_SRC
        lda #>level_data
        sta PTR_COPY_SRC+1
        lda #<level_data_end
        sta PTR_COPY_SRC_END
        lda #>level_data_end
        sta PTR_COPY_SRC_END+1
        lda #<level_state
        sta PTR_COPY_DST
        lda #>level_state
        sta PTR_COPY_DST+1
        jsr copy

        jsr draw_tile

.mg_loop
        lda KEY_CURRENT
        cmp KEY_LAST
        sta KEY_LAST
        bne .update_start
        jmp .skip_update

.update_start
        lda #8
        sta TANK_INDEX

.update_loop
        ldx TANK_INDEX
        lda tank_state,x
        bmi .skip_tank
        jsr update_tank
        jsr draw_tank
.skip_tank
        dec TANK_INDEX
        bmi .break
        jmp .update_loop
.break

.skip_update
        jmp .mg_loop

        rts

sprite_data
        include "./data/sprite_data.s"
sprite_data_end

level_data
        include "./data/level_data.s"
level_data_end


; update_tank
        subroutine
update_tank
        ldx TANK_INDEX
        lda tank_state,x
        and #STATE_ROTATING
        beq .not_rotating
        jmp .rotating
.not_rotating
        lda tank_state,x
        and #STATE_MOVING
        beq .not_moving
        jmp .moving
.not_moving

        ldx TANK_INDEX
        bne .not_player
        lda KEY_CURRENT
        tax
        lda PLAYER_STATE
        cpx #KEY_UP_DOWN
        bne .not_up_down
        ora #STATE_MOVING
.not_up_down
        cpx #KEY_LEFT_RIGHT
        bne .not_left_right
        ora #STATE_ROTATING
.not_left_right
        ldx TANK_INDEX
        sta tank_state,x
.not_player

        ldx TANK_INDEX
        lda tank_position,x
        sta POSITION
        jsr neighbor
        ldx TANK_INDEX
        lda tank_state,x
        and #STATE_ROTATION
        tay
        lda NEIGHBOR_UP,y
        sta POSITION
        jsr position2screen

        ldy #0
        lda (PTR_SCREEN),y
        beq .not_blocked
        ldx TANK_INDEX
        lda tank_state,x
        and #$ff^STATE_MOVING
        sta tank_state,x
.not_blocked

        jmp .finish_update


.rotating
        inc tank_state,x
        lda tank_state,x
        and #STATE_ROTATION
        sta tank_state,x
        jmp .finish_update
.moving
        ldy #0
        lda #SCREEN_EMPTY
        sta SCREEN_CURRENT
        lda tank_position,x
        sta POSITION
        jsr position2screen
        jsr draw_screen
        jsr neighbor
        ldx TANK_INDEX
        lda tank_state,x
        and #STATE_ROTATION
        sta tank_state,x
        tay
        lda NEIGHBOR_UP,y
        sta tank_position,x
.finish_update
        rts


; draw_tank
        subroutine
draw_tank
        lda #SCREEN_TANK_UP
        sta SCREEN_CURRENT
        lda #COLOR_RED
        ldx TANK_INDEX
        bne .not_player
        lda #COLOR_GREEN
.not_player
        sta COLOR_CURRENT
        lda tank_state,x
        sta STATE
        lda tank_position,x
        sta POSITION
        jsr draw_entity
        rts


; draw_entity
        subroutine
draw_entity
        clc
        lda STATE
        and #STATE_ROTATION
        adc SCREEN_CURRENT
        sta SCREEN_CURRENT
        clc
        lda STATE
        and #STATE_ROTATING|STATE_MOVING
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
        lda STATE
        and #STATE_ROTATION
        tax
        lda NEIGHBOR_UP,x
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
        jsr draw_screen
        rts


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
AMMO_TYPE = TEMP

; ammo_color
; --y
        subroutine
ammo_color
        ldx AMMO_TYPE
        beq .normal
        dex
        beq .rock
.bomb
        lda #COLOR_YELLOW
        jmp .color
.rock
        lda #COLOR_CYAN
        jmp .color
.normal
        lda #COLOR_RED
.color
        sta COLOR_CURRENT
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
        and #$0f
        adc #<SCREEN_RAM+<GAME_OFFSET
        sta PTR_SCREEN
        lda #>SCREEN_RAM+>GAME_OFFSET
        adc #0
        sta PTR_SCREEN+1

        clc
        lda POSITION
        and #$0f
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


; zp
PTR_COPY_SRC = $80 ; 2 bytes
PTR_COPY_SRC_END = $82 ; 2 bytes
PTR_COPY_DST = $84 ; 2 bytes

; copy
; -x-
        subroutine
copy
        ldy #0
.copy_loop
        lda PTR_COPY_SRC
        cmp PTR_COPY_SRC_END
        bne .0
        lda PTR_COPY_SRC+1
        cmp PTR_COPY_SRC_END+1
        beq .copy_done
.0
        lda (PTR_COPY_SRC),y
        sta (PTR_COPY_DST),y
        inc PTR_COPY_SRC
        bne .1
        inc PTR_COPY_SRC+1
.1
        inc PTR_COPY_DST
        bne .2
        inc PTR_COPY_DST+1
.2
        jmp .copy_loop
.copy_done
        rts
