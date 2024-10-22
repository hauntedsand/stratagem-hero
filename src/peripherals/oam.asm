;
; gameboy/oam_dma.asm

INCLUDE "gameboy/constants.asm"

SECTION "OAM DMA Subroutine Prototype", ROM0

;
; oam_dma_prototype
;
;   a: source address (in OAM convention)
;

oam_dma_prototype::

; The transfer should take 160 M-cycles: 640 dots (1.4 lines) in normal
; speed, or 320 dots (0.7 lines) in CGB double speed mode. I suppose this
; duration is constant. It looks like it copies a fixed amount of data to
; fill OAM.
;
; Transfers are from ROM or RAM to OAM (Object Attribute Memory).

    ldh [R_OAM_SRC], a                      ; OAM DMA source address and start register
    ld               a,                  40 ; delay (4 * 40 = 160 M-cycles). Is this delay exact for a DMA copy? Or is it just an approximation?

    ; busy wait for memory copy
.wait:

    dec       a
    jr       nz,               .wait
    
    ret

SECTION "OAM DMA Subroutine", HRAM

    DS SIZEOF("OAM DMA Subroutine Prototype") - 1
        oam_dma:: DB
