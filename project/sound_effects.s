; sound_effects.s
;
; playing sound effects back to back

; sound effect parameters
STARTP  = 235                   ; initial pitch of player explosion
DECP    = 2                     ; rate of decrease
FINALP  = 195                   ; final pitch of player explosion
STARTE  = 215                   ; initial pitch of enemy explosion
INCE    = 2                     ; rate of increase
FINALE  = 245                   ; final pitch of enemy explosion
STARTB  = 245                   ; initial pitch of bullet
FINALB  = 237                   ; final pitch of bullet
STARTR  = 225                   ; initial pitch of rock
FINALR  = 217                   ; final pitch of rock

; KERNAL addresses
SB      = $900a                 ; bass
SA      = $900b                 ; alto
SS      = $900c                 ; soprano
SN      = $900d                 ; noise
SV      = $900e                 ; volume
JC      = $00a2                 ; jiffy clock


; generic cleanup
exit_sound_effect
        lda #0                  ; shut off the speaker!
        sta SV
        sta SB                  ; reset the pitches in the four channels
        sta SA
        sta SS
        sta SN
        ldx #0                  ; reset X offset
        rts


; player explosion sound effect
playerExplosion
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
        jmp playerExplosion     ; restart main loop


; enemy explosion sound effect
enemyExplosion
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
        jmp enemyExplosion      ; restart main loop


; shoot bullet sound effect
sfx_bullet
        ldy #STARTB             ; load the first pitch into the Y register
        lda velocities          ; load a note velocity (just use the first one from the explosion velocities)
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
; if we qre here, it is done
        jmp exit_sound_effect   ; restart main loop


; shoot rock sound effect
sfx_rock
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
; if we qre here, it is done
        jmp exit_sound_effect   ; restart main loop


; define explosion velocities
velocities
        dc  9, 6, 3, 1, 0
