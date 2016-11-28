odac: main.orc main.sco
	csound -odac main.orc main.sco

main.wav: main.orc main.sco
	csound -3 -o main.wav main.orc main.sco

main.flac: main.wav
	flac -f main.wav main.flac

test: main.flac
	mpv main.flac

clean: 
	rm stems/*.wav *.wav *.flac *.mp3 .*.swp
