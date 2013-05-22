CC   = gcc
CILK = cilkc
GREP = grep
.SUFFIXES:.cilk

NPROC        = 8
PROGFLAGS    = --nproc $(NPROC)

TARGET_ARCH  = -march=native -mtune=native
OPTIM        = -O3 -flto -g
CPPFLAGS     = -DNDEBUG
CFLAGS       = -Wall $(OPTIM) -Wvector-operation-performance
LDLIBS       = -lrt
LDFLAGS      = -Wall $(OPTIM)
CILKFLAGS    = -D_POSIX_C_SOURCE=199506 -D_XOPEN_SOURCE=600 # -cilk-profile

COMPILE.cilk = $(CILK) $(CPPFLAGS) $(CFLAGS) $(TARGET_ARCH) $(CILKFLAGS)
LINK.cilk    = $(CILK) $(LDFLAGS) $(TARGET_ARCH) $(CILKFLAGS)  -o $@

.PHONY: clean run

%.o: %.cilk
	$(COMPILE.cilk) -o $@ -c $< 2>&1| $(GREP) -v "implicit.*__builtin_"

all: mongen monser mgen monbug

alarm.o: alarm.h
monoid.o: monoid.h


mongen.o: mongen.cilk monoid.h alarm.h
mongen: mongen.o alarm.o monoid.o
	$(LINK.cilk) $^
clean::
	-$(RM)  mongen

monbug.cilkc: mongen.cilk monoid.h alarm.h
	$(COMPILE.cilk) -E1 -save-temps $< 2>&1| $(GREP) -v "implicit.*__builtin_"
	$(GREP) -v mfence.\*memory mongen.cilkc > monbug.cilkc
monbug.o: monbug.cilkc monoid.h alarm.h
	$(COMPILE.cilk) -c $<
monbug: monbug.o alarm.o monoid.o
	$(LINK.cilk) $^
clean::
	-$(RM)  mongen.cilki mongen.cilkc monbug.cilkc monbug


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
