CILK = cilkc

SUFFIXES = .cilk
NPROC = 8
PROGFLAGS = --nproc $(NPROC)

CFLAGS = -g -W -O3 -march=native -mtune=native -lrt -Wvector-operation-performance -DNDEBUG
CILKFLAGS = -D_POSIX_C_SOURCE=199506 -D_XOPEN_SOURCE=600 # -cilk-profile
CILKCOMPILE = $(CILK) $(DEFS) $(INCLUDES) $(CFLAGS) $(CILKFLAGS)
CILKLD = $(CILK)
CILKLINK = $(CILKLD) $(CILKFLAGS) $(LDFLAGS) -o $@
LINK = $(CILKLINK)


all: mongen monser mgen

mongen: mongen.cilk
	$(CILKCOMPILE) mongen.cilk -o mongen 2>&1| grep -v "implicit.*__builtin_"

monser: mongen.cilk
	gcc $(CFLAGS) mongen.c -o monser

mgen: mgen.c
	gcc $(CFLAGS) mgen.c -o mgen

run: all
	./mongen $(PROGFLAGS)

clean:
	rm -f mongen monser mgen
