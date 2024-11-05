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

the_beginning
        ; Display title screen
        jsr decompress_all

        ; Play title theme
        jsr playsong

        ; Enter game
        jsr main_game_loop

        ; Display title screen again
        jmp the_beginning

        rts

        include "./title_screen_zx02.s"

        include "./title_theme.s"

        include "./main_game_loop.s"

        if . >= $1e00
        echo "ERROR: tromping on screen memory!"
        err
        endif
