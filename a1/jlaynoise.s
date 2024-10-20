; jlaynoise.s
;
; play a short sound with timing using jiffy clock

        processor 6502
; KERNAL addresses
S1      = $900a ; bass
S2      = $900b ; alto
S3      = $900c ; soprano
S4      = $900d ; noise
SV      = $900e ; volume
JC      = $00a2 ; jiffy clock
        org $1001
; BASIC stub
        dc.w nextstmt
        dc.w 10
        dc.b $9e, "4109", 0
nextstmt
        dc.w 0
; assembly program
        lda #15 ; full volume!
        sta SV
loop
        lda JC
        sta S2
        jmp loop
        rts

; define the song
song        ; note frequency data
        dc  200,200,228,219,0
duration    ; note duration data
        dc  $0f,$0f,$ff,$ff,0
