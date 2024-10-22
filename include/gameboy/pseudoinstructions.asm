;
; gameboy/pseudoinstructions.asm
;

INCLUDE "gameboy/constants.asm"

; For now just hardcoded the MBC in use
DEF MBC_MBC5 EQU 1

;
; cplw (Complement Word)
;

MACRO cplw
    ld         a , LOW (\1)
    cpl
    ld   LOW (\1),       a

    ld         a , HIGH(\1)
    cpl
    ld   HIGH(\1),       a
ENDM

;
; subw r16, r16 (Subtract Word)
;
; Subtract 16-bit registers using 8-bit subtract with carry.
;
; Flags:
;
;   C = Set if the subtraction underflowed
;

MACRO subw
    scf                       ; reset the carry flag
    ccf

    ld         a , LOW (\1)   ; subtract low
    sub        a , LOW (\2)
    ld   LOW (\1),       a

    ld         a , HIGH(\1)   ; subtract high with carry
    sbc        a , HIGH(\2)
    ld   HIGH(\1),       a
ENDM

;
; czw r16 (Compare Zero Word)
;
; Assert whether a 16-bit register is zero.
;
; Flags:
;
;   Z = Set if result is zero
;   N = 1
;   H = 0 (due to OR)
;   C = 0 (due to OR)
;

MACRO czw
    xor  a
    or   a , LOW (\1)
    or   a , HIGH(\1)
    cp   a ,       0
ENDM

;
; cpw r16, n16 (Compare Word) (UNTESTED)
;
; An approximation of CP a, r8 for 16-bit registers. Significantly slower,
; approx. 4 + 3 + (subw * cycles) + 3 cycles.
;

MACRO cpw
    push  hl
    ld    hl , \2
    subw  \1 , hl
    pop   hl
ENDM

MACRO minw
    push    \1
    subw    \1 ,        \2
    pop     \1

    jr       c , .return\@
    ld LOW (\1),   LOW (\2)
    ld HIGH(\1),   HIGH(\2)

.return\@
ENDM

;
; vbs (VRAM Bank Select)
;
; Switch VRAM bank.
;

MACRO vbs
    ld       a , \1
    ldh [R_VBK],  a
ENDM

IF DEF(MBC_MBC5)

    ;
    ; rbs (ROM Bank Select)
    ;

    MACRO rbs
        ld      a ,  LOW(\1)
        ld [$2000],       a
        ld      a , HIGH(\1)
        ld [$3000],       a
    ENDM

ENDC
