; playnoise.s
;
; initial test for making sounds on the vic20

        processor 6502
; KERNAL addresses
S1      = $900a ; bass
S2      = $900b ; alto
S3      = $900c ; soprano
S4      = $900d ; noise
SV      = $900e ; volume
        org $1001
; BASIC stub
        dc.w nextstmt
        dc.w 10
        dc.b $9e, "4109", 0
nextstmt
        dc.w 0
; assembly program
        lda #$07 ; volume = 7/15
        sta SV
outer
        ldx #$00
loop
        stx S2
        inx
        ldy #$00
inner
        iny
        cpy #$ff
        bne inner
        cpx #$ff
        bne loop
        beq outer
        rts
