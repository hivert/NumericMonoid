cimport cmonoid

cdef class Monoid:
    cdef cmonoid.monoid _m

    cpdef int genus(self)
    cpdef int min(self)
    cpdef int conductor(self)
    cpdef prnt(self)
    cpdef Monoid remove_generator(self, unsigned int gen)
    cpdef int count_children(self)
    cpdef list children(self)
    cpdef list children_generators(self)
    cpdef list nth_generation(self, unsigned int n)
    cpdef list generators(self)
    cpdef list elements(self)

cpdef from_generators(list l)
