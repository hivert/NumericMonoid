CPP          = g++
CILKPP	     = cilk++
TARGET_ARCH  = -march=native -mtune=native
OPTIM        = -g -flto  
LIBARG	     = -O3 -g
CPPFLAGS     = -DNDEBUG
CFLAGS       =  $(OPTIM) -fPIC -Wvector-operation-performance
TARGETS      = mongen mgen

all: $(TARGETS)

%.o:%.cpp
	$(CPP) $(CPPFLAGS) $(CFLAGS) $(TARGET_ARCH) -o $@ -c $<

monoid.o: monoid.hpp
alarm.o: alarm.hpp
mgen.o: monoid.hpp alarm.hpp

mgen: alarm.o monoid.o mgen.o
	$(CPP)  $(LDFLAGS) $(TARGET_ARCH) -o $@ $^

mongen: mongen.cilk monoid.o 
	$(CILKPP) $(LIBARG)  $^  -o $@

clean:
	-$(RM) $(TARGETS) *.o