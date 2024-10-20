; visual_counter.s
;
; a counter with visual indication, like object count
; used for bullet count
; here, we visualize the jiffy clock

	processor 6502

CHARACTER_RAM = $1c00
JIFFY_CLOCK = $a2

HALF_SCREEN = $fd
SCREEN_RAM_UPPER = $1e00
SCREEN_RAM_LOWER = $1efd
COLOR_RAM_UPPER = $9600
COLOR_RAM_LOWER = $96fd

SPACE_SCREEN_CODE = $e0
BLUE_COLOR_CODE = 6

VISUAL_COUNTER_VALUE = $00
LAST_VC_VALUE = $01
VISUAL_COUNTER_START = $1ef5

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

; infinite loop to observe
inf_loop

        lda VISUAL_COUNTER_VALUE
        sta LAST_VC_VALUE
        lda JIFFY_CLOCK
        sta VISUAL_COUNTER_VALUE
        ; shift 4 times to the right
        lsr VISUAL_COUNTER_VALUE
        lsr VISUAL_COUNTER_VALUE
        lsr VISUAL_COUNTER_VALUE
        lsr VISUAL_COUNTER_VALUE

        lda VISUAL_COUNTER_VALUE
        cmp LAST_VC_VALUE
        beq inf_loop ; only redraw when the value change

; clear the counter draw area
        ldx #0
clear_loop
        lda #SPACE_SCREEN_CODE
        sta VISUAL_COUNTER_START,x
        inx
        cpx #$f
        bmi clear_loop

; draw the visual counter
        ldx #0
draw_loop
        lda #0 ; custom character
        sta VISUAL_COUNTER_START,x
        inx
        cpx VISUAL_COUNTER_VALUE
        bmi draw_loop

        jmp inf_loop

; custom character
custom_char
        include "./chars/test.s"
