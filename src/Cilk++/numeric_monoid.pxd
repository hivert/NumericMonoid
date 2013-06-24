from monoid cimport *
from sage.structure.sage_object cimport SageObject

cdef class MonoidList(object)

cdef class NumericMonoid(SageObject):
    cdef monoid _m

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
    cpdef list gaps(self)
    cpdef unsigned char[:] _decomposition_numbers(self)
    cpdef list multiplicities(self)
    cpdef list walk_children_stack(self, int bound)
    cpdef list walk_children(self, int bound)
    cpdef MonoidList nth_generation_cilk(self, unsigned int genus)

cpdef NumericMonoid _from_pickle(type typ, int sz, int cond, int mn, int genus, tuple decs)

from libcpp.list cimport list as stl_list

cdef class MonoidList(object):
    cdef stl_list[monoid] _l

cdef class MonoidListIterator(object):
    cdef MonoidList _ml
    cdef stl_list[monoid].iterator _it, _end

