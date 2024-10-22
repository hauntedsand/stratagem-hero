;
; gbg.asm
;

SECTION "GBG Loader Subroutines", ROM0

;
; gbg_load
;
; hl: pointer to the structure header
;

gbg_load::

    ld     a ,          [hli]
    ld     d ,             a

    inc                   hl   ; skip the padding byte

; load the resources specified in the manifest

    and    a ,            $1
    call  nz ,  load_tileset
    call   z , tileset_reset

    ld     a ,             d
    and    a ,            $2
    call  nz ,  load_palette
    call   z , palette_reset

    ld     a ,             d
    and    a ,            $4
    call  nz ,  load_tilemap
    call   z , tilemap_reset

    ld     a ,             d
    and    a ,            $8
    call  nz ,  load_attrmap
    call   z , attrmap_reset

    ret

resolve_section:

    push  hl
    push  hl

    xor    a
    ld     b ,      a
    add   hl ,     bc  ; add section header offset to pointer

    ld     a ,  [hli]  ; the section offset
    ld     d ,     a
    ld     a ,  [hli]
    ld     e ,     a

    ld     a ,  [hli]  ; the section size
    ld     b ,     a
    ld     a ,  [hli]
    ld     c ,     a

    pop   hl           ; resolve the section address
    add   hl ,    de
    ld     e ,     l
    ld     d ,     h

    pop   hl
    ret

load_tileset:

    push          hl
    push          de
    push          af

    ld     c ,    $0
    call          resolve_section
    call          tileset_load

    pop           af
    pop           de
    pop           hl
    ret

load_palette:

    push          hl
    push          de
    push          af

    ld     c ,    $4
    call          resolve_section
    call          palette_load

    pop           af
    pop           de
    pop           hl
    ret

load_tilemap:

    push          hl
    push          de
    push          af

    ld     c ,    $8
    call          resolve_section
    call          tilemap_load
    
    pop           af
    pop           de
    pop           hl
    ret

load_attrmap:

    push          hl
    push          de
    push          af

    ld     c ,    $b
    call          resolve_section
    call          attrmap_load
    
    pop           af
    pop           de
    pop           hl
    ret
