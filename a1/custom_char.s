; custom_char.s
;
; switch from default rom characters to reading some from ram

	processor 6502

CHARACTER_RAM = $1c00

HALF_SCREEN = $fd
SCREEN_RAM_UPPER = $1e00
SCREEN_RAM_LOWER = $1efd
COLOR_RAM_UPPER = $9600
COLOR_RAM_LOWER = $96fd

SPACE_SCREEN_CODE = $e0
BLUE_COLOR_CODE = 6

	org $1001

; BASIC stub 
        dc.w nextstmt
        dc.w 10
        dc.b $9e, [start]d, 0
nextstmt
        dc.w 0

; main
start

; clear screen
        lda #SPACE_SCREEN_CODE
        ldx #0
csr_screen_ul
        sta SCREEN_RAM_UPPER,X
        inx
        cpx #HALF_SCREEN
        bne csr_screen_ul

        lda #SPACE_SCREEN_CODE
        ldx #0
csr_screen_ll
        sta SCREEN_RAM_LOWER,X
        inx
        cpx #HALF_SCREEN
        bne csr_screen_ll

; fill screen with color BLUE
        lda #BLUE_COLOR_CODE
        ldx #0
csr_color_ul
        sta COLOR_RAM_UPPER,X
        inx
        cpx #HALF_SCREEN
        bne csr_color_ul

        lda #BLUE_COLOR_CODE
        ldx #0
csr_color_ll
        sta COLOR_RAM_LOWER,X
        inx
        cpx #HALF_SCREEN
        bne csr_color_ll

; set character location to character ram
        lda #$ff
        sta $9005

; copy custom character to character ram
        ldx #0
ccr_loop
        lda custom_char,X
        sta CHARACTER_RAM,X
        inx
        cpx #8
        bne ccr_loop

; draw custom character
        lda #0 ; custom character
        sta SCREEN_RAM_UPPER
        lda #$93 ; new S
        sta SCREEN_RAM_UPPER + 2
        sta SCREEN_RAM_UPPER + 4
        lda #$95 ; new U
        sta SCREEN_RAM_UPPER + 3

inf_loop
        jmp inf_loop

; custom character
custom_char
        include "./chars/test.s"
