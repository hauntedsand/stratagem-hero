;
; interrupt_handlers/joypad.asm

interrupt_joypad::

; save registers
    push af
    push bc
    push de
    push hl

; restore registers
    pop  hl
    pop  de
    pop  bc
    pop  af

    reti
