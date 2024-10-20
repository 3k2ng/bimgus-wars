; displaychar.s
;
; fill the screen with characters by writing on the screen ram and the color ram
; since the screen and color ram are bigger than a byte (the size of the registers),
; we do the filling loop twice

	processor 6502

HALF_SCREEN = $fd
SCREEN_RAM_UPPER = $1e00
SCREEN_RAM_LOWER = $1efd
COLOR_RAM_UPPER = $9600
COLOR_RAM_LOWER = $96fd

SPACE_SCREEN_CODE = 96
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

; draw screen code
        ldx #0
dsr_screen_ul
        txa
        sta SCREEN_RAM_UPPER,X
        inx
        cpx #HALF_SCREEN
        bne dsr_screen_ul

        ldx #0
dsr_screen_ll
        txa
        sta SCREEN_RAM_LOWER,X
        inx
        cpx #HALF_SCREEN
        bne dsr_screen_ll

inf_loop
        jmp inf_loop

