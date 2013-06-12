CILKDIR     = /home/florent/install/Cilk-gcc/gcc-cilk
CXX         = $(CILKDIR)/bin/g++
CPPFLAGS    = -DNDEBUG
CXXFLAGS    = -std=c++0x -fcilkplus -g -Wall -O3 # -Winline
LDFLAGS     = -lcilkrts
TARGET_ARCH = -march=native -mtune=native
CYFLAGS     = -fPIC -DMAX_GENUS=86
TARGET = treewalk monoid-cy.o treewalk-cy.o

%-cy.o: %.cpp %.hpp
	$(COMPILE.cpp) $(CYFLAGS) -c $< -o $@

all: $(TARGET)

monoid.o: monoid.cpp monoid.hpp
monoid-cy.o: monoid.cpp monoid.hpp
treewalk.o: treewalk.cpp monoid.hpp
treewalk-cy.o: treewalk.cpp monoid.hpp

treewalk: treewalk.o monoid.o
	$(CXX) $(LDFLAGS) $? $(LOADLIBES) $(LDLIBS) -o $@

clean:
	rm -f $(TARGET) *.o
