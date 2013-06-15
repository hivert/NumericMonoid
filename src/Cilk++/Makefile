# CILK_ROOT must contains the GCC/Cilk root directory

CXX         = $(CILK_ROOT)/bin/g++
CPPFLAGS    = -DNDEBUG -DMAX_GENUS=$(MAX_GENUS)
CXXFLAGS    = -std=c++0x -fcilkplus -g -Wall -O3 # -Winline
LDFLAGS     = -lcilkrts -Wl,-rpath=$(CILK_ROOT)/lib64
TARGET_ARCH = -march=native -mtune=native
TARGET = treewalk numeric_monoid.so

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

monoid.o: monoid.cpp monoid.hpp
treewalk.o: treewalk.cpp treewalk.hpp monoid.hpp
treewalk: treewalk.o monoid.o
	$(CXX) $(LDFLAGS) $^ $(LOADLIBES) $(LDLIBS) -o $@

numeric_monoid.so: treewalk.cpp treewalk.hpp monoid.cpp monoid.hpp numeric_monoid.pxd numeric_monoid.pyx cppmonoid.pxd
	$(PYTHON) setup.py build_ext --inplace

clean:
	rm -rf $(TARGET) *.o build numeric_monoid.so numeric_monoid.html numeric_monoid.cpp

test: all
	./treewalk
	$(SAGE) -t --force-lib numeric_monoid.pyx
