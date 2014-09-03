# CILK_ROOT must contains the GCC/Cilk root directory

CXX         = g++
CPPFLAGS    = -DNDEBUG 
CXXFLAGS    = -std=c++11  -g -Wall -O3 # -Winline

TARGET_ARCH = -march=native -mtune=native



TARGET = treewalk

# Pour compiler avec une valeur différente: make MAX_GENUS=35

all: $(TARGET)

main.o: main.cpp
monoid.o: monoid.cpp monoid.hpp
treewalk:  main.o monoid.o
	$(CXX) $(LDFLAGS) $^ $(LOADLIBES) $(LDLIBS) -o $@

clean:
	rm -rf $(TARGET) *.o 

test: all
	./treewalk

