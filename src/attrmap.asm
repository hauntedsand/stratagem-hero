;
; attrmap.asm
;

INCLUDE "gameboy/constants.asm"
INCLUDE "gameboy/pseudoinstructions.asm"

SECTION "Attrmap Subroutines", ROM0

attrmap_load::

    push  hl

    vbs    1

    push  de
    push  bc
    
    ld    hl ,         $9800
    minw  bc , $9BFF - $9800
    call              memcpy

    pop   bc
    pop   de

    ld    hl ,         $9C00
    minw  bc , $9FFF - $9C00
    call              memcpy

    vbs    0

    pop   hl
    ret

attrmap_reset::

    push  hl

    vbs    1

    ld    hl ,  $9800
    ld    bc ,  $9BFF - $9800
    call                bzero

    ld    hl ,  $9C00
    ld    bc ,  $9FFF - $9C00
    call                bzero

    pop   hl
    ret
