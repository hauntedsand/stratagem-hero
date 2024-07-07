;
; game/game.asm
;
; Game state is managed by a singleton structure in WRAM accessed via methods.

INCLUDE "gameboy/constants.asm"
INCLUDE "gameboy/pseudoinstructions.asm"
INCLUDE "game/types.asm"

MACRO DEREF_BYTE
    ld   de,  \1
    add  hl,  de
    ld    a, [hl]
ENDM

DEF STRATAGEM_CODE_ROW             EQU   12
DEF STRATAGEM_CODE_COLUMN          EQU    1
DEF STRATAGEM_CODE_TILESET_OFFSET  EQU  $16

DEF STRATAGEM_CODE_F_CLEAR         EQU    1
DEF STRATAGEM_CODE_F_HIGHLIGHT     EQU    2      ; turns it dark gray

DEF STRATAGEM_CODE_ARROW_TILE_SIZE EQU    4
DEF STRATAGEM_CODE_ARROW_LEFT      EQU    0
DEF STRATAGEM_CODE_ARROW_UP        EQU    1
DEF STRATAGEM_CODE_ARROW_RIGHT     EQU    2
DEF STRATAGEM_CODE_ARROW_DOWN      EQU    3

DEF STRATAGEM_NAME_CHARACTER_MAP_OFFSET EQU  38

SECTION "Game State Methods", ROM0

sz_eagle:

    DB "Eagle",0

sz_500kg_bomb:

    DB "500kg Bomb",0

sz_airstrike:

    DB "Airstrike",0

sz_hellbomb:
    DB "Hellbomb",0

;
; game_construct
;
; Called to initialise game state. Akin to a constructor.
;
;   hl: the base address of the game state structure
;

game_construct::

    push               hl

    ld                 bc , SIZEOF("Game State")
    call            bzero

    pop                hl  ; restore the object pointer
    push               hl

    ld                  a , F_GAME_REDRAW
    call        set_flags

    pop                hl

    ret

;
; game_vblank
;
; Called when VBlank interrupts occur. This is where redraws occur.
;

game_vblank::

    push                   hl

    call  is_redraw_requested
    call                    z, redraw

; For now, always set the redraw flag so redraw will always be invoked

    ld                      a, F_GAME_REDRAW
    call            set_flags

    pop                    hl

    ret

;
; game_start
;
; Called when the game is started, post-initialisation.
;

game_start::

    push hl

; Reset the palette

    call         tileset_reset
    call         palette_reset
    call         tilemap_reset
    call         attrmap_reset

    rbs          BANK   ("assets/backgrounds/stratagem_hero")
    ld      hl , STARTOF("assets/backgrounds/stratagem_hero")
    call         gbg_load

    pop          hl
    push         hl

;   call         load_default_tiles
    call         load_default_palettes

    pop          hl
    push         hl

;    ld           de , $0404
;    push         de
;    ld           de , $abcd
;    push         de
;    ld           de , sz_hellbomb
;    push         de

;    ld           hl , sp + 0
;    ld            e , l
;    ld            d , h

;    ld          de , $abcd
;    ld           c ,   4
;    call         draw_stratagem_code

; there's an unaccounted for side-effect from draw_stratagem_code
; that's ensuring draw_stratagem_name works; it fails without it

; this was the issue - in the wrong vram bank
    vbs       0

     xor          a
     inc          a
     ld          de , sz_hellbomb
     call             draw_stratagem_name

;   add         sp , 6

; Set unsigned background and window tile addressing to 8000 mode

    ld       a , [R_LCDC]
    or       a ,      16   ; 0b10000
    ld [R_LCDC],       a

    call lcd_enable

; Enable VBlank interrupts

    xor                       a
    set  F_INTERRUPT_VBLANK , a
    ldh               [R_IE], a

    ei

.loop

    halt                             ; wait for next interrupt
    
    nop

    jr .loop

    pop  hl

    ret

;
; clear_structure
;
; Clear the instance structure.
;

clear_structure:

    push     hl
    
    ld       bc , SIZEOF("Game State")
    call  bzero
    
    pop      hl

    ret

; draw_arrow
;
;   d (high) : flags
;   d (low)  : the total number of arrows on the line (determines position and alignment)
;   e (high) : the orientation of the arrow
;   e (low)  : the index of the arrow to draw

draw_arrow:

; todo: reset carry flag

; this assumes the tiles are in VRAM bank 0

    push     hl
    push     de                            ; may not be necessary to save de

    vbs       0

; calculate the x offset of the arrow

    ld        a ,      e
    and       a ,    $0f
    rlc       a                            ; multiply by 2
    add       a ,      STRATAGEM_CODE_COLUMN
    ld        c ,      a
    ld        b ,      0

; calculate the code length offset (9 - n)

    ld        a ,      d
    and       a ,    $0f
    ld        d ,      a
    ld        a ,      9
    sub       a ,      d
    add       a ,      c
    ld        c ,      a

; calculate the y offset

    ld       hl ,      STRATAGEM_CODE_ROW  ; multiply by 32 (shift left 5x)
    
    rlc       l                            ; the maximum range is 0-31, so maximum of 2 overflow bits
    rlc       l
    rlc       l
    rlc       l
    rl        h                            ; carry any overflow bit
    
    rlc       l
    rl        h                            ; carry any overflow bit

; add x to y to get the tile map offset

    add      hl ,     bc                   ; add the x offset

    dec      hl                            ; DEBUG: there's an off-by-one error so instead of thinking i dec

; if the clear flag is set, skip tile set indexing
    
    pop      de                            ; refresh register d
    push     de

    ld        a ,      d
    swap      a
    and       a ,      STRATAGEM_CODE_F_CLEAR
    jr       nz ,     .clear

; calculate the tile set offset for the desired orientation

    ld        a ,      e
    swap      a
    and       a ,    $0f
    rlc       a                            ; multiply by 4
    rlc       a
    add       a ,      STRATAGEM_CODE_TILESET_OFFSET

.map_tiles

; map the tiles

    push     hl                            ; get the address pointing into tile map 1
    
    ld       bc ,  $9800
    add      hl ,     bc

    ld     [hli],      a                   ; map the tiles on row 1
    inc       a
    ld     [hli],      a
    inc       a

    ld       bc ,     30
    add      hl ,     bc                   ; seek one row

    ld     [hli],      a                   ; map the tiles on row 2
    inc       a
    ld     [hli],      a

    pop      hl                            ; this would be re-used for tile map 2

    jr                 .return

.clear

; a tileset_set subroutine that accepts an offset would be more suitable than
; this ad-hoc code

    push     hl                            ; get the address pointing into tile map 1

    ld       bc ,  $9800
    add      hl ,     bc

    xor       a

    ld     [hli],      a
    ld     [hli],      a

    ld       bc ,     30
    add      hl ,     bc                   ; seek one row

    ld     [hli],      a
    ld     [hli],      a

    pop      hl                            ; this would be re-used for tile map 2

.return

    pop      de
    pop      hl
    ret

;
; draw_stratagem_code
;
; Draw a bit-encoded stratagem code suitable for stored configuration.
;
; Parameters:
;
;    b:  reserved
;    c:  size
;   de:  code bits
;

draw_stratagem_code:

    push  hl

    xor    a
    ld     b ,       a

.loop

    push  bc
    push  de

    ld     a ,       e       ; arrow orientation (high 4 bits)
    and    a ,       3
    swap   a
    or     a ,       b       ; arrow index
    
    ld     e ,       a
    ld     d ,       c       ; total number of arrows (low 4 bits)

    call   draw_arrow

    pop   de
    pop   bc

    inc    b

    ld     a ,       c
    cp     a ,       b
    jr     z , .return

    rrc    d                 ; shift the arrow bitfield two to the right
    rr     e
    rrc    d
    rr     e
    
    jr           .loop

.return

    pop   hl
    ret

;
; draw_stratagem
;
; Draw a stratagem from a state object. These instances will eventually be
; created in WRAM, linked to their associated resources, and potentially
; record the state of code entry.
;
; Parameters:
;
;   hl: instance pointer
;

draw_stratagem:

    push  hl

; draw the stratagem name
    ld     a ,  [hli]
    ld     e ,     a
    ld     a ,  [hli]
    ld     d ,     a

    call        draw_stratagem_name

; draw the stratagem arrows
    ld     a ,  [hli]
    ld     e ,     a
    ld     a ,  [hli]
    ld     d ,     a
    ld     a ,  [hli]
    ld     c ,     a

    call        draw_stratagem_code

    pop   hl
    ret

; For the purposes of this check we just consider SP ($20) the one true
; space.

ascii_is_space:

    push     de

    ld        d ,                0  ; result = 0

    cp        a ,              $20  ; equal or greater than ASCII a
    jr        z ,          .return
    
    ld        d ,                1

.return

    ld        a ,                d

    pop      de
    ret

ascii_is_digit:

    push     de

    ld        d ,                0  ; result = 0

    cp        a ,              $30  ; equal or greater than ASCII 0
    jr        c ,          .return
    
    cp        a ,              $40  ; equal or less than ASCII 9
    jr       nc ,          .return

    ld        d ,                1  ; result = 1

.return

    ld        a ,                d
    
    pop      de
    ret

ascii_is_lower:

    push     de

    ld        d ,                0  ; result = 0

    cp        a ,              $61  ; equal or greater than ASCII a
    jr        c ,          .return
    
    cp        a ,              $7b  ; equal or less than ASCII z
    jr       nc ,          .return

    ld        d ,                1  ; result = 1

.return

    ld        a ,                d

    pop      de
    ret

ascii_is_upper:

    push     de

    ld        d ,                0  ; result = 0

    cp        a ,              $41  ; equal or greater than ASCII A
    jr        c ,          .return
    
    cp        a ,              $5b  ; equal or less than ASCII Z
    jr       nc ,          .return

    ld        d ,                1  ; result = 1

.return

    ld        a ,                d

    pop      de
    ret

ascii_resolve:

    ld        d ,                a

    call            ascii_is_digit
    cp        a ,                1
    jr        z ,    .return_digit

    ld        a ,                d
    call            ascii_is_lower
    cp        a ,                1
    jr       nz ,         .branch1

    ld        a ,                d    ; If a lowercase letter, remap it to the
    sub       a ,              $20    ; ASCII uppercase range
    ld        d ,                a

.branch1

    ld        a ,                d
    call            ascii_is_upper
    cp        a ,                1
    jr        z ,   .return_letter

    ld        a ,                d
    call            ascii_is_space
    cp        a ,                1
    jr        z ,    .return_space

; otherwise, return a default invalid value

.return_invalid
.return_space:

    ld        a ,                                   3
    ret

.return_digit

    ld        a ,                                   d
    sub       a ,                                 $30
    add       a , STRATAGEM_NAME_CHARACTER_MAP_OFFSET + 25   ; the arithmetic here is sketchy but whatever
    ret

.return_letter

    ld        a ,                                   d
    sub       a ,                                 $41
    add       a , STRATAGEM_NAME_CHARACTER_MAP_OFFSET
    ret

;
; strlen
;

strlen_:

    push de

    ld   bc ,        0

.loop

    ld    a ,      [de]
    inc  de

    cp    a ,        0
    jr    z ,  .return

    inc  bc
    jr           .loop

.return

    pop  de
    ret

;
; draw_stratagem_name
;
; Map text to the stratagem name space in the background tile map.
;
; Parameters:
;
;   de: null-terminated ASCII string
;
; TODO:
;
;   - Clean up test logic (so tired)
;   - Add support for line breaks
;

draw_stratagem_name:

    push  hl

    xor    a
    ld     b , a
    ld     c , a

; de = string
    call       strlen_

; Something broke. But what?
;   scf
;   ccf

    rrc              b    ; divide by two
    rr               c

    ld    hl ,       9
    subw  hl ,      bc

    ld    bc ,   $9800 + 289 ; 10 x 32 + 1
    add   hl ,      bc

.loop:

    ld     a ,     [de]   ; break the loop if *str == 0
    inc   de
    cp     a ,       0
    jr     z , .return

    push            de
    call ascii_resolve
    pop             de

    ld  [hli],       a
    jr           .loop

.return
    
    pop   hl
    ret

;
; get_flags
;
; Parameters:
;
;  hl: instance pointer
;
; Returns:
;
;   a: flags
;

get_flags:

    ; Rather than this, I could use the bit instruction

    push  hl

    ld    de ,  GameState_Flags
    add   hl ,  de
    ld     a , [hl]

    pop   hl

    ret

;
; is_redraw_requested
;
; Sets the Z flag to reflect whether a redraw was requested.
;

is_redraw_requested:

    call  get_flags
    ld            b , 1 << F_GAME_REDRAW                     
    and           a ,                  b

    ret

load_default_palettes:

    push    hl

    ld      hl ,   $3f7e   ; helldiver yellow
    push    hl
    ld      hl ,   $5ad6   ; status gray
    push    hl
    ld      hl ,   $ffff   ; white
    push    hl
    ld      hl ,   $1084   ; helldiver gray
    push    hl

; load the background palette

    ld      hl ,      sp + 0
    ld       e ,       l
    ld       d ,       h
    ld      bc ,      $8

    call           palette_load

; load the object palette

    ld      hl ,      sp + 0
    ld       e ,       l
    ld       d ,       h
    ld      bc ,      $8

    call           palette_obj_load

    add     sp ,      $8

    pop     hl
    ret

load_default_tiles:

    push    hl

; Load the four solid background tiles: $0000, $ff00, $00ff, and $ffff.

    add     sp , -$40

    ld      hl ,   sp + 0
    ld      bc ,  $10
    xor      a

    call    memset

; todo: the in between tiles will need striping

    ld      hl ,   sp + $30
    ld      bc ,  $10
    ld       a ,  $ff

    call    memset

    ld      hl ,   sp + 0
    ld       e ,    l
    ld       d ,    h
    ld      bc ,  $20

    call    tileset_load

    add     sp ,  $40
    
    pop     hl
    ret

;
; redraw
;
; Called during VBlank when the game must redraw.
;

redraw:

; load the game state

    push hl

    push hl
    DEREF_BYTE GameState_State
    pop  hl

; dispatch to the appropriate handler

    cp    a , 0
    call  z , redraw_splash

    pop  hl

    ret

;
; redraw_splash
;
; Redraw the splash screen during VBlank.
;

redraw_splash:

    ret

;
; set_flags
;
; Parameters:
;
;  hl: instance pointer
;   a: flags
;
; Preserves hl.
;

set_flags:

    push         hl

; combine the current flags and the new flags

    ld            b , a
    call  get_flags
    or            a , b

; set the flags

    ld           de , GameState_Flags
    add          hl , de

    ld          [hl], a
    
    pop          hl

    ret
