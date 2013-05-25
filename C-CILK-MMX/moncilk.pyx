cdef extern from "call-cilk.h":
    cdef unsigned long int call_cilk()

cpdef unsigned long int callcilk():
     return call_cilk()
