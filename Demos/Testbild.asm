
;------------------------------------------------------------------------------
; Titel: 		Testbild für JuTe 6K nach Idee von Rolf Weidlich 
;			ergänzt um sehr schnellen X/Y-Line-Code.	
;
; Erstellt:		20.01.2024
;------------------------------------------------------------------------------
		cpu	z8601
		assume RP:0C0h		 ; keine Register-Optimierung !
		
	ifndef	BASE
		BASE: 	set	2000H	
	endif
		
	ifndef	ES40_INC
		org	BASE
		include	..\ES4.0\es40_inc.asm
		NOT_INCLUDED: set TRUE
	endif	

		radix	16		
		
Testbild: 	PUSH    RP
  		SRP     #10
  		LD      R0, #0F7
  		LD      R1, #0A0
  		LDE     R2, @RR0
  		PUSH    R2

		ifdef NOT_INCLUDED
		LD      15, #0C		; wenn stand alone -> CLS mit ES4.0 Funktion,
  		CALL    CHAROUT		; wenn included in Demo -> Super-Fast-CLS aus FCSL-Lib.
		endif
		
  		CLR     4A
  		LD      4B, #10		; V = 16
  		CLR     4C		; 
  		CLR     4D		; W = 0	
  		CLR     4E
  		LD      4F, #10		; X = 16
  		CLR     50		; 
  		LD      51, #BF		; Y = 191
  		LD      R0, #13		
		
loc2027: 	LD      53, #0F		; Z = 15 (weiss)
  		CALL    VLINE		; Fast X Line 
  		ADD     4F, #10		; X = X + 16
  		ADC     4E, #0
  		ADD     4B, #10		; V = V + 16
  		ADC     4A, #0
  		DJNZ    R0, loc2027
		
  		CLR     4A
  		CLR     4B		; V = 0
  		CLR     4C
  		LD      4D, #10		; W = 16
  		LD      4E, #1	
  		LD      4F, #3F		; X = 319
  		CLR     50
  		LD      51, #10		; Y = 16
  		LD      R0, #0B		
		
loc2051:	LD      53, #0F		; Z = 15 (weiss)
   		CALL    HLINE		; Fast Y Line 
   		ADD     4D, #10		; W = W + 16
   		ADC     4C, #0		
   		ADD     51, #10		; Y = Y + 16
   		ADC     50, #0
   		DJNZ    R0, loc2051	
	
		; Ende Gitter
		
   		CLR     4A
   		LD      4B, #55
   		CLR     4E
   		LD      4F, #0A0
   		CLR     50
   		LD      51, #60
   		CALL    circle
		
   		CLR     4A
   		LD      4B, #10
   		CLR     4E
   		LD      4F, #18
   		CLR     50
   		LD      51, #18
   		CALL    circle

   		LD      4E, #1
   		LD      4F, #28
   		CLR     50
   		LD      51, #18
   		CALL    circle

   		CLR     4E
   		LD      4F, #18
   		CLR     50
   		LD      51, #A8
   		CALL    circle

   		LD      4E, #1
   		LD      4F, #28
   		CLR     50
   		LD      51, #A8
   		CALL    circle
		
		; Ende Kreise

   		LD      R3, #0
   		CLR     4E		; X
   		LD      4F, #0C
   		LD      R2, #8
loc20BB:	CALL    loc2186
   		CLR     50		; Y
   		LD      51, #5
   		CALL    loc217F
   		CALL    loc218D
   		CLR     50		; Y
   		LD      51, #6
   		CALL    loc217F
   		CALL    loc218D
   		ADD     R3, #0F
   		ADD     4F, #2
   		DJNZ    R2, loc20BB
	
   		CLR     4E
   		LD      4F, #0C
   		LD      R2, #8
loc20E3:	CALL    loc2186
   		CLR     50
   		LD      51, #7
   		CALL    loc217F
   		CALL    loc218D
   		CLR     50
   		LD      51, #8
   		CALL    loc217F
   		CALL    loc218D
   		ADD     R3, #0F
   		ADD     4F, #2
   		DJNZ    R2, loc20E3
		
   		LD      R3, #F0
   		CALL    loc2186
   		CLR     4E
   		LD      4F, #0C
   		CLR     50
   		LD      51, #0A
   		LD      R4, #0
   		LD      R6, #8
		
loc2117:	CALL    loc217F
   		LD      R2, #10
		
loc211C:	CP      R4, #20
   		JR      NC, loc2127
   		LD      15, #0E
   		CALL    CHAROUT
loc2127:	LD      15, R4
   		CALL    CHAROUT
   		INC     R4
   		DJNZ    R2, loc211C
		
   		INC     51
   		DJNZ    R6, loc2117
		
   		LD      R3, #0F
   		CALL    loc2186
   		CLR     4E
   		LD      4F, #0D
   		CLR     50
   		LD      51, #13
   		CALL    loc217F
   		CALL    PRISTRI
		db	"JU-TE-COMPUTER",0
	
   		CLR     4E
   		LD      4F, #12
   		CLR     50
   		LD      51, #14
   		CALL    loc217F
   		CALL    PRISTRI
		db	"*6K*",0

   		CLR     4E
   		LD      4F, #11
   		CLR     50
   		LD      51, #3
   		CALL    loc217F
   		CALL    PRISTRI
		db	"*FCSL*",0
		
   		CLR     4E
   		LD      4F, #0F
   		CLR     50
   		LD      51, #4
   		CALL    loc217F
   		CALL    PRISTRI
		db	"Sprite Demo",0

   		POP     R3
   		CALL    loc2186
   		CLR     4E
   		CLR     4F
   		CLR     50
   		CLR     51
   		CALL    loc217F
   		POP     RP
   		RET

		; ENDE

;------------------------------------------------------------------------------	
	
loc217F:	LD      53, #1		
   		CALL    SCRFUN
   		RET

loc2186:   	LD      R0, #0F7	; %F7A0 Bitmaske für Textzeichen
   		LD      R1, #0A0
   		LDE     @RR0, R3
   		RET
	
loc218D:	LD      53, R3	
   		CALL    PRISTRI
   		db	"  ",0
   		RET	

circle:		PUSH    RP
   		SRP     #70
   		PUSH    4B
   		PUSH    4E
   		PUSH    4F
   		PUSH    51
   		PUSH    53
   		LD      R4, 4E
   		LD      R5, 4F
   		LD      R6, 51
   		LD      R0, 4B
   		CLR     R1
   		LD      5D, 4B
   		CALL    loc21DF
loc21B4:	LD      R3, R1
   		RL      R3
   		INC     R3
   		INC     R1
   		SUB     5D, R3
   		JR      NC, loc21CA
   		LD      R2, R0
   		RL      R2
   		DEC     R2
   		DEC     R0
   		ADD     5D, R2
loc21CA:	CALL    loc21DF
   		CP      R1, R0
   		JP      C, loc21B4
   		POP     53
   		POP     51
   		POP     4F
   		POP     4E
   		POP     4B
   		POP     RP
   		RET

;------------------------------------------------------------------------------	

loc21DF:	LD      4F, R5
   		LD      4E, R4
   		ADD     4F, R0
   		ADC     4E, #0
   		LD      51, R6
   		ADD     51, R1
   		JR      NC, loc21F3
   		LD      51, #C0
loc21F3:	CALL    loc2298
   		LD      4F, R5
   		LD      4E, R4
   		SUB     4F, R0
   		SBC     4E, #0
   		LD      51, R6
   		ADD     51, R1
   		JR      NC, loc220A
   		LD      51, #C0
loc220A:	CALL    loc2298
   		LD      4F, R5
   		LD      4E, R4
   		SUB     4F, R0
   		SBC     4E, #0
   		LD      51, R6
   		SUB     51, R1
   		JR      NC, loc2221
   		LD      51, #C0
loc2221:	CALL    loc2298
   		LD      4F, R5
   		LD      4E, R4
   		ADD     4F, R0
   		ADC     4E, #0
   		LD      51, R6
   		SUB     51, R1
   		JR      NC, loc2238
   		LD      51, #C0
loc2238:	CALL    loc2298
   		LD      4F, R5
   		LD      4E, R4
   		ADD     4F, R1
   		ADC     4E, #0
   		LD      51, R6
   		ADD     51, R0
   		JR      NC, loc224F
   		LD      51, #C0
loc224F:	CALL    loc2298
   		LD      4F, R5
   		LD      4E, R4
   		SUB     4F, R1
   		SBC     4E, #0
   		LD      51, R6
   		ADD     51, R0
   		JR      NC, loc2266
   		LD      51, #C0
loc2266:	CALL    loc2298
   		LD      4F, R5
   		LD      4E, R4
   		SUB     4F, R1
   		SBC     4E, #0
   		LD      51, R6
   		SUB     51, R0
   		JR      NC, loc227D
   		LD      51, #C0
loc227D:	CALL    loc2298
   		LD      4F, R5
   		LD      4E, R4
   		ADD     4F, R1
   		ADC     4E, #0
   		LD      51, R6
   		SUB     51, R0
   		JR      NC, loc2294
   		LD      51, #C0
loc2294:	CALL    loc2298
   		RET

loc2298:   	CALL    PLOT
  		CLR     4E
  		RET

;------------------------------------------------------------------------------	
		radix	10

VLINE:		push	var_Y_lo
		ld	var_Y_lo, var_W_lo
		ld	r10, #192
		
		srp	#60h		
		call	0FBBh		; X,Y --> VRAM		
		ld	16h, 60h	; r0 = VRAM hi
		ld	17h, 61h	; r1 = VRAM lo
		ld	13h, 63h	; r3 = Pixel-Pos
		
		srp	#10h		; r6 = VRAM hi
					; r7 = VRAM lo
		                        ; r3 = Pixel-Pos
		                      
		ld	r12, #60h	; Farb-Register hi
		
		ld	p01m, #0B2h	; Ports	0-1 mode, langsames Timing für ext. Speicher
		
fdl2:		ld	r13, #11011111b	; Farb-Bänke = RGBHxxxx (blau)
		lde	@rr12, r13
		ld	r11, #0FFh	; 8 Pixel
		lde	@rr6, r11

		ld	r13, #00101111b	; Farb-Bänke = RGBHxxxx (rot, grün, hell)
		lde	@rr12, r13
		lde	@rr6, r3	; 1 Pixel aus R3

		add	R7, #28h	; next VRAM-Adr. -> Y = Y +1 	
		jr	C,  vram1       
		jr	OV, vram2	
		tcm	R7, #78h	
		jr	NZ, vram3	
		db  0Bh	                						
vram1:		inc	R6		
vram2:		add	R7, #8		
		adc	R6, #0		
vram3:				
		djnz	r10, fdl2
		
		ld	p01m, #092h	; Ports	0-1 mode, schnelles Timing für ext. Speicher
		
		pop	var_Y_lo
		ret
		
;------------------------------------------------------------------------------	

HLINE:		push	var_X_hi
		push	var_X_lo
		
		ld	var_X_hi, var_V_hi
		ld	var_X_lo, var_V_lo
		ld	r11, #40

		srp	#60h		
		call	0FBBh		
		ld	16h, 60h	; r6 = VRAM hi
		ld	17h, 61h        ; r7 = VRAM lo
		srp	#10h		
		
		ld	r12, #60h	; Farb-Register hi
		ld	r13, #00001111b	; Farb-Bänke = 0000xxxx (alle Bänke an = weiss)	
		lde	@rr12, r13
		ld	r13, #0FFh	; 8 Pixel 

		ld	p01m, #0B2h	; Ports	0-1 mode, langsames Timing für ext. Speicher
			
fdl3:		lde	@rr6, r13
		incw	rr6
		
		djnz 	r11, fdl3
		
		ld	p01m, #092h	; Ports	0-1 mode, schnelles Timing für ext. Speicher
		
		pop	var_X_lo
		pop	var_X_hi
		ret

		
		