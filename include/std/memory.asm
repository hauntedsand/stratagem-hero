;
; std/memory.asm

INCLUDE "gameboy/pseudoinstructions.asm"

IF ! DEF(INCLUDE_STD_MEMORY)
DEF      INCLUDE_STD_MEMORY EQU 1

;
; INLINE_SUBROUTINE_MEMCPY
;
;   hl: destination pointer
;   de: source pointer
;   bc: byte count
;
;    a: local
;
;   Assumes that bc is greater than zero. Assume that all registers involved
;   are clobbered. Caller is responsible for saving registers.
;

MACRO INLINE_SUBROUTINE_MEMCPY
.loop\@  ld     a , [de]         ; copy one byte to de
         ld  [hli],   a

         inc  de                 ; increment source pointer and decrement byte count
         dec  bc

         czw  bc

         jr   nz ,  .loop\@
ENDM

;
; INLINE_SUBROUTINE_MEMSET
;
;   hl: destination pointer
;   bc: byte count
;    a: value
;
;    d: local
;
;   Assumes that bc is greater than zero. Assume that all registers involved
;   are clobbered. Caller is responsible for saving registers.
;

MACRO INLINE_SUBROUTINE_MEMSET
         ld          d,   a

.loop\@  ld        [hl],  d
         inc        hl
         dec        bc

         czw        bc

         jr         nz ,  .loop\@
ENDM

;
; INLINE_SUBROUTINE_BZERO
;
; See INLINE_SUBROUTINE_MEMSET.
;

MACRO INLINE_SUBROUTINE_BZERO
    xor a
    INLINE_SUBROUTINE_MEMSET
ENDM

ENDC
