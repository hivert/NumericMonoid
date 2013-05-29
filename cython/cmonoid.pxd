cdef extern from "../src/monoid.h":
    enum: MAX_GENUS
    enum: SIZE
    ctypedef unsigned char nb_decompositions[SIZE]
    ctypedef struct monoid:
        nb_decompositions decs
        unsigned long int conductor, min, genus

    ctypedef unsigned long long int result[MAX_GENUS]

    monoid *alloc_monoid()
    void init_full_N(monoid *pm)
    void print_monoid(monoid *)
    inline void copy_decs(nb_decompositions *src, nb_decompositions *dst) nogil
    inline void remove_generator(monoid *, monoid *, unsigned long int) nogil

    ctypedef struct generator_iter:
        pass

    inline void init_all_generator_iter(monoid *pm, generator_iter *scan) nogil
    inline void init_children_generator_iter(monoid *pm, generator_iter *scan) nogil
    inline unsigned long int next_generator_iter(monoid *pm, generator_iter *scan) nogil
    inline unsigned char count_generator_iter(monoid *pm, generator_iter *scan) nogil
