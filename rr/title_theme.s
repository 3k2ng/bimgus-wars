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
        beq .restart_loop       ; if duration is 0, exit the main loop
; we should not exit on this note
        clc
        adc JC                  ; accumulator now stores the desired end time
; wait until jiffy clock equals the value in the accumulator
.inner
        ; check if we need to exit (player input)
        ldy KEY_CURRENT
        cpy #64
        bne .end_song
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
        lda #0
        sta SB
        sta SA
        sta SS
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