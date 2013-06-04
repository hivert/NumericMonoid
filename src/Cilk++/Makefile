# Makefile for Cilk++ example.  See source code for details.

# CILKPP	= cilk++
CILKPP	= /home/florent/install/Cilk-gcc/gcc-cilk/bin/g++
LIBARG	= -O3 -g -Wall 
TARGET	= mon
SRC	= $(addsuffix .cilk,$(TARGET))

all: $(TARGET)

# $(TARGET): $(SRC)
#	$(CILKPP) $(SRC) $(LIBARG) monoid.o -o $@
mon: mon.cpp monoid.hpp
	$(CILKPP) -std=c++0x -march=native -mtune=native -fcilkplus -I/home/florent/install/Cilk-gcc/gcc-cilk/include/cilk -L/home/florent/install/Cilk-gcc/gcc-cilk/lib64 -lcilkrts mon.cpp -O3 -g -Wall -o mon

clean:
	rm -f $(TARGET)
