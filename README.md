# JU-TE-6K-Sprites
[Demo Video](https://nextcloud-ext.peppermint.de/s/AZwtTL8gKgPew44)

![Testbild](/Bilder/Sprite-Demo-A2.png)

Die hier beschriebene Sprite-Bibliothek für den JuTe-6K-Computer (ES4.0) (s. [Quellen](https://github.com/haykonus/JU-TE-6K-Sprites/blob/main/README.md#quellen)) stellt Funktionen für Software-Sprites (Shapes) mit 16x16 Pixeln und 16 Farben pro Pixel zur Verfügung. Sie ist vollständig in Zilog Z8-Assembler realisiert. Zum Assemblieren wurde der [Arnold-Assembler](http://john.ccac.rwth-aachen.de:8000/as/) unter Windows 11 verwendet.
  
## Vorausetzungen

- JuTe 6K (JuTe-2K/4K + Grafikerweiterung oder JuTe-6K-Compact)
- min. 32KB RAM

Der Video-RAM sollte möglichst schnell sein. Die Binaries der Sprite-Bibliothek (s. [FCSL](https://github.com/haykonus/JU-TE-6K-Sprites/tree/main/FCSL)) sind für schnellen Zugriff auf den Video-RAM erstellt worden (External Memory Timing = normal). Das Timing kann im Quellcode mit `VRAM_TIMING = SLOW|FAST` angepasst werden.

Der Code ist speziell auf die Hardware des JuTe-6K abgestimmt. Die Zugriffe der Host-CPU auf den 32K Video-RAM (4 x 8K Farb-Bänke: Rot, Grün, Blau, Hell) für eine Sprite-Bewegung, werden in ca. 7,5 ms in der Austastlücke (8 ms) des Videosignals durchgeführt. Das ist notwendig, damit die Sprites synchron zum Bildaufbau dargestellt werden. Damit ergibt sich eine flüssige Bewegung und es gibt zusätzlich keine Störungen im Bild durch konkurrierende Zugriffe der Host- und Video-CPU auf den Video-RAM.

Eine Sprite-Bewegung besteht aus:
- Hintergund zum Zeitpunkt (t-1) wieder herstellen
- Hintergrund zum Zeitpunkt (t) retten
- Hintergrund zum Zeitpunkt (t) mit Sprite-Mask kombinieren und Sprite an neuer Position schreiben

Im [JTCEMU](http://www.jens-mueller.org/jtcemu/index.html) laufen die Programme natürlich auch, aber die getrennte Architektur zwischen Host- und Video-CPU ist im [JTCEMU](http://www.jens-mueller.org/jtcemu/index.html) nicht abgebildet. Deshalb flackern die Sprites bei Bewegungen auf dem Bildschirm. 
  
## Demos
### Assembler

- [FCSL-Demo_8000H.bin](https://github.com/haykonus/JU-TE-6K-Sprites/blob/main/Demos/FCSL-Demo_8000H.bin) auf Adresse 8000H laden
- im Monitor mit `J8000` starten 

### TINY-MP-Basic
#### Ohne Basic-Erweiterung
Ein Beispiel, auch mit "tanzenden Smiley's", aber ohne Hintergrundbild und mit weniger Animationen, als in der Assembler-Version.
- [FCSL_8300H.bin](https://github.com/haykonus/JU-TE-6K-Sprites/blob/main/FCSL/FCSL_8300H.bin) auf Adresse 8300H laden
- [FCSL-Demo_8300H.bas](https://github.com/haykonus/JU-TE-6K-Sprites/blob/main/Demos/FCSL-Demo_8300H.bas) laden (auf E000H) und starten

#### Mit Basic-Erweiterung
Dieses Beispiel entspricht exakt der Assembler-Version, das Steuer-Programm ist jedoch vollständig in TINY-MP-Basic geschrieben. Die [Basic-Erweiterung](https://hc-ddr.hucki.net/wiki/doku.php/tiny/software/baserw40) (von V. Pohlers) wird ebenfalls genutzt. Die zusätzlichen Befehle "RESTORE und "READ" sind sehr nützlich für das Lesen der Steuerdaten der Animationen. Die Sprite-Definitionen werden weiterhin mit der Pseudo-Anweisung "BREM" im [JTCEMU](http://www.jens-mueller.org/jtcemu/index.html)-Format abgelegt, die seit der [JTCEMU](http://www.jens-mueller.org/jtcemu/index.html)-Version 2.1 zur Verfügung steht.

- [FCSL+baserw40_8000H.bin](https://github.com/haykonus/JU-TE-6K-Sprites/blob/main/FCSL/FCSL+baserw40_8000H.bin) auf Adresse 8000H laden
- [FCSL+baserw40-Demo_8000H.bas](https://github.com/haykonus/JU-TE-6K-Sprites/blob/main/Demos/FCSL+baserw40-Demo_8000H.bas) laden (auf E000H) und starten

<br>

## Schnellstart

- [FCSL_8300H.bin](https://github.com/haykonus/JU-TE-6K-Sprites/blob/main/FCSL/FCSL_8300H.bin) auf Adresse 8300H laden.
- Das folgende TINY-MP-Basic-Programm im [JTCEMU](http://www.jens-mueller.org/jtcemu/index.html)-Format ausprobieren:

```
2 BREM 255,255,255,255,255,0,0,0,0,0,0,255,255,255,255,255
BREM255,255,255,0,0,11,11,11,11,11,11,0,0,255,255,255
BREM 255,255,0,11,11,11,11,11,11,11,11,11,11,0,255,255
BREM 255,0,11,11,11,11,0,0,11,0,0,11,11,11,0,255
BREM 255,0,11,11,11,0,11,11,0,11,11,0,11,11,0,255
BREM 0,11,11,11,11,0,11,0,0,11,0,0,11,11,11,0
BREM 0,11,11,11,11,0,11,0,0,11,0,0,11,11,11,0
BREM 0,11,11,11,11,11,0,0,11,0,0,11,11,11,11,0
BREM 0,11,11,11,11,11,11,11,11,11,11,11,11,11,11,0
BREM 0,11,11,11,11,11,11,11,11,11,11,11,11,11,11,0
BREM 0,11,11,11,11,0,11,11,11,11,11,0,11,11,11,0
BREM 255,0,11,11,11,11,0,0,0,0,0,11,11,11,0,255
BREM 255,0,11,11,11,11,11,11,9,9,9,11,11,11,0,255
BREM 255,255,0,11,11,11,11,11,11,9,11,11,11,0,255,255
BREM 255,255,255,0,0,11,11,11,11,11,11,0,0,255,255,255
BREM 255,255,255,255,255,0,0,0,0,0,0,255,255,255,255,255

10 PROC SETEB[%F7A0,13]; PROC PTC[12];

20 PRINT "INIT Sprite"
25 LET W=%E003;	REM Sprite Daten
30 LET X=72;	REM X-Koordinate 
40 LET Y=89; 	REM Y-Koordinate
50 LET Z=0; 	REM Slot
60 CALL %8300; 	REM INIT_SPRITE 

80 WAIT 2000

100 PRINT "MOVE Sprite"
120 LET X=150; 	REM X-Koordinate
130 LET Z=0; 	REM Slot
140 CALL %8309;	REM MOVE_SPRITE 

150 WAIT 2000

200 PRINT "WALK Sprite"
205 LET V=0;    REM Timer
210 LET W=30;	REM Schritte
220 LET X=1;	REM Schrittweite 
230 LET Y=4; 	REM Richtung (UP_RIGHT)
240 LET Z=0; 	REM Slot
250 CALL %830C; REM WALK_SPRITE 

255 PRINT "WALK Sprite"
260 LET Y=5; 	REM Richtung (DOWN_RIGHT)
270 CALL %830C; REM WALK_SPRITE

275 PRINT "WALK Sprite" 
280 LET Y=6; 	REM Richtung (DOWN_LEFT)
290 CALL %830C; REM WALK_SPRITE 

295 PRINT "WALK Sprite"
300 LET Y=7; 	REM Richtung (UP_LEFT)
310 CALL %830C; REM WALK_SPRITE 

330 WAIT 2000

400 PRINT "CLR  Sprite"
405 LET Z=0
410 CALL %8306; REM CLR_SPRITE 
```
## Full Color Sprite Library (FCSL)

Es können max. 8 Sprites definiert werden. Die Speicherwaltung erfolgt automatisch. Es muss lediglich in der Variablen Z die Nummer (Slot) des Sprites zur Adressierung in allen Funktionen angegeben werden. Ein Sprite belegt 3 KByte RAM, da alle 8 möglichen Bit-Positionen eines Sprites für alle 4 Farb-Bänke mit INIT_SPRITE vorher berechnet und im Slot gespeichert werden. Der Hintergrund-Puffer sowie die SET- und CLR-Tabellen benötigen ebenfalls Platz.

```
INIT_SPRITE	-> Intialisiert Sprite in Slot N(t) und stellt ihn dar.
SET_SPRITE	-> Stellt Sprite in Slot N(t) dar.
CLR_SPRITE	-> Löscht Sprite in Slot N(t-1).
MOVE_SPRITE	-> Stellt Sprite in Slot N(t) dar + CLR_SPRITE in N(t-1)
WALK_SPRITE	-> Bewegt Sprite um W Schritte, mit der Schrittweite X 
                   in die Richtung Y mit der Verzögerung V * 1ms.
```
### Sprungverteiler
Der Sprungverteiler liegt jeweils am Anfang der Bibliothek (s. [FCSL](https://github.com/haykonus/JU-TE-6K-Sprites/tree/main/FCSL)):

```
                RAM-Version 1)  ROM-Version
Funktion 	FCSL_8300H.bin	FCSL_3000H.bin 
-----------------------------------------------
INIT_SPRITE	8300H    	3000H 
SET_SPRITE	8303H    	3003H 
CLR_SPRITE	8306H		3006H 
MOVE_SPRITE	8309H		3009H 
WALK_SPRITE	830CH		300CH

1) Die RAM-Version liegt auf 8300H, damit die Basic-Erweiterung von Volker Pohlers noch auf 8000H geladen werden kann.
```
s. [Basic-Erweiterung](https://hc-ddr.hucki.net/wiki/doku.php/tiny/software/baserw40)

<br>

### Speicherbelegung

```
Version		Code		RAM-Nutzung	
----------------------------------------------------		
FCSL_8300H.bin	8300H-8DFFH	8E00H + 512 + N*3072 
FCSL_3000H.bin	3000H-3AFFH	8300H + 512 + N*3072

N = Anzahl der benutzten Sprites (1-8)
```

### INIT_SPRITE

```
Intialisiert einen Sprite und stellt ihn auf dem Bildschirm dar. Es werden
alle benötigten Sprite-Daten (pre shifted) im JuTe 6K Format aus der
Sprite-Definition erstellt.
 
Parameter:

W = Pointer auf Sprite-Definition aus Akusprite
X = x-Koordinate (oben links) (0-303)
Y = y-Koordinate (oben links) (0-175)	
Z = Slot (0-7)
```

### CLR_SPRITE
```
Löscht einen Sprite an der zuvor mit SET_SPRITE, MOVE_SPRITE oder WALK_SPRITE
gesetzten Position.

Parameter:

Z = Slot (0-7)
```

### SET_SPRITE
```
Stellt einen Sprite auf dem Bildschirm dar. Für das Löschen wird der 
Hintergrund gerettet und die CLR-Table dazu wird erstellt. Zum Löschen 
kann CLR_SPRITE aufgerufen werden.

Parameter:

X = x-Koordinate (oben links) (0-303)
Y = y-Koordinate (oben links) (0-175)	
Z = Slot (0-7)
```

### MOVE_SPRITE
```
Stellt einen Sprite an einer neuen Position zum Zeitpunkt (t) dar und löscht 
ihn an der Postion zum Zeitpunkt (t-1). Der Hintergrund zum Zeitpunkt (t) wird
gerettet, der Hintergrund vom Zeitpunkt (t-1) wird wieder hergestellt.

Parameter:

X = x-Koordinate (oben links) (0-303)
Y = y-Koordinate (oben links) (0-175)	
Z = Slot (0-7)
```

### WALK_SPRITE
```
Bewegt einen Sprite um W Schritte, mit der Schrittweite X in die Richtung Y.
In V kann eine Verzögerung von V * 1ms eingestellt werden. Es sollte 0
oder ein Vielfaches von 15-20ms eingestellt werden (z.B. 20, 40, 60, ...) um 
synchron zur Austastlücke zu bleiben.

Parameter:                                 Richtungen:

V = Verzögerung um V * 1ms             	       UP(0)
W = Anzahl der Schritte (0-303)        (7)UPLE      UPRI(4)
X = Schrittweite (0-255)              (3)LE            RI(1)
Y = Richtung (0-7)                     (6)DOLE      DORI(5)
Z = Slot (0-7)                         	       DO(2)
                                               
```

## Sprites 
Sprites werden in einer Matix von 16 x 16 Bytes definiert, z.B.:

```
63,63,63,63,63,0,0,0,0,0,0,63,63,63,63,63
63,63,63,0,0,11,11,11,11,11,11,0,0,63,63,63
63,63,0,11,11,11,11,11,11,11,11,11,11,0,63,63
63,0,11,11,11,11,0,0,11,0,0,11,11,11,0,63
63,0,11,11,11,0,11,11,0,11,11,0,11,11,0,63
0,11,11,11,11,0,11,0,0,11,0,0,11,11,11,0
0,11,11,11,11,0,11,0,0,11,0,0,11,11,11,0
0,11,11,11,11,11,0,0,11,0,0,11,11,11,11,0
0,11,11,11,11,11,11,11,11,11,11,11,11,11,11,0
0,11,11,11,11,11,11,11,11,11,11,11,11,11,11,0
0,11,11,11,11,0,11,11,11,11,11,0,11,11,11,0
63,0,11,11,11,11,0,0,0,0,0,11,11,11,0,63
63,0,11,11,11,11,11,11,9,9,9,11,11,11,0,63
63,63,0,11,11,11,11,11,11,9,11,11,11,0,63,63
63,63,63,0,0,11,11,11,11,11,11,0,0,63,63,63
63,63,63,63,63,0,0,0,0,0,0,63,63,63,63,63
```

Das Ergebnis ist:

</br>

![Smiley](/Bilder/Smiley0-50.png)

</br>

> [!NOTE]
> Die folgende Beschreibung der Kodierung eines Pixels wird intern in der FCSL verwendet. Sie entspricht nicht der Abbildung in der Hardware des "JuTe 6K".

</br>

Jedes Byte enthält die Farb-Codierung oder die Maske eines Pixels des Sprites:

```
           +-------------------------------+
Bit:       | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 | 
           |---|---|---|---|---|---|---|---|
Funktion:  | M | M | M | M | R | G | B | H |
           +-------------------------------+

M = Maske
R = Rot, R = Grün, B = Blau, H = Hell
```
</br>
</br>

**Beispiel**: Pixel = BLAU
```
           +-------------------------------+
Bit:       | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 | 
           |---|---|---|---|---|---|---|---|
Funktion:  | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 |
           +-------------------------------+

Die Farben sind definiert durch die Werte: 0-15
```
</br>
</br>

**Beispiel**: Pixel = MASKE
```
           +-------------------------------+
Bit:       | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 | 
           |---|---|---|---|---|---|---|---|
Funktion:  | 1 | 1 | 1 | 1 | 0 | 0 | 0 | 0 |
           +-------------------------------+

Die Maske ist definiert, wenn Wert im Bereich: 16-255 (beliebig)
```
</br>

### Sprites mit Akusprite erstellen

Die Sprites können auch mit den Tool [Akusprite](https://www.chibiakumas.com/akusprite/) erstellt werden. Die Grundeinstellungen kann man in den Bildern sehen. Man muss aber ein wenig mit dem Tool spielen, um es dann auch gut einsetzen zu können.

<br>

![Smiley](/Bilder/AkuSprite.png)

![Smiley](/Bilder/AkuSprite-Settings.png)


Anschliessend mit `File -> File Save AS` das Textfile abspeichern, die 16x16 Matrix kopieren und im eigenen Programm verwenden.

```
...
spritebank,0
SpriteStart
SpriteBitmapBlock,0,16,16
63,63,63,63,63,0,0,0,0,0,0,63,63,63,63,63
63,63,63,0,0,11,11,11,11,11,11,0,0,63,63,63
63,63,0,11,11,11,11,11,11,11,11,11,11,0,63,63
63,0,11,11,11,11,0,0,11,0,0,11,11,11,0,63
63,0,11,11,11,0,11,11,0,11,11,0,11,11,0,63
0,11,11,11,11,0,11,0,0,11,0,0,11,11,11,0
0,11,11,11,11,0,11,0,0,11,0,0,11,11,11,0
0,11,11,11,11,11,0,0,11,0,0,11,11,11,11,0
0,11,11,11,11,11,11,11,11,11,11,11,11,11,11,0
0,11,11,11,11,11,11,11,11,11,11,11,11,11,11,0
0,11,11,11,11,0,11,11,11,11,11,0,11,11,11,0
63,0,11,11,11,11,0,0,0,0,0,11,11,11,0,63
63,0,11,11,11,11,11,11,9,9,9,11,11,11,0,63
63,63,0,11,11,11,11,11,11,9,11,11,11,0,63,63
63,63,63,0,0,11,11,11,11,11,11,0,0,63,63,63
63,63,63,63,63,0,0,0,0,0,0,63,63,63,63,63
SpriteSpeccyBlock,0,2,2
7,0,1,7,0,1
7,0,1,7,0,1
...
```

## Quellen

Dieses Projekt nutzt Infos und Software aus folgenden Quellen:

https://hc-ddr.hucki.net/wiki/doku.php/tiny/es40

https://www.chibiakumas.com/akusprite/

http://oldmachinery.blogspot.com/2014/04/zx-sprites.html

https://github.com/boert/JU-TE-Computer

https://www.tiny-computer.de/

https://eb-harwardt.jimdofree.com/8-bit-technik/tiny-computer-6kb-aus-ju-te/

https://github.com/seidat1/Tiny

http://www.jens-mueller.org/jtcemu/index.html

https://www.robotrontechnik.de/html/forum/thwb/

Besonderer Dank geht an die vielen Tüftler im [Robotrontechnik-Forum](https://www.robotrontechnik.de/html/forum/thwb/), welche die schönen alten Computer bewahren und sogar weiterentwickeln.

