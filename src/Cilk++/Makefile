# CILK_ROOT must contains the GCC/Cilk root directory
OS	 		= $(shell uname)
CPPFLAGS    = -DNDEBUG -DMAX_GENUS=$(MAX_GENUS)
CXXFLAGS    = -std=c++11 -fcilkplus -g -Wall -O3 # -fsanitize=thread # -Winline

ifeq ($(shell uname), Darwin)
TARGET_ARCH = -march=corei7 -march=corei7
LDFLAGS 	= -lcilkrts
else
TARGET_ARCH = -march=native -mtune=native
LDFLAGS     = -lcilkrts # -ltsan # -Wl,-rpath=$(CILK_ROOT)/lib64
endif

TARGET = treewalk

SAGE = sage
PYTHON = $(SAGE) -python

# Experimental TBB stuff
# Suppose that TBB is installed in $(TBB_ROOT)
ifdef USE_TBB
CPPFLAGS += -DTBB=1 -I$(TBB_ROOT)/include
LDFLAGS +=-Wl,-rpath=$(TBB_ROOT)/lib/intel64/gcc4.4 -L$(TBB_ROOT)/lib/intel64/gcc4.4 -ltbbmalloc
endif

# Pour compiler avec une valeur différente: make MAX_GENUS=35
DEFAULT_MAX_GENUS=40
MAX_GENUS=$(DEFAULT_MAX_GENUS)

all: $(TARGET)

alarm.o: alarm.cpp alarm.hpp
monoid.o: monoid.cpp monoid.hpp
treewalk.o: treewalk.cpp treewalk.hpp monoid.hpp alarm.hpp
treewalk: treewalk.o monoid.o alarm.o
	$(CXX) $(LDFLAGS) $^ $(LOADLIBES) $(LDLIBS) -o $@

numeric_monoid.so: treewalk.cpp treewalk.hpp monoid.cpp monoid.hpp numeric_monoid.pxd numeric_monoid.pyx monoid.pxd treewalk.pxd
	$(PYTHON) setup.py build_ext --inplace

clean:
	rm -rf $(TARGET) *.o build cysignals numeric_monoid.so numeric_monoid.html numeric_monoid.cpp

test: all
	./treewalk
	$(SAGE) -t --force-lib numeric_monoid.pyx
