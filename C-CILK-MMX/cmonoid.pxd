cdef extern from "monoid.h":
    enum: SIZE
    ctypedef unsigned char nb_decompositions[SIZE]
    ctypedef struct monoid:
        nb_decompositions decs
        unsigned long int conductor, min, genus

    monoid *alloc_monoid()
    void init_full_N(monoid *pm)
    void print_monoid(monoid *)
    inline void copy_decs(nb_decompositions *src, nb_decompositions *dst)
    inline void remove_generator(monoid *, monoid *, unsigned long int)

    ctypedef struct monoid_generator_scan:
        pass

    inline void init_all_generator_scan(monoid *pm, monoid_generator_scan *scan)
    inline void init_children_generator_scan(monoid *pm, monoid_generator_scan *scan)
    inline unsigned long int next_generator_scan(monoid *pm, monoid_generator_scan *scan)
    inline unsigned char count_generator_scan(monoid *pm, monoid_generator_scan *scan)
