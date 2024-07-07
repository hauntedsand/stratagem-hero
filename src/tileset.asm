;
; tileset.asm
;

INCLUDE "gameboy/constants.asm"
INCLUDE "gameboy/pseudoinstructions.asm"

SECTION "Tileset Subroutines", ROM0

;
; tileset_load
;
;   Distributes a buffer of tiles into VRAM tile buffers.
;
; Side effects:
;
;   - VRAM bank will be in an undefined state
;
; Considerations:
;
;   - If the source buffer is stored in a ROM bank, the caller is responsible
;     for switching to the corresponding ROM bank
;

tileset_load::

    push   hl

    push   de                  ; Save the source buffer pointer and size
    push   bc

    vbs     0                  ; VRAM bank 0

    call        tileset_load_

    pop    bc                  ; Restore the source buffer pointer and size
    pop    de

    vbs     1                  ; VRAM bank 1

    call        tileset_load_

    pop    hl

    ret
    
tileset_load_:

    ld     hl,  .return
    push   hl

    ld     hl ,       0   ; Break
    push   hl

    ld     hl ,   $8800   ; VRAM tileset at $8800
    push   hl
    ld     hl ,    $800
    push   hl

    ld     hl ,   $8000   ; VRAM tileset at $8000
    push   hl
    ld     hl ,    $800
    push   hl

    jp      vector_load

.return:

    ret


tileset_reset::

    push   hl

    ld     hl ,   $8000   ; VRAM tileset at $8000
    ld     bc ,    $800
    call          bzero

    ld     hl ,   $8800   ; VRAM tileset at $8800
    ld     bc ,    $800
    call          bzero

    pop    hl

    ret
