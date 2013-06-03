# Makefile for Cilk++ example.  See source code for details.

CILKPP	= cilk++
LIBARG	= -O3 -g
TARGET	= mon
SRC	= $(addsuffix .cilk,$(TARGET))

all: $(TARGET)

$(TARGET): $(SRC)
	$(CILKPP) $(SRC) $(LIBARG) monoid.o -o $@

clean:
	rm -f $(TARGET)
