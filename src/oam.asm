;
; oam.asm
;

IF ! DEF(INCLUDE_OAM)
DEF      INCLUDE_OAM EQU 1

SECTION "OAM Shadow", WRAM0

    ;
    ; oam_shadow
    ;
    ; The OAM shadow is reserved WRAM for the state of OAM for DMA transfer
    ; into OAM whenever it needs to be updated.
    ;

    DS 160 - 1
        oam_shadow:: DB

SECTION "OAM Shadow Driver", ROM0

    ;
    ; oam_shadow_clear
    ;
    ; Zeros out the OAM shadow. Does not update OAM.
    ;

    oam_shadow_clear::

        ld       hl, STARTOF("OAM Shadow")
        ld       bc, SIZEOF ("OAM Shadow")
        call  bzero

        ret

    ;
    ; oam_sync
    ;
    ; Copies the OAM shadow to OAM with DMA.
    ;

    oam_sync::

        ld          a, HIGH(STARTOF("OAM Shadow"))
        call  oam_dma

        ret

ENDC
