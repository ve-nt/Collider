odac: main.orc main.sco
	csound -odac main.orc main.sco

main.wav: main.orc main.sco
	csound -3 -o main.wav main.orc main.sco

main.flac: main.wav
	flac -f main.wav main.flac

test: main.flac
	mpv main.flac

clean: 
	rm *.wav || \
	rm stems/*.wav || \
	rm *.flac || \
	rm *.mp3 || \
	rm .*.swp
