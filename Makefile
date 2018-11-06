OBJS=minesweeper.o

all: minesweeper.sms

objects.link:
	echo "[objects]\n$(OBJS)" > objects.link

minesweeper.sms: minesweeper.o objects.link
	wlalink -dvs objects.link $@

%.o: %.z80asm
	wla-z80 -vo $< $@

clean:
	rm -f *.o objects.link minesweeper.sym minesweeper.sms
