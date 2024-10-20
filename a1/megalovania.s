; megalovania.s
;
; erm, have you heard of the song Megalovania from the hit game Undertale?

	processor 6502
; KERNAL addresses
SB      = $900a                 ; bass
SA      = $900b                 ; alto
SS      = $900c                 ; soprano
SN      = $900d                 ; noise
SV      = $900e                 ; volume
JC      = $00a2                 ; jiffy clock
	org $1001
; BASIC stub
        dc.w nextstmt
        dc.w 10
        dc.b $9e, "4109", 0
nextstmt
        dc.w 0
; assembly program
        ldy #0                  ; store the special offset in Y register
main
        lda #15                 ; set speakers to full volume!
        sta SV                  ; set speakers to full volume!
        ldx #0                  ; store the offset in X register
; main loop
loop
        lda song,X              ; get the current note
        cmp #$ff
        bne nextY1
        lda special,Y
nextY1
        sta SB                  ; write the note to the bass speaker
        sta SA                  ; write the note to the alto speaker
; check if we should exit on this note
        lda duration,X          ; load accumulator with duration of current note
        cmp #0                  ; compare accumulator with 0
        beq exit                ; if duration is 0, exit the main loop
; we should not exit on this note
        lda duration,X          ; load accumulator with duration of current note, again (?)
        adc JC                  ; accumulator now stores the desired end time
; wait until jiffy clock equals the value in the accumulator (in this way, polyphony is impossible ;-;)
inner
        cmp JC
        bne inner
; move on to the next note
        inx                     ; increment the note offset (X register)
        jmp loop                ; restart main loop
; cleanup
exit
        lda #0                  ; shut off the speaker!
        sta SV                  ; shut off the speaker!
        iny                     ; move on to the next special offset
        cpy #4
        bne nextY2
        ldy #0
nextY2
        jmp main                ; loop the song
        rts                     ; lol

; define megalovania
duration
        dc  9,1,10,20,20,10,10,10,10,10,20,10,10,10,0
        ; hex 0b 01 0c 16 16 0b 0b 0b 0b 0b 16 0b 0b 0b 00
song
        dc  $ff,0,$ff,228,219,0,216,0,214,0,209,200,209,214
        ; hex ff 00 ff e4 db 00 d8 00 d6 00 d1 c8 d1 d6
special
        dc  200,195,190,185
