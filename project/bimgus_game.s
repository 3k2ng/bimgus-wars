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

        jsr display_title_screen

        jsr main_game_loop

        rts

        include "./title_screen_zx02.s"

        include "./main_game_loop.s"
