CILK = cilkc

SUFFIXES = .cilk
NPROC = 8
PROGFLAGS = --nproc $(NPROC)

CFLAGS = -W -march=native -mtune=native -O3 -DNDEBUG -lrt -Wvector-operation-performance
CILKFLAGS = -D_POSIX_C_SOURCE=199506 -D_XOPEN_SOURCE=600 # -cilk-profile
CILKCOMPILE = $(CILK) $(DEFS) $(INCLUDES) $(CFLAGS) $(AM_CILKFLAGS) $(CILKFLAGS)
CILKLD = $(CILK)
CILKLINK = $(CILKLD) $(CILKFLAGS) $(LDFLAGS) -o $@
LINK = $(CILKLINK)


all: mongen.cilk
	$(CILKCOMPILE) mongen.cilk -o mongen 2>&1| grep -v "implicit.*__builtin_ia32"

run: all
	./mongen $(PROGFLAGS)
