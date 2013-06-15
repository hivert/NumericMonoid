from libc.stdint cimport uint8_t, uint_fast64_t

cdef extern from "monoid.hpp":
    enum: MAX_GENUS
    enum: SIZE
    ctypedef uint_fast64_t ind_t
    ctypedef uint8_t dec_numbers[SIZE]
    cdef cppclass monoid:
        dec_numbers decs
        ind_t conductor, min, genus

    void init_full_N(monoid &pm) nogil
    void print_monoid(monoid &) nogil
    inline void remove_generator(monoid &dst, monoid &src, ind_t) nogil

    enum generator_type "generator_iter::generator_type":
        ALL      "generator_iter::ALL"
        CHILDREN "generator_iter::CHILDREN"

    cdef cppclass generator_iter:
        generator_iter(const monoid &mon, generator_type tp) nogil
        bint move_next() nogil
        uint8_t count() nogil
        ind_t get_gen() nogil

from libcpp.list cimport list as stl_list

cdef extern from "treewalk.hpp":
    ctypedef unsigned long int results_type[MAX_GENUS]
    void walk_children_stack(monoid m, results_type &res) nogil
    void walk_children_stack(monoid m, ind_t bound, results_type &res) nogil

    cdef cppclass ResultsReducer:
        unsigned long int & operator[](int i) nogil
        results_type &get_array() nogil
        void reset() nogil

    cdef cppclass ListReducer "cilk::reducer_list_append<monoid>":
        stl_list[monoid] get_value() nogil
        stl_list[monoid] &get_reference() nogil
    ResultsReducer cilk_results
    ListReducer cilk_list_results
    void walk_children(const monoid &m) nogil
    void walk_children(const monoid &m, ind_t bound) nogil
    void list_children(const monoid &m, ind_t bound) nogil

