# CILK_ROOT must contains the GCC/Cilk root directory
OS	 		= $(shell uname) 
CXXFLAGS    = -std=c++11 -fcilkplus -g -Wall -fsanitize=thread # -O3 # -Winline

TARGET_ARCH = -march=native -mtune=native
LDFLAGS     = -lcilkrts

TARGET = red red2 red_alloc red-norec redarray

all: $(TARGET)
clean:
	rm -rf $(TARGET)
