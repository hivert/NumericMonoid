# CILK_ROOT must contains the GCC/Cilk root directory
OS	 		= $(shell uname) 
CXX         = /usr/bin/g++-5
CXXFLAGS    = -std=c++11 -fcilkplus -g -Wall -O3 # -Winline

ifeq ($(shell uname), Darwin)
TARGET_ARCH = -march=corei7 -march=corei7
LDFLAGS 	= -lcilkrts
else
TARGET_ARCH = -march=native -mtune=native
LDFLAGS     = -lcilkrts -Wl,-rpath=$(CILK_ROOT)/lib64
endif

TARGET = red

all: $(TARGET)

red: red.o
	$(CXX) $(LDFLAGS) $^ $(LOADLIBES) $(LDLIBS) -o $@

clean:
	rm -rf $(TARGET) *.o red
