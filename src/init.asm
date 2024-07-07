;
; init.asm
;

INCLUDE "gameboy/constants.asm"
INCLUDE "std/memory.asm"
INCLUDE "game/types.asm"

INCLUDE "rst.asm"
INCLUDE "interrupts.asm"
INCLUDE "cartridge.asm"
INCLUDE "entry.asm"
INCLUDE "oam.asm"

SECTION "Init", ROM0

;
; General loop is this:
;
; - Initialise program state and hardware in init
; - Process VBlank interrupts for redraws
; - Process Joypad interrupts for user input
;

init::

    ; Disable interrupts during setup
    di

; Store whether the game is running on Game Boy Color.

    ; There are nine different known official boot ROMs. Some key properties
    ; of them are listed below:
    ;
    ; CGB0 - Does not init wave RAM
    ;
    ; CGB  - Split in two parts with the cartridge header in the middle,
    ;        though this seems unlikely to affect the boot sequence if it is
    ;        unmapped by time this subroutine is executed
    ;
    ; AGB0 - Increments B register for GBA identification
    ;
    ; TL;DR, GB ROMs hand off $01 or $FF in register a as a leftover artefact
    ; of handing control to the application from the boot ROM (ldh [$FF50], a).
    ; GBC hands off $11 instead. This can be used to identify a GBC.

    ; Cache the bootloader fingerprint in bootstrap space
    ld [STARTOF(WRAM0)], a

.init_registers:

; Reset registers

    xor             a

    ; clear interrupt registers
    ldh     [R_IF], a
    ldh     [R_IE], a

    ; zero screen X/Y registers
    ldh    [R_SCX], a
    ldh    [R_SCY], a

    ; clear serial transfer registers
    ldh     [R_SB], a
    ldh     [R_SC], a

    ; zero window X/Y registers
    ldh     [R_WX], a
    ldh     [R_WY], a

    ; zero timer modulo and control
    ldh    [R_TMA], a
    ldh    [R_TAC], a

    ; clear background palette data (only relevant in non-CGB mode)
    ldh   [R_BGP ], a
    ldh   [R_OBP0], a
    ldh   [R_OBP1], a

; WRAM is zeroed out inline as the stack will be stored there, and hence the
; return address would be wiped out.
;
; I could probably just exempt the stack from the wipe as it's at the top of
; WRAM anyway instead of using the 16 byte reserved space for the bootprint.

    ld    hl, STARTOF(WRAM0) + $10
    ld    bc, SIZEOF (WRAM0) - $10

    INLINE_SUBROUTINE_BZERO

; Initialize the stack

    ld  sp, stack

; Disable the LCD (after enabling it for some reason?)

    ld          a , M_LCDC_ENABLE
    ldh   [R_LCDC], a

    call  lcd_disable

; Transfer data from the bootstrap space

    ld                                                     a , [STARTOF(WRAM0)]
    ld  [STARTOF("GameBoy Metadata") + GameBoyMeta_Bootprint], a

; Copy the OAM DMA subroutine into HRAM

    ld        hl , STARTOF("OAM DMA Subroutine")
    ld        de , STARTOF("OAM DMA Subroutine Prototype")
    ld        bc , SIZEOF ("OAM DMA Subroutine Prototype")

    call  memcpy

; Wipe VRAM
    
    ld       hl , STARTOF(VRAM)
    ld       bc , SIZEOF (VRAM)

    call  bzero

;   call  reset_monochrome_palettes

; Clear OAM

    call  oam_shadow_clear
    call  oam_sync

; Start the game

    ld                hl , STARTOF("Game State")
    call  game_construct
    call  game_start

; TODO: Maybe I could display some debug graphics here

.wait:

    halt
    jr    .wait

;
; reset_monochrome_palettes
;
; Reset the monochrome palette to a default value. This is probably better
; off in the game logic implementation.
;

reset_monochrome_palettes:

    ; These values are taken from the pokered-gbc project, which I used as a
    ; reference for getting my head around the hardware

    ld        a , %11100100 ; 3210
    ldh  [R_BGP], a

    ld        a , %11100100 ; same as the background
    ldh [R_OBP0], a

    ret

INCLUDE "tile_data.asm"
