CILKDIR = /home/florent/install/Cilk-gcc/gcc-cilk
CILKPP	= $(CILKDIR)/bin/g++
LIBARG	= -g -Wall -O3
TARGET	= mon
SRC	= $(addsuffix .cilk,$(TARGET))

all: $(TARGET)

# $(TARGET): $(SRC)
#	$(CILKPP) $(SRC) $(LIBARG) monoid.o -o $@
mon: mon.cpp monoid.hpp
	$(CILKPP) -std=c++0x -march=native -mtune=native -fcilkplus -I$(CILKDIR)/include/cilk -L$(CILKDIR)/lib64 -lcilkrts mon.cpp $(LIBARG) -o mon

run:	all
	LD_LIBRARY_PATH=$(CILKDIR)/lib64 time ./mon

clean:
	rm -f $(TARGET)
