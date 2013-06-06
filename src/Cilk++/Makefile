CILKDIR     = /home/florent/install/Cilk-gcc/gcc-cilk
CXX         = $(CILKDIR)/bin/g++
CPPFLAGS    = -DNDEBUG
CXXFLAGS    = -std=c++0x -fcilkplus -g -Wall -O3 -Winline 
LDFLAGS     = -lcilkrts
TARGET_ARCH = -march=native -mtune=native

TARGET = treewalk

all: $(TARGET)

treewalk: treewalk.cpp monoid.hpp

clean:
	rm -f $(TARGET)
