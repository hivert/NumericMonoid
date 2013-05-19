CC = gcc
CILK = cilkc

SUFFIXES = .cilk
NPROC = 8
PROGFLAGS = --nproc $(NPROC)

CFLAGS = -g -Wall \
	-O3 -flto -march=native -mtune=native -Wvector-operation-performance -DNDEBUG
LDFLAGS = -lrt $(CFLAGS)
CILKFLAGS = -D_POSIX_C_SOURCE=199506 -D_XOPEN_SOURCE=600 # -cilk-profile

CILKCOMPILE = $(CILK) $(DEFS) $(INCLUDES) $(CFLAGS) $(CILKFLAGS)
CILKLD = $(CILK)
CILKLINK = $(CILKLD) $(CILKFLAGS) $(LDFLAGS) -o $@

%.o: %.c
	$(CC) -o $@ -c $< $(CFLAGS)

all: mongen monser mgen

alarm.o: alarm.h
monoid.o: monoid.h

mongen.o: mongen.cilk monoid.h alarm.h
	$(CILKCOMPILE) mongen.cilk -c 2>&1| grep -v "implicit.*__builtin_"
mongen: mongen.o alarm.o monoid.o
	$(CILKLINK) $^

monser: mongen.cilk monser.c monoid.o alarm.o
	gcc $(CFLAGS) monoid.o alarm.o monser.c -o monser

mgen: mgen.c alarm.o monoid.o
	gcc $(CFLAGS) monoid.o alarm.o mgen.c -o mgen

run: all
	./mongen $(PROGFLAGS)

clean:
	rm -f mongen monser mgen *.o
