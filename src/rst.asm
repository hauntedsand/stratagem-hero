;
; rst.asm
;
; Game Boy ROM0 contains 8 RST instruction jump vectors. RST is a more
; efficient alternative to CALL. These jump vectors are convention, and
; if RST is not used the memory may be used arbitrarily.
;
; Probably good candidates for interrupts (interrupt -> rst -> jp).
;

SECTION "rst0", ROM0
    ret

SECTION "rst8", ROM0
    ret

SECTION "rst10", ROM0
    ret

SECTION "rst18", ROM0
    ret

SECTION "rst20", ROM0
    ret

SECTION "rst28", ROM0
    ret

SECTION "rst30", ROM0
    ret

SECTION "rst38", ROM0
    ret
