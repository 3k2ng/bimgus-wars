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
        subroutine
play_title_theme
        lda #9                  ; load accumulator with desired volume
        sta SV                  ; set speakers to that volume
        ldx #0                  ; store the offset in X register
        stx SN
; main loop
.loop
        ; play note
        lda songb,X             ; get the current bass note
        sta SB                  ; write the note to the bass speaker
        lda songa,X             ; get the current alto note
        sta SA                  ; write the note to the alto speaker
        lda songs,X             ; get the current soprano note
        sta SS                  ; write the note to the soprano speaker
; check if we should exit on this note
        lda duration,X          ; load accumulator with duration of current note
        ; multiply by 10 (10x = 8x + 2x)
        ; asl
        ; sta DURATION_TEMP
        ; asl
        ; asl
        ; clc
        ; adc DURATION_TEMP
        beq .restart_loop       ; if duration is 0, exit the main loop
; we should not exit on this note
        clc
        adc JC                  ; accumulator now stores the desired end time
; wait until jiffy clock equals the value in the accumulator (in this way, polyphony is impossible ;-;)
.inner
        ; check if we need to exit (player input)
        ldy CURRENT_KEY
        cpy #SPACE_KEY_CODE
        beq .end_song
        ; check if the note duration is elapsed
        cmp JC
        bne .inner
; move on to the next note
        inx                     ; increment the note offset (X register)
        jmp .loop               ; restart main loop
; cleanup
.restart_loop
        ldx #$20
        jmp .loop
.end_song
        rts

; define the song
N0 = 0
; note values
songb
        dc  D0,D0,D0,D0,C1,C1,Bb0,N0,N0,Bb0,Bb0,Bb0,C1,C1,G0,N0
        dc  D0,D0,D0,D0,C1,C1,Bb0,N0,N0,Bb0,Bb0,Bb0,C1,C1,D0,N0
        dc  C2,D2,N0,D2,N0,D2,C2, D2,N0,D2, N0, D2, C2,D2,N0,D2
        dc  C2,D2,N0,D2,N0,D2,C2, D2,N0,D2, N0, D2, A1,A1,N0,A1
songa
        dc  A1,A1,A1,A1,G1,G1,F1,N0,N0,F1,F1,F1,G1,G1,D2,N0
        dc  A1,A1,A1,A1,G1,G1,F1,N0,N0,F1,F1,F1,G1,G1,A1,N0
        dc  C2,D2,N0,D2,N0,D2,C2,D2,N0,D2,N0,D2,E2,F2,N0,F2
        dc  C2,D2,N0,D2,N0,D2,C2,D2,N0,D2,N0,D2,G1,A1,G1,A1
songs
        dc  D2,E2,F2,G2,E2,C2,D2,N0,C2,Bb1,C2,D2,C2,Bb1,A1,N0
        dc  D2,E2,F2,G2,E2,C2,D2,N0,C2,Bb1,C2,D2,E2,C2, D2,N0
; note value constants
D0 = 145
G0 = 174
Bb0 = 186
C1 = 195
F1 = 209
G1 = 214
A1 = 219
Bb1 = 220
C2 = 224
D2 = 228
E2 = 231
F2 = 232
G2 = 235

; duration values (N0 is delimiter)
duration
        dc  Ne, Ne, Ne, Ne, Nq, Ne, Nh+Ne, Nq, Nq, Nq, Ne, Ne, Nq, Ne, Nh+Ne, Nh
        dc  Ne, Ne, Ne, Ne, Nq, Ne, Nh+Ne, Nq, Nq, Nq, Ne, Ne, Nq, Ne, Nh+Ne, Nh
        dc  Ne, Ne, Ne, Ne, Ne, Ne, Ne,    Ne, Ne, Ne, Ne, Ne, Ne, Ne, Ne,    Ne
        dc  Ne, Ne, Ne, Ne, Ne, Ne, Ne,    Ne, Ne, Ne, Ne, Ne, Ne, Ne, Ne,    Ne
        dc  N0
; duration constants
Nh = 40
Nq = 20
Ne = 10

; songb ;bass
;         dc  145,145,145,145,195,195,186,0,  0,  186,186,186,195,195,174,0
;         dc  145,145,145,145,195,195,186,0,  0,  186,186,186,195,195,145,0
;         dc  224,228,0,228,0,228,224,228,0,  228,0,  228,224,228,0,228
;         dc  224,228,0,228,0,228,224,228,0,  228,0,  228,219,219,0,219
; songa ;alto
;         dc  219,219,219,219,214,214,209,0,  0,  209,209,209,214,214,228,0
;         dc  219,219,219,219,214,214,209,0,  0,  209,209,209,214,214,219,0
;         dc  224,228,0,228,0,228,224,228,0,  228,0,  228,231,232,0,  232
;         dc  224,228,0,228,0,228,224,228,0,  228,0,  228,214,219,214,219
; songs ;soprano
;         dc  228,231,232,235,231,224,228,0,  224,220,224,228,224,220,219,0
;         dc  228,231,232,235,231,224,228,0,  224,220,224,228,231,224,228,0
; duration
;         dc  10, 10, 10, 10, 20, 10, 50, 20, 20, 20, 10, 10, 20, 10, 50, 40
;         dc  10, 10, 10, 10, 20, 10, 50, 20, 20, 20, 10, 10, 20, 10, 50, 40
;         dc  10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10
;         dc  10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10
;         dc  0