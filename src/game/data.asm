;
; game/data.asm

INCLUDE "game/types.asm"

SECTION "Game State", WRAM0

   DS GameState_SIZE - 1
      GameState:: DB
