; game_theme.s
;
; playing the in-game theme song

	processor 6502
; KERNAL addresses
SB      = $900a                 ; bass
SA      = $900b                 ; alto
SS      = $900c                 ; soprano
SN      = $900d                 ; noise
SV      = $900e                 ; volume

NOISEM  = %00000001             ; noise mask
BASSM   = %00000010             ; bass mask
ALTOM   = %00000100             ; alto mask
SOPRM   = %00001000             ; soprano mask

JC      = $00a2                 ; jiffy clock
	org $1001
; BASIC stub 
        dc.w nextstmt
        dc.w 10
        dc.b $9e, "4109", 0
nextstmt
        dc.w 0
; assembly program
main
        lda #0
        sta SB                  ; reset the pitches in the four channels
        sta SA
        sta SS
        sta SN
        ldx #0                  ; store the offset in X register
; main loop
loop
        ldy bitmaskOffset       ; load the offset into the Y register
        lda bitmask,Y           ; get the bitmask from memory
        and #NOISEM             ; apply the noise mask to the bitmask
        cmp #0                  ; check if the bit is 0 or not
        beq next1               ; if 0, don't play the noise channel
        lda songn,X             ; get the current noise note
        sta SN                  ; write the note to the noise channel
next1
        lda bitmask,Y           ; get the bitmask from memory
        and #BASSM              ; apply the bass mask to the bitmask
        cmp #0                  ; check if the bit is 0 or not
        beq next2               ; if 0, don't play the bass channel
        lda songb,X             ; get the current bass note
        sta SB                  ; write the note to the bass channel
next2
        lda bitmask,Y           ; get the bitmask from memory
        and #ALTOM              ; apply the alto mask to the bitmask
        cmp #0                  ; check if the bit is 0 or not
        beq next3               ; if 0, don't play the alto channel
        lda songa,X             ; get the current alto note
        sta SA                  ; write the note to the alto channel
next3
        lda bitmask,Y           ; get the bitmask from memory
        and #SOPRM              ; apply the sopranp mask to the bitmask
        cmp #0                  ; check if the bit is 0 or not
        beq next4               ; if 0, don't play the soprano channel
        lda songs,X             ; get the current soprano note
        sta SS                  ; write the note to the soprano channel
next4
; check if we should exit on this note
        ldy duration,X
        cpy #0                  ; compare duration with 0
        beq backToMain          ; if duration is 0, restart the main loop
; we should not exit on this note
        lda #6                  ; load Y register with initial velocity
        sta SV                  ; update speaker with velocity
outer
        lda JC                  ; load accumulator with current jiffy clock
        adc #1                  ; accumulator now stores the next jiffy
; wait a jiffy
inner
        cmp JC
        bne inner
; decrease velocity by 1
        lda SV                  ; get the current volume
        sbc #1                  ; decrement the volume
        cmp #0                  ; we don't want the velocity to go below 0!
        bne skip
        adc #1                  ; keep velocity greater than 0
skip
        sta SV                  ; update speaker with new velocity
; decrease remaining duration by 1
        dey
        cpy #0                  ; if duration run out:
        beq next                ; next note
        jmp outer               ; if not, wait another jiffy
; move on to the next note
next
        inx                     ; increment the note offset (X register)
        jmp loop                ; restart main loop
backToMain
        inc bitmaskOffset       ; increment the bitmask offset
        ldy bitmaskOffset       ; load the offset to check the current bitmask
        lda bitmask,Y           ; load the current bitmask using the offset
        cmp #0                  ; check if it is 0 (i.e. no channels playing)
        bne nextY               ; if not, skip this next bit
        sta bitmaskOffset       ; if so, store 0 in the offset "register" so the song loops
nextY
        jmp main                ; jump back to main

; define the song
songb
        dc  220, 220, 220, 220, 220, 220, 220, 220, 224, 224
        dc  220, 220, 220, 220, 220, 220, 220, 208, 216, 216, 216, 216
songa
        dc  226, 226, 226, 226, 226, 226, 226, 226, 229, 229
        dc  226, 226, 226, 226, 226, 226, 226, 220, 224, 224, 216, 216
songs
        dc  232, 232, 232, 232, 232, 232, 232, 232, 235, 235
        dc  232, 232, 232, 232, 232, 232, 232, 226, 229, 229, 229, 229
songn
        dc  225, 131, 181, 131, 225, 131, 181, 131, 215, 201
        dc  225, 131, 181, 131, 225, 131, 181, 131, 209, 197, 209, 197
duration
        dc  8, 4, 4, 8, 8, 4, 4, 8, 4, 4
        dc  8, 4, 4, 8, 8, 4, 4, 8, 2,2,2,2
        dc  0
; define the bitmasks and the offset "register"
bitmaskOffset
        dc  0
bitmask
        dc  %00000001, %00000011, %00000111, %00001101, %00001111, %00001111, %00001110
        dc  0

        if . >= $1e00
        echo "ERROR: tromping on screen memory!"
        err
        endif
