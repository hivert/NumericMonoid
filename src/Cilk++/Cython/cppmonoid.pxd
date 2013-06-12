from libc.stdint cimport uint8_t, uint_fast64_t

cdef extern from "cmonoid.h":
    enum: MAX_GENUS
    enum: SIZE
    ctypedef uint_fast64_t ind_t
    ctypedef uint8_t dec_numbers[SIZE]
    cdef cppclass monoid:
        dec_numbers decs
        ind_t conductor, min, genus

    void init_full_N(monoid &pm)
    void print_monoid(monoid &)
    inline void remove_generator(monoid &dst, monoid &src, ind_t)

    enum generator_type "generator_iter::generator_type":
        ALL      "generator_iter::ALL"
        CHILDREN "generator_iter::CHILDREN"

    cdef cppclass generator_iter:
        generator_iter(const monoid &mon, generator_type tp)
        bint move_next()
        uint8_t count()
        ind_t get_gen() const

