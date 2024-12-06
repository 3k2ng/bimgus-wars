; sound_effects.s
;
; playing sound effects

; SOUND EFFECTS PRECEDENCE (most important at top)
        ; Player explosion
        ; Enemy explosion
        ; Player shoot + enemy shoot
        ; Player movement (move fwd/rotate)

; zero page variables
SFX_SAVE_ACC = $24
SFX_BITMASK = $25

MOVE_BM     = %1
SHOOT_BM    = %10
EXPLODE_BM  = %100

; sound effect parameters
STARTP  = 235                   ; initial pitch of player explosion
DECP    = 2                     ; rate of decrease
FINALP  = 195                   ; final pitch of player explosion
STARTE  = 215                   ; initial pitch of enemy explosion
INCE    = 2                     ; rate of increase
FINALE  = 245                   ; final pitch of enemy explosion
STARTBV = 8                     ; initial velocity of bullet
STARTB  = 225                   ; initial pitch of bullet
FINALB  = 217                   ; final pitch of bullet
STARTR  = 225                   ; initial pitch of rock
FINALR  = 217                   ; final pitch of rock
STARTM  = 215                   ; initial pitch of move

reset_sfx_bitmask
        lda #0
        sta SFX_BITMASK
        rts

; player explosion sound effect
playerExplosion
; check if it was an enemy who died
        lda OTHER_TANK_INDEX
        bne enemyExplosion
; play player explosion noise
        sta SFX_SAVE_ACC        ; save accumulator so it can be restored at the end, just in case
        lda SFX_BITMASK
        and #EXPLODE_BM
        bne exit_sound_effect
        jsr reset_pitches
        ldx #0
playerExplosionNext
        lda velocities,X        ; get the current note velocity
        sta SV                  ; set speakers to volume in accumulator
; check if we should exit on this note
        beq exit_expl           ; if volume is 0, exit the main loop
; we should not exit on this note
        inx                     ; move on
; set up the inner loop
        ldy #STARTP             ; load the first pitch into the Y register
; inner loop (decreasing pitch)
innerP
        sty SB                  ; write the note to the bass channel
        sty SN                  ; write the note to the noise channel
; set up the jiffy waiting loop
        lda JC                  ; load jiffy clock into accumulator
        adc #1                  ; accumulator now stores the desired end time (one jiffy away)
; wait one jiffy
jiffyP
        cmp JC
        bne jiffyP
; decrease pitch until it hits final pitch
        tya
        sbc #DECP               ; decrease pitch
        tay
        cpy #FINALP             ; check current pitch against final pitch
        bne innerP              ; if we haven't hit it yet, loop the inner loop
; move on to the next velocity value
        beq playerExplosionNext ; restart main loop

; enemy explosion sound effect
enemyExplosion
        sta SFX_SAVE_ACC        ; save accumulator so it can be restored at the end, just in case
        lda SFX_BITMASK
        and #EXPLODE_BM
        bne exit_sound_effect
        jsr reset_pitches
        ldx #0
enemyExplosionNext
        lda velocities,X        ; get the current note velocity
        sta SV                  ; set speakers to volume in accumulator
; check if we should exit on this note
        beq exit_expl           ; if volume is 0, exit the main loop
; we should not exit on this note
        inx                     ; move on
; set up the inner loop
        ldy #STARTE             ; load the first pitch into the Y register
; inner loop (decreasing pitch)
innerE
        sty SN                  ; write the note to the noise channel
; set up the jiffy waiting loop
        lda JC                  ; load jiffy clock into accumulator
        adc #1                  ; accumulator now stores the desired end time (one jiffy away)
; wait one jiffy
jiffyE
        cmp JC
        bne jiffyE
; increase pitch until it hits final pitch
        tya
        clc
        adc #INCE               ; increase pitch
        tay
        cpy #FINALE             ; check current pitch against final pitch
        bne innerE              ; if we haven't hit it yet, loop the inner loop
; move on to the next velocity value
        beq enemyExplosionNext  ; restart main loop

; exit sfx, update bitmask to prevent repeat sfx
exit_move
        lda SFX_BITMASK
        ora #MOVE_BM
        sta SFX_BITMASK
        bne exit_sound_effect
exit_expl
        lda SFX_BITMASK
        ora #EXPLODE_BM
        sta SFX_BITMASK
; generic cleanup
exit_sound_effect
        lda SFX_SAVE_ACC        ; restore accumulator
        rts

; generic entry
reset_pitches
        lda #0
        sta SB                  ; reset the pitches in the four channels
        sta SA
        sta SS
        sta SN
        rts

; shoot bullet sound effect
sfx_bullet
        sta SFX_SAVE_ACC        ; save accumulator so it can be restored at the end, just in case
        lda SFX_BITMASK
        and #SHOOT_BM
        bne exit_sound_effect
        jsr reset_pitches
        ldy #STARTB             ; load the first pitch into the Y register
        lda #STARTBV            ; load the initial note velocity
        sta SV                  ; set speaker to velocity
; inner loop (decreasing pitch)
innerB
        dec SV                  ; decrease velocity by 1
        sty SA                  ; write the note to the alto channel
        sty SN                  ; write the note to the soprano channel
; set up the jiffy waiting loop
        lda JC                  ; load jiffy clock into accumulator
        adc #1                  ; accumulator now stores the desired end time (one jiffy away)
; wait one jiffy
jiffyB
        cmp JC
        bne jiffyB
; decrease pitch until it hits final pitch
        dey                     ; decrement pitch by 1
        cpy #FINALB             ; check current pitch against final pitch
        bne innerB              ; if we haven't hit it yet, loop the inner loop
; if we are here, it is done
        lda SFX_BITMASK
        ora #SHOOT_BM
        sta SFX_BITMASK
        bne exit_sound_effect   ; restart main loop


; player movement sound effect
player_movement
        sta SFX_SAVE_ACC        ; save accumulator so it can be restored at the end, just in case
        lda SFX_BITMASK
        and #MOVE_BM
        bne exit_sound_effect
        jsr reset_pitches
        ldx #0
        ldy #STARTM             ; load the first pitch into the Y register
        sty SN                  ; write the note to the noise channel
player_movement_next
        lda mov_velocities,X    ; get the current note velocity
        sta SV                  ; set speakers to volume in accumulator
; check if we should exit on this note
        beq exit_move           ; if volume is 0, exit the main loop
; we should not exit on this note
        inx                     ; move on
; set up the jiffy waiting loop
        ldy JC                  ; load jiffy clock into Y register
        iny                     ; Y register now stores the desired end time (one jiffy away)
; wait one jiffy
jiffyM
        cpy JC
        bne jiffyM
; move on to the next velocity value
        beq player_movement_next ; restart main loop


; define explosion velocities
velocities
        dc  9, 6, 3, 0
mov_velocities
        dc  3, 6, 3, 0