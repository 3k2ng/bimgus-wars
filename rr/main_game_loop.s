; main game loop

; ram location
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
EMPTY_SCREEN_CODE = $00
WALL_SCREEN_CODE = $01
CRACK_SCREEN_CODE = $02
BUSH_SCREEN_CODE = $03
TANK_N_SCREEN_CODE = $04
TANK_NW_SCREEN_CODE = $10
BULLET_N_SCREEN_CODE = $14
SHOT_1_SCREEN_CODE = $20

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

; offsets

; constants
SCREEN_ROW_SIZE = 22
GAME_SCREEN_OFFSET = 69
GAME_SIZE_WIDTH = 16
GAME_SIZE_HEIGHT = 16

; zero page variables
; zp
LEVEL_DATA_PTR = $00 ; 2 bytes
SCREEN_RAM_PTR = $02 ; 2 bytes
COLOR_RAM_PTR = $04 ; 2 bytes

; local variables
LAST_KEY
        ds.b 1
; current level data
current_level_data
tile_data
        ds.b 64
tile_data_end
player_data
PLAYER_STATE
        ds.b 1 ; %000srmRR
PLAYER_POSITION
        ds.b 1 ; $yyxx
enemy_data
        ds.b 16 ; same as player data
player_shots_info
        ds.b 2
; end of level data
bullet_data
player_bullet
        ds.b 1
enemy_bullet
        ds.b 8

TANK_INDEX
        ds.b 1

        subroutine
main_game_loop
        ; use copy subroutine to load character set
        lda #<sprite_data
        sta COPY_SRC
        lda #>sprite_data
        sta COPY_SRC+1
        lda #<sprite_data_end
        sta COPY_SRC_END
        lda #>sprite_data_end
        sta COPY_SRC_END+1
        lda #<CHARACTER_RAM
        sta COPY_DST
        lda #>CHARACTER_RAM
        sta COPY_DST+1
        jsr copy_sr

        ; initialize level data pointer
        lda #<level_data
        sta LEVEL_DATA_PTR
        lda #>level_data
        sta LEVEL_DATA_PTR+1

        ; clear the screen
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
        lda #EMPTY_SCREEN_CODE
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
        lda LEVEL_DATA_PTR
        cmp #<level_data_end
        bne .load_level
        lda LEVEL_DATA_PTR+1
        cmp #>level_data_end
        bne .load_level
        rts

        ; load level
.load_level
        clc
        lda LEVEL_DATA_PTR
        sta COPY_SRC
        adc #84
        sta COPY_SRC_END
        lda LEVEL_DATA_PTR+1
        sta COPY_SRC+1
        adc #0
        sta COPY_SRC_END+1
        lda #<current_level_data
        sta COPY_DST
        lda #>current_level_data
        sta COPY_DST+1
        jsr copy_sr

        jsr draw_tile

.mgl_loop
; update key
        lda CURRENT_KEY
        cmp LAST_KEY
        sta LAST_KEY
        beq .skip_drawing

        lda PLAYER_POSITION
        sta GF_POSITION
        lda PLAYER_STATE
        and #3
        sta GF_ROTATION
        jsr get_front
        lda GF_FRONT
        sta P2S_POSITION
        jsr position2screen

        lda PLAYER_STATE
        and #%00000100
        bne .on_move
        lda PLAYER_STATE
        and #%00001000
        bne .on_rotate

.check_key
        lda CURRENT_KEY
        tax
        lda PLAYER_STATE
        cpx #UP_DOWN_KEY_CODE
        bne .not_up_down
        ora #%00000100
.not_up_down
        cpx #LEFT_RIGHT_KEY_CODE
        bne .not_left_right
        ora #%00001000
.not_left_right
        sta PLAYER_STATE

        ldy #0
        lda (SCREEN_RAM_PTR),y
        beq .not_blocked
        lda PLAYER_STATE
        and #%00001011
        sta PLAYER_STATE
.not_blocked

        jmp .draw_update

.skip_drawing
        jmp .finish_update

.on_rotate
        inc PLAYER_STATE
        lda PLAYER_STATE
        and #3
        sta PLAYER_STATE
        jmp .draw_update

.on_move
        lda PLAYER_STATE
        and #3
        sta PLAYER_STATE
        lda PLAYER_POSITION
        sta P2S_POSITION
        jsr position2screen
        ldy #0
        lda #EMPTY_SCREEN_CODE
        sta (SCREEN_RAM_PTR),y
        jsr get_front
        lda GF_FRONT
        sta PLAYER_POSITION

.draw_update
        lda #TANK_N_SCREEN_CODE
        sta DE_N_SCREEN_CODE
        lda #RED_COLOR_CODE
        sta DE_COLOR

        lda #16
        sta TANK_INDEX
.draw_tank_loop
        ldy TANK_INDEX
        bne .not_player
        lda #GREEN_COLOR_CODE
        sta DE_COLOR
.not_player
        lda player_data,y
        sta DE_STATE
        bmi .skip_current_tank
        iny
        lda player_data,y
        sta DE_POSITION
        jsr draw_entity
.skip_current_tank
        dec TANK_INDEX
        dec TANK_INDEX
        bpl .draw_tank_loop

.finish_update
        jmp .mgl_loop

;inf_loop
;        jmp inf_loop

        rts

sprite_data
        include "./data/sprite_data.s"
sprite_data_end

level_data
        include "./data/level_data.s"
level_data_end

; draw tile from level data
; zp
; P2S_POSITION = $80 ; 1 byte
TILE_DATA_PTR = $81 ; 2 bytes
DT_BYTE = $83 ; 1 byte
DT_POSITION = $84 ; 1 byte

        subroutine
draw_tile
        lda #<tile_data
        sta TILE_DATA_PTR
        lda #>tile_data
        sta TILE_DATA_PTR+1
        lda #0
        sta DT_POSITION

.dt_loop_byte
        lda DT_POSITION
        sta P2S_POSITION
        jsr position2screen
        ldy #0
        lda (TILE_DATA_PTR),y
        sta DT_BYTE

        ldy #3
.dt_loop_tile
        lda DT_BYTE
        and #3
        sta (SCREEN_RAM_PTR),y
        lda DT_BYTE
        lsr
        lsr
        sta DT_BYTE
        lda #WHITE_COLOR_CODE
        sta (COLOR_RAM_PTR),y
        dey
        bpl .dt_loop_tile

        inc TILE_DATA_PTR
        bne .dt_sk0
        inc TILE_DATA_PTR+1
.dt_sk0
        clc
        lda DT_POSITION
        adc #4
        sta DT_POSITION
        bne .dt_loop_byte
        rts

; draw entity, like tank or bullet
; input position, state, n_screen_code and color
; please remove the shooting bit before calling draw entity <--- READ THIS
DE_POSITION = $80 ; 1 byte
DE_ROTATION = $81 ; 1 byte
;GF_FRONT = $82 ; 1 byte
;GF_X = $83 ; 1 byte
DE_STATE = $84 ; 1 byte
DE_N_SCREEN_CODE = $85 ; 1 byte
DE_SCREEN_CODE = $86 ; 1 byte
DE_COLOR = $87 ; 1 byte

        subroutine
draw_entity
        jsr position2screen
        ldy #0
        lda DE_STATE
        and #$3
        sta DE_ROTATION
        lda DE_STATE
        lsr
        lsr
        beq .normal
        lsr
        beq .moving
.rotating
        clc
        lda DE_N_SCREEN_CODE
        adc #12
        adc DE_ROTATION
        sta (SCREEN_RAM_PTR),y
        lda DE_COLOR
        sta (COLOR_RAM_PTR),y
        rts
.moving
        clc
        lda DE_ROTATION
        asl
        adc DE_ROTATION
        adc DE_N_SCREEN_CODE
        adc #1
        sta DE_SCREEN_CODE
        sta (SCREEN_RAM_PTR),y
        lda DE_COLOR
        sta (COLOR_RAM_PTR),y
        jsr get_front
        lda GF_FRONT
        sta DE_POSITION
        jsr position2screen
        inc DE_SCREEN_CODE
        lda DE_SCREEN_CODE
        sta (SCREEN_RAM_PTR),y
        lda DE_COLOR
        sta (COLOR_RAM_PTR),y
        rts
.normal
        clc
        lda DE_ROTATION
        asl
        adc DE_ROTATION
        adc DE_N_SCREEN_CODE
        sta (SCREEN_RAM_PTR),y
        lda DE_COLOR
        sta (COLOR_RAM_PTR),y
        rts

; convert 1 byte position to screen ram position
; zp
P2S_POSITION = $80 ; 1 byte

        subroutine
position2screen
        clc
        lda P2S_POSITION
        and #$0f
        adc #<SCREEN_RAM+GAME_SCREEN_OFFSET
        sta SCREEN_RAM_PTR
        lda #>SCREEN_RAM
        adc #0
        sta SCREEN_RAM_PTR+1
        clc
        lda P2S_POSITION
        and #$0f
        adc #<COLOR_RAM+GAME_SCREEN_OFFSET
        sta COLOR_RAM_PTR
        lda #>COLOR_RAM
        adc #0
        sta COLOR_RAM_PTR+1

        lda P2S_POSITION
        lsr
        lsr
        lsr
        lsr
        beq .y_loop_exit
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
.y_loop_exit
        rts

; get the position in front of the given position, give a rotation
; zp
GF_POSITION = $80 ; 1 byte
GF_ROTATION = $81 ; 1 byte
GF_FRONT = $82 ; 1 byte
GF_X = $83 ; 1 byte

        subroutine
get_front
        lda GF_POSITION
        and #$0f
        sta GF_X
        lda GF_POSITION
        and #$f0
        sta GF_FRONT
        ldx GF_ROTATION
        clc ; <--- clc
        beq .up
        dex
        beq .left
        dex
        beq .down
.right
        inc GF_X
        jmp .move_done
.down
        lda GF_FRONT
        adc #$10
        sta GF_FRONT
        jmp .move_done
.left
        dec GF_X
        jmp .move_done
.up
        lda GF_FRONT
        sbc #$0f
        sta GF_FRONT
        jmp .move_done

.move_done
        lda GF_X
        and #$0f
        sta GF_X
        clc
        lda GF_FRONT
        adc GF_X
        sta GF_FRONT
        rts

; temp copy subroutine, will replace with zx02 decoder later
; zp
COPY_SRC = $80 ; 2 bytes
COPY_SRC_END = $82 ; 2 bytes
COPY_DST = $84 ; 2 bytes

        subroutine
copy_sr
        ldy #0
.copy_loop
        lda COPY_SRC
        cmp COPY_SRC_END
        bne .sk0
        lda COPY_SRC+1
        cmp COPY_SRC_END+1
        beq .copy_done
.sk0
        lda (COPY_SRC),y
        sta (COPY_DST),y
        inc COPY_SRC
        bne .sk1
        inc COPY_SRC+1
.sk1
        inc COPY_DST
        bne .sk2
        inc COPY_DST+1
.sk2
        jmp .copy_loop
.copy_done
        rts
