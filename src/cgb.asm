;
; cgb.asm
;

INCLUDE "game/types.asm"

SECTION "GameBoy Metadata Subroutines", ROM0

;
; is_cgb
;
; Sets the Z flag if hardware is a GameBoy Color.
;
; This should be moved to a separate module for the GameBoy metadata structure
; and exposed as a global export.
;

is_cgb::

    ld   a , [STARTOF("GameBoy Metadata") + GameBoyMeta_Bootprint]
    cp   a , $11

    ret
