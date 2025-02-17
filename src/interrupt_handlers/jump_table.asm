;
; interrupt_handlers/jump_table.asm
;
; Game Boy ROM0 contains 5 interrupt handler jump vectors.
;

    ; VBlank
    ;
    ; VBlank is called approx 59.7 times a second on a DMG or CGB. It occurs
    ; at the beginning of the VBlank period (LY=144). During this period,
    ; video hardware is not using VRAM, so it may be accessed freely.
    ;
    ; I assume the VBlank callback will be important for ticking video state.
    
SECTION "interrupt40", ROM0
    jp   interrupt_vblank

    ; Stat
SECTION "interrupt48", ROM0
    reti

    ; Timer
SECTION "interrupt50", ROM0
    reti

    ; Serial
SECTION "interrupt58", ROM0
    reti

    ; Joypad
    ;
    ; Requested when any of the P1 bits 0-3 change from High to Low. This
    ; happens when a button is pressed (provided the action/direction buttons
    ; are enabled by bit 5/4 respectively). Due to switch bounce, one or more
    ; High to Low transitions are usually produced when pressing a button, so
    ; IO logic will need to account for this.

SECTION "interrupt60", ROM0
    jp   interrupt_joypad
