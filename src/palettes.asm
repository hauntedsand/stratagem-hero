;
; palettes.asm
;

INCLUDE "gameboy/constants.asm"
INCLUDE "gameboy/pseudoinstructions.asm"

SECTION "Palette Subroutines", ROM0

;
; palette_obj_load
;

palette_obj_load::

    push      hl

; Clear the background palette index address and enable auto-increment
    xor        a
    set        7 ,      a
    ldh  [R_OBPI],      a

    ld         l ,      e   ; hl = palette_ptr
    ld         h ,      d
    minw      bc ,     64   ; as 64 fits within one byte, the minimum byte
                            ; count will always fit in the low byte (c)

.loop
    ld         a ,   [hli]
    dec                 c
    ldh  [R_OBPD],      a
    jr        nz ,  .loop

    pop       hl
    ret

;
; palette_load
;

palette_load::

    push      hl

; Clear the background palette index address and enable auto-increment
    xor        a
    set        7 ,      a
    ldh  [R_BGPI],      a

    ld         l ,      e   ; hl = palette_ptr
    ld         h ,      d
    minw      bc ,     64   ; as 64 fits within one byte, the minimum byte
                            ; count will always fit in the low byte (c)

.loop
    ld         a ,   [hli]
    dec                 c
    ldh  [R_BGPD],      a
    jr        nz ,  .loop

    pop       hl
    ret

;
; palette_reset
;
; Resets the CGB color palette.
;

palette_reset::

    push     hl

    call     is_cgb
    push     af

    call  z, palette_reset_color
    
    pop      af
    
    call nz, palette_reset_monochrome

    pop      hl

    ret

palette_reset_color:

    call     palette_reset_color_background
    call     palette_reset_color_objects

    ret

palette_reset_color_background:

; Clear the background palette index address and enable auto-increment
    xor        a
    set        7 ,      a
    ldh  [R_BGPI],      a

    ld         c ,     64

; Set the background palette to black
    ld         a ,    $ff
.loop
    sub        a ,     32
    dec                 c
    ldh  [R_BGPD],      a
    jr        nz ,  .loop

    ret

palette_reset_color_objects:

; Clear the background palette index address and enable auto-increment
    xor        a
    set        7 ,     a
    ldh  [R_OBPI],     a

    ld         c ,    64

; Set the background palette to black
    xor                a
.loop
    dec                c
    ldh  [R_OBPD],     a
    jr        nz , .loop

    ret

palette_reset_monochrome:

    ld        a , $ff

    ldh [R_BGP ],   a
    ldh [R_OBP0],   a
    ldh [R_OBP1],   a

    ret
