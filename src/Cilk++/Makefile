CILKDIR     = /home/florent/install/Cilk-gcc/gcc-cilk
CXX         = $(CILKDIR)/bin/g++
CPPFLAGS    = -DNDEBUG
CXXFLAGS    = -std=c++0x -fcilkplus -g -Wall -O3 -Winline
LDFLAGS     = -lcilkrts
TARGET_ARCH = -march=native -mtune=native

TARGET = treewalk

all: $(TARGET)

treewalk.o: treewalk.cpp monoid.hpp
treewalk: treewalk.o
	$(CXX) $(LDFLAGS) $< $(LOADLIBES) $(LDLIBS) -o $@

clean:
	rm -f $(TARGET) *.o
