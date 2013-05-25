cimport cmonoid
cimport mon

cdef extern from "call-cilk.h":
    cdef unsigned long int call_cilk(cmonoid.monoid *)

cpdef unsigned long int callcilk(mon.Monoid m):
     return call_cilk(&m.pmon)
