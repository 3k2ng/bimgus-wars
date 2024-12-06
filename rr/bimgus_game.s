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

        ; Display title screen
        jsr decompress_all

        jsr play_title_theme

        jsr main_game

        jmp start

        include "./title_screen_zx02.s"

        include "./title_theme.s"

        include "./main_game.s"

        include "./sound_effects.s"

        if . >= $1c00
        echo "ERROR: out of memory!"
        err
        endif
