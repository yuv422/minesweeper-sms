OBJS=minesweeper.o

all: minesweeper.sms

objects.link:
	echo -e "[objects]\n$(OBJS)" > objects.link

minesweeper.sms: minesweeper.o objects.link
	wlalink -d -v -S objects.link $@

%.o: %.z80asm
	wla-z80 -v -o $@ $<

clean:
	rm -f *.o objects.link minesweeper.sym minesweeper.sms
