;
; peripherals/lcd.asm

INCLUDE "gameboy/constants.asm"

SECTION "LCD Subroutines", ROM0

;
; lcd_disable
;
; Disable the LCD and PPU.
;
; This grants full access to the VRAM, OAM, and other resources with LCD
; contention.
;

lcd_disable::

    ; The LCD must only be disabled during VBlank. Disabling the display
    ; outside of VBlank may damage the hardware by burning in a black
    ; horizontal line. Nintendo rejected any games not following
    ; this rule.
    ;
    ; Therefore, we wait until we're in VBlank.

    ; clear interrupt flags
        xor      a
        ldh  [R_IF],      a
    
    ; disable VBlank interrupts
        ldh      a ,  [R_IE]
        ld       b ,      a                   ; save IE
        res      0 ,      a
        ldh  [R_IE],      a
    
    ; wait until we're out of vblank (?)
    .wait:
    
        ldh               a , [R_LCDC_LY]     ; subtract this magic constant from R_LCD_LY (is it a flag?)
        cp      C_LY_VBLANK
        jr               nz ,      .wait
    
    ; clear the LCDC enable flag
        ldh               a ,    [R_LCDC]
        and  ~M_LCDC_ENABLE
        ldh        [R_LCDC] ,          a
    
    ; restore IE
        ld                a ,          b
        ldh          [R_IE] ,          a
    
        ret
    
;
; lcd_enable
;
; Enable the LCD and PPU.
;
; This will cause LCD contention with video related resources.
;

lcd_enable::
    
    ldh              a , [R_LCDC]
    set  F_LCDC_ENABLE ,       a
    ldh        [R_LCDC],       a

    ret
