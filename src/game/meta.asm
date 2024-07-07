;
; game/meta.asm

INCLUDE "game/types.asm"

SECTION "GameBoy Metadata", WRAM0

; Populated with metadata about the hardware
    DS GameBoyMeta_SIZE - 1
       GameBoyMeta:: DB
