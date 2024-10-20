; read_inputs.s
;
; read only the three inputs needed for the game:
; - SPACE for shooting
; - UP/DOWN for moving forward
; - LEFT/RIGHT for rotating left

	processor 6502

CHROUT = $ffd2

LAST_KEY = $0
CURRENT_KEY = $c5

SPACE_KEY_CODE = $20
UP_DOWN_KEY_CODE = $1f
LEFT_RIGHT_KEY_CODE = $17

	org $1001

; BASIC stub 
        dc.w nextstmt
        dc.w 10
        dc.b $9e, [start]d, 0
nextstmt
        dc.w 0

; main
start
        lda #64
        sta LAST_KEY
inf_loop
        lda CURRENT_KEY
        cmp LAST_KEY
        sta LAST_KEY
        beq skip_print ; repeated input

        cmp #SPACE_KEY_CODE
        beq print_space

        cmp #UP_DOWN_KEY_CODE
        beq print_up_down

        cmp #LEFT_RIGHT_KEY_CODE
        beq print_left_right

        jmp skip_print ; if not one of the three above, skip

print_space
        lda #'S
        jsr CHROUT
        jmp skip_print

print_up_down
        lda #'F
        jsr CHROUT
        jmp skip_print

print_left_right
        lda #'R
        jsr CHROUT
        jmp skip_print

skip_print
        jmp inf_loop

