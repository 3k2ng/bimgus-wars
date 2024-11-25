; game_theme.s
;
; playing the in-game theme song

; bitmask definitions
NOISEM  = %00000001             ; noise mask
BASSM   = %00000010             ; bass mask
ALTOM   = %00000100             ; alto mask
SOPRM   = %00001000             ; soprano mask

; parameters
INIT_V  = 8                     ; initial velocity of note

; zero page variables
GAME_X_OFFSET = $10             ; note offset (i.e. X register)
GAME_Y_OFFSET = $11             ; bitmask offset (i.e. Y register)
GAME_DURATION = $12             ; stores a jiffy clock time that denotes when to move to the next note
GAME_PREV_JC  = $13             ; stores the previous jiffy clock time (to calculate delta)
; GAME_DELTA    = $13             ; temp variable that stores delta between prev time and now


; initialize everything so that the game theme can start playing
        subroutine
play_game_theme
        jsr reset_pitches
        sta GAME_X_OFFSET       ; initialize note offset to 0
        sta GAME_Y_OFFSET       ; initialize bitmask offset to 0
; set up GAME_PREV_JC for the first time
        lda JC
        sta GAME_PREV_JC
        jmp .first_time         ; skip the lines of code that check if time has elapsed yet

; update state of song
update_game_theme
; check if JC has changed since last update
        lda JC
        cmp GAME_PREV_JC
        sta GAME_PREV_JC
        beq .exit               ; if jiffy clock has not changed, exit early
; update remaining duration by decrementing it
        dec GAME_DURATION
        bne .dont_update_note   ; if remaining duration is > 0, we dont need to change note

.first_time
; update note
        jsr reset_pitches
        ldx GAME_X_OFFSET       ; load the note offset into the X register
        ldy GAME_Y_OFFSET       ; load the bitmask offset into the Y register
; set note veloicty to initial velocity
        lda #INIT_V+1           ; load Y register with initial velocity
                                ; (+1 because it is gonna get decremented immediately after)
        sta SV                  ; update speaker with velocity
; determine which tracks need to be activated using the bitmask
        lda game_bitmask,Y      ; get the bitmask from memory
        and #NOISEM             ; apply the noise mask to the bitmask
        beq .next1              ; if 0, don't play the noise channel
        lda gamen,X             ; get the current noise note
        sta SN                  ; write the note to the noise channel
.next1
        lda game_bitmask,Y      ; get the bitmask from memory
        and #BASSM              ; apply the bass mask to the bitmask
        beq .next2              ; if 0, don't play the bass channel
        lda gameb,X             ; get the current bass note
        sta SB                  ; write the note to the bass channel
.next2
        lda game_bitmask,Y      ; get the bitmask from memory
        and #ALTOM              ; apply the alto mask to the bitmask
        beq .next3              ; if 0, don't play the alto channel
        lda gamea,X             ; get the current alto note
        sta SA                  ; write the note to the alto channel
.next3
        lda game_bitmask,Y      ; get the bitmask from memory
        and #SOPRM              ; apply the sopranp mask to the bitmask
        beq .next4              ; if 0, don't play the soprano channel
        lda games,X             ; get the current soprano note
        sta SS                  ; write the note to the soprano channel
.next4

; update GAME_DURATION
        lda game_duration,X
        sta GAME_DURATION
; update note offset
        inc GAME_X_OFFSET       ; increment the note offset (X register) to move on to the next note
; check if the (now) current note's duration is the delimiter (i.e. prev note was last note of song)
        ldx GAME_X_OFFSET       ; load the note offset into the X register
        ldy game_duration,X
        bne .next5              ; if duration is not delimiter, skip this next part
        sty GAME_X_OFFSET       ; reset offset to 0
; update bitmask offset
        inc GAME_Y_OFFSET       ; (salient) increment the bitmask offset by 1
.next5
; check if the (now) current bitmask is the delimiter (i.e. prev bitmask was last bitmask of song)
        ldy GAME_Y_OFFSET       ; load the offset to check the (now) current bitmask
        lda game_bitmask,Y      ; load the (now) current bitmask
        bne .next6              ; if at least one channel should be playing, skip this next line
        sta GAME_Y_OFFSET       ; if none, store 0 in the offset "register" so the whole song loops
.next6
.dont_update_note

; decrease velocity by 1 every other tick
        lda JC
        and #1
        bne .next7
        dec SV                  ; decrement velocity
        bne .next7              ; if decremented volume is not 0 yet, skip the next line
        inc SV                  ; if it is 0, increment it to keep it greater than 0!
.next7

.exit
; save current time (EDIT: now doing this at the beginning of the subroutine)
        ; lda JC
        ; sta GAME_PREV_JC
; return
        rts


        subroutine
reset_pitches
        lda #0
        sta SB                  ; reset the pitches in the four channels
        sta SA
        sta SS
        sta SN
        rts


; define the song
N0 = 0
; note values
gameb   dc  220, 220, 220, 220, 220, 220, 220, 220, 224,      224
        dc  220, 220, 220, 220, 220, 220, 220, 208, 216, 216, 216, 216
gamea   dc  226, 226, 226, 226, 226, 226, 226, 226, 229,      229
        dc  226, 226, 226, 226, 226, 226, 226, 220, 224, 224, 216, 216
games   dc  232, 232, 232, 232, 232, 232, 232, 232, 235,      235
        dc  232, 232, 232, 232, 232, 232, 232, 226, 229, 229, 229, 229
gamen   dc  225, 131, 181, 131, 225, 131, 181, 131, 215,      201
        dc  225, 131, 181, 131, 225, 131, 181, 131, 209, 197, 209, 197
; duration values
game_duration
        dc  GNq, GNe, GNe, GNq, GNq, GNe, GNe, GNq, GNe,      GNe
        dc  GNq, GNe, GNe, GNq, GNq, GNe, GNe, GNq, GNs, GNs, GNs, GNs
        dc  N0
; duration constants
GScale = 4
GNq = GScale*4
GNe = GScale*2
GNs = GScale
; define the bitmasks and the offset "register"
game_bitmask
        dc  %00000001, %00000011, %00000111, %00001101, %00001111, %00001111, %00001110
        dc  N0
