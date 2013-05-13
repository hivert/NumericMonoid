CILK = cilkc

SUFFIXES = .cilk
NPROC = 8
PROGFLAGS = --nproc $(NPROC)

CILKFLAGS = -g -O2
CILKCOMPILE = $(CILK) $(DEFS) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CILKFLAGS) $(CILKFLAGS)
CILKLD = $(CILK)
CILKLINK = $(CILKLD) $(AM_CILKFLAGS) $(CILKFLAGS) $(LDFLAGS) -o $@
LINK = $(CILKLINK)


all: mongen.cilk
	cilkc -W -march=native -mtune=native -g -O3 -D_POSIX_C_SOURCE=199506 -D_XOPEN_SOURCE=600 mongen.cilk -o mongen

run: all
	./mongen $(PROGFLAGS)
