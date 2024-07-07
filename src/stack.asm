;
; stack.asm

SECTION "Stack", WRAM0

    ; reserve space for the stack
    DS $100 - 1

    ; locate the base of the stack at the final byte
    stack:: DB
