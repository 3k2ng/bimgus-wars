; bimgus game base only have the BASIC stub really, include other files

	processor 6502
	org $1001

; BASIC stub 
        dc.w nextstmt
        dc.w 10
        dc.b $9e, [start]d, 0
nextstmt
        dc.w 0

; main
start

; set character location to character ram (TODO: get rid of magic numbers!)
        lda #$ff
        sta $9005

; set screen and border color (TODO: get rid of magic numbers!)
        lda #$0b
        sta $900f

        jsr main_game
        rts

        include "./main_game.s"

        if . >= $1c00
        echo "ERROR: out of memory!"
        err
        endif
