make:
	@clear
	as -32 -gstabs trab.s -o trab.o
	ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -L /usr/lib32 -lc trab.o -o trab
	./trab

clean:
	@clear
	rm -f trab trab.o
