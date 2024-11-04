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

; set character location to character ram
        lda #$ff
        sta $9005

; set screen and border color
        lda #$0b
        sta $900f

        ; Display title screen
        jsr decompress_all

        ; Play title theme
        jsr playsong

        ; Enter game
        jsr main_game_loop

        ; Display title screen again
        jsr decompress_all

        rts

        include "./title_screen_zx02.s"

        include "./title_theme.s"

        include "./main_game_loop.s"

        if . >= $1e00
        echo "ERROR: tromping on screen memory!"
        err
        endif
