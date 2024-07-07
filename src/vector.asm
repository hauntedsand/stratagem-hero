;
; vector.asm
;

INCLUDE "gameboy/pseudoinstructions.asm"

SECTION "Vector Subroutines", ROM0

;
; vector_load
;
; Loads a buffer into a vector of buffers.
;
; Parameters:
;
;   de: source pointer
;   bc: source count
;

vector_load::

.loop

    czw   bc             ; break if source count is zero
    jr     z , .return

    pop   hl             ; break if the destination count is null
    czw   hl
    push  hl
    jr     z , .return

    push  bc              ; save the source count

    add   sp ,        2   ; sp = &dest_count
    
    pop   hl              ; copy_count = min(dest_count, src_count)
    minw  bc ,       hl
    push  bc              ; dest_count = copy_count

    add   sp ,        2   ; sp = &dest_ptr
    pop   hl              ; *sp == pc

    call         memcpy   ; pc overwrites dest_ptr, which we don't care about

    add   sp ,       -6
    pop   bc              ; saved source count
    pop   hl              ; copy count
    subw  bc ,       hl   ; remaining source count

    add   sp ,        2   ; *sp == pc

    jr            .loop

.return

; pop any remaining data from the stack

    pop   hl
    czw   hl
    jr    nz ,  .return

    ret
