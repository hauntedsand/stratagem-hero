;
; interrupt_handlers.asm

SECTION "Interrupt Handlers", ROM0

INCLUDE "interrupt_handlers/vblank.asm"
INCLUDE "interrupt_handlers/joypad.asm"
