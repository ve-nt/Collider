sr 	=	44100
kr 	= 	4410
nchnls 	= 	2
0dbfs 	= 	1

; Global a-rate variables for each instrument used for stem generation
garl01 	init 	0
garr01 	init 	0
garl02 	init 	0
garr02 	init 	0
garl03 	init 	0
garr03 	init 	0
garl04 	init 	0
garr04 	init 	0
garl05 	init 	0
garr05 	init 	0
garl06 	init 	0
garr06 	init 	0
garl07 	init 	0
garr07 	init 	0
garl08 	init 	0
garr08 	init 	0
garl09 	init 	0
garr09 	init 	0
garl10 	init 	0
garr10 	init 	0
garl11 	init 	0
garr11 	init 	0
garl12 	init 	0
garr12 	init 	0
garl13 	init 	0
garr13 	init 	0
garl14 	init 	0
garr14 	init 	0
garl15 	init 	0
garr15 	init 	0
garl16 	init 	0
garr16 	init 	0
garl17 	init 	0
garr17 	init 	0
garl18 	init 	0
garr18 	init 	0
garl19 	init 	0
garr19 	init 	0

garl101 init 	0
garr101 init 	0
garl102 init 	0
garr102 init 	0

gacmb	init	0
garvb	init	0
	zakinit	50,50			; Initialize the zak system
gifn	ftgen	0,0, 257, 9, .5,1,270


	instr 1; sweeping fm with vibrato & discrete pan

idur	=		p3
iamp	=		p4
ifrq	=		cpspch(p5)
ifc	=		p6
ifm	=		p7
indx1	=		p8
indx2	=		p9
indxtim	=		p10	
ilfodep	=		p11
ilfofrq	=		p12		
ipan	=		p13		
irvbsnd	=		p14		

iatk	=		.00000000000001
irel	=		.00000000000001

kampenv	expseg	.000001, iatk, iamp, idur/12, iamp*.9999, idur-(iatk+irel+idur/12), iamp*.01, irel,.000001
klfo	oscil	ilfodep, ilfofrq, 1
kindex  expon  	indx1, indxtim, indx2
asig   	foscil 	kampenv, ifrq+klfo, ifc, ifm, kindex, 1
	outs    asig*ipan, asig*(1-ipan)
garvb	=	garvb+(asig*irvbsnd)

garl01 	= 	asig*ipan
garr01 	= 	asig*(1-ipan)

	endin

        instr 2; Stereo Cymbal

idur	=	p3		; Duration
iamp	=	p4		; Amplitude
ifqc	=	cpspch(p5)	; Pitch
ipanl	=	p6		; Pan left
ifco	=	p7		; Fco
iq	=	p8		; Q
iotv	=	p9		; Overtone volume
iotf	=	ifco*p10	; Fco*OTFqc
iotq	=	iq*p11		; Q*OTQ
imix	=	p12

iinchl	=	1		; Noise input for left channel
iinchr	=	2		; Noise input for right channel
ipanr	=	1-ipanl		; Pan right

kdclk	linseg	0, .002, 1, idur-.004, 1, .002, 0 ; Declick envelope
kamp	expseg	1, idur, .01
kamp2	linseg	0, idur*.2, 1, idur*.4, .3, idur*.4, 0
kamp2   =       kamp2*imix
kamp3	linseg	0, .002, 1, .004, .5, .004, 0, idur-.01, 0
kflp	linseg	8000, .01, 5000, idur-.01, 1000

arndl	zar	iinchl
arndr	zar	iinchr

;asig0	vco	1, ifqc*.5,  2, .5, 1, 1	; Generate impulse
asig1	vco	1, ifqc,     2, .5, 1, 1	; Generate impulse
asig2	vco	1, ifqc*1.5, 2, .5, 1, 1	; Generate impulse

asigl	=	(asig1*asig2*(1+arndl))*kamp+arndl*kamp2
asigr	=	(asig1*asig2*(1+arndr))*kamp+arndr*kamp2

aoutl1	rezzy	asigl, ifco, iq, 1	; Apply amp envelope and declick
aoutr1	rezzy	asigr, ifco, iq, 1	; Apply amp envelope and declick

aoutl2	rezzy	asigl, iotf, iotq, 1	; Apply amp envelope and declick
aoutr2	rezzy	asigr, iotf, iotq, 1	; Apply amp envelope and declick

aoutl	=	aoutl1+aoutl2*iotv	; Mix the signal with the overtone
aoutr	=	aoutr1+aoutr2*iotv

alpl	butlp	aoutl, 15000		; Low pass filter the very high
alpr	butlp	aoutr, 15000		; frequencies to get rid of some noise

	outs	alpl*ipanl*iamp*kdclk, alpr*ipanr*iamp*kdclk
garl02 	= 	alpl*ipanl*iamp*kdclk
garr02 	= 	alpr*ipanr*iamp*kdclk

	endin

	instr 3; Rand Sweep
idur 	= p3 
iamp 	= p4
ibeta 	= p5
ipanl 	= p6 
irvbsnd = p7
icmbsnd = p8

iatk 	= 0.05
idec 	= 0.05
islev 	= 15
irel 	= 0.05
irise 	= iatk+idec
idec 	= irel
ipanr 	= 1-ipanl

kfrq 	linen 	ibeta, irise, idur, idec
kenv 	adsr 	iatk, idec, islev, irel
asig 	rand 	iamp*kenv
aout	butlp 	asig, kfrq
	outs  	aout*ipanl, aout*ipanr
garvb	=	garvb+(aout*irvbsnd)
gacmb 	= 	gacmb+(aout*icmbsnd)

garl03 	= 	aout*ipanl
garr03 	= 	aout*ipanr
	endin

	instr 4; Rand Hit
idur 	= p3
iamp 	= p4
ipanl 	= p5
irvb 	= p6
icmb 	= p7

iatk 	= .01
idec 	= .01
irel 	= .04
isus 	= .6
ipanr 	= 1-ipanl
idfn 	= 4
idist1 	= 0
idist2 	= 1

kenv 	adsr 	iatk, idec, isus, irel
asig 	rand 	kenv*iamp
kdist 	line 	idist1, idur, idist2
aout 	distort asig, kdist, idfn
	outs  	aout*ipanl, aout*ipanr
garvb	=	garvb+(aout*irvb)
gacmb 	= 	gacmb+(aout*icmb)

garl04 	= 	aout*ipanl
garr04 	= 	aout*ipanr
	endin

	instr 5; String Reverb Only

idur 	= p3
iamp 	= p4
kcps 	= cpspch(p5)
icps 	= cpspch(p6)

iatk 	= .5
idec 	= .5
isus 	= .7
irel 	= .5
ifn 	= 0
imeth 	= 1
ilamp 	= .005
ilcps 	= .5
irvb 	= 1

klcps 	lfo 	ilamp, ilcps
kenv 	adsr 	iatk, idec, isus, irel
asig 	pluck 	iamp*kenv, kcps+klcps, icps, ifn, imeth
	;outs 	asig, asig
garvb 	= 	garvb+(asig*irvb)

garl05 	= 	asig
garr05 	= 	asig
	endin

	instr 6; Hum

idur 	= p3
iamp 	= p4
ifrq 	= cpspch(p5)
iret 	= p6
itype 	= p7
idist1 	= p8
idist2 	= p9
irvb 	= p10

ifn 	= 1
irise 	= .2
idec 	= .2

kamp 	lfo 		iamp, iret, itype
kenv 	linen 		iamp, irise, idur, idec
asig 	oscil 		kamp*kenv, ifrq, ifn
kdist 	line 		idist1, idur, idist2
aout 	distort 	asig, kdist, gifn
	outs 		aout, aout
garvb 	= 		garvb+(aout*irvb)

garl06	= 	aout
garr06	= 	aout

	endin

	instr 7; Rand Draw

idur 	= p3
ia	= p4
ib 	= p5
ipanl 	= p6
icmb 	= p7

ipanr 	= 1-ipanl

kamp 	line 	ia, idur, ib
asig 	trirand kamp
	outs 	asig*ipanl, asig*ipanr
gacmb 	= 	gacmb+(asig*icmb)

garl07 	= 	asig*ipanl
garr07 	= 	asig*ipanr
	endin

	instr 8; Buzzer

idur 	= p3
iamp 	= p4
ifrq1 	= cpspch(p5)
ifrq2 	= cpspch(p6)
ifn 	= p7
ipanl 	= p8
icmb 	= p9
irvb 	= p10

iatk 	= 0.005
idec 	= 0.005
isus 	= 0.2
irel 	= 0.005
ipanr 	= 1-ipanl

kfrq 	line 	ifrq1, idur, ifrq2
kenv 	adsr 	iatk, idec, isus, irel
asig 	oscil 	iamp*kenv, kfrq, ifn
	outs 	asig*ipanl, asig*ipanr
gacmb 	= 	gacmb+(asig*icmb)
garvb 	= 	garvb+(asig*irvb)

garl08 	= 	asig*ipanl
garr08 	= 	asig*ipanr

	endin

       instr 9; Snare

idur	=	p3		; Duration
iamp	=	p4		; Amplitude
ifqc	=	cpspch(p5)	; Pitch to frequency
ipanl	=	p6		; Pan left
irez	=	p7		; Tone
ispdec	=	p8		; Spring decay
ispton	=	p9		; Spring tone
ispmix	=	p10		; Spring mix
ispq	=	p11		; Spring Q
ipbnd	=	p12		; Pitch bend
ipbtm	=	p13		; Pitch bend time
irvb 	= 	p14

ipanr	=	1-p6		; Pan right

arndr1 init      0
arndr2 init      0

kdclk  linseg    1, idur-.002, 1, .002, 0                ; Declick envelope
aamp   linseg    1, .2/ifqc, 1, .1/ifqc, 0, idur-.002, 0 ; An amplitude pulse
kptch  linseg    1, ipbtm, ipbnd, ipbtm, 1, .1, 1

aosc1  vco      1, ifqc, 2, 1, 1, 1 ; Use a pulse of the vco to stimulate the filters
aosc   =        -aosc1*aamp        ; Multiply by the envelope pulse
aosc2  butterlp aosc, 12000        ; Lowpass at 12K to take the edge off

asig1  moogvcf  aosc,    ifqc*kptch, .9*irez      ; Moof filter with high resonance for basic drum tone
asig2  moogvcf  aosc*.5, ifqc*2.1*kptch, .75*irez ; Sweeten with an overtone

aampr  expseg    .1, .002, 1, .2, .005

arnd1  zar      1
arnd2  zar      2

arnd1  =        arnd1*2*asig1
arndr1 delay    arnd1-arndr2*.6, .01

arnd2  =        arnd2*2*asig1
arndr2 delay    arnd2-arndr1*.6, .01

ahp1l  rezzy    arnd1+arndr1, 2700*ispton*kptch, 5*ispq, 1 ; High pass rezzy based at 2700
ahp2l  butterbp arnd1, 2000*ispton*kptch, 500/ispq  ; Generate an undertone
ahp3l  butterbp arnd1, 5400*ispton*kptch, 500/ispq  ; Generate an overtone
ahpl   pareq    ahp1l+ahp2l*.7+ahp3l*.3, 15000, .1, .707, 2 ; Attenuate the highs a bit

ahp1r  rezzy    arnd2+arndr2, 2700*ispton*kptch, 5*ispq, 1 ; High pass rezzy based at 2700
ahp2r  butterbp arnd2, 2000*ispton*kptch, 500/ispq  ; Generate an undertone
ahp3r  butterbp arnd2, 5400*ispton*kptch, 500/ispq  ; Generate an overtone
ahpr   pareq    ahp1r+ahp2r*.7+ahp3r*.3, 15000, .1, .707, 2 ; Attenuate the highs a bit


; Mix drum tones, pulse and noise signal & declick
aoutl 	=         (asig1+asig2+aosc2*.1+ahpl*ispmix*4)*iamp*kdclk*ipanl
aoutr  	=         (asig1+asig2+aosc2*.1+ahpr*ispmix*4)*iamp*kdclk*ipanr 
       	outs      aoutl, aoutr		; Output the sound

garl09 	= 	aoutl
garr09 	= 	aoutr

garvb 	= 	garvb+((aoutl+aoutr)*irvb)

       endin

	instr 10; Dun Dun Din
idur 	= p3
iamp 	= p4
ifrq 	= cpspch(p5)

iatk 	= .04
idec 	= .04
irel 	= .08
isus 	= .4
ifn 	= 4

kenv 	adsr 	iatk, idec, isus, irel
asig 	oscil	iamp*kenv, ifrq, ifn
	outs 	asig, asig

garl10 	= 	asig
garr10 	= 	asig

	endin

	instr 11; Kick Drum 2

idur	=	p3		; Duration
iamp	=	p4		; Amplitude
ihif	=	p5		; Low frequency
ilof	=	p6		; High freqency
ipanl	=	sqrt(p7)	; Pan left & right use sqrt
ipanr	=	sqrt(1-p7)	; for smoother panning
idec	=	p8		; Decay
itens	=	p9		; Tension
ihit	=	p10		; Accent
iq	=	p11		; Pitch Bend Q (oscilation)
iod	=	p12		; Amplitude of overtones
ioc	=	p13		; Control of overtone amplitudes
iof	=	p14		; Control of overtone frequencies
isus	=	p15		; Sustain
iqf	=	p16		; FM resonance frequency
ilpf	=	p17		; Amp low pass frequency

; Freq Envelope
afqc	linseg	ihif,idec,ilof,idur*-idec,ilof	; Hi-Lo fqc sweep
afqc2	rezzy	afqc,iqf,iq			; Add some ripples
afqc3	=	afqc-afqc2*itens		; Mix fqc sweep with ripples

aamp	expseg	1,idur,isus			; Exp amp envelope
aamp2   butlp	aamp,ilpf			; Low pass version
aamp3	=	(aamp*ihit+aamp2*(1-ihit))	; Mix the two envelopes for different attacks
adclk	linseg	0,.002,1,idur-.004,1,.002,0	; Declick envelope

asig	oscil	1,afqc3,1			; Simple sine oscillator

ioc1	=	1+ioc				; Overtone control for base fqc*2
ioc2	=	1+ioc*2				; ditto fqc*3
ioc3	=	1+ioc*3				; ditto fqc*5

asig2a	oscil	1,afqc3*2,1,.25			; Sine oscillator 2
asigo	=	asig2a+.95			; Scale for the tanh
asig2b	=	-tanh((asig2a+.9)*ioc1)+1		; Create a squarish envelope for the overtones
asig2c	=	(asig2a*asig2b)*aamp3^ioc1	; This makes pulses of sine waves

asig3a	oscil	1,afqc3*(1+iof*2),1,.25		; Sine oscillator 3
asig3b	=	-tanh(asigo*ioc2)+1		; Squarish envelope pulses
asig3c	=	(asig3a*asig3b)*aamp3^ioc2	; Adjust the magnitude with ioc2

asig5a	oscil	1,afqc3*(1+iof*4),1,.25		; Sine oscillator 5
asig5b	=	-tanh(asigo*ioc2)+1		; Squarish envelope pulses
asig5c	=	(asig5a*asig5b)*aamp3^ioc3	; Adjust the magnitude

; Prepare for output
aout	=	(asig*aamp3+(asig2c+asig3c+asig5c)*iod)*adclk*iamp
aoutl	=	aout
aoutr	=	aout

       outs      aoutl*ipanl, aoutr*ipanr		; Output the sound

garl11 	= 	aoutl*ipanl
garr11 	= 	aoutr*ipanr

       endin

	instr 12; BG Oscil Ambient


idur 	= p3
iamp 	= p4
ifrq 	= cpspch(p5)
irise 	= p6
idec 	= p7
ilamp 	= p8
ilcps 	= p9 
ifil	= p10

itype 	= 0
ifn 	= 1

kcps 	lfo 	ilamp, ilcps, itype
kenv 	linen 	iamp, irise, idur, idec
asig 	oscil 	kenv, ifrq+kcps, ifn
aout 	butlp 	asig, ifil
	outs 	aout, aout

garl12 	= 	aout
garr12 	= 	aout

	endin

	instr 13; Disk Scratch

idur 	= p3
iamp 	= p4
ifrq 	= cpspch(p5)
irise 	= p6
idec 	= p7
ilamp 	= p8
ilcps 	= p9 
ifil	= p10

itype 	= 0
ifn 	= 1
idist1  = 1
idist2  = 2
iline 	= idur/4

kcps 	lfo 	ilamp, ilcps, itype
kenv 	linen 	iamp, irise, idur, idec
asig1 	oscil 	kenv, ifrq+kcps, ifn
asig2 	butlp 	asig1, ifil
kdist 	line 	idist1, iline, idist2
aout 	distort asig2, kdist, gifn
	outs 	aout, aout

garl13 	= 	aout
garr13 	= 	aout

	endin

	instr 14; Snare

idur 	= p3
iamp 	= p4
ifrq1 	= cpspch(p5)
ifrq2 	= cpspch(p6)
ipanl 	= p7

ipanr 	= 1-ipanl
iatk 	= .02
idec 	= .02
isus 	= .2
irel 	= .04
ifn 	= 4

kfrq 	line 	ifrq1, idur, ifrq2
kenv 	adsr 	iatk, idec, isus, irel
aout 	oscil 	iamp*kenv, kfrq, ifn
	outs 	aout*ipanl, aout*ipanr

garl14 	= 	aout*ipanl
garr14 	= 	aout*ipanr

	endin

	instr 15; BG Oscil Ambient


idur 	= p3
iamp 	= p4
ifrq 	= cpspch(p5)
irise 	= p6
idec 	= p7
ilamp 	= p8
ilcps 	= p9 
ifil	= p10

itype 	= 0
ifn 	= 1

kcps 	lfo 	ilamp, ilcps, itype
kenv 	linen 	iamp, irise, idur, idec
asig 	oscil 	kenv, ifrq+kcps, ifn
aout 	butlp 	asig, ifil
	outs 	aout, aout

garl15 	= 	aout
garr15 	= 	aout

	endin

	instr 16; String

idur 	= p3
iamp 	= p4
kcps 	= cpspch(p5)
icps 	= cpspch(p6)

iatk 	= .1
idec 	= .1
isus 	= .7
irel 	= .1
ifn 	= 0
imeth 	= 1
ilamp 	= .5
ilcps 	= 4
irvb 	= .4

klcps 	lfo 	ilamp, ilcps
kenv 	adsr 	iatk, idec, isus, irel
asig 	pluck 	iamp*kenv, kcps+klcps, icps, ifn, imeth
	outs 	asig, asig
garvb 	= 	garvb+(asig*irvb)

garl16 	= 	asig
garr16 	= 	asig
	endin

	instr 17; Oscil FRQ rise

idur 	= p3
iamp 	= p4
ifrq 	= cpspch(p5)
ifn 	= p6

iamp1	= 0
irise 	= 1.4
idec 	= .2

kenv 	linen 	iamp, irise, idur, idec
aout 	oscil 	kenv, ifrq, ifn
	outs 	aout, aout

garl17 	= 	aout
garr17 	= 	aout
	endin

	instr 18; Helicopter

idur 	= p3
iamp 	= p4
itype 	= p5
icps1 	= p6
icps2 	= p7

ipana 	= 1
ipanf 	= .5

kcps 	expon 		icps1, idur, icps2
krange 	lfo 		iamp, kcps, itype
aout 	bexprnd 	krange
kpan 	lfo 		ipana, ipanf
	outs 		aout*kpan, aout*(1-kpan)

garl18 	= 	aout*kpan
garr18 	= 	aout*(1-kpan)
	endin

	instr 19; Oscil FRQ rise

idur 	= p3
iamp 	= p4
ifrq 	= cpspch(p5)

ifn 	= 1
irise 	= 1.4
idec 	= .2

kenv 	linen 	iamp, irise, idur, idec
aout 	oscil 	kenv, ifrq, ifn
	outs 	aout, aout

garl19 	= 	aout
garr19 	= 	aout
	endin

	instr 20; Rand Rand

idur 	= p3
iamp 	= p4 	

kamp 	trirand iamp
asig 	trirand kamp
	outs  	asig, asig
	endin 

          instr 21; Filtered Noise
idur      = p3
iamp      = p4/100000
iswpstart = p5
isweepend = p6
ibndwidth = p7
ibalance  = p8                  ; 1 = left, .5 = center, 0 = right
irvbgain  = p9

iattack   = .01
irelease  = .05
iwhite    = 2050

kamp      	linen     iamp, iattack, idur, irelease
ksweep    	line      iswpstart, idur, isweepend
asig      	rand      iwhite
afilt     	reson     asig, ksweep, ibndwidth
arampsig  	=         kamp * afilt
          	outs      arampsig * ibalance, arampsig * (1 - ibalance)
garvb 		=         garvb + arampsig * p9
          endin

	instr 22; Pinkish Noise Pitch Bent

idur 	= p3
iamp 	= p4
inum	= p5

iatk 	= .03
idec 	= .03
isus	= .4
irel 	= .04
imethod = 0

kenv 	adsr 	iatk, idec, isus, irel
asig	pinkish kenv*iamp, imethod, inum
	outs 	asig, asig


        endin

	instr 23; String 

idur 	= p3
iamp 	= p4
kcps 	= cpspch(p5)
icps 	= cpspch(p6)

iatk 	= .1
idec 	= .1
isus 	= .7
irel 	= .1
ifn 	= 0
imeth 	= 1
ilamp 	= .005
ilcps 	= .5
irvb 	= 1

klcps 	lfo 	ilamp, ilcps
kenv 	adsr 	iatk, idec, isus, irel
asig 	pluck 	iamp*kenv, kcps+klcps, icps, ifn, imeth
	outs 	asig, asig
garvb 	= 	garvb+(asig*irvb)

garl05 	= 	asig
garr05 	= 	asig
	endin

	instr 100; Stem Generator

	itype 	= 18

	fout 	"stems/001.wav", itype, garl01, garr01
	fout 	"stems/002.wav", itype, garl02, garr02
	fout 	"stems/003.wav", itype, garl03, garr03
	fout 	"stems/004.wav", itype, garl04, garr04
	fout 	"stems/005.wav", itype, garl05, garr05
	fout 	"stems/006.wav", itype, garl06, garr06
	fout 	"stems/007.wav", itype, garl07, garr07
	fout 	"stems/008.wav", itype, garl08, garr08
	fout 	"stems/009.wav", itype, garl09, garr09
	fout 	"stems/010.wav", itype, garl10, garr10
	fout 	"stems/011.wav", itype, garl11, garr11
	fout 	"stems/012.wav", itype, garl12, garr12
	fout 	"stems/013.wav", itype, garl13, garr13
	fout 	"stems/014.wav", itype, garl14, garr14
	fout 	"stems/015.wav", itype, garl15, garr15
	fout 	"stems/016.wav", itype, garl16, garr16
	fout 	"stems/017.wav", itype, garl17, garr17
	fout 	"stems/018.wav", itype, garl18, garr18
	fout 	"stems/019.wav", itype, garl19, garr19

	fout 	"stems/101.wav", itype, garl101, garr101
	fout 	"stems/102.wav", itype, garl102, garr102


	clear 	garl01, garr01
	clear 	garl02, garr02
	clear 	garl03, garr03
	clear 	garl04, garr04
	clear 	garl05, garr05
	clear 	garl06, garr06
	clear 	garl07, garr07
	clear 	garl08, garr08
	clear 	garl09, garr09
	clear 	garl10, garr10
	clear 	garl11, garr11
	clear 	garl12, garr12
	clear 	garl13, garr13
	clear 	garl14, garr14
	clear 	garl15, garr15
	clear 	garl16, garr16
	clear 	garl17, garr17
	clear 	garl18, garr18
	clear 	garl19, garr19

	clear 	garl101, garr101
	clear 	garl102, garr102

	endin

	instr 101; Global Comb
idur	=	p3
itime 	= 	p4
iloop 	= 	p5

kenv	linen	1, .01, idur, .01
acomb 	comb	gacmb, itime, iloop, 0
	outs	acomb*kenv, acomb*kenv
gacmb	=		0

garl101 = 	acomb*kenv
garr101 = 	acomb*kenv
	endin
		
	instr 102; Global Reverb
idur	=		p3					
irvbtim	=		p4
ihiatn	=		p5

arvb	nreverb	garvb, irvbtim, ihiatn
	outs	arvb, arvb
garvb	=	0

garl102 = 	arvb
garr102 = 	arvb
	endin
