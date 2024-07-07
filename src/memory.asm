;
; memory.asm
;
; Common subroutines for manipulating memory.

INCLUDE "std/memory.asm"

SECTION "Memory Subroutines", ROM0

; TODO: Save registers according to calling conventions
bzero::

    INLINE_SUBROUTINE_BZERO
    ret

; TODO: Save registers according to calling conventions
memcpy::
    
    INLINE_SUBROUTINE_MEMCPY
    ret

; TODO: Save registers according to calling conventions
memset::

    INLINE_SUBROUTINE_MEMSET
    ret
