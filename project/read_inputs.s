; read_inputs.s
;
; read only the three inputs needed for the game:
; - SPACE for shooting
; - UP/DOWN for moving forward
; - LEFT/RIGHT for rotating left

; main
read_input
        lda CURRENT_KEY
        cmp LAST_KEY
        sta LAST_KEY
        beq skip_print ; repeated input

        cmp #SPACE_KEY_CODE
        beq exitmenu

skip_print
        lda #1
        rts

exitmenu
        lda #0
        rts