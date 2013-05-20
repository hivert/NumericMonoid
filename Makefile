CC   = gcc
CILK = cilkc

.SUFFIXES:.cilk

NPROC        = 8
PROGFLAGS    = --nproc $(NPROC)

TARGET_ARCH  = -march=native -mtune=native
OPTIM        = -O3 -flto
CPPFLAGS     = -DNDEBUG
CFLAGS       = -Wall $(OPTIM) -Wvector-operation-performance
LDLIBS       = -lrt
LDFLAGS      = -Wall $(OPTIM)
CILKFLAGS    = -D_POSIX_C_SOURCE=199506 -D_XOPEN_SOURCE=600 # -cilk-profile

COMPILE.cilk = $(CILK) $(CPPFLAGS) $(CFLAGS) $(TARGET_ARCH) $(CILKFLAGS)
LINK.cilk    = $(CILK) $(LDFLAGS) $(TARGET_ARCH) $(CILKFLAGS)  -o $@

.PHONY: clean run

%.o: %.cilk
	$(COMPILE.cilk) -o $@ -c $< 2>&1| grep -v "implicit.*__builtin_"

all: mongen monser mgen

alarm.o: alarm.h
monoid.o: monoid.h


mongen.o: mongen.cilk monoid.h alarm.h
mongen: mongen.o alarm.o monoid.o
	$(LINK.cilk) $^
clean::
	-$(RM)  mongen


monser.o: mongen.cilk monoid.h alarm.h
monser: monser.o alarm.o monoid.o
clean::
	-$(RM) monser

mgen.o: monoid.h alarm.h
mgen: mgen.o alarm.o monoid.o
clean::
	-$(RM) mgen


run: all
	./mongen $(PROGFLAGS)


clean::
	-$(RM) *.o perf.data
