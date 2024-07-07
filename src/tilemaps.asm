;
; tilemaps.asm
;

INCLUDE "gameboy/constants.asm"
INCLUDE "gameboy/pseudoinstructions.asm"

SECTION "Tilemap Subroutines", ROM0

;
; tilemap_load
;

tilemap_load::

    push  hl

; It would be useful if there were a map of tile distribution within VRAM
; banks so the background attributes could be filled out without extra
; data

    vbs 0

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

.return

    pop   hl
    ret

;
; tilemap_reset
;
; Zero out the VRAM tile map buffers.
;

tilemap_reset::

; Since this probably won't be a GameState specific subroutine, saving hl
; isn't really necessary

    push  hl

    vbs    0

    ld    hl ,  $9800
    ld    bc ,  $9BFF - $9800
    call                bzero

    ld    hl ,  $9C00
    ld    bc ,  $9FFF - $9C00
    call                bzero

    pop   hl
    ret
