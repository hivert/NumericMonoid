cimport cmonoid
from sage.structure.sage_object cimport SageObject

cdef class Monoid(SageObject):
    cdef cmonoid.monoid _m

    cpdef int genus(self)
    cpdef int min(self)
    cpdef int conductor(self)
    cpdef _print(self)
    cpdef Monoid remove_generator(self, unsigned int gen)
    cpdef int count_children(self)
    cpdef list children(self)
    cpdef list children_generators(self)
    cpdef list nth_generation(self, unsigned int n)
    cpdef list generators(self)
    cpdef list elements(self)
    cpdef _decomposition_numbers(self)
