;
; game/types.asm

IF ! DEF(INCLUDE_GAME_TYPES)
DEF      INCLUDE_GAME_TYPES EQU 1

;
; GameBoyMeta
;
; This structure contains metadata about the hardware.
;

                          RSRESET
DEF GameBoyMeta_Bootprint RB 1
DEF GameBoyMeta_SIZE      RB 1

;
; GameState
;
; This structure contains the state of the game.
;

                           RSRESET
DEF GameState_Flags        RB  1
DEF GameState_State        RB  1
DEF GameState_SIZE         RB  1

DEF GameState_State_Boot   EQU 0
DEF GameState_State_Splash EQU 1

; GameState_Flags
;
; Set when video state is dirty and should be redrawn.

DEF F_GAME_REDRAW         EQU 1

ENDC
