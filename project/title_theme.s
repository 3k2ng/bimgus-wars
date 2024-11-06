; title_theme.s
;
; playing the title theme song

; KERNAL addresses
SB      = $900a                 ; bass
SA      = $900b                 ; alto
SS      = $900c                 ; soprano
SN      = $900d                 ; noise
SV      = $900e                 ; volume
JC      = $00a2                 ; jiffy clock
; assembly program
playsong
        lda #9                  ; load accumulator with desired volume
        sta SV                  ; set speakers to that volume
        ldx #0                  ; store the offset in X register
; main loop
loop
        ; check if we need to exit
        lda CURRENT_KEY
        cmp LAST_KEY
        sta LAST_KEY
        beq skip_print ; repeated input

        cmp #SPACE_KEY_CODE
        beq endsong
skip_print
        ; play note
        lda songb,X             ; get the current bass note
        sta SB                  ; write the note to the bass speaker
        lda songa,X             ; get the current alto note
        sta SA                  ; write the note to the alto speaker
        lda songs,X             ; get the current soprano note
        sta SS                  ; write the note to the soprano speaker
; check if we should exit on this note
        lda duration,X          ; load accumulator with duration of current note
        beq restartloop         ; if duration is 0, exit the main loop
; we should not exit on this note
        lda duration,X          ; load accumulator with duration of current note, again (?)
        clc
        adc JC                  ; accumulator now stores the desired end time
; wait until jiffy clock equals the value in the accumulator (in this way, polyphony is impossible ;-;)
inner
        cmp JC
        bne inner
; move on to the next note
        inx                     ; increment the note offset (X register)
        jmp loop                ; restart main loop
; cleanup
restartloop
        ldx #$20
        jmp loop
endsong
        lda #0                  ; shut off the speaker!
        sta SV
        rts

; define the song
songb ;bass
        dc  145,145,145,145,195,195,186,0,  0,  186,186,186,195,195,174,0
        dc  145,145,145,145,195,195,186,0,  0,  186,186,186,195,195,145,0
        dc  224,228,0,228,0,228,224,228,0,  228,0,  228,224,228,0,228
        dc  224,228,0,228,0,228,224,228,0,  228,0,  228,219,219,0,219
songa ;alto
        dc  219,219,219,219,214,214,209,0,  0,  209,209,209,214,214,228,0
        dc  219,219,219,219,214,214,209,0,  0,  209,209,209,214,214,219,0
        dc  224,228,0,228,0,228,224,228,0,  228,0,  228,231,232,0,  232
        dc  224,228,0,228,0,228,224,228,0,  228,0,  228,214,219,214,219
songs ;soprano
        dc  228,231,232,235,231,224,228,0,  224,220,224,228,224,220,219,0
        dc  228,231,232,235,231,224,228,0,  224,220,224,228,231,224,228,0
duration
        dc  10, 10, 10, 10, 20, 10, 50, 20, 20, 20, 10, 10, 20, 10, 50, 40
        dc  10, 10, 10, 10, 20, 10, 50, 20, 20, 20, 10, 10, 20, 10, 50, 40
        dc  10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10
        dc  10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10
        dc  0