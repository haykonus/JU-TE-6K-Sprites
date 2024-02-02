;------------------------------------------------------------------------------
; Titel: 		JuTe 6K Full-Color-Sprite-Library  (6K-FCSL)
;
; Erstellt:		10.11.2023
;------------------------------------------------------------------------------	
	
		cpu	z8601
		assume RP:0C0h		; keine Register-Optimierung !
		
		ENUM	ROM, RAM, EXE
		
;			ROM		SP-Lib / ROM Version
;					Lib-Code-Start:  3000h
;					RAM-Start:       8300h

;			RAM		SP-Lib / RAM Version
;					Lib-Code-Start:  8300h
;					RAM-Start:       Ende-Lib-Code
		
;			EXE		SP-Exe / RAM Version
;					Lib-Code-Start:  Ende-Programm-Code
;					RAM-Start:       Ende-Lib-Code

		ENUM	SHORT, LONG	
		
;			SHORT		short CLR-Adr-Table (langsamer)
;			LONG  		long  CLR-Adr-Table (schneller)

		ENUM	SMALL, BIG	
		
;			SMALL 		Optimiert für Sprites <= 3x16 (schneller)
;			BIG   		für Sprites > 3x16	
	
		ENUM	SLOW, FAST
		
;			SLOW		VRAM Timing langsam	
;			FAST		VRAM Timing schnell	

;------------------------------------------------------------------------------		
; Info's zur Registerbelegung aus Daten von V.Pohlers
;------------------------------------------------------------------------------	
		
; 66h-6Bh 	; frei ? Nicht benutzt im ASM-File es40-as.asm

save1		equ	6Ah		; Hilfs-Register	
save2		equ	6Bh		; Hilfs-Register

;save1		equ	var_U_hi	; Hilfs-Register	
;save2		equ	var_U_lo	; Hilfs-Register

;------------------------------------------------------------------------------	
; Einstellung der Parameter
;------------------------------------------------------------------------------	

;SP_VERSION	equ	ROM,RAM,EXE	; Schalter -D im Arnold-Assembler:
					; -D SP_VERSION=(0,1,2)
					
SP_SIZE		equ	SMALL		; optimiert für Sprites <= 3x16
CLR_TAB		equ	LONG		; long CLR-Adr-Table (schneller)
VRAM_TIMING	equ	FAST		; schneller Zugriff auf VRAM

;------------------------------------------------------------------------------
; Sprite-Definition
;------------------------------------------------------------------------------
					
SP_X_BYTES	equ	3		; 3 Bytes 	-> X = 16 Pixel + 8 Shift-Bits
SP_Y_LINES	equ	16		; 16 Zeilen	-> Y = 16 Zeilen
SP_COLOR_MAPS	equ	4		; 4 Farb-Bänke	-> C = 16 Farben pro Pixel

SP_XY_BYTES	equ	SP_X_BYTES*SP_Y_LINES
						
;------------------------------------------------------------------------------	
				
		if SP_VERSION == ROM	 ; SP-Lib / ROM Version	
	
		org	3000h
		include ..\ES4.0\es40_inc.asm
		
		elseif SP_VERSION == RAM ; SP-Lib / RAM Version
		
		org	8300h
		include ..\ES4.0\es40_inc.asm
		
		endif
		
;------------------------------------------------------------------------------	
; Datenstrukturen
;------------------------------------------------------------------------------

		if SP_VERSION == ROM	; SP-Lib ROM Version
RAM_START	equ	8300h	
		endif
			
VRAM		equ	4000h
VRAM_END	equ	5FFFh
VRAM_LEN	equ	VRAM_END - VRAM
VRAM_TAB_HI	equ	RAM_START	; muss xx00-Adr. sein
VRAM_TAB_LO	equ	RAM_START+100h	; muss xx00-Adr. sein

SP_BASE		equ	RAM_START+200h	; muss xx00-Adr. sein

;------------------------------------------------------------------------------

MAP		STRUCT	
red		ds	SP_XY_BYTES
green		ds	SP_XY_BYTES
blue		ds	SP_XY_BYTES
bright		ds	SP_XY_BYTES
mask		ds	SP_XY_BYTES
		if SP_SIZE == SMALL		
		align	100h
		endif
MAP		ENDSTRUCT

;------------------------------------------------------------------------------

MAPS		STRUCT	
MAP0		MAP
MAP1		MAP
MAP2		MAP
MAP3		MAP
MAP4		MAP
MAP5		MAP
MAP6		MAP
MAP7		MAP		
MAPS		ENDSTRUCT

;------------------------------------------------------------------------------

BG_BUFFER	STRUCT	
		ds	SP_XY_BYTES*SP_COLOR_MAPS
BG_BUFFER	ENDSTRUCT

;------------------------------------------------------------------------------

SET_TABLE	STRUCT
		ds	SP_XY_BYTES*2 	; 48*2   (VRAM-Adr.)
SET_TABLE	ENDSTRUCT

;------------------------------------------------------------------------------

CLR_TABLE	STRUCT
		if CLR_TAB == LONG  	; Sprite-CLR VRAM-Adr.-Table LONG  (576 Bytes)  
					; 48*4*2 = 384 (VRAM-Adr.) + 48*4 = 192 (BG)
		ds	SP_XY_BYTES*SP_COLOR_MAPS*2 + SP_XY_BYTES*SP_COLOR_MAPS
		
		else                   	; Sprite-CLR VRAM-Adr.-Table SHORT (192 Bytes)
		ds	SP_XY_BYTES*2	; 48*2   (VRAM-Adr.)
		
		endif		
CLR_TABLE	ENDSTRUCT

;------------------------------------------------------------------------------
					; max. 160 Byte (bei 3x16, LONG, SMALL)
STATUS		STRUCT			; max. 128 Byte (bei 3x16, SHORT, SMALL)
					
;stepw		dw	? 		;T
;steps		dw	?		;U
;dir		dw	? 		;V
;data		dw	? 		;W
x		dw	? 		;X
y		dw	? 		;Y
;slot		dw	? 		;Z					
STATUS		ENDSTRUCT

;------------------------------------------------------------------------------

SP		STRUCT
MAPS		MAPS			; SP_MAP 0-7, SP_MASK 0-7                                    
BG_BUFFER	BG_BUFFER           	; Hintergrund-Puffer                                  
SET_TABLE	SET_TABLE            	; Sprite-SET VRAM-Adr.-Table     
CLR_TABLE	CLR_TABLE   		; Sprite-CLR VRAM-Adr.-Table                
STATUS		STATUS			; 
		if SP_SIZE == SMALL
		align 100h	
		endif
SP		ENDSTRUCT
		
;------------------------------------------------------------------------------
; Macro für Zugriff auf Pointer im Slot N per Slot-Nummer
;
; in:  	index	 = Index für Pointer
;	var_Z_lo = Slot N 
;	
; out:  Pointer auf Daten im Slot N (regHI, regLO)
;------------------------------------------------------------------------------	

		if SP_SIZE == SMALL	
getp	MACRO	index, regHI, regLO

		ld	r0, #hi(slot_table)
		ld	r1, #lo(slot_table)	
		
		add	r1, var_Z_lo		; @rr0 = Slot
		
		lde	regHI, @rr0
		ld 	regLO, #0
		
		add	regLO, #lo(index)
		adc	regHI, #hi(index)	; @reg = Pointer in Slot N
	ENDM	
		else
getp	MACRO	index, regHI, regLO

		ld	r0, #hi(slot_table)
		ld	r1, #lo(slot_table)
		
		ld	regLO, var_Z_lo
		rl	regLO
		add	r1, regLO
		adc	r0, #0			; @rr0 = Slot 
		
		lde	regHI, @rr0		
		incw	rr0
		lde	regLO, @rr0
									
		add	regLO, #lo(index)
		adc	regHI, #hi(index)	; @reg = Pointer in Slot N
	ENDM
		endif
		

		if SP_SIZE == SMALL
		align 100h
		endif
		
;------------------------------------------------------------------------------		
; Interface 
;------------------------------------------------------------------------------

INIT_SPRITE:	jp	init_sprite0	; xx00	
SET_SPRITE:	jp	set_sprite0	; xx03	
CLR_SPRITE:	jp	clear_sprite0	; xx06		
MOVE_SPRITE:	jp	move_sprite0	; xx09	
WALK_SPRITE:	jp	walk_sprite0	; xx0C	

;------------------------------------------------------------------------------

		; Slots 0-7
		
		if SP_SIZE == SMALL	
slot_table:	db	hi(SP_BASE)
		db	hi(SP_BASE + 1*SP_LEN)
		db	hi(SP_BASE + 2*SP_LEN)
		db	hi(SP_BASE + 3*SP_LEN)
		db	hi(SP_BASE + 4*SP_LEN)
		db	hi(SP_BASE + 5*SP_LEN)
		db	hi(SP_BASE + 6*SP_LEN)
		db	hi(SP_BASE + 7*SP_LEN)	
		else	
slot_table:	dw	SP_BASE
		dw	SP_BASE + 1*SP_LEN
		dw	SP_BASE + 2*SP_LEN
		dw	SP_BASE + 3*SP_LEN
		dw	SP_BASE + 4*SP_LEN
		dw	SP_BASE + 5*SP_LEN
		dw	SP_BASE + 6*SP_LEN
		dw	SP_BASE + 7*SP_LEN
		endif
		
;------------------------------------------------------------------------------
; X/Y Postion des Sprites merken
;------------------------------------------------------------------------------		

save_xy:	getp	SP_STATUS_x, r2, r3
		ld	r4, #var_X_hi
		ldei	@rr2, @r4	; SP_STATUS_x = var_X
		ldei	@rr2, @r4
		ldei	@rr2, @r4	; SP_STATUS_y = var_Y		
		ldei	@rr2, @r4
		ret

;------------------------------------------------------------------------------
; X/Y Postion des Sprites holen
;------------------------------------------------------------------------------		

get_xy:		getp	SP_STATUS_x, r2, r3
		ld	r4, #var_X_hi
		ldei	@r4, @rr2	; var_X = SP_STATUS_x
		ldei	@r4, @rr2
		ldei	@r4, @rr2	; var_Y = SP_STATUS_y		
		ldei	@r4, @rr2
		ret		
		
;------------------------------------------------------------------------------
; Intialisiert einen Sprite und stellt ihn auf dem Bildschirm dar. Es werden
; alle benötigten Sprite-Daten (pre shifted) im JuTe 6K Format aus dem Sprite-
; Export aus AkuSprite (https://www.chibiakumas.com/akusprite) erstellt.
;
; in:
;	var_W_hi	= Pointer auf Sprite-Definition (hi) aus AkuSprite	
;	var_W_lo	= Pointer auf Sprite-Definition (lo) aus AkuSprite
;
;	var_X_hi	= X-Pos-hi  
;	var_X_lo	= X-Pos-lo
;
;	var_Y_hi	= 0
;	var_Y_lo	= Y-Pos-lo 
;
;	var_Z_lo	= Sprite-Slot
;------------------------------------------------------------------------------

init_sprite0:	push	rp
		srp	#70h
		call	save_xy
		
		call	make_vram_tab
		call 	make_sp_maps
		call	make_sp_set_table
		call	write_sprite
		call	make_sp_clr_table
		pop	rp
		ret
	
;------------------------------------------------------------------------------
; Stellt einen Sprite an einer neuen Position zum Zeitpunkt (t) dar, und löscht 
; ihn an der Postion zum Zeitpunkt (t-1). Der Hintergrund zum Zeitpunkt (t) wird
; gerettet, der Hintergrund vom Zeitpunkt (t-1) wird wieder hergestellt.
;
; Für die Zugriffe auf den VRAM stehen nur 8 ms in der Austastlücke zur Verfügung.
;
; ---+                        +----------------+
;    |                        |                |
;    |                        |                |
;    +------------------------+                +------------------
;   
;    <----------------------->|<-------------->|
;               12ms                   8ms
;
; 
; Das ist notwendig, weil:
;
;  1. Damit ein Sprite ohne Flackern dargestellt wird (für Sprites <= 3x16)
;  2. Die Störungen bei VRAM-Zugriff durch die CPU verhindert werden.
;
;------------------------------------------------------------------------------
; in:	
;	var_X_hi	= X-Pos-hi  
;	var_X_lo	= X-Pos-lo
;
;	var_Y_hi	= 0
;	var_Y_lo	= Y-Pos-lo 
;
;	var_Z_lo	= Sprite-Slot
;
; out:	Sprite an neuer Position, 
;------------------------------------------------------------------------------

move_sprite0:	push	rp
		srp	#70h    
		call	save_xy	
		call	move_sprite00
		pop	rp
		ret
		
;------------------------------------------------------------------------------		
		
move_sprite00:					; bei Sprite 3x16 und
						; SP_SIZE 	= SMALL und
						; CLR_TAB 	= LONG  und
						; VRAM_TIMING 	= FAST
						; gilt:		
						;                   |
		call	make_sp_set_table	; 1,120 ms          |
						;	      +-----+    <-- Sync.   
		call	clear_sprite		; 2,099 ms    | 
		ld	r2, #0			;             | 7,5 ms !!!
		call	write_sprite		; 5,387 ms    | 
						;             +-----+  
		call	make_sp_clr_table	; 4,690 ms          |
						;                   |
		ret				;                   |	
							
;------------------------------------------------------------------------------
; Stellt einen Sprite auf dem Bildschirm dar. Für das Löschen wird der 
; Hintergrund gerettet und die CLR-Table dazu wird erstellt. Zum Löschen 
; kann CLR_SPRITE aufgerufen werden.
;
; in:	var_X_hi	= X-Pos-hi  
;	var_X_lo	= X-Pos-lo
;
;	var_Y_hi	= 0
;	var_Y_lo	= Y-Pos-lo 
;
;	var_Z_lo	= Sprite-Slot
;
; out:	Sprite an neuer Position
;------------------------------------------------------------------------------

set_sprite0:	push	rp
		srp	#70h                    ; bei Sprite 3x16 und
		call	save_xy			; SP_SIZE 	= SMALL und
						; CLR_TAB 	= LONG  und
						; VRAM_TIMING 	= FAST
						; gilt:	
						;                   |
		call	make_sp_set_table	; 1,120 ms          |
						;		    |
		ld	r2, #0			;             +-----+    <-- Sync.   
		call	write_sprite		; 5,387 ms    | 
						;             | 9,9 ms
		call	make_sp_clr_table	; 4,690 ms    |         						
						;	      +-----+     						
		pop	rp			;		    |
		ret
		
;------------------------------------------------------------------------------
; Löscht einen Sprite an der zuvor mit SET_SPRITE, MOVE_SPRITE oder WALK_SPRITE
; gesetzten Position.
;
; in:	var_Z_lo	= Sprite-Slot 
;
; out:	Sprite gelöscht und Hintergrund (t-1) wieder hergestellt.
;------------------------------------------------------------------------------
 
clear_sprite0:
		push	rp
		srp	#70h
		call	clear_sprite
		pop	rp
		ret

;------------------------------------------------------------------------------
; Bewegt einen Sprite um W Schritte, mit der Schrittweite X in die Richtung Y.
; In V kann eine Verzögerung von V * 1ms eingestellt werden. Es sollte 0
; oder ein Vielfaches von 15-20ms eingestellt werden (z.B. 20, 40, 60, ...) um 
; synchron zur Austastlücke zu bleiben. 
;
;                                                         
; in:	var_V_hi	= Timer hi	
;	var_V_lo	= Timer lo			   Richtungen:
;
;	var_W_hi	= Anzahl Schritte hi         
;	var_W_lo	= Anzahl Schritte lo                  up(0)
;			                               uple(7)     upri(4)
;	var_X_lo	= Schrittweite               
;                                                     le(3)           ri(1)
;	var_Y_lo	= Richtung                   
;                                                      dole(6)     dori(5)
;       var_Z_lo	= Sprite-Slot                         do(2)
;                                                  
;------------------------------------------------------------------------------

		ENUM	up, ri, do, le, upri, dori, dole, uple 	

stepw		equ	var_Y_hi
dir		equ	var_Z_hi
		
walk_sprite0:
		push	rp
		srp	#70h
		
		push	var_W_hi
		push	var_W_lo
		push	var_X_hi
		push	var_X_lo
		push	var_Y_lo
					
		push	var_X_lo	; stepw
		push	var_Y_lo        ; dir	
		call	get_xy		; hole X/Y(t-1)	
		pop	dir		
		pop	stepw		

		;---------------------------------------------
				
walp:		cp	dir, #up
		jr	nz, wasp1
		
		sub	var_Y_lo, stepw	
		jr	waset
		
wasp1:		cp	dir, #do
		jr	nz, wasp2
		
		add	var_Y_lo, stepw
		jr	waset

wasp2:		cp	dir, #ri
		jr	nz, wasp3
		
		add	var_X_lo, stepw
		adc	var_X_hi, #0			
		jr	waset

wasp3:		cp	dir, #le
		jr	nz, wasp4
		
		sub	var_X_lo, stepw
		sbc	var_X_hi, #0
		jr	waset

		;---------------------------------------------

wasp4:		cp	dir, #upri
		jr	nz, wasp5

		sub	var_Y_lo, stepw
		add	var_X_lo, stepw
		adc	var_X_hi, #0	
		jr	waset

wasp5:		cp	dir, #dori
		jr	nz, wasp6

		add	var_Y_lo, stepw
		add	var_X_lo, stepw
		adc	var_X_hi, #0
		jr	waset

wasp6:		cp	dir, #dole
		jr	nz, wasp7

		add	var_Y_lo, stepw
		sub	var_X_lo, stepw
		sbc	var_X_hi, #0
		jr	waset

wasp7:		cp	dir, #uple
		jr	nz, wasp8

		sub	var_Y_lo, stepw
		sub	var_X_lo, stepw
		sbc	var_X_hi, #0
		jr	waset

		;---------------------------------------------
		
wasp8:		jr	waspend
		
waset:		call	move_sprite00
		call	timer0
		
		decw	var_W_hi	; Schritte - 1
		jp	nz, walp

		call	save_xy		; X/Y(t) merken
	
waspend:	clr	var_Z_hi
		clr	var_Y_hi
		pop	var_Y_lo
		pop	var_X_lo
		pop	var_X_hi
		pop	var_W_lo
		pop	var_W_hi
		
		pop	rp	
		ret
	
;------------------------------------------------------------------------------
; Stellt einen Sprite auf dem Bildschirm dar und rettet den Hintergrund.
;
; in:	var_X_lo	= X-Pos-lo 
;	var_Z_lo	= Sprite-Slot
;	SET_ADR_TABLE
;
; out:	Sprite an neuer Position 
;
; intern:	
;	r0		getp
;	r1		getp
;	r2		Flag: MOVE = 0, SET = 1
;	r3*		SP_COLOR_MAPS 
;	r4*		Masken-Transfer		
;	r5*		Sprite-Transfer
;	r6*		VRAM hi / temp
;	r7*		VRAM lo / temp
;	r8*		SP_MASK hi
;	r9*		SP_MASK lo
;	r10*		SP_MAP hi
;	r11*		SP_MAP lo
;	r12*		BG-Buffer hi / temp
;	r13*		BG-Buffer lo 
;	r14*		Farb-Register hi 
;	r15*		Farb-Register lo
	
;	SPH		SET_ADR_TABLE hi
;	SPL		SET_ADR_TABLE lo
;	save1		SPH merken
;	save2		SPL merken	
;
;	Laufzeit:	21550 T x 0,25µs = 5,387 ms 
;------------------------------------------------------------------------------

write_sprite:	
						; Sync. mit Austastlücke
clvtpbusw:	tm	p3, #4			; Port 3
		jr	NZ, clvtpbusw		; warten, bis not BUSY
		
		getp	SP_MAPS, r10, r11
	
		if SP_SIZE == SMALL
		
		ld	r12, var_X_lo
		and	r12, #00000111b		; 8 Maps (0-7)
		add	r10, r12		; Sprite-MapN ermitteln
		ld	r8, r10			; MASK-Pointer hi
		ld	r9, #MAP_mask		; MASK-Pointer lo
		
		else
		
		; var_X * MAPS_LEN
		ld	r12, var_X_lo
		and	r12, #00000111b		; 8 Maps (0-7)		
		cp	r12, #0
		jr	z, ws2
	ws1:	add	r11, #lo(MAP_LEN)	; Sprite-MapN ermitteln
		adc	r10, #hi(MAP_LEN)	
		djnz	r12, ws1
		
	ws2:	ld	r8, r10			
		ld	r9, r11
		add	r9, #lo(MAP_mask)	; MASK-Pointer
		adc	r8, #hi(MAP_mask)		
		
		endif
		
		getp	SP_BG_BUFFER, r12, r13
		
		ld	r3,  #SP_COLOR_MAPS	; 4 Farb-Bänke
		ld	r14, #60h		; Farb-Register hi
		ld	r15, #01111111b		; Farb-Bank 0		
		lde	@rr14, r15
		
		DI
		ld	save1, SPH 
		ld	save2, SPL		
			
		if VRAM_TIMING == SLOW	
		ld	p01m, #0B2h		; Ports	0-1 mode, langsames Timing für ext. Speicher
		endif
		
		bkloop:	
			getp	SP_SET_TABLE, r6, r7
			ld	sph, r6
			ld	spl, r7	
			
		rept	SP_XY_BYTES				
			pop	r7		; 10 VRAM lo Adresse holen
			pop	r6		; 10 VRAM hi Adresse holen
						
			lde	r5, @rr6	; 12 VRAM holen	
			lde	@rr12, r5	; 12 Hintergrund retten
			
			lde	r4, @rr8	; 12 Maske holen 
			and	r5, r4		;  6 Spritebereich aus HG ausblenden
			
			lde	r4, @rr10	; 12 Sprite holen
			or	r5, r4		;  6 Sprite und HG kombinieren
		
			lde	@rr6, r5	; 12 VRAM schreiben
			
			if SP_SIZE == SMALL						
			inc	r11		;  6 inc Sprite-Pointer 
			inc	r13		;  6 inc BG-Buffer-Pointer
			inc	r9		;  6 inc Mask-Pointer 
			else
			incw	rr10		;(10)inc Sprite-Pointer
			incw	rr12		;(10)inc BG-Buffer-Pointer
			incw	rr8		;(10)inc Mask-Pointer 			
			endif	
		endm				;-------			
						;110 T x 48 x 4 = 21120 T = 5,280 ms
						
			rr	r15		; Farb-Bänke 1-3
			lde	@rr14, r15	

			if SP_SIZE == SMALL			
			ld	r9, #MAP_mask		; MASK-Pointer lo			
			else						
			sub	r9, #lo(SP_XY_BYTES)	; MASK-Pointer
			sbc	r8, #hi(SP_XY_BYTES)			
			endif
			
			dec	r3	
		jp	nz, bkloop

		if VRAM_TIMING == SLOW	
		ld	p01m, #92h		; Ports	0-1 mode, schnelles Timing für ext. Speicher
		endif
		
		ld	SPH, save1
		ld	SPL, save2
		EI

		cp	r2, #1			; r2 = 1 -> SET-Mode
		jr	nz, setnc1
setnc2:		tm	p3, #4			; Port 3
		jr	Z, setnc2		; warten, bis BUSY (Ende Austastlücke)
		
setnc1:		ret

;------------------------------------------------------------------------------	
;
; in:	var_X_hi	= X-Pos-hi  
;	var_X_lo	= X-Pos-lo 
;
;	var_Y_hi	= 0
;	var_Y_lo	= Y-Pos-lo	
;
;	var_Z_lo	= Sprite-Slot	 
;	
; out:	SET_ADR_TABLE
;
; intern:	
;	r0		getp
;	r1		getp	
;	r2*		#hi(VRAM_TAB_HI)	
;	r3*		XBY_to_vram
;	r4*		#hi(VRAM_TAB_LO)	
;	r5*		XBY_to_vram
;	r6*		VRAM hi / temp
;	r7*		VRAM lo / temp
;	r8*		XBY_to_vram
;	r9*		SP_X_BYTES
;	r10*		SP_Y_LINES
;	r11		-
;	r12		-
;	r13		-
;	r14		-
;	r15		-

;	SPH		SET_ADR_TABLE hi
;	SPL		SET_ADR_TABLE lo
;	save1		SPH merken
;	save2		SPL merken
;
; 	Laufzeit:	4516 T x 0,25µs = 1,12 ms
;------------------------------------------------------------------------------

make_sp_set_table:

		ld	r2, #hi(VRAM_TAB_HI)	; für xy_to_vram
		ld	r4, #hi(VRAM_TAB_LO)	; für xy_to_vram

		ld	r10, #SP_Y_LINES
		
		ld	r3, var_Y_lo		
		add	r3, #SP_Y_LINES-1
		
	
		ld	r8, var_X_lo		; r8 = x / 8 (x = 0-319)
		and	r8, #11111000b	
		or	r8, var_X_hi	
		rl	r8		
		swap	r8			
		add	r8, #SP_X_BYTES-1	

		DI
		ld	save1, SPH
		ld	save2, SPL	
		getp	SP_SET_TABLE + SET_TABLE_LEN, r6, r7
		ld	sph, r6
		ld	spl, r7	
		
		mvtbaset1:	
			ld	r5, r3		; VRAM Adresse holen	
			lde	r6, @rr2	
			lde	r7, @rr4	
			add	r7, r8		
				
			ld	r9, #SP_X_BYTES		
			btlpmvtset:			
				push	r6
				push	r7
				dec	r7
			djnz	r9, btlpmvtset
	
			dec	r3	
		djnz	r10, mvtbaset1
		
		ld	SPH, save1
		ld	SPL, save2
		EI
		ret	
		
;-------------------------------------------------------------------------------
; Löscht einen Sprite auf dem Bildschirm an Position x,y(t-1) und stellt den
; mit 'set_sprite' überschriebenen Hintergrund vollständig wieder her.
;
; in:	CRL_ADR_TABLE
;
; out:	Sprite an Position x,y(t-1) gelöscht.
;	
; intern:		
;	r0		getp
;	r1		getp
;	r2		-	
;	r3*		SP_COLOR_MAPS
;	r4		-	
;	r5*		für BG-Transfer
;	r6*		VRAM hi
;	r7*		VRAM lo
;	r8		-
;	r9		-
;	r10		-
;	r11		-
;	r12*		BG-Buffer hi 
;	r13*		BG-Buffer lo 
;	r14*		Farb-Register hi 
;	r15*		Farb-Register lo
;
;	SPH		CLR_ADR_TABLE hi
;	SPL		CLR_ADR_TABLE lo
;	save1		SPH merken
;	save2		SPL merken
;
; 	Laufzeit:	9994 T x 0,25µs = 2,498 ms -> SHORT CLR-Table 
;			8398 T x 0,25µs = 2,099 ms -> LONG  CLR-Table 
;------------------------------------------------------------------------------
		
clear_sprite:	;push	rp
		;srp	#70h
						; Sync. mit Austastlücke
clvtpbus:	tm	p3, #4			; Port 3
		jr	NZ, clvtpbus		; warten, bis not BUSY
	
		getp	SP_BG_BUFFER, r12, r13

		ld	r3,  #SP_COLOR_MAPS	; 4 Farb-Bänke
		ld	r14, #60h		; Farb-Register hi		
		ld	r15, #01111111b		; Farb-Bank 0		
		lde	@rr14, r15

		DI
		ld	save1, SPH
		ld	save2, SPL
		if CLR_TAB == LONG
		getp	SP_CLR_TABLE, r6, r7
		ld	sph, r6
		ld	spl, r7	
		endif
		
		if VRAM_TIMING == SLOW	
		ld	p01m, #92h		; Ports	0-1 mode, schnelles Timing für ext. Speicher
		endif
		
		fblp:
			if CLR_TAB == SHORT
			getp	SP_CLR_TABLE, r6, r7
			ld	sph, r6
			ld	spl, r7
			endif
			
		rept	SP_XY_BYTES
			pop	r7		; 10 VRAM lo Adresse holen
			pop	r6		; 10 VRAM hi Adresse holen
			
			if CLR_TAB == LONG
			pop	r5		; 10 Hintergrund holen
			else
			lde	r5, @rr12	; 12 Hintergrund holen
			incw 	rr12		; 10 incw rr12 für BIG
			endif
			
			lde	@rr6, r5	; 12 VRAM schreiben
		endm				;---
						; 50 T x 48 x 4 = 9600 T = 2,400 ms SMALL
						;(42)T x 48 x 4 = 8064 T = 2,016 ms LONG
		
			rr	r15		; Farb-Bänke 1-3
			lde	@rr14, r15
		
			dec	r3
		jp	nz, fblp
		
		if VRAM_TIMING == SLOW	
		ld	p01m, #92h		; Ports	0-1 mode, schnelles Timing für ext. Speicher
		endif
		
		ld	SPH, save1
		ld	SPL, save2
		EI
		
		;pop	rp
		
		ret	
		
;------------------------------------------------------------------------------	
;
; in:	var_X_hi	= X-Pos-hi  
;	var_X_lo	= X-Pos-lo 
;
;	var_Y_hi	= 0
;	var_Y_lo	= Y-Pos-lo	
;
;	var_Z_lo	= Sprite-Slot	 
;	
; out:	CRL_ADR_TABLE
;	
; intern:		
;	r0		getp
;	r1		getp
;	r2*		#hi(VRAM_TAB_HI)	
;	r3*		XBY_to_vram
;	r4*		#hi(VRAM_TAB_LO)
;	r5*		XBY_to_vram
;	r6*		VRAM hi
;	r7*		VRAM lo
;	r8*		XBY_to_vram
;	r9*		SP_X_BYTES
;	r10*		SP_Y_LINES
;	r11*		SP_COLOR_MAPS
;	r12*		BG-Buffer hi 
;	r13*		BG-Buffer lo 
;	r14		-
;	r15		-

;	save1		SPH merken
;	save2		SPL merken
;	SPH		CLR_ADR_TABLE hi
;	SPL		CLR_ADR_TABLE lo
;
; 	Laufzeit:	 3184 T x 0,25µs = 0,796 ms -> SHORT CLR-Table 
;			18762 T x 0,25µs = 4,690 ms -> LONG  CLR-Table 
;------------------------------------------------------------------------------

make_sp_clr_table:

		ld	r2, #hi(VRAM_TAB_HI)	; für xy_to_vram
		ld	r4, #hi(VRAM_TAB_LO)	; für xy_to_vram
		
		if CLR_TAB == LONG
		getp	SP_BG_BUFFER + BG_BUFFER_LEN - 1, r12, r13		
		ld	r11,  #SP_COLOR_MAPS	; 4 Farb-Bänke			
		endif
		
		ld	r8, var_X_lo		; r8 = x / 8 (x = 0-319)
		and	r8, #11111000b	
		or	r8, var_X_hi	
		rl	r8		
		swap	r8			
		add	r8, #SP_X_BYTES-1	

		DI
		ld	save1, SPH
		ld	save2, SPL	
		getp	SP_CLR_TABLE + CLR_TABLE_LEN, r6, r7
		ld	sph, r6
		ld	spl, r7	
		
		fblpmvt2:
			ld	r10, #SP_Y_LINES
			
			ld	r3, var_Y_lo		
			add	r3, #SP_Y_LINES-1
			
			mvtba12:	
				ld	r5, r3		; VRAM-Adresse holen	
				lde	r6, @rr2	
				lde	r7, @rr4	
				add	r7, r8	
				
				ld	r9, #SP_X_BYTES					
				btlpmvt2:
					if CLR_TAB == LONG
					lde	r5, @rr12
					decw 	rr12
					push	r5	; Hintergrund speichern
					endif
					
					push	r6	; VRAM-Adresse speichern
					push	r7
					dec	r7
				djnz	r9, btlpmvt2
				
				dec	r3	
			djnz	r10, mvtba12
			
		if CLR_TAB == LONG
		djnz	r11, fblpmvt2
		endif
		
		ld	SPH, save1
		ld	SPL, save2
		EI
		ret		

		
;------------------------------------------------------------------------------
; Erstellt alle 8 Sprite-Maps eines Sprites
;
; in:	SP_DATA = Pointer auf Sprite-Definition (aus AcuSprite)
;	SP_MAP  = Pointer auf Sprite-Map0
;	
; out:	SP_MAP  => Sprite-Map0-7 für jede Bit-Position 
;		
;------------------------------------------------------------------------------ 

make_sp_maps:
		call	make_sprite_map			; Erzeuge Sprite-Map0 aus Sprite-Editor-Daten
		call	make_sprite_mask		
		call	copy_sprite_maps		; Kopiere Sprite-Map0 zu Sprite-Map1-7
		
		ld	r4, #1				; Zähler für 8 Bit-Positionen in X-Richtung (Anzahl Verschiebungen)

		getp	SP_MAPS, r14, r15
		add	r15, #lo(MAP_LEN)
		adc	r14, #hi(MAP_LEN)
		
		mstt1:	
			ld	r0, r14
			ld	r1, r15
			
			push 	r4
			call	move_sprite_map		; Verschiebe Sprite-Map @rr0 um r4 Positionen nach rechts
			pop	r4
			
			add	r15, #lo(MAP_LEN)
			adc	r14, #hi(MAP_LEN)	
			inc	r4
			cp	r4, #8			; 8 Sprite-Maps, für jede Bit-Position eines VRAM-Bytes
		jr	nz, mstt1
		
		ret	
	
;------------------------------------------------------------------------------
; Erstellt die interne Sprite-Daten-Struktur (Sprite-Map)
;
; in:	var_W   = Pointer auf Sprite-Definition (aus AcuSprite)
;	SP_MAP  = Pointer auf Sprite-Map0
	
; out:	SP_MAP  => Sprite-Map0 für Bit-Position-0	
;------------------------------------------------------------------------------

make_sprite_map:
		ld	r8,  var_W_hi 		; SP_DATA aus AkuSprite
		ld	r9,  var_W_lo

		getp	SP_MAPS, r10, r11	; Pointer auf SP_MAP holen

		ld	r12, #SP_X_BYTES	; 3 Bytes in Richtung	
		ld	r0,  #SP_Y_LINES	; 16 Zeilen
		ld	r2,  #SP_COLOR_MAPS 	; 4 Farbbänke
		ld	r1,  #8			; 8 Bits vom SP_MAP-Byte
		
		mst5:	ld	r6, #10000000b	; Maske Bit-Set von SP_MAP		
			mst6:			
				mst4:	ld	r5, #00000001b	; Maske für Bit-Test von SP_DATA 0000RGBH

					cp	r12, #1		; letztes Byte ist immer Maske 
					jr	nz, mst7
					ld	r4, #0F0h	; set SP_DATA = Maske	
					jr	mst1
				mst7:	lde	r4, @rr8	; lade SP_DATA
					
					mst1:	lde	r3, @rr10	; lade SP_MAP 					
						tm	r4, #0F0h	; wenn Maske, dann lösche SP_MAP-Bit
						jr	nz, mst2
	
						tm	r4, r5		; Test SP_DATA-Bit
						jr	z, mst2	
						
						or	r3, r6		; wenn SP_DATA-Bit 1, setze SP_MAP-Bit			
						jr	mst3
						
					mst2:	ld	r7, r6		; wenn SP_DATA-Bit 0, lösche SP_MAP-Bit	
						com	r7
						and	r3, r7		 
				
					mst3:	lde	@rr10, r3	; schreibe SP_MAP
				
						add	r11, #lo(SP_XY_BYTES) ; 16 * 3 = 48
						adc	r10, #hi(SP_XY_BYTES)
												
						rl	r5		; next SP_DATA Bit
					
					djnz	r2, mst1	; 4 Farbbänke durchlaufen
					ld	r2, #SP_COLOR_MAPS
					
					sub	r11, #lo(SP_XY_BYTES*SP_COLOR_MAPS) ;16 * 3 * 4 = 192 
					sbc	r10, #hi(SP_XY_BYTES*SP_COLOR_MAPS)
					
					cp	r12, #1		; letztes Byte ist immer Maske
					jr	z, mst8						
					incw	rr8		; next SP_DATA-Byte	
				mst8:	rr	r6		; next SP_MAP-Bit
				
				djnz	r1, mst4	; 8 x SP_MAP-Byte durchlaufen
				ld	r1, #8
				incw	rr10		; inc SP_MAP
				
			djnz	r12, mst6	; 3 Bytes in X-Richtung
			ld	r12, #SP_X_BYTES
						
		djnz	r0, mst6	; 16 Zeilen
			
		ret

;------------------------------------------------------------------------------
; Erstellt die Sprite-Mask hinter Sprite-Map0
;
; in:	var_W   = Pointer auf Sprite-Definition (SP_DATA aus AcuSprite)
;	SP_MAP  = Pointer auf Sprite-Mask0
	
; out:	SP_MAP  => Sprite-Mask0 für Bit-Position-0	
;------------------------------------------------------------------------------

make_sprite_mask:
		ld	r8,  var_W_hi		; SP_DATA aus AkuSprite
		ld	r9,  var_W_lo
		
		getp	SP_MAPS + MAP_mask, r10, r11			; Pointer auf Maske holen
		
		ld	r12, #SP_X_BYTES	; 3 Bytes in Richtung	
		ld	r0,  #SP_Y_LINES	; 16 Zeilen
		ld	r1,  #8			; 8 Bits vom SP_MASK-Byte
		
		mstm5:	ld	r6, #10000000b	; Maske Bit-Set von SP_MASK		
			mstm6:			
				mstm7:	cp	r12, #1		; letztes Byte ist immer Maske 
					jr	nz, mstm4
					ld	r4, #0F0h	; set SP_DATA = Maske	
					jr	mstm1					
				mstm4:	lde	r4, @rr8	; lade SP_DATA			
				
				mstm1:	lde	r3, @rr10	; lade SP_MASK 
					tm	r4, #0F0h	; Test SP_DATA, ob Maske oder Pixel
					jr	z, mstm2
					
					or	r3, r6		; wenn Maske, setze SP_MASK-Bit			
					jr	mstm3
					
				mstm2:	ld	r7, r6		; wenn Pixel, lösche SP_MASK-Bit
					com	r7
					and	r3, r7			
				
				mstm3:	lde	@rr10, r3	; schreibe SP_MASK
					
					cp	r12, #1		; letztes Byte ist immer Maske
					jr	z, mstm8								
					incw	rr8		; next SP_DATA-Byte			
				mstm8:	rr	r6		; next SP_MASK-Bit
				
				djnz	r1, mstm7	; 8 x SP_MASK-Byte durchlaufen
				ld	r1, #8
				incw	rr10		; inc SP_MASK
				
			djnz	r12, mstm6	; 3 Bytes in X-Richtung
			ld	r12, #SP_X_BYTES
			
		djnz	r0, mstm6	; 16 Zeilen
			
		ret

;------------------------------------------------------------------------------
; Kopiert Sprite-Map0/Mask0 zu Sprite-Map1-7/Mask1-7
;
; in:	SP_MAP  = Pointer auf Sprite-Map0
;		
; out:	Sprite-Map1-7/Mask1-7 für Bit-Position-0		
;------------------------------------------------------------------------------

copy_sprite_maps:

		ld	r14, #1			; Zähler für 8 Bit-Positionen in X-Richtung
		
		getp	SP_MAPS, r10, r11
		ld	r2, r10
		ld	r3, r11
		add	r3, #lo(MAP_LEN)
		adc	r2, #hi(MAP_LEN)
		
		cs2:	getp	SP_MAPS, r10, r11

			ld	r6, #hi(MAP_LEN)	
			ld	r7, #lo(MAP_LEN)	
			
			cs1:	
				lde	r15, @rr10
				lde	@rr2, r15
				incw	rr10
				incw	rr2
		
				decw	rr6
			jr	nz, cs1
		
		inc	r14
		cp	r14, #8			; 8 Sprite-Maps für jede Bit-Position eines VRAM-Bytes
		jr	nz, cs2

		ret
	
;------------------------------------------------------------------------------
; Verschiebt eine komplette SpriteMap/Mask n-mal nach rechts
;
; in:	rr0  	= Pointer auf Sprite-Map/Mask 
;	r4	= n
;	
; out:	rr0  	=> Sprite-Map/Mask für Bit-Position n		
;------------------------------------------------------------------------------				

move_sprite_map:

		ld	r8, r4	; n Moves merken
		ld	r7, #SP_X_BYTES	
		ld	r5, #SP_COLOR_MAPS+1			; 4 MAPS + 1 MASK
		ld	r6, #SP_Y_LINES			
				
		ms1:
			ms2:
				add	r1, #lo(SP_X_BYTES-1)	; ans letzte Byte der Zeile springen
				adc	r0, #hi(SP_X_BYTES-1)
				
				lde	r13, @rr0
				
				sub	r1, #lo(SP_X_BYTES-1)
				sbc	r0, #hi(SP_X_BYTES-1)
				
				tm	r13, #00000001b		; Bit 0 testen
				jr	nz, ms5
				rcf
				jr	ms4	
			ms5:	scf
			ms4:
				ms6:				
					ms7:	lde	r13, @rr0
						rrc	r13
						lde	@rr0, r13
						incw	rr0
					djnz	r7, ms7
					ld	r7, #SP_X_BYTES	; 3 Bytes / Zeile			
						
					push	FLAGS		; CF für Bit-Moves retten	
					sub	r1, #lo(SP_X_BYTES)
					sbc	r0, #hi(SP_X_BYTES)
					pop	FLAGS	
					
				djnz	r4, ms6		; n Moves
				ld	r4, r8		; n Moves zurück

				add	r1, #lo(SP_X_BYTES)
				adc	r0, #hi(SP_X_BYTES)
			
			djnz	r5, ms2	; 
			ld	r5, #SP_COLOR_MAPS+1	; 4 MAPS + 1 MASK	
			
		djnz	r6, ms1	; 16 Zeilen
		
		ret

;------------------------------------------------------------------------------
; Erstellt die Lookup-Tabelle für die Konvertierung der X,Y Koordinaten in 
; VRAM-Adressen.
; 
; in:	---
;
; out:	VRAM_TAB_LO/HI im RAM 	

; int:	r0-r4	
;------------------------------------------------------------------------------			

make_vram_tab:	; Low-Bytes erzeugen

		ld	r0, #hi(VRAM_TAB_LO)
		ld	r1, #0
		
		ld	r3, #64		; 64 x 3 Zeilen = 192 Zeilen

		ld	r4, #0
		lde	@rr0, r4
		incw	rr0

make_vt1:	add	r4,#40
		lde	@rr0, r4
		incw	rr0

		add	r4,#40
		lde	@rr0, r4
		incw	rr0
				
		add	r4,#48
		lde	@rr0, r4
		incw	rr0
		
		djnz	r3, make_vt1
		
		; 3 aus 8 Dekoder erzeugen
		
		decw	rr0
		ld	r3, #8
		ld	r4, 10000000b
make_vt3:	lde	@rr0, r4
		rr	r4
		incw	rr0
		djnz	r3, make_vt3
		
		; High-Bytes erzeugen

		ld	r0, #hi(VRAM_TAB_HI)
		ld	r1, #0
		
		ld	r2, #6
		ld	r3, #32		; 32 x 6 Zeilen = 192 Zeilen

		ld	r4, #hi(VRAM)
		
make_vt2:	lde	@rr0, r4
		incw	rr0
		djnz	r2, make_vt2	; 6 x 40h, 41h, 42h, ...
		ld	r2, #6
		inc	r4
		djnz	r3, make_vt2	; 32 Blöcke

		ret	
	
;------------------------------------------------------------------------------	
; Löscht den Bildschirm sehr schnell.
;
; in: 	var_Z_lo = Farbe (low-aktiv)	|R|G|B|V|x|x|x|x|
;	var_Z_hi = Pixel (high-aktiv)	|x|x|x|x|x|x|x|x|
;
; int:	r0-r9
;------------------------------------------------------------------------------	
cls:		ld	r6, var_Z_hi
		ld	r3, var_Z_lo
		
		if VRAM_TIMING == SLOW	
		ld	p01m, #0B2h		; Ports	0-1 mode, langsames Timing für ext. Speicher
		endif

		ld	r0, #hi(VRAM)		; VRAM
		ld	r1, #lo(VRAM)	
		
		ld	r8, #hi(VRAM_LEN)	; Zähler
		ld	r9, #lo(VRAM_LEN)

		ld	r2, #60h		; Farb-Register hi
		ld	r4, r2
		
		ld	r5, #00h		; Farb-Bänke = 0000xxxx (alle Bänke an)
						
		
cls_1:		lde	@rr4, r5		; Farb-Bänke = 0000xxxx (alle Bänke an)
		lde	@rr0, r5		; Pixel      = 00000000 -> Bank 1-4
		
		lde	@rr2, r3		; Farb-Bänke = RGBVxxxx 		
		lde	@rr0, r6		; Pixel      = xxxxxxxx	
		
		incw	rr0			; Nächste RAM-Pos.
		decw	rr8			; Zähler -1
		jr	nz, cls_1
		
		if VRAM_TIMING == SLOW	
		ld	p01m, #92h		; Ports	0-1 mode, schnelles Timing für ext. Speicher
		endif
		
		ret		

;------------------------------------------------------------------------------	
; Timer
;
; in: 	var_V	= N 
;
; out:	wartet N * 1 ms
;------------------------------------------------------------------------------	
		
timer0:		cp	var_V_lo, #0
		jr	nz, tm0
		cp	var_V_hi, #0
		jr	z, tmend
		
tm0:		push	r12
		push	r13
		push	r0
		
		ld	r12, var_V_hi
		ld	r13, var_V_lo
			 		
tm2:		ld	r0, #0dfh	; 1 ms
		
tm1:		dec	r0
		jr	nz, tm1
		
		decw	rr12
		jr	nz, tm2

		pop	r0
		pop	r13
		pop	r12
tmend:		ret

;------------------------------------------------------------------------------

		if SP_VERSION != ROM		; RAM oder EXE Version	
		
		align 100h			; VRAM-Tab muss XX00-Adr. sein
RAM_START	equ	$

		endif		
		

;==============================================================================
;		
; Betrachtungen zum Speicherbedarf der Sprite-Routinen (für Sprites 3x16)
;
;==============================================================================
; SHORT
;==============================================================================
;------------------------------------------------------------------------------
; Variante 1:
;------------------------------------------------------------------------------
; 0000	192	SP_MAP 0	
; 00C0	 48	SP_MASK 0		
; 00F0   16	-		Verlust: 128 = 8 x 16
;------------------------
;       256

; 0100 ... 07FF SP_MAP/SP_MASK 1-7

; 0800	192	BG_BUFFER
; 08C0	 96	SET_TABLE		
; 0920	 96	CLR_TABLE 	
; 0980  128	-		Verlust: 128
;------------------------
;       512
  
; 0A00 ...

; Summe:   -> 2048 + 512 = 2560	
; Verlust: ->  128 + 128 =  256


;------------------------------------------------------------------------------
; Variante 2:
;------------------------------------------------------------------------------
; 0000	192	SP_MAP 0	
; 00C0	 48	SP_MASK 0		
; 00F0   16	-		Verlust: 128 = 8 x 16
;------------------------
;       256

; 0100 ... 07FF SP_MAP/SP_MASK 1-7

; 0800	192	BG_BUFFER
; 08C0	 64	-		Verlust: 64
;------------------------
;       256

; 0900 ...

; XXXX 	 96	SET_TABLE
; XXXX	 96	CLR_TABLE 	
;------------------------
;       192

; Summe:   -> 2048 + 256 + 192 = 2496   
; Verlust: ->  128 +  64       =  192


;==============================================================================
; LONG (inkl. Hintergrund in VRAM-CLR-Table)
;==============================================================================
;------------------------------------------------------------------------------
; Variante 1:
;------------------------------------------------------------------------------
; 0000	192	SP_MAP 0	
; 00C0	 48	SP_MASK 0		
; 00F0   16	-		Verlust: 128 = 8 x 16
;------------------------
;       256

; 0100 ... 07FF SP_MAP/SP_MASK 1-7

; 0800	192	BG_BUFFER
; 08C0	 96	SET_TABLE		
; 0920	576	CLR_TABLE 	
; 0B60  160	-		Verlust: 160
;------------------------
;      1024       
; 
; 0C00 ...
;
; Summe:   -> 2048 + 1024 = 3072 
; Verlust: ->  128 +  160 =  288


;------------------------------------------------------------------------------
; Variante 2:
;------------------------------------------------------------------------------
; 0000	192	SP_MAP 0	
; 00C0	 48	SP_MASK 0		
; 00F0   16	-		Verlust: 128 = 8 x 16
;------------------------
;       256

; 0100 ... 07FF SP_MAP/SP_MASK 1-7

; 0800 ...

; XXXX 	192	BG_BUFFER	incw !!!
; XXXX 	 96	SET_TABLE
; XXXX	576	CLR_TABLE
;------------------------
;       864	


; Summe:   -> 2048 + 864 = 2912 
; Verlust: ->  128 +   0 =  128

		
