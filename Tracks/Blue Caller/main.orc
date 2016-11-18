sr 	=	44100
kr 	= 	4410
nchnls 	= 	2
0dbfs 	= 	1

gacmb	init	0
garvb	init	0
	zakinit	50,50			; Initialize the zak system
gifn	ftgen	0,0, 257, 9, .5,1,270


	instr 1; sweeping fm with vibrato & discrete pan
idur	=		p3
iamp	=		ampdb(p4)
ifrq	=		cpspch(p5)
ifc	=		p6
ifm	=		p7
iatk	=		p8
irel	=		p9
indx1	=		p10
indx2	=		p11
indxtim	=		p12	
ilfodep	=		p13
ilfofrq	=		p14		
ipan	=		p15		
irvbsnd	=		p16		

kampenv	expseg	.01, iatk, iamp, idur/9, iamp*.6, idur-(iatk+irel+idur/9), iamp*.7, irel,.01
klfo	oscil	ilfodep, ilfofrq, 1
kindex  expon  	indx1, indxtim, indx2
asig   	foscil 	kampenv, ifrq+klfo, ifc, ifm, kindex, 1
	outs    asig*ipan, asig*(1-ipan)
garvb	=	garvb+(asig*irvbsnd)
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
ipanr 	= 1-ipanl
idfn 	= 4
idist1 	= 0
idist2 	= 1

kenv 	adsr 	iatk, idec, iamp, irel
asig 	rand 	kenv
kdist 	line 	idist1, idur, idist2
aout 	distort asig, kdist, idfn
	outs  	aout*ipanl, aout*ipanr
garvb	=	garvb+(aout*irvb)
gacmb 	= 	gacmb+(aout*icmb)

	endin

	instr 5; String

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

ipanr	=	1-p6		; Pan right

arndr1 init      0
arndr2 init      0

kdclk  linseg    1, idur-.002, 1, .002, 0                ; Declick envelope
aamp   linseg    0, .2/ifqc, 1, .2/ifqc, 0, idur-.4, 0 ; An amplitude pulse
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
aoutl  =         (asig1+asig2+aosc2*.1+ahpl*ispmix*4)*iamp*kdclk 
aoutr  =         (asig1+asig2+aosc2*.1+ahpr*ispmix*4)*iamp*kdclk 
       outs      aoutl*ipanl, aoutr*ipanr              ; Output the sound

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

       endin

	instr 101; Global Comb
idur	=	p3
itime 	= 	p4
iloop 	= 	p5

kenv	linen	1, .01, idur, .01
acomb 	comb	gacmb, itime, iloop, 0
	outs	acomb*kenv, acomb*kenv
gacmb	=		0
	endin
		
	instr 102; Global Reverb
idur	=		p3					
irvbtim	=		p4
ihiatn	=		p5

arvb	nreverb	garvb, irvbtim, ihiatn
	outs	arvb, arvb
garvb	=	0
	endin
