CILKDIR     = /home/florent/install/Cilk-gcc/gcc-cilk
CXX         = $(CILKDIR)/bin/g++
CPPFLAGS    = -DNDEBUG -DMAX_GENUS=$(MAX_GENUS)
CXXFLAGS    = -std=c++0x -fcilkplus -g -Wall -O3 # -Winline
LDFLAGS     = -lcilkrts -Wl,-rpath=$(CILKDIR)/lib64
TARGET_ARCH = -march=native -mtune=native
CYFLAGS     = -fPIC
TARGET = treewalk monoid-cy.o treewalk-cy.o

ifdef USE_TBB
# TBB stuff 
TBBDIR = /home/florent/install/tbb41_20130314oss
CPPFLAGS += -DTBB=1 -I$(TBBDIR)/include
LDFLAGS +=-Wl,-rpath=$(TBBDIR)/lib/intel64/gcc4.4 -L$(TBBDIR)/lib/intel64/gcc4.4 -ltbbmalloc
endif

# Pour compiler avec une valeur différente: make MAX_GENUS=35
DEFAULT_MAX_GENUS=40
CY_MAX_GENUS=86

MAX_GENUS=$(DEFAULT_MAX_GENUS)

%-cy.o: %.cpp %.hpp
	$(COMPILE.cpp) $(CYFLAGS) -c $< -o $@

all: $(TARGET)

monoid.o: monoid.cpp monoid.hpp
treewalk.o: treewalk.cpp monoid.hpp

treewalk-cy.o monoid-cy.o: override MAX_GENUS=$(CY_MAX_GENUS)
monoid-cy.o: monoid.cpp monoid.hpp
treewalk-cy.o: treewalk.cpp monoid.hpp

treewalk: treewalk.o monoid.o
	$(CXX) $(LDFLAGS) $? $(LOADLIBES) $(LDLIBS) -o $@

clean:
	rm -f $(TARGET) *.o
