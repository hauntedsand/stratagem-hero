;
; interrupt_handlers/vblank.asm

interrupt_vblank::

    push              af
    push              bc
    push              de
    push              hl

    ld                hl, STARTOF("Game State")
    call     game_vblank

    pop               hl
    pop               de
    pop               bc
    pop               af

    reti
