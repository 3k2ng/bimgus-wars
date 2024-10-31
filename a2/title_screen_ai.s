	processor 6502

CHARACTER_RAM = $1c00

SCREEN_RAM = $1e00
; screen_ram split into 2 bytes
SCRB0 = $00
SCRB1 = $1e

COLOR_RAM = $9600
; color_ram split into 2 bytes
CORB0 = $00
CORB1 = $96

; zero page variables
VALUE = $00       ; Current value to repeat
COUNT = $01       ; How many times to repeat
DEST_PTR = $02    ; 2 bytes - destination pointer
SRC_PTR = $04     ; 2 bytes - source pointer

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

; copy custom character to character ram using RLE decoding
        lda #<uncompressed_char_set
        sta SRC_PTR
        lda #>uncompressed_char_set
        sta SRC_PTR+1
        
        lda #<CHARACTER_RAM
        sta DEST_PTR
        lda #>CHARACTER_RAM
        sta DEST_PTR+1
        
        jsr decode_rle

; decode screen data
        lda #<hcc_char_map
        sta SRC_PTR
        lda #>hcc_char_map
        sta SRC_PTR+1
        
        lda #SCRB0
        sta DEST_PTR
        lda #SCRB1
        sta DEST_PTR+1
        
        jsr decode_rle

; decode color data
        lda #<hcc_color_map
        sta SRC_PTR
        lda #>hcc_color_map
        sta SRC_PTR+1
        
        lda #CORB0
        sta DEST_PTR
        lda #CORB1
        sta DEST_PTR+1
        
        jsr decode_rle

inf_loop
        jmp inf_loop

; RLE decoding subroutine
decode_rle
        ldy #0
.decode_loop
        ; Get the value
        lda (SRC_PTR),y
        sta VALUE
        
        ; Move to next byte
        inc SRC_PTR
        bne .skip1
        inc SRC_PTR+1
.skip1

        ; Get the count
        lda (SRC_PTR),y
        sta COUNT
        
        ; Move to next byte
        inc SRC_PTR
        bne .skip2
        inc SRC_PTR+1
.skip2

        ; Check if we're done (count = $7f)
        lda COUNT
        cmp #$7f
        beq .done

        ; Write the value COUNT times
        ldx COUNT
.write_loop
        lda VALUE
        ldy #0
        sta (DEST_PTR),y
        
        ; Increment destination
        inc DEST_PTR
        bne .skip3
        inc DEST_PTR+1
.skip3
        
        dex
        bne .write_loop
        
        jmp .decode_loop

.done
        rts

        ;include "./data/hcc_data.s"
        include "./data/rle_data.s"
