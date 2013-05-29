CC   = gcc
CILK = cilkc
CYTHON = /home/data/Sage-Install/sage/local/bin/cython
GREP = grep


NPROC        = 8
PROGFLAGS    = --nproc $(NPROC)

TARGET_ARCH  = -march=native -mtune=native
OPTIM        = -O3 -flto -g
CPPFLAGS     = -DNDEBUG
CFLAGS       = -fPIC -Wall $(OPTIM) -Wvector-operation-performance
MODFLAGS     = -shared -pthread -fwrapv -fno-strict-aliasing -I/usr/include/python2.7
LDFLAGS      = -Wall $(OPTIM)
CILKFLAGS    = -D_POSIX_C_SOURCE=199506 -D_XOPEN_SOURCE=600 # -cilk-profile
CLFLAGS      = -I/usr/local/include/cilk/ -L/usr/local/lib64/cilk -lcilkrt0 -lcilk -pthread

COMPILE.module = $(CC) $(CPPFLAGS) $(CFLAGS) $(TARGET_ARCH) $(MODFLAGS)
COMPILE.cilk = $(CILK) $(CPPFLAGS) $(CFLAGS) $(TARGET_ARCH) $(CILKFLAGS)
LINK.cilk    = $(CILK) $(LDFLAGS) $(TARGET_ARCH) $(CILKFLAGS) -o $@

.PHONY: clean run tags

.SUFFIXES:.cilk .cilkc .pyx .pxd


%.o: %.cilk
	$(COMPILE.cilk) -c $< -o $@
%.o: %.cilkc
	$(COMPILE.cilk) -I/usr/local/include/cilk/ -c $< -o $@
%.c: %.pyx            # Must be declared before .pxd
	$(CYTHON) $<
%.so: %.c
	$(COMPILE.module) $^ -o $@

TARGETS = mongen monser mgen mon_no_fence mon.so moncilk.so
all: $(TARGETS)

alarm.o: alarm.h
monoid.o: monoid.h


mongen.o: mongen.cilk monoid.h alarm.h
mongen: mongen.o alarm.o monoid.o
	$(LINK.cilk) $^

mon_no_fence.cilkc: mongen.cilk monoid.h alarm.h
	$(COMPILE.cilk) -E1 -save-temps $<
	$(GREP) -v mfence.\*memory mongen.cilkc > mon_no_fence.cilkc
mon_no_fence.o: mon_no_fence.cilkc monoid.h alarm.h
mon_no_fence: mon_no_fence.o alarm.o monoid.o
	$(LINK.cilk) $^
clean::
	-$(RM) mongen.cilki mongen.cilkc mon_no_fence.cilkc

monser.o: mongen.cilk monoid.h alarm.h
monser: monser.o alarm.o monoid.o

mgen.o: monoid.h alarm.h
mgen: mgen.o alarm.o monoid.o

mon.c: cmonoid.pxd
mon.so:	mon.c monoid.o

moncilk.c: mon.pxd cmonoid.pxd
moncilk.so: moncilk.c mongen.o monoid.o alarm.o mongen.h
	$(COMPILE.module) $(CLFLAGS) $^ -o $@
clean::
	-$(RM) mon.c cmonoid.c moncilk.c

test: mon.so moncilk.so
	python testmon.py

run: all
	./mongen $(PROGFLAGS)

tags:
	etags *.c *.h *.cilk

clean::
	-$(RM) $(TARGETS) *.o perf.data* tags
