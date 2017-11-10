; https://github.com/Michaelangel007/apple2_softswitch
;
; What happens to HIGH RAM on Set ALTZP $C009?
; Init 0.
;         Aux  LC RAM = 'A'
;         Main LC RAM = 'M'
; Test 1. Aux  LC RAM
; Test 2. Main LC RAM
; Test 3. n/a  LC ROM
; ====================

SETSTDZP    = $C008
SETALTZP    = $C009

ROMIN2      = $C082
LCBANK2     = $C083 ; Must be LOAD x2

; We want an address in ROM that has a printable byte 'R' = $92
;across all ROM versions
;
; $FD92 is a ROM entry point for PRA1
; It is called from $FDB3
; FDB3:20 92 FD  832  XAM      JSR   PRA1
;         ^^
;         'R'
TEST        = $FDB4

SAVE_A      = $400  ; LC Aux
SAVE_M      = $401  ; LC Main
SAVE_R      = $402  ; LC ROM

OUT_1       = $480
OUT_2       = $481
OUT_3       = $482

; ====================

    ORG $300        ; Yes, on the stack

__MAIN
    STA ROMIN2      ; bank LC ROM
    LDA TEST
    STA SAVE_R      ; save original ROM $E000

    LDA LCBANK2     ; Enable LC RAM read
    LDA LCBANK2     ; Enable LC RAM write

SaveE000
    LDX #'A'+$80
    LDY #'M'+$80

    STA SETALTZP    ; Aux  $D000..$FFFF
    LDA TEST
    STA SAVE_A      ; save original Aux  $E000
    STX TEST        ; Visual Aux  flag 'A'

    STA SETSTDZP    ; Main $D000..$FFFF
    LDA TEST
    STA SAVE_M      ; save original Main $E000
    STY TEST        ; Visual Main flag 'M'

; Test 1 = Aux  LC RAM
    STA SETALTZP    ; moment of truth
    LDA TEST        ; should be 'A'
    STA OUT_1       ;

; Test 2 = Main LC RAM
    STA SETSTDZP    ; moment of truth
    LDX TEST        ; should be 'M'
    STX OUT_2

; Test 3 = n/a  LC ROM
    STA ROMIN2
    STA SETALTZP    ; moment of truth - won't matter if STDZP or ALTZP
    LDY TEST        ; should be ROM
    STY OUT_3

LoadE000
    LDA LCBANK2     ; Enable LC RAM read
    LDA LCBANK2     ; Enable LC RAM write

    LDX SAVE_A
    LDY SAVE_M
;   STA TESTALTZP   ; OPTIMIZATION: set above
    STX TEST        ; restore CARD $E000
    STA SETSTDZP
    STY TEST        ; restore MAIN $E000

    STA ROMIN2      ; ROM
    RTS

