CPP          = g++
TARGET_ARCH  = -march=native -mtune=native
OPTIM        = -O3 -flto -g
CPPFLAGS     = -DNDEBUG
CFLAGS       = -fPIC $(OPTIM) -Wvector-operation-performance
LDFLAGS      = -Wall $(OPTIM)
all: mgen

%.o:%.cpp
	$(CPP) $(CPPFLAGS) $(CFLAGS) $(TARGET_ARCH) -o $@ -c $<

monoid.o: monoid.hpp
alarm.o: alarm.hpp
mgen.o: monoid.hpp alarm.hpp

mgen: alarm.o monoid.o mgen.o
	$(CPP)  $(LDFLAGS) $(TARGET_ARCH) -o $@ $^

clean:
	-$(RM) mgen *.o