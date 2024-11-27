; sound_effects.s
;
; playing sound effects

; SOUND EFFECTS PRECEDENCE (most important at top)
        ; Player explosion
        ; Enemy explosion
        ; Player shoot + enemy shoot
        ; Player movement (move fwd/rotate)

; zero page variables


; sound effect parameters
STARTP  = 235                   ; initial pitch of player explosion
DECP    = 2                     ; rate of decrease
FINALP  = 195                   ; final pitch of player explosion
STARTE  = 215                   ; initial pitch of enemy explosion
INCE    = 2                     ; rate of increase
FINALE  = 245                   ; final pitch of enemy explosion
STARTBV = 8                     ; initial velocity of bullet
STARTB  = 245                   ; initial pitch of bullet
FINALB  = 237                   ; final pitch of bullet
STARTR  = 225                   ; initial pitch of rock
FINALR  = 217                   ; final pitch of rock
STARTM  = 215                   ; initial pitch of move


; player explosion sound effect
playerExplosion
        ; lda #0
        ; sta SA
        ; sta SS
        jsr reset_pitches
        ldx #0
playerExplosionNext
        lda velocities,X        ; get the current note velocity
; check if we should exit on this note
        beq exit_sound_effect   ; if volume is 0, exit the main loop
; we should not exit on this note
        inx                     ; move on
        sta SV                  ; set speakers to volume in accumulator
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
        jmp playerExplosionNext ; restart main loop


; enemy explosion sound effect
enemyExplosion
        ; lda #0
        ; sta SB
        ; sta SA
        ; sta SS
        jsr reset_pitches
        ldx #0
enemyExplosionNext
        lda velocities,X        ; get the current note velocity
; check if we should exit on this note
        beq exit_sound_effect   ; if volume is 0, exit the main loop
; we should not exit on this note
        inx                     ; move on
        sta SV                  ; set speakers to volume in accumulator
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
        jmp enemyExplosionNext  ; restart main loop

; generic cleanup
exit_sound_effect
        lda #0                  ; shut off the speaker!
        ; sta SV
        ; sta SB                  ; reset the pitches in the four channels
        ; sta SA
        ; sta SS
        ; sta SN
        ; ldx #0                  ; reset X offset
        rts

; shoot bullet sound effect
sfx_bullet
        ; lda #0
        ; sta SB
        ; sta SN
        jsr reset_pitches
        ldy #STARTB             ; load the first pitch into the Y register
        lda #STARTBV            ; load the initial note velocity
        sta SV                  ; set speaker to velocity
; inner loop (decreasing pitch)
innerB
        dec SV                  ; decrease velocity by 1
        sty SA                  ; write the note to the alto channel
        sty SS                  ; write the note to the soprano channel
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
        jmp exit_sound_effect   ; restart main loop


; shoot rock sound effect
sfx_rock
        ; lda #0
        ; sta SS
        ; sta SN
        jsr reset_pitches
        ldy #STARTR             ; load the first pitch into the Y register
        lda velocities          ; load a note velocity (just use the first one from the explosion velocities)
        sta SV                  ; set speaker to velocity
; inner loop (decreasing pitch)
innerR
        dec SV                  ; decrease velocity by 1
        sty SA                  ; write the note to the alto channel
        sty SB                  ; write the note to the bass channel
; set up the jiffy waiting loop
        lda JC                  ; load jiffy clock into accumulator
        adc #1                  ; accumulator now stores the desired end time (one jiffy away)
; wait one jiffy
jiffyR
        cmp JC
        bne jiffyR
; decrease pitch until it hits final pitch
        dey                     ; decrement pitch by 1
        cpy #FINALR             ; check current pitch against final pitch
        bne innerR              ; if we haven't hit it yet, loop the inner loop
; if we are here, it is done
        jmp exit_sound_effect   ; restart main loop


; player movement sound effect
player_movement
        ; lda #0
        ; sta SB
        ; sta SA
        ; sta SS
        jsr reset_pitches
        ldx #0
        ldy #STARTM             ; load the first pitch into the Y register
        sty SN                  ; write the note to the noise channel
player_movement_next
        lda mov_velocities,X    ; get the current note velocity
        sta SV                  ; set speakers to volume in accumulator
; check if we should exit on this note
        beq exit_sound_effect   ; if volume is 0, exit the main loop
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
        jmp player_movement_next ; restart main loop


; define explosion velocities
velocities
        dc  9, 6, 3, 1, 0
mov_velocities
        dc  3, 6, 3, 0