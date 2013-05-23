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

.PHONY: clean run tags

%.o: %.cilk
	$(COMPILE.cilk) -o $@ -c $< 2>&1| $(GREP) -v "implicit.*__builtin_"

all: mongen monser mgen mon_no_fence

alarm.o: alarm.h
monoid.o: monoid.h


mongen.o: mongen.cilk monoid.h alarm.h
mongen: mongen.o alarm.o monoid.o
	$(LINK.cilk) $^
clean::
	-$(RM)  mongen

mon_no_fence.cilkc: mongen.cilk monoid.h alarm.h
	$(COMPILE.cilk) -E1 -save-temps $< 2>&1| $(GREP) -v "implicit.*__builtin_"
	$(GREP) -v mfence.\*memory mongen.cilkc > mon_no_fence.cilkc
mon_no_fence.o: mon_no_fence.cilkc monoid.h alarm.h
	$(COMPILE.cilk) -c $<
mon_no_fence: mon_no_fence.o alarm.o monoid.o
	$(LINK.cilk) $^
clean::
	-$(RM)  mongen.cilki mongen.cilkc mon_no_fence.cilkc mon_no_fence

monser.o: mongen.cilk monoid.h alarm.h
monser: monser.o alarm.o monoid.o
clean::
	-$(RM) monser

mgen.o: monoid.h alarm.h
mgen: mgen.o alarm.o monoid.o
clean::
	-$(RM) mgen


run: all
	./mongen $(PROGFLAGS)\
tags:
	etags *.c *.h *.cilk
clean::
	-$(RM) *.o perf.data* tags
