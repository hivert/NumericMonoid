CC = gcc
CILK = cilkc

.SUFFIXES:.cilk

NPROC = 8
PROGFLAGS = --nproc $(NPROC)

TARGET_ARCH = -march=native -mtune=native
OPTIM = -O3 -flto
DEFS = -DNDEBUG
CFLAGS = -Wall $(OPTIM) -Wvector-operation-performance $(DEFS)
LDFLAGS = -Wall $(OPTIM) -lrt
CILKFLAGS = -D_POSIX_C_SOURCE=199506 -D_XOPEN_SOURCE=600 # -cilk-profile

COMPILE.cilk = $(CILK) $(CFLAGS) $(TARGET_ARCH) $(CILKFLAGS)
LINK.cilk = $(CILK) $(LDFLAGS) $(TARGET_ARCH) $(CILKFLAGS)  -o $@

.PHONY: clean run

%.o: %.c
	$(COMPILE.c) -o $@ $<
%.o: %.cilk
	$(COMPILE.cilk) -o $@ -c $< 2>&1| grep -v "implicit.*__builtin_"

all: mongen monser mgen

alarm.o: alarm.h
monoid.o: monoid.h

mongen.o: mongen.cilk monoid.h alarm.h
mongen: mongen.o alarm.o monoid.o
	$(LINK.cilk) $^

monser.o: mongen.cilk monoid.h alarm.h
monser: monser.o monoid.o alarm.o

mgen.o: monoid.h alarm.h
mgen: mgen.o alarm.o monoid.o

time: all
	./mongen $(PROGFLAGS)

clean:
	rm -f mongen monser mgen *.o
