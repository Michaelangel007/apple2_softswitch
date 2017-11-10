; What happens to HIGH RAM on Set ALTZP $C009?
; Init 0.
;         Aux  LC RAM = 'A'
;         Main LC RAM = 'M'
; Test 1. Aux  LC RAM
; Test 2. Main LC RAM
; Test 3. n/a  LC ROM
; ====================

STORE80     = $C000

RDMAINRAM   = $C002
RDCARDRAM   = $C003

WRMAINRAM   = $C004
WRCARDRAM   = $C005

SETSTDZP    = $C008
SETALTZP    = $C009

ROMIN2      = $C082
LCBANK2     = $C083 ; Must be LOAD x2

MOV_SRC     = $003C ; A1L
MOV_END     = $003E ; A2L
MOV_DST     = $0042 ; A4L
AUXMOVE     = $C311 ; C=0 Aux->Main, C=1 Main->Aux
MOVE        = $FE2C ; Main<->Main, *MUST* set Y=0 prior!

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

__LEN = __END - __MAIN

__MAIN
     STA STORE80     ; Allow RD*RAM and WR*RAM to work

; 22 bytes
;    LDA #0
;    LDX #<__END
;    LDY #>__MAIN
;    STA MOV_SRC+0
;    STX MOV_END+0
;    STA MOV_DST+0
;    STY MOV_SRC+1
;    STY MOV_END+1
;    STY MOV_DST+1
;    SEC             ;  C=1 Main->Aux
;    JSR AUXMOVE

; 17 bytes
    LDX #<__END
    STA RDMAINRAM
    STA WRCARDRAM
Copy2Aux
    LDA __MAIN,X
    STA __MAIN,X
    DEX
    BNE Copy2Aux    ; off-by-one bug but is OK

    STA ROMIN2      ; bank LC ROM
    LDA TEST
    STA WRMAINRAM
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
    STA SETALTZP    ; moment of truth - won't matter if STD or ALT
    LDY TEST        ; should be ROM
    STY OUT_3

LoadE000
    LDA LCBANK2     ; Enable LC RAM read
    LDA LCBANK2     ; Enable LC RAM write

    LDX SAVE_A
    LDY SAVE_M
    STX TEST        ; restore CARD $E000
    STA SETSTDZP
    STY TEST        ; restore MAIN $E000

    STA ROMIN2      ; ROM
    STA STORE80+1   ;
    RTS
__END

