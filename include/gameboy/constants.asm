
IF  ! DEF(INCLUDE_GAMEBOY_CONSTANTS)
DEF       INCLUDE_GAMEBOY_CONSTANTS EQU 1

; Interrupts

DEF R_IF          EQU $ff0f ; interrupt flag
DEF R_IE          EQU $ffff ; interrupt enable

; LCD
DEF R_LCDC        EQU $ff40
DEF R_LCDC_STAT   EQU $ff41
DEF R_LCDC_SCY    EQU $ff42
DEF R_LCDC_SCX    EQU $ff43
DEF R_LCDC_LY     EQU $ff44
DEF R_LCDC_LYC    EQU $ff45

; Object Palette
DEF R_OBP0        EQU $ff48
DEF R_OBP1        EQU $ff49

; BG Palette Data
DEF R_BGP         EQU $ff47

; Timer
DEF R_TAC         EQU $ff07
DEF R_TMA         EQU $ff06

; Serial
DEF R_SB          EQU $ff01
DEF R_SC          EQU $ff02

; Scroll
DEF R_SCY         EQU $ff42
DEF R_SCX         EQU $ff43

; Window
DEF R_WY          EQU $ff4a
DEF R_WX          EQU $ff4b

; OAM DMA
DEF R_OAM_SRC     EQU $FF46

;
; Palettes
;

; CGB backgrounds

DEF R_BCPS        EQU $ff68
DEF R_BGPI        EQU $ff68
DEF R_BCPD        EQU $ff69
DEF R_BGPD        EQU $ff69

; CGB objects

DEF R_OCPS        EQU $ff6a
DEF R_OBPI        EQU $ff6a

DEF R_OCPD        EQU $ff6b
DEF R_OBPD        EQU $ff6b

DEF F_LCDC_ENABLE EQU 7
DEF M_LCDC_ENABLE EQU 1 << F_LCDC_ENABLE

DEF C_LY_VBLANK   EQU 145

;
; VRAM bank
;

DEF R_VBK         EQU $ff4f

;
; Interrupt flags
;
; Number of bitshifts to the flag.
;

DEF F_INTERRUPT_VBLANK EQU 0
DEF F_INTERRUPT_LCD    EQU 1
DEF F_INTERRUPT_TIMER  EQU 2
DEF F_INTERRUPT_SERIAL EQU 3
DEF F_INTERRUPT_JOYPAD EQU 4

ENDC
