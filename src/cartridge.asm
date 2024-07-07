;
; cartridge.asm

SECTION "Nintendo Logo",     ROM0[$0104]

    INCBIN "assets/nintendo_logo.bin"

    ; TODO: Handle 15 and 16 byte cases. Perhaps a struct or union would be
    ;       more appropriate.
SECTION "Title",             ROM0[$0134]
    DS 11, $00

SECTION "Manufacturer Code", ROM0[$013F]
    DB 0,0,0,0

SECTION "CGB Flag",          ROM0[$0143]
    DB $C0

SECTION "New Licensee Code", ROM0[$0144]
    DB "01" ; Nintendo Research and Development

SECTION "SGB Flag",          ROM0[$0146]
    DB $00

; MBC5
SECTION "Cartridge Type",    ROM0[$0147]
    DB $19

; MBC5 - 8MiB ROM
SECTION "ROM Size",          ROM0[$0148]
    DB $08

; MBC $19 doesn't have RAM
SECTION "RAM Size",          ROM0[$0149]
    DB $00

SECTION "Destination Code",  ROM0[$014A]
    DB $00

SECTION "Old Licensee Code", ROM0[$014B]
    DB $00

SECTION "Mask ROM Version",  ROM0[$014C]
    DB $00

SECTION "Header Checksum",   ROM0[$014D]
    DB $00

SECTION "Global Checksum",   ROM0[$014E]
    DB $00,$00
