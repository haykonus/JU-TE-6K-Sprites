;-----------------------------------------------------------------------------
; JU+TE TINY  ES4.0
; Include-Datei mit Systemfunktionen, V. Pohlers 12/2022
;------------------------------------------------------------------------------

ES40_INC				; Flag für include-Anweisungen

; Prozeduren aus ES40

; In all diesen Routinen wird vorausgesetzt, daß der Registerpointer auf %10 steht
PMON 		equ	0AF7h 		; druckt "Mon" und einen Returncode aus. Wenn ein Befehl nach erfolgreicher Ausführung "Mon" melden soll, dann ist er statt mit RET mit JP %0AF7 zu beenden.
HTA16 		equ	0C69h 		; druckt die 16 Bit aus %18/19 als 4-Ziffer-Hexzahl aus, %18/19 zerstört
HTA8 		equ	0C72h 		; druckt die 8 Bit aus %19 als 2-Ziffer-Hexzahl aus, %19 zerstört
HTA4 		equ	0C7Bh 		; druckt die niederen 4 Bit aus %19 als Hexziffer aus, %19 zerstört
PRRET 		equ	0C8Dh 		; druckt einen Return-Kode aus (%0D)
RWCONT 		equ	0C91h 		; druckt einen Return-Kode aus und wartet dann auf Tastendruck, wenn die Leertaste gedrückt wurde ist das Z-Flag gesetzt
PCAS 		equ	0C9Bh 		; druckt das Zeichen aus %15 aus, dann die 16 Bit aus %1A/1B (%18/19 zerstört) als Hexzahl und noch ein Leerzeichen 
ADRE 		equ	0CA9h 		; wandelt die 4 Ziffern ab Adresse (%1E/1F) nach %1C/1D und %lA/1B, bei Wandlungsfehler wird POP POP RET ausgeführt, sonst Rückkehr mit um fünf erhöhtem %1F
ATH4 		equ	0CB8h 		; wandelt die Ziffer von (%1E/1F) in niedere 4 Bit von %1D, %1F um eins erhöht
ATH16 		equ	0CD5h 		; wandelt 4 Ziffern ab (%1E/1F) nach %1C/1D, %12 zerstört, %1F um vier erhöht
ATH8 		equ	0CDCh 		; wandelt 2 Ziffern ab (%1E/1F) nach %1D, %12 zerstört, %1F um zwei erhöht
DAXTH16 	equ	0A52h 		; wandelt eine 1 bis 5 Ziffern lange Dezimalzahl (0 bis 65535) ab (%1E/1F) nach %14/15, %12/13 und %1C/1D zerstört, %1F um Anzahl der gewandelten Ziffern erhöht

; RP-unabhängig
KOMMAND   	equ	0812h		; Einsprung nach RESET, Returnadr. f. externe Programme
CHARIN    	equ	0815h		; CHARIN liefert in %13 nacheinander die Zeichen einer vom FSE editierten Zeile, als letztes noch %0D (returncode)
CHAROUT   	equ	0818h		; CHAROUT führt das Zeichen aus %15 auf dem Bildschirm aus und gibt es evt. noch auf den Drucker (siehe Register %55) aus.
KEY       	equ	081Bh		; KEY liefert den ASCII-Kode der momentan gedrückten Taste in %6D, wenn keine gedrückt, dann %00
WKEY      	equ	081Eh		; WKEY wartet mit Kursordarstellung auf einen Tastendruck und liefert den ASCII-Kode dann in %13
SAVE      	equ	0821h		; SAVE speichert den Speicherbereich auf Kassette, dessen Anfangsadresse in %20/21 steht mit der in %22/23 angegebenen Anzahl von Bytes ab
LOAD      	equ	0824h		; LOAD lädt ab der in %20/21 stehenden Adresse die Daten von Kassette in den Speicher und gibt in %22/23 die Anzahl der fehlerfrei geladenen Byte zurück
SCRFUN    	equ	0827h		; Spezialfunktionen für den Textbildschirm
					; Z=0 -> liefert in X (Spalte) und in Y (Zeile) die Position des Textkursors.
					; Z=1 -> setzt den Textkursor auf X (Spalte) und in Y (Zeile)
					; Z=2 -> liefert in Z den ASCII-Kode des Zeichens an Position X (Spalte) und Y (Zeile).
MONITOR   	equ	082Ah		; ruft den Maschinenmonitor MON auf
PRISTRI   	equ	082Dh		; druckt eine Zeichenkette über CHAROUT aus, die nach dem CALL-Aufruf beginnt und mit einem %00-Kode endet.
SHOWPLAYER	equ	0830h		; zeichnet Sprite X,Y-Postion, V-Video(Farbe), W-Adr. Sprite (48 Byte), Z-Adr. BG-Buffer (48 Byte)
HIDEPLAYER	equ	0833h		; löscht Sprite
RND       	equ	0836h		; liefert nach jedem Aufruf in %74/75 eine 16-Bit-Zufallszahl

; Grafik. Die Farbe wird immer in Z übergeben
DRAW 		equ	17F7h		; DRAW verbindet die Punkte (V,W) und (X,Y) durch eine Gerade der Farbe Z
PTEST		equ	17FAh		; PTEST liefert die Farbe des Punktes (X,Y) in Z
PLOT 		equ	17FDh		; PLOT setzt den Punkt (X,Y) mit der Farbe aus Z

; Systemzellen
cupos 		equ 	5Bh		; 2 Byte Position (X = 0..39,Y = 0..23)
; %56/57 	Sprungvektor für IRQ
; %58 		OSD (Zeilenlänge)   
; %67 		H-Byte Startadresse Zeichensatz
; %6C		Tastaturfunktionen

; Speicher
; %4000-5FFF 	Video-RAM-Bänke
; %6000-63FF 	Steuerregister für Videorambankauswahl
; %E000-F4FF 	Std.RAM, frei zur Nutzung
; %F500-F511 	IRQ-Sprünge
; %F600-F6FF 	Stack
; %F700-F74F 	Zeilenspeicher bei Rückkehr aus Routine CHARIN
; (%F800-FBFF 	zweiter ASCII-Textspeicher)
; (%FC00-FFBF 	ASCII-Textspeicher)
; %FFC0-FFFF 	I/O-Vektortabelle

;------------------------------------------------------------------------------
; Speicher 
;------------------------------------------------------------------------------

; Register %67		Zeichensatz (hi-Byte)
; 
; in Klammern: nach Möglichkeit keine direkten Zugriffe
; OS: vom ES4.0 in einigen Routinen genutzt
; OSD: vom ES4.0 ständig genutzt
; %0000-07FF interner ROM des U883
; %0800-1FFF Betriebssystem ES4.0 auf EPROM 2764
; %2000-3FFF frei
; %4000-5FFF Video-RAM-bänke
; %6000-63FF Steuerregister für Videorambankauswahl
; %6400-7BFF frei (für IO-Geräte, Ramdisk, ...)
; %7000-7FFF Tastaturabfrage
; %8000- RAM-Beginn bei 32 KByte Vollausbau
; %C000- RAM-Beginn bei 16 KByte
; %E000- RAM-Beginn bei 8 KByte
; bis F4FF RAM, frei zur Nutzung
; %F500-F511 IRQ-Sprünge
; %F512-F579 RAM für Druckroutine, siehe 8.
; (%F57B-F5FF Kassettenpuffer)
; %F600-F6FF Stack
; %F700-F74F Zeilenspeicher bei Rückkehr aus Routine CHARIN
; (%F750-F76F RAM für Gleitkommaroutinen)
; %F770-F77F noch frei
; (%F780-F78F Registerspeicher des MON)
; %F790-F79F noch frei
; %F7A0 Bitmaske für Textzeichen, siehe 11.
; %F7A1 Bitmaske für Kursor, siehe 11.
; (%F7A2-F7AB OSD)
; (%F7AC-F7DF evtl. später OSD)
; %F7E0-F7FF Funktionstastenprogramme
; (%F800-FBFF zweiter ASCII-Textspeicher)
; (%FC00-FFBF ASCII-Textspeicher)
; %FFC0-FFFF IO-Vektortabelle, siehe 16
; 
; %F512 Drucker-Routine
; 
; Aufzeichnungsverfahren
; Fileaufbau: 5s Vorton, Blöcke mit Pause von 40 ms
; Blocksendung: Vorimpuls (eine Phase mit 0.5 ms), %85 Bytes
; Blockaufbau: (Adresse im Kassettenpuffer als erste Zahl)
; %F57B Blocknummer %00 bis %FF, evt. wieder von vorn
; %F57C Kopie von %F57B
; %F57D Prüfsumme über Formatbyte und Datenbytes (Byte-Summe mit dazuaddierten Carrys)
; %F57E Kopie von %F57D
; %F57F Formatbyte: %FA: weniger als 128 Datenbyte. Anzahl der gültigen Datenbyte auf %F5FF
; 	%FC: 128 Datenbyte
; 	%FE: End of File Block, ohne sinnvolle Datenbytes
; %F580-F5FF Datenbytes


; Control-Codes, Steuerkodes
; C_00:		EQU	00h		; nicht belegt
C_LEFT:		EQU	01h		; Kursor links
C_RIGHT:	EQU	02h		; Kursor rechts
C_UP:		EQU	03h		; Kursor hoch
C_DOWN:		EQU	04h		; Kursor runter
C_HOME:		EQU	05h		; HOM (home)
C_SOL:		EQU	06h		; SOL (start of line)
C_DEL:		EQU	07h		; DEL (delete)
C_BS:		EQU	08h		; DBS (delete back space)
C_INS:		EQU	09h		; INS (insert)
C_LDEL:		EQU	0Ah		; LDE (line delete)
C_LINS:		EQU	0Bh		; LIN (line insert)
C_CLS:		EQU	0Ch		; CLS (clear screen)
C_ENTER:	EQU	0Dh		; RET (return)
C_ESC:		EQU	0Eh		; ESC (return)
; C_0F:		EQU	0Fh		; nicht belegt


;------------------------------------------------------------------------------

; BASIC-Variablen

var_A_hi 	equ 	20h
var_A_lo 	equ 	21h
var_B_hi 	equ 	22h
var_B_lo 	equ 	23h
var_C_hi 	equ 	24h
var_C_lo 	equ 	25h
var_D_hi 	equ 	26h
var_D_lo 	equ 	27h
var_E_hi 	equ 	28h
var_E_lo 	equ 	29h
var_F_hi 	equ 	2Ah
var_F_lo 	equ 	2Bh
var_G_hi 	equ 	2Ch
var_G_lo 	equ 	2Dh
var_H_hi 	equ 	2Eh
var_H_lo 	equ 	2Fh
var_I_hi 	equ 	30h
var_I_lo 	equ 	31h
var_J_hi 	equ 	32h
var_J_lo 	equ 	33h
var_K_hi 	equ 	34h
var_K_lo 	equ 	35h
var_L_hi 	equ 	36h
var_L_lo 	equ 	37h
var_M_hi 	equ 	38h
var_M_lo 	equ 	39h
var_N_hi 	equ 	3Ah
var_N_lo 	equ 	3Bh
var_O_hi 	equ 	3Ch
var_O_lo 	equ 	3Dh
var_P_hi 	equ 	3Eh
var_P_lo 	equ 	3Fh
var_Q_hi 	equ 	40h
var_Q_lo 	equ 	41h
var_R_hi 	equ 	42h
var_R_lo 	equ 	43h
var_S_hi 	equ 	44h
var_S_lo 	equ 	45h
var_T_hi 	equ 	46h
var_T_lo 	equ 	47h
var_U_hi 	equ 	48h
var_U_lo 	equ 	49h
var_V_hi 	equ 	4Ah
var_V_lo 	equ 	4Bh
var_W_hi 	equ 	4Ch
var_W_lo 	equ 	4Dh
var_X_hi 	equ 	4Eh
var_X_lo 	equ 	4Fh
var_Y_hi 	equ 	50h
var_Y_lo 	equ 	51h
var_Z_hi 	equ 	52h
var_Z_lo 	equ 	53h

;------------------------------------------------------------------------------
; Z8-Register

P0		EQU	00H		; Port 0
P1		EQU	01H		; Port 1
P2		EQU	02H		; Port 2
P3		EQU	03H		; Port 3
SIO		EQU	0F0H		; serielles Ein-Ausgaberegister
FLAGS		EQU	0FCH		; Flagregister
SPH		EQU	0FEH		; Stackpointer, Highteil
SPL		EQU	0FFH		; Stackpointer, Lowteil
TMR		EQU	0F1H		; Zähler/Zeitgeberbetriebsart
T0		EQU	0F4H		; Zähler/Zeitgeberregister Kanal 0
T1		EQU	0F2H		; Zähler/Zeitgeberregister Kanal 1
PRE0		EQU	0F5H		; T0-Vorteilerregister
PRE1		EQU	0F3H		; T1-Vorteilerregister
P01M		EQU	0F8H		; Tor 0, Tor 1 Betriebsart
P2M		EQU	0F6H		; Tor 2 Betriebsart
P3M		EQU	0F7H		; Tor 3 Betriebsart
IMR		EQU	0FBH		; Interrupt-Maskierungsregister
IPR		EQU	0F9H		; Interrupt-Prioritätsregister
IRQ		EQU	0FAH		; Interrupt-Anmelderegister
RP		EQU	0FDH		; Registerpointer

;------------------------------------------------------------------------------
; AS-Funktionen
hi	function x,(x>>8)&255
lo	function x, x&255


