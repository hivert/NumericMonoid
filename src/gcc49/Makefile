CXX         = g++
CPPFLAGS    = -DNDEBUG -DMAX_GENUS=$(MAX_GENUS)
CXXFLAGS    = -std=c++11 -fcilkplus -g -Wall -O3 # -Winline
TARGET_ARCH = -march=native -march=native
LDFLAGS     = -lcilkrts -Wl,-rpath=/home/fromentin/root/lib


TARGET = treewalk

# Pour compiler avec une valeur différente: make MAX_GENUS=35
DEFAULT_MAX_GENUS=40
MAX_GENUS=$(DEFAULT_MAX_GENUS)

all: $(TARGET)

monoid.o: monoid.cpp monoid.hpp
treewalk.o: treewalk.cpp treewalk.hpp monoid.hpp
treewalk: treewalk.o monoid.o
	$(CXX) $(LDFLAGS) $^ $(LOADLIBES) $(LDLIBS) -o $@

numeric_monoid.so: treewalk.cpp treewalk.hpp monoid.cpp monoid.hpp numeric_monoid.pxd numeric_monoid.pyx monoid.pxd treewalk.pxd
	$(PYTHON) setup.py build_ext --inplace

clean:
	rm -rf $(TARGET) *.o build numeric_monoid.so numeric_monoid.html numeric_monoid.cpp

