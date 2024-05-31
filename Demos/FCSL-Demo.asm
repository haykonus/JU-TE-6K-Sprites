;------------------------------------------------------------------------------
; Title:                JuTe 6K Full-Color-Sprite-Library  (6K-FCSL) Demo
;
; Created:              02.01.2024 
;------------------------------------------------------------------------------ 

                cpu     z8601
                assume RP:0C0h                  ; no register optimisation 
                
        ifndef  BASE
                BASE:   set     8000H   
        endif   
                org     BASE
                include ..\ES4.0\es40_inc.asm

;------------------------------------------------------------------------------ 
; vars
;------------------------------------------------------------------------------ 

IXH             equ     var_R_lo                ; index to a track
IXL             equ     var_S_hi

slot            equ     var_S_lo                ; program parameter
loops           equ     var_T_hi
steps           equ     var_T_lo        
start_dir       equ     var_U_hi
start_steps     equ     var_U_lo

wtimer_hi       equ     var_V_hi                ; WALK_SPRITE parameter
wtimer_lo       equ     var_V_lo
wsteps_hi       equ     var_W_hi
wsteps_lo       equ     var_W_lo
wstepw          equ     var_X_lo
wdir            equ     var_Y_lo
wslot           equ     var_Z_lo

;------------------------------------------------------------------------------
; track structure
;------------------------------------------------------------------------------
                ENUM    INIT, MOVE, SET, CLR, WALK, TIMER
                
TRACKS          STRUCT

action          dw      ?       ; INIT, MOVE, SET, CLR, WALK, TIMER     
arg1            dw      ?       ; V     
arg2            dw      ?       ; W     
arg3            dw      ?       ; X
arg4            dw      ?       ; Y
arg5            dw      ?       ; Z

TRACKS          ENDSTRUCT

;------------------------------------------------------------------------------
; main
;------------------------------------------------------------------------------

                srp     #70h
                
                ; clear screen
                
                ld      var_Z_lo, #11010000b    ; blue -> Color RGBH0000
                ld      var_Z_hi, #00ffh        ; pixel
                call    cls                     ; fast clear
                call    Testbild                ; fast Testbild 
        
                jr      lp1
                
                ld      IXH, #hi(test)          ; Smiley's, on your place !
                ld      IXL, #lo(test)          
                call    statemachine
                
                jr      lp1
                ;jp     monitor
        
;------------------------------------------------------------------------------
                
        lp1:    ld      IXH, #hi(fullcolor)     ; full color sprite
                ld      IXL, #lo(fullcolor)             
                call    statemachine

        lp3:    ld      IXH, #hi(ready)         ; Smiley's, on your place !
                ld      IXL, #lo(ready)         
                call    statemachine            
                
        lp2:    call    dancing                 ; dance !       
        
                ld      IXH, #hi(home)          ; back home ...
                ld      IXL, #lo(home)          
                call    statemachine            
                
                ld      IXH, #hi(bye)           ; bye ...
                ld      IXL, #lo(bye)
                call    statemachine
                
                jp      MONITOR
                
;------------------------------------------------------------------------------
; animation of sprites 
;------------------------------------------------------------------------------
dancing:
                ; WALK_SPRITE initial setup
                
                clr     wsteps_hi       ; steps
                ld      wsteps_lo, #1
                
                ld      wtimer_hi, #0
                ld      wtimer_lo, #0
                
                ld      wstepw, #1      ; stepw
                
                ; start parameter
                
                clr     loops
                ld      start_dir, #3
                ld      start_steps, #80                
                
                dm2:    ld      steps, start_steps
                        ld      wdir, start_dir
                        
                        dm1:
                                clr     slot    
                                
                                dm5:    inc     wdir            ; next direction
                                        and     wdir, #03h      ; drop to 4-7
                                        or      wdir, #04h
                                        
                                        ld      wslot, slot     ; next slot                     
                                        call    WALK_SPRITE
                                        
                                inc     slot
                                cp      slot, #4
                                jr      nz, dm5
                                                                                                
                        dec     steps
                        jr      nz, dm1         
                
                inc     start_dir       
                
                ld      slot, loops     ; slot is temp var ...       switch speed 
                and     slot, #00000111b;                         +---------------+             
                                        ;                         |               |
                                        ;                         v               v     
                cp      slot, #4        ; loop:   0   1   2   3   4   5   6   7   8   9  ...
                jr      nc, dm3         ; steps: 80  40  20  10   5  10  20  40  80  40  ...
                                        ; stepw:  1   2   4   8  16   8   4   2   1   2  ...
                
                rr      start_steps     ; steps / 2             
                rl      wstepw          ; stepw * 2
                
                jr      dm4
                
        dm3:    rl      start_steps     ; steps * 2
                rr      wstepw          ; stepw / 2
                
        dm4:    inc     loops
                cp      loops, #8       
                jr      nz, dm2
                
                ret
                
;------------------------------------------------------------------------------
; state machine to run tracks
;------------------------------------------------------------------------------
        
statemachine:   

        ps2:    ld      r0, IXH
                ld      r1, IXL
                incw    rr0
                lde     r3, @rr0                ; r3 = action   
                incw    rr0                     ; rr0 to arg1
                
                ld      r2, #var_V_hi           ; load V-Z with arg1-5
        ps7:    ldei    @r2, @rr0
                cp      r2, #var_Z_lo+1
                jr      nz, ps7 
                
                cp      r3, #-1                 ; action = -1 ? -> END ?
                jp      z, ps1          
                
                cp      r3, #INIT               
                jp      nz, ps3 
                call    INIT_SPRITE
                jp      ps6
        
        ps3:    cp      r3, #MOVE
                jp      nz, ps41
                call    MOVE_SPRITE     
                jp      ps6

        ps41:   cp      r3, #SET
                jr      nz, ps42
                call    SET_SPRITE      
                jp      ps6
                
        ps42:   cp      r3, #CLR
                jr      nz, ps5         
                call    CLR_SPRITE
                jp      ps6
                
        ps5:    cp      r3, #WALK
                jr      nz, ps51        
                call    WALK_SPRITE
                jp      ps6     

        ps51:   cp      r3, #TIMER
                jr      nz, ps6
                call    timer0  
                jr      ps6
                                
        ps6:    add     IXL, #lo(TRACKS_LEN)    ; next track entry
                adc     IXH, #hi(TRACKS_LEN)
                
                jp      ps2
                
        ps1:    ret
                                
;-------------------------------------------------------------------------------                
; track table:                  V       W       X       Y       Z               
;                               arg1    arg2    arg3    arg4    arg5  
;               
;                       action  -       data    x       y       slot
;                       action  timer   steps   stepw   dir     slot            
;-------------------------------------------------------------------------------

fullcolor:      dw      INIT,   -1,     smiley0, 8*16,  40,     0
                dw      INIT,   -1,     smiley1, 9*16,  40,     1
                dw      INIT,   -1,     smiley2, 10*16, 40,     2
                dw      INIT,   -1,     smiley3, 11*16, 40,     3
                
                dw      TIMER,  1000,   -1,     -1,     -1,     -1
                
                dw      INIT,   -1,     colors, 6*16,   40,     4
                dw      TIMER,  500,    -1,     -1,     -1,     -1
                
                dw      CLR,    -1,     -1,     -1,     -1,     4
                dw      TIMER,  500,    -1,     -1,     -1,     -1
                
                dw      SET,    -1,     -1,     6*16,   40,     4
                dw      TIMER,  500,    -1,     -1,     -1,     -1
                
                dw      CLR,    -1,     -1,     -1,     -1,     4
                dw      TIMER,  500,    -1,     -1,     -1,     -1

                dw      SET,    -1,     -1,     6*16,   40,     4
                dw      TIMER,  1000,   -1,     -1,     -1,     -1

                dw      WALK,   15,     40,     1,      do,     4
                dw      WALK,   15,     3*16+8, 1,      dori,   4
                dw      WALK,   15,     3*16+8, 1,      upri,   4
                dw      WALK,   15,     40,     1,      up,     4
                
                dw      WALK,   0,      7*4,    4,      le,     4
                
                dw      TIMER,  1000,   -1,     -1,     -1,     -1
                dw      CLR,    -1,     -1,     -1,     -1,     4
                
                dw      -1,     -1,     -1,     -1,     -1,     -1                                      

                                        
ready:          dw      TIMER,  1000,   -1,     -1,     -1,     -1
                
                dw      MOVE,   -1,     -1,     16,     192-31, 3       
                dw      TIMER,  500,    -1,     -1,     -1,     -1
                
                dw      MOVE,   -1,     -1,     320-31, 192-31, 2
                dw      TIMER,  500,    -1,     -1,     -1,     -1
                
                dw      MOVE,   -1,     -1,     320-31, 16,     1
                dw      TIMER,  500,    -1,     -1,     -1,     -1
                
                dw      MOVE,   -1,     -1,     16,     16,     0
                dw      TIMER,  2000,   -1,     -1,     -1,     -1
                
                dw      WALK,   0,      89-16,  1,      do,     0
                dw      WALK,   0,      72-16,  1,      ri,     0
                                                
                dw      WALK,   0,      137,    1,      le,     1
                dw      WALK,   0,      16-8,   1,      up,     1
                                                
                dw      WALK,   0,      57,     1,      le,     2
                dw      WALK,   0,      72,     1,      up,     2
                                                
                dw      WALK,   0,      137,    1,      ri,     3
                dw      WALK,   0,      16-8,   1,      do,     3
                
                dw      TIMER,  2000,   -1,     -1,     -1,     -1
                
                dw      -1,     -1,     -1,     -1,     -1,     -1

                                
home:           dw      TIMER,  2000,   -1,     -1,     -1,     -1

                dw      WALK,   0,      16-8,   1,      up,     3
                dw      WALK,   0,      137,    1,      le,     3
                                                        
                dw      WALK,   0,      72,     1,      do,     2
                dw      WALK,   0,      57,     1,      ri,     2
                                                        
                dw      WALK,   0,      16-8,   1,      do,     1
                dw      WALK,   0,      137,    1,      ri,     1
                                                        
                dw      WALK,   0,      72-16,  1,      le,     0
                dw      WALK,   0,      89-16,  1,      up,     0               

                dw      -1,     -1,     -1,     -1,     -1,     -1      

                
bye:            dw      TIMER,  2000,   -1,     -1,     -1,     -1

                dw      MOVE,   -1,     -1,     8*16,   40,     0
                dw      TIMER,  500,    -1,     -1,     -1,     -1
                
                dw      MOVE,   -1,     -1,     9*16,   40,     1
                dw      TIMER,  500,    -1,     -1,     -1,     -1
                
                dw      MOVE,   -1,     -1,     10*16,  40,     2
                dw      TIMER,  500,    -1,     -1,     -1,     -1
                
                dw      MOVE,   -1,     -1,     11*16,  40,     3

                dw      TIMER,  2000,   -1,     -1,     -1,     -1

                dw      CLR,    -1,     -1,     -1,     -1,     3
                dw      CLR,    -1,     -1,     -1,     -1,     2
                dw      CLR,    -1,     -1,     -1,     -1,     1
                dw      CLR,    -1,     -1,     -1,     -1,     0
                        
                dw      -1,     -1,     -1,     -1,     -1,     -1


test:
                dw      INIT,   -1,     smiley3, 153,   169,    3       
                dw      INIT,   -1,     smiley2, 232,   89,     2
                dw      INIT,   -1,     smiley1, 152,   8,      1
                dw      INIT,   -1,     smiley0, 72,    89,     0
                
                dw      -1,     -1,     -1,     -1,     -1,     -1      
                
;----------------------------------------------------------------------------------
; sprite definitions created with Akusprite (https://www.chibiakumas.com/akusprite)
;----------------------------------------------------------------------------------
                
smiley0:        db      63,63,63,63,63,0,0,0,0,0,0,63,63,63,63,63
                db      63,63,63,0,0,11,11,11,11,11,11,0,0,63,63,63
                db      63,63,0,11,11,11,11,11,11,11,11,11,11,0,63,63
                db      63,0,11,11,11,11,0,0,11,0,0,11,11,11,0,63
                db      63,0,11,11,11,0,11,11,0,11,11,0,11,11,0,63
                db      0,11,11,11,11,0,11,0,0,11,0,0,11,11,11,0
                db      0,11,11,11,11,0,11,0,0,11,0,0,11,11,11,0
                db      0,11,11,11,11,11,0,0,11,0,0,11,11,11,11,0
                db      0,11,11,11,11,11,11,11,11,11,11,11,11,11,11,0
                db      0,11,11,11,11,11,11,11,11,11,11,11,11,11,11,0
                db      0,11,11,11,11,0,11,11,11,11,11,0,11,11,11,0
                db      63,0,11,11,11,11,0,0,0,0,0,11,11,11,0,63
                db      63,0,11,11,11,11,11,11,9,9,9,11,11,11,0,63
                db      63,63,0,11,11,11,11,11,11,9,11,11,11,0,63,63
                db      63,63,63,0,0,11,11,11,11,11,11,0,0,63,63,63
                db      63,63,63,63,63,0,0,0,0,0,0,63,63,63,63,63

smiley1:        db      63,63,63,63,63,0,0,0,0,0,0,63,63,63,63,63
                db      63,63,63,0,0,11,11,11,11,11,11,0,0,63,63,63
                db      63,63,0,11,11,11,11,11,11,11,11,11,11,0,63,63
                db      63,0,11,11,11,11,11,11,11,11,11,11,11,11,0,63
                db      63,0,11,11,11,11,11,11,11,11,11,11,11,11,0,63
                db      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                db      0,11,0,15,15,0,0,0,0,15,15,0,0,11,11,0
                db      0,11,0,15,0,0,0,11,0,15,0,0,0,11,11,0
                db      0,11,11,0,0,0,11,11,11,0,0,0,11,11,11,0
                db      0,11,11,11,11,11,11,11,11,11,11,11,11,11,11,0
                db      0,11,11,11,11,11,11,11,11,11,11,11,11,11,11,0
                db      63,0,11,11,11,11,11,11,11,11,0,11,11,11,0,63
                db      63,0,11,11,11,0,0,0,0,0,11,11,11,11,0,63
                db      63,63,0,11,11,11,11,11,11,11,11,11,11,0,63,63
                db      63,63,63,0,0,11,11,11,11,11,11,0,0,63,63,63
                db      63,63,63,63,63,0,0,0,0,0,0,63,63,63,63,63

smiley2:        db      63,63,63,63,63,0,0,0,0,0,0,63,63,63,63,63
                db      63,63,63,0,0,11,11,11,11,11,11,0,0,63,63,63
                db      63,63,0,11,11,11,11,11,11,11,11,11,11,0,63,63
                db      63,0,11,11,11,11,0,0,11,0,0,11,11,11,0,63
                db      63,0,11,11,11,0,11,11,0,11,11,0,11,11,0,63
                db      0,11,11,11,11,0,0,11,0,0,11,0,11,11,11,0
                db      0,11,11,11,11,0,0,11,0,0,11,0,11,11,11,0
                db      0,11,11,11,11,11,0,0,11,0,0,11,11,11,11,0
                db      0,11,9,9,11,11,11,11,11,11,11,11,9,9,11,0
                db      0,11,9,9,11,11,11,11,11,11,11,11,9,9,11,0
                db      0,11,11,11,0,11,11,11,11,11,11,0,11,11,11,0
                db      63,0,11,11,11,0,0,0,0,0,0,11,11,11,0,63
                db      63,0,11,11,11,11,11,11,11,11,11,11,11,11,0,63
                db      63,63,0,11,11,11,11,11,11,11,11,11,11,0,63,63
                db      63,63,63,0,0,11,11,11,11,11,11,0,0,63,63,63
                db      63,63,63,63,63,0,0,0,0,0,0,63,63,63,63,63

smiley3:        db      63,63,63,63,63,0,0,0,0,0,0,63,63,63,63,63
                db      63,63,63,0,0,11,11,11,11,11,11,0,0,63,63,63
                db      63,63,0,11,11,11,11,11,11,11,11,11,11,0,63,63
                db      63,0,11,11,11,0,0,11,0,0,11,11,11,11,0,63
                db      63,0,11,11,0,11,11,0,11,11,0,11,11,11,0,63
                db      0,11,11,11,0,11,0,0,11,0,0,11,11,11,11,0
                db      0,11,11,11,0,11,0,0,11,0,0,11,11,11,11,0
                db      0,11,11,11,11,0,0,11,0,0,11,11,11,11,11,0
                db      0,11,11,11,11,11,11,11,11,11,11,15,9,15,11,0
                db      0,11,11,11,11,11,11,11,11,11,11,9,9,9,11,0
                db      0,11,11,11,11,11,11,11,11,11,11,15,9,15,11,0
                db      63,0,11,11,11,0,0,0,0,0,11,11,11,11,0,63
                db      63,0,11,11,11,11,11,11,11,11,11,11,11,11,0,63
                db      63,63,0,11,11,11,11,11,11,11,11,11,11,0,63,63
                db      63,63,63,0,0,11,11,11,11,11,11,0,0,63,63,63
                db      63,63,63,63,63,0,0,0,0,0,0,63,63,63,63,63
                
colors:         db      15,15,15,15,0,0,0,0,8,8,8,8,4,4,4,4
                db      15,15,15,15,0,0,0,0,8,8,8,8,4,4,4,4
                db      15,15,15,15,0,0,0,0,8,8,8,8,4,4,4,4
                db      15,15,15,15,0,0,0,0,8,8,8,8,4,4,4,4
                db      12,12,12,12,2,2,2,2,10,10,10,10,6,6,6,6
                db      12,12,12,12,2,2,2,2,10,10,10,10,6,6,6,6
                db      12,12,12,12,2,2,2,2,10,10,10,10,6,6,6,6
                db      12,12,12,12,2,2,2,2,10,10,10,10,6,6,6,6
                db      14,14,14,14,1,1,1,1,9,9,9,9,5,5,5,5
                db      14,14,14,14,1,1,1,1,9,9,9,9,5,5,5,5
                db      14,14,14,14,1,1,1,1,9,9,9,9,5,5,5,5
                db      14,14,14,14,1,1,1,1,9,9,9,9,5,5,5,5
                db      13,13,13,13,3,3,3,3,11,11,11,11,7,7,7,7
                db      13,13,13,13,3,3,3,3,11,11,11,11,7,7,7,7
                db      13,13,13,13,3,3,3,3,11,11,11,11,7,7,7,7
                db      13,13,13,13,3,3,3,3,11,11,11,11,7,7,7,7
                
                include testbild.asm

                SP_VERSION:     set     2       ; EXE   
                include ..\FCSL\FCSL.asm        