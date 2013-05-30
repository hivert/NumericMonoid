cimport cmonoid
from sage.structure.sage_object cimport SageObject

cdef class NumericMonoid(SageObject):
    cdef cmonoid.monoid _m

    cpdef int genus(self)
    cpdef int min(self)
    cpdef int conductor(self)
    cpdef _print(self)
    cpdef NumericMonoid remove_generator(self, unsigned int gen)
    cpdef int count_children(self)
    cpdef list children(self)
    cpdef list children_generators(self)
    cpdef list nth_generation(self, unsigned int n)
    cpdef list generators(self)
    cpdef list elements(self)
    cpdef unsigned char[:] _decomposition_numbers(self)

cpdef NumericMonoid _from_pickle(type typ, int sz, int cond, int mn, int genus, tuple decs)
