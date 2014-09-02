from libc.stdint cimport uint8_t, uint_fast64_t

cdef extern from "monoid.hpp":
    enum: cMAX_GENUS "MAX_GENUS"
    enum: cSIZE "SIZE"
    ctypedef uint_fast64_t ind_t
    ctypedef uint8_t dec_numbers[cSIZE]
    cdef cppclass monoid:
        dec_numbers decs
        ind_t conductor, min, genus

    void init_full_N(monoid &pm) nogil
    void print_monoid(const monoid &) nogil
    inline void remove_generator(monoid &dst, const monoid &src, ind_t) nogil
    inline monoid remove_generator(const monoid &src, ind_t) nogil

    # Fake type since Cython only allows for instanciation of template by types.
    cdef cppclass ALL:
        pass
    cdef cppclass CHILDREN:
        pass

    cdef cppclass generator_iter[T]:
        generator_iter(const monoid &mon) nogil
        bint move_next() nogil
        uint8_t count() nogil
        ind_t get_gen() nogil
